require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

local function smart_bdelete()
  local current_buf = vim.api.nvim_get_current_buf()
  local buffers = vim.api.nvim_list_bufs()
  local valid_buffers = {}
  
  -- Collect all valid buffers (listed, loaded, and not NvimTree)
  for _, buf in ipairs(buffers) do
    if buf ~= current_buf 
       and vim.api.nvim_buf_is_valid(buf) 
       and vim.fn.buflisted(buf) == 1 then
      local name = vim.api.nvim_buf_get_name(buf)
      if not name:match("NvimTree") then
        table.insert(valid_buffers, buf)
      end
    end
  end
  
  -- Try to find the best buffer to switch to
  local target_buf = nil
  
  -- First, try the alternate buffer
  local alt_buf = vim.fn.bufnr("#")
  if alt_buf > 0 and vim.tbl_contains(valid_buffers, alt_buf) then
    target_buf = alt_buf
  elseif #valid_buffers > 0 then
    -- If no valid alternate, use the most recently used valid buffer
    -- Sort buffers by last used time (most recent first)
    table.sort(valid_buffers, function(a, b)
      local a_lastused = vim.fn.getbufinfo(a)[1].lastused or 0
      local b_lastused = vim.fn.getbufinfo(b)[1].lastused or 0
      return a_lastused > b_lastused
    end)
    target_buf = valid_buffers[1]
  end
  
  -- Switch to target buffer or create new one
  if target_buf then
    vim.api.nvim_set_current_buf(target_buf)
  else
    vim.cmd("enew")
  end
  
  -- Now delete the original buffer
  -- Use bang to force delete even if modified
  vim.cmd("bdelete! " .. current_buf)
end

-- Make :bd use smart_bdelete so tabufline doesn't break
vim.api.nvim_create_user_command("Bd", smart_bdelete, {})
vim.cmd("cabbrev bd Bd")

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- LSP keybindings for C/C++ development
map("n", "gd", vim.lsp.buf.definition, { desc = "LSP go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "LSP go to declaration" })
map("n", "gr", vim.lsp.buf.references, { desc = "LSP show references" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "LSP go to implementation" })
map("n", "K", vim.lsp.buf.hover, { desc = "LSP hover documentation" })
map("n", "<C-k>", vim.lsp.buf.signature_help, { desc = "LSP signature help" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP rename symbol" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP code actions" })
map("n", "<leader>bf", function()
  require("conform").format({ lsp_fallback = true })
end, { desc = "Format buffer" })
map("v", "<leader>bf", function()
  require("conform").format({ lsp_fallback = true })
end, { desc = "Format selection" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic list" })

-- LSP Diagnostics
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show error under cursor" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "<leader>qa", function() vim.diagnostic.setqflist() end, { desc = "All project diagnostics" })

map("n", "<leader>x", smart_bdelete, { desc = "Smart buffer delete" })

-- Buffer Navigation
map("n", "[b", "<cmd>bprev<CR>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader><leader>", "<C-^>", { desc = "Switch to alternate buffer" })

-- NvimTree
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })
map("n", "<leader>v", "<cmd>NvimTreeFocus<CR>", { desc = "Focus NvimTree" })
map("n", "<leader>bD", "<cmd>%bd|NvimTreeOpen<CR>", { desc = "Close all buffers, show tree only" })

-- Toggle NvimTree max width
local nvimtree_width_state = { maximized = false, original_width = 30 }
local function toggle_nvimtree_width()
  local nvim_tree = require("nvim-tree.api")
  local view = require("nvim-tree.view")

  if not view.is_visible() then
    vim.notify("NvimTree is not open", vim.log.levels.WARN)
    return
  end

  local tree_winid = view.get_winnr()
  if not tree_winid then return end

  if nvimtree_width_state.maximized then
    -- Restore to original width
    vim.api.nvim_win_set_width(tree_winid, nvimtree_width_state.original_width)
    nvimtree_width_state.maximized = false
  else
    -- Save current width and maximize
    nvimtree_width_state.original_width = vim.api.nvim_win_get_width(tree_winid)
    local max_width = vim.o.columns - 10  -- Leave some space for main window
    vim.api.nvim_win_set_width(tree_winid, max_width)
    nvimtree_width_state.maximized = true
  end
end

map("n", "<leader>em", toggle_nvimtree_width, { desc = "Toggle NvimTree max width" })

-- Override default window resize to use 3x larger steps
map("n", "<C-w>>", "6<C-w>>", { desc = "Increase window width" })
map("n", "<C-w><", "6<C-w><", { desc = "Decrease window width" })
map("n", "<C-w>+", "6<C-w>+", { desc = "Increase window height" })
map("n", "<C-w>-", "6<C-w>-", { desc = "Decrease window height" })



-- Clangd specific mappings
map("n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<CR>", { desc = "Switch between source/header" })
map("n", "<leader>ct", "<cmd>ClangdTypeHierarchy<CR>", { desc = "Show type hierarchy" })
map("n", "<leader>cs", "<cmd>ClangdSymbolInfo<CR>", { desc = "Show symbol info" })

-- 📁 Files
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Recent files" })
map("n", "<leader>fw", "<cmd>Telescope live_grep<CR>", { desc = "Grep word in project" })
map("v", "<leader>fw", function()
  local text = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), {type = vim.fn.mode()})[1]
  require("telescope.builtin").live_grep({ default_text = text })
end, { desc = "Grep selection" })
map("n", "<leader>Fb", "<cmd>Telescope buffers<CR>", { desc = "Find open buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Search help" })

