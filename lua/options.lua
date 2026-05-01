require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
--

local opt = vim.opt

-- Line number settings
opt.number = true
opt.relativenumber = true

-- Clipboard settings
opt.clipboard = "unnamed"

-- Auto-indent settings (CLion-like behavior)
opt.autoindent = true      -- Copy indent from current line when starting new line
opt.smartindent = true     -- Smart autoindenting when starting a new line
opt.cindent = true         -- C-style indenting (works for C, C++, Java, etc.)
opt.indentexpr = ""        -- Use cindent instead of expression-based indenting

-- Indent settings
opt.tabstop = 2           -- Number of spaces a tab counts for
opt.shiftwidth = 2        -- Number of spaces for each step of autoindent
opt.softtabstop = 2       -- Number of spaces a tab counts for while editing
opt.expandtab = true      -- Use spaces instead of tabs

-- Additional helpful settings
opt.shiftround = true     -- Round indent to multiple of shiftwidth
opt.smarttab = true       -- Smart tab behavior at beginning of line

-- Folding settings (configured by nvim-ufo plugin)
-- opt.foldmethod = "expr"
-- opt.foldexpr = "nvim_treesitter#foldexpr()"
-- opt.foldenable = true
-- opt.foldlevel = 99        -- Start with all folds open

-- Function to toggle whitespace characters visibility
local function toggle_whitespace()
  if vim.opt.list:get() then
    vim.opt.list = false
    print("Hidden characters: OFF")
  else
    vim.opt.list = true
    print("Hidden characters: ON")
  end
end

-- Function to hide all whitespace characters
local function hide_whitespace()
  vim.opt.list = false
  print("Hidden characters: OFF")
end

-- Function to show whitespace characters
local function show_whitespace()
  vim.opt.list = true
  print("Hidden characters: ON")
end

-- Make functions globally available
vim.g.toggle_whitespace = toggle_whitespace
vim.g.hide_whitespace = hide_whitespace
vim.g.show_whitespace = show_whitespace

-- Hide whitespace characters by default
opt.list = false
opt.listchars = {
  tab = "->",        -- Show tabs as ->
  trail = "•",       -- Show trailing spaces as •
  extends = "▶",     -- Show when line extends beyond screen
  precedes = "◀",    -- Show when line precedes beyond screen
  nbsp = "○",        -- Show non-breaking spaces
  eol = "↴",         -- Show end of line (optional)
}

-- Auto-reload files changed on disk
opt.autoread = true

-- Session management
opt.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,winpos"

-- Window resize step (3x larger than default)
opt.winwidth = 10
opt.winminwidth = 10
vim.g.resize_step = 6  -- Custom resize step (default is 2)

-- Obsidian conceallevel for markdown files
vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
  pattern = { "markdown", "*.md" },
  callback = function()
    vim.opt_local.conceallevel = 2
    -- Remap markdown todo toggle from <leader>x to <leader>tx to avoid conflict with buffer delete
    -- First unmap the conflicting key, then remap to new key
    pcall(vim.keymap.del, "n", "<leader>x", { buffer = true })
    -- If your markdown plugin uses <leader>x for todo toggle, remap it to <leader>tx
    vim.keymap.set("n", "<leader>tx", function()
      -- Try to call the todo toggle function from various markdown plugins
      local ok, _ = pcall(function()
        -- For bullets.vim or similar
        vim.cmd("normal! <Plug>(bullets-toggle-checkbox)")
      end)
      if not ok then
        -- Fallback: manually toggle [ ] to [x] and vice versa
        local line = vim.api.nvim_get_current_line()
        if line:match("%[ %]") then
          local new_line = line:gsub("%[ %]", "[x]", 1)
          vim.api.nvim_set_current_line(new_line)
        elseif line:match("%[x%]") or line:match("%[X%]") then
          local new_line = line:gsub("%[x%]", "[ ]", 1):gsub("%[X%]", "[ ]", 1)
          vim.api.nvim_set_current_line(new_line)
        end
      end
    end, { buffer = true, desc = "Toggle markdown todo checkbox" })
  end,
})

-- Blue cursor
vim.api.nvim_set_hl(0, "Cursor", { fg = "#000000", bg = "#56B4E9" })
opt.guicursor = "n-v-c-sm:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20-Cursor"

-- Background-aware color palettes
local function get_colors()
  local is_dark = vim.o.background == "dark"
  if is_dark then
    return {
      variable = "#e6e6e6",
      parameter = "#d4d4d4",
      field = "#9cdcfe",
      property = "#9cdcfe",
      func = "#dcdcaa",
      method = "#dcdcaa",
      keyword = "#569cd6",
      type = "#4ec9b0",
      string = "#ce9178",
      comment = "#6a9955",
      visual_bg = "#45475a",
      cursorline_bg = "#2a2b3c",
      cursorline_nr_fg = "#cdd6f4",
      dap_stopped_line_bg = "#2e2e2e",
    }
  else
    return {
      variable = "#24292e",
      parameter = "#383a42",
      field = "#005cc5",
      property = "#005cc5",
      func = "#6f42c1",
      method = "#6f42c1",
      keyword = "#d73a49",
      type = "#22863a",
      string = "#032f62",
      comment = "#6a737d",
      visual_bg = "#c8d6f0",
      cursorline_bg = "#f0f0f0",
      cursorline_nr_fg = "#24292e",
      dap_stopped_line_bg = "#e8f5e9",
    }
  end
end

-- Make get_colors globally accessible for other files (e.g., dap.lua)
vim.g._theme_get_colors = true
_G.get_theme_colors = get_colors

-- Apply theme-aware highlights on every ColorScheme change
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    local c = get_colors()
    -- Tree-sitter syntax highlights
    vim.api.nvim_set_hl(0, "@variable", { fg = c.variable })
    vim.api.nvim_set_hl(0, "@parameter", { fg = c.parameter })
    vim.api.nvim_set_hl(0, "@field", { fg = c.field })
    vim.api.nvim_set_hl(0, "@property", { fg = c.property })
    vim.api.nvim_set_hl(0, "@function", { fg = c.func })
    vim.api.nvim_set_hl(0, "@method", { fg = c.method })
    vim.api.nvim_set_hl(0, "@keyword", { fg = c.keyword })
    vim.api.nvim_set_hl(0, "@type", { fg = c.type })
    vim.api.nvim_set_hl(0, "@string", { fg = c.string })
    vim.api.nvim_set_hl(0, "@comment", { fg = c.comment })
    -- UI highlights
    vim.api.nvim_set_hl(0, "Visual", { bg = c.visual_bg, fg = "NONE" })
    vim.api.nvim_set_hl(0, "VisualNOS", { bg = c.visual_bg, fg = "NONE" })
    vim.api.nvim_set_hl(0, "CursorLine", { bg = c.cursorline_bg })
    vim.api.nvim_set_hl(0, "CursorLineNr", { fg = c.cursorline_nr_fg, bold = true })
    -- DAP highlights
    vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = c.dap_stopped_line_bg })
  end,
})
