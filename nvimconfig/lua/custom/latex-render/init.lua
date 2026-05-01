local M = {}

local cache_dir = vim.fn.stdpath("cache") .. "/latex-render"
local images = {} -- track rendered images by id
local ns = vim.api.nvim_create_namespace("latex-render")
local density = 300

local function ensure_cache_dir()
  vim.fn.mkdir(cache_dir, "p")
end

--- Convert a LaTeX math string to a PNG file
---@param latex string the raw LaTeX math
---@param id string unique identifier for caching
---@return string? png_path
local function latex_to_png(latex, id)
  ensure_cache_dir()

  local png_path = cache_dir .. "/" .. id .. ".png"

  local hash_path = cache_dir .. "/" .. id .. ".hash"
  local old_hash = ""
  local f = io.open(hash_path, "r")
  if f then
    old_hash = f:read("*a")
    f:close()
  end
  if old_hash == latex and vim.fn.filereadable(png_path) == 1 then
    return png_path
  end

  local tex_content = table.concat({
    "\\documentclass[preview,border=2pt]{standalone}",
    "\\usepackage{amsmath,amssymb,amsfonts}",
    "\\begin{document}",
    "\\[\n" .. latex .. "\n\\]",
    "\\end{document}",
  }, "\n")

  local tex_path = cache_dir .. "/" .. id .. ".tex"
  local wf = io.open(tex_path, "w")
  if not wf then return nil end
  wf:write(tex_content)
  wf:close()

  local compile_cmd = string.format(
    "cd %s && pdflatex -interaction=nonstopmode -halt-on-error %s > /dev/null 2>&1 && magick -density %d %s -quality 100 %s > /dev/null 2>&1",
    vim.fn.shellescape(cache_dir),
    vim.fn.shellescape(tex_path),
    density,
    vim.fn.shellescape(cache_dir .. "/" .. id .. ".pdf"),
    vim.fn.shellescape(png_path)
  )

  local result = os.execute(compile_cmd)
  if result ~= 0 then
    return nil
  end

  local hf = io.open(hash_path, "w")
  if hf then
    hf:write(latex)
    hf:close()
  end

  return png_path
end

--- Find display math $$...$$ blocks in the current buffer
---@param bufnr number
---@return table[] list of {start_row, end_row, latex}
local function find_display_blocks(bufnr)
  local blocks = {}
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local in_display = false
  local display_start = nil
  local display_content = {}

  for i, line in ipairs(lines) do
    local row = i - 1

    if not in_display then
      if line:match("^%s*%$%$%s*$") then
        in_display = true
        display_start = row
        display_content = {}
      elseif line:match("^%s*%$%$(.+)%$%$%s*$") then
        local single = line:match("^%s*%$%$(.+)%$%$%s*$")
        table.insert(blocks, {
          start_row = row,
          end_row = row,
          latex = vim.trim(single),
        })
      end
    else
      if line:match("^%s*%$%$%s*$") then
        in_display = false
        table.insert(blocks, {
          start_row = display_start,
          end_row = row,
          latex = vim.trim(table.concat(display_content, "\n")),
        })
      else
        table.insert(display_content, line)
      end
    end
  end

  return blocks
end

--- Clear all rendered images for a buffer
---@param bufnr number
function M.clear(bufnr)
  local buf_key = tostring(bufnr) .. ":"
  for id, img in pairs(images) do
    if id:sub(1, #buf_key) == buf_key then
      img:clear()
      images[id] = nil
    end
  end
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
end

--- Render display math blocks in a buffer
---@param bufnr? number
function M.render(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if vim.bo[bufnr].filetype ~= "markdown" then return end

  M.clear(bufnr)

  local blocks = find_display_blocks(bufnr)
  local image_api = require("image")
  local line_count = vim.api.nvim_buf_line_count(bufnr)

  for i, block in ipairs(blocks) do
    local id = tostring(bufnr) .. ":" .. i .. ":" .. block.start_row
    local hash = vim.fn.sha256(block.latex):sub(1, 16)
    local file_id = "latex_" .. hash

    local png_path = latex_to_png(block.latex, file_id)
    if png_path then
      local y = math.min(block.end_row + 1, line_count - 1)

      local img = image_api.from_file(png_path, {
        id = id,
        buffer = bufnr,
        window = vim.api.nvim_get_current_win(),
        with_virtual_padding = true,
        x = 0,
        y = y,
      })
      if img then
        img:render()
        images[id] = img
      end
    end
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("LatexRender", { clear = true })

  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    pattern = "*.md",
    callback = function(ev)
      M.render(ev.buf)
    end,
  })

  vim.api.nvim_create_user_command("LatexRender", function()
    M.render()
  end, { desc = "Render LaTeX math blocks as images" })

  vim.api.nvim_create_user_command("LatexClear", function()
    M.clear(vim.api.nvim_get_current_buf())
  end, { desc = "Clear rendered LaTeX images" })
end

return M