-- 🏗️ Code Structure
map("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "Document symbols (all)" })
map("n", "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<CR>", { desc = "Workspace symbols (LSP)" })
map("n", "<leader>fo", "<cmd>Telescope lsp_document_symbols symbols=class,struct,enum,function,method,interface<CR>", { desc = "Document symbols (outline)" })
map("n", "<leader>ft", "<cmd>Telescope treesitter<CR>", { desc = "Treesitter symbols" })
map("n", "<leader>fg", "<cmd>Telescope grep_string<CR>", { desc = "Grep word under cursor" })

-- ⚙️ Others
map("n", "<leader>km", "<cmd>Telescope keymaps<CR>", { desc = "List keymaps" })
map("n", "<leader>cm", "<cmd>Telescope commands<CR>", { desc = "List commands" })
map("n", "<leader>bi", "<cmd>Telescope builtin<CR>", { desc = "Telescope pickers" })

-- 📝 Snippets
map({"i", "s"}, "<C-l>", function() 
  if require("luasnip").expand_or_jumpable() then
    require("luasnip").expand_or_jump()
  end
end, { desc = "Expand snippet or jump forward" })

map({"i", "s"}, "<C-h>", function()
  if require("luasnip").jumpable(-1) then
    require("luasnip").jump(-1)
  end
end, { desc = "Jump backward in snippet" })


map("n", "<leader>sr", "<cmd>lua require('luasnip.loaders').edit_snippet_files()<CR>", { desc = "Edit snippets" })

-- Move lines up/down
map("n", "<leader>j", ":m .+1<CR>==", { desc = "Move line down" })
map("n", "<leader>k", ":m .-2<CR>==", { desc = "Move line up" })
map("i", "<C-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down" })
map("i", "<C-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up" })
map("v", "<leader>j", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<leader>k", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })



-- Table mode for markdown
map("n", "<leader>tm", "<cmd>TableModeToggle<CR>", { desc = "Toggle table mode" })

-- Image refresh
map("n", "<leader>ir", "<cmd>ImageClear<CR><cmd>ImageRender<CR>", { desc = "Refresh images" })

-- LaTeX render in markdown
map("n", "<leader>lr", "<cmd>LatexRender<CR>", { desc = "Render LaTeX math" })
map("n", "<leader>lc", "<cmd>LatexClear<CR>", { desc = "Clear LaTeX renders" })


-- Undo Tree and Navigation
local function simple_undo_browser()
  vim.cmd("undolist")
  vim.ui.input({ prompt = "Enter undo number (or press Enter to cancel): " }, function(input)
    if input and input ~= "" then
      local num = tonumber(input)
      if num then
        vim.cmd("undo " .. num)
        vim.notify("Jumped to undo state: " .. num, vim.log.levels.INFO)
      end
    end
  end)
end

map("n", "<leader>u", function()
  if vim.fn.exists(":UndotreeToggle") > 0 then
    vim.cmd("UndotreeToggle")
  else
    simple_undo_browser()
  end
end, { desc = "Toggle undo tree / Simple undo browser" })

-- Built-in undo navigation (works immediately)
map("n", "g-", "g-", { desc = "Go to older text state" })  
map("n", "g+", "g+", { desc = "Go to newer text state" })
map("n", "<leader>ul", "<cmd>undolist<CR>", { desc = "Show undo list" })

-- Session Management
local function save_session()
  local session_file = vim.fn.getcwd() .. "/.nvim-session"
  -- Debug: show what buffers are open
  local buffers = vim.api.nvim_list_bufs()
  local valid_buffers = {}
  for _, buf in ipairs(buffers) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.fn.buflisted(buf) == 1 then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= "" then
        table.insert(valid_buffers, name)
      end
    end
  end
  
  if #valid_buffers == 0 then
    vim.notify("No valid buffers to save in session", vim.log.levels.WARN)
    return
  end
  
  vim.cmd("mksession! " .. session_file)
  vim.notify(string.format("Session saved: %d buffers to %s", #valid_buffers, session_file), vim.log.levels.INFO)
end

local function load_session()
  local session_file = vim.fn.getcwd() .. "/.nvim-session"
  if vim.fn.filereadable(session_file) == 1 then
    -- Save all buffers first, then close them
    vim.cmd("wall") -- Save all buffers
    vim.cmd("bufdo bdelete!") -- Force close all buffers (! ignores unsaved changes after saving)
    vim.cmd("source " .. session_file)
    vim.notify("Session loaded from: " .. session_file, vim.log.levels.INFO)
  else
    vim.notify("No session file found in current directory", vim.log.levels.WARN)
  end
end

local function auto_save_session()
  local session_file = vim.fn.getcwd() .. "/.nvim-session"
  vim.cmd("mksession! " .. session_file)
end

-- Session keymaps
map("n", "<leader>ss", save_session, { desc = "Save session" })
map("n", "<leader>sl", load_session, { desc = "Load session" })
map("n", "<leader>sd", function()
  local session_file = vim.fn.getcwd() .. "/.nvim-session"
  if vim.fn.delete(session_file) == 0 then
    vim.notify("Session file deleted", vim.log.levels.INFO)
  else
    vim.notify("No session file to delete", vim.log.levels.WARN)
  end
end, { desc = "Delete session" })


-- Replace within current function
map("n", "<leader>rf", function()
  local start_pos = vim.fn.searchpairpos('{', '', '}', 'bnW')
  if start_pos[1] == 0 then
    vim.notify("Not inside a function block", vim.log.levels.WARN)
    return
  end
  vim.api.nvim_win_set_cursor(0, { start_pos[1], start_pos[2] - 1 })
  local end_line = vim.fn.searchpair('{', '', '}', 'n')
  if end_line == 0 then return end
  vim.ui.input({ prompt = "Replace (old/new): " }, function(input)
    if not input or not input:match("/") then return end
    local old, new = input:match("^(.+)/(.+)$")
    if old and new then
      vim.cmd(string.format("%d,%ds/%s/%s/gc", start_pos[1], end_line, old, new))
    end
  end)
end, { desc = "Replace within current function" })

-- Navigation
map("n", "[f", "[[", { desc = "Go to function start" })
map("n", "]f", "]]", { desc = "Go to next function start" })

-- CMake Build Functions
local last_build_target = nil -- Remember last target (start with none)

local function cmake_build_target()
  local prompt = last_build_target and 
    string.format("Build target (Enter for '%s'): ", last_build_target) or
    "Build target (or press Enter for all): "
  local default_val = last_build_target or ""
  
  vim.ui.input({ prompt = prompt, default = default_val }, function(target)
    if target == nil then return end
    target = target == "" and (last_build_target or "all") or target
    last_build_target = target -- Remember this target
    local build_dir = "cmake-build-vscpp/release"
    local cmd = string.format("cmake --build %s --target %s", build_dir, target)
    vim.cmd("cexpr system('" .. cmd .. "')")
    vim.cmd("copen")
  end)
end

local function cmake_rebuild_last()
  if not last_build_target then
    vim.notify("No previous target. Use <space>cb first to set a target.", vim.log.levels.ERROR)
    return
  end
  
  local build_dir = "cmake-build-vscpp/release"
  local cmd = string.format("cmake --build %s --target %s", build_dir, last_build_target)
  print("Building target: " .. last_build_target)
  vim.cmd("cexpr system('" .. cmd .. "')")
  vim.cmd("copen")
end

local function cmake_configure()
  local build_dir = "cmake-build-vscpp/release"
  local cmd = string.format("cmake -S . -B %s -DCMAKE_BUILD_TYPE=Release", build_dir)
  vim.cmd("cexpr system('" .. cmd .. "')")
  vim.cmd("copen")
end

-- Macro indentation
vim.api.nvim_create_user_command("IndentMacros", function()
  require("custom.indent_macros").indent_preprocessor_directives()
end, { desc = "Indent preprocessor directives" })

map("n", "<leader>im", "<cmd>IndentMacros<CR>", { desc = "Indent preprocessor macros" })

-- CMake and Error Navigation
map("n", "<leader>cb", cmake_build_target, { desc = "CMake build target" })
map("n", "<leader>cr", cmake_rebuild_last, { desc = "CMake rebuild last target" })
map("n", "<leader>cA", "<cmd>cexpr system('cmake --build cmake-build-vscpp/release')<CR><cmd>copen<CR>", { desc = "CMake build all" })
map("n", "<leader>cm", cmake_configure, { desc = "CMake configure" })
map("n", "<leader>co", "<cmd>copen<CR>", { desc = "Open quickfix list" })
map("n", "<leader>cq", "<cmd>cclose<CR>", { desc = "Close quickfix list" })
map("n", "]q", "<cmd>cnext<CR>", { desc = "Next error" })
map("n", "[q", "<cmd>cprev<CR>", { desc = "Previous error" })
map("n", "<leader>cf", "<cmd>cfirst<CR>", { desc = "First error" })
map("n", "<leader>cl", "<cmd>clast<CR>", { desc = "Last error" })

-- Tmux buffer yank (for headless/SSH sessions without system clipboard)
map("n", "<leader>ty", ":.w !tmux load-buffer -<CR>", { desc = "Yank line to tmux buffer" })
map("v", "<leader>ty", ":'<,'>w !tmux load-buffer -<CR>", { desc = "Yank selection to tmux buffer" })
map("n", "<leader>td", function()
  local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
  local diags = vim.diagnostic.get(0, { lnum = lnum })
  if #diags == 0 then
    vim.notify("No diagnostics on this line", vim.log.levels.WARN)
    return
  end
  local msgs = {}
  for _, d in ipairs(diags) do table.insert(msgs, d.message) end
  vim.fn.system("tmux load-buffer -", table.concat(msgs, "\n"))
  vim.notify("Diagnostic copied to tmux buffer", vim.log.levels.INFO)
end, { desc = "Copy line diagnostic to tmux buffer" })
map("n", "<leader>tD", function()
  local diags = vim.diagnostic.get(0)
  if #diags == 0 then
    vim.notify("No diagnostics in buffer", vim.log.levels.WARN)
    return
  end
  local msgs = {}
  for _, d in ipairs(diags) do table.insert(msgs, (d.lnum + 1) .. ": " .. d.message) end
  vim.fn.system("tmux load-buffer -", table.concat(msgs, "\n"))
  vim.notify(#diags .. " diagnostics copied to tmux buffer", vim.log.levels.INFO)
end, { desc = "Copy all diagnostics to tmux buffer" })

