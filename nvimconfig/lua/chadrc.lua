-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

-- Theme is persisted in lua/theme_state.lua (gitignored), so theme switching
-- doesn't dirty the repo. autocmds.lua redirects NvChad's writer there.
local function load_theme()
	package.loaded.theme_state = nil
	local ok, t = pcall(require, "theme_state")
	if ok and type(t) == "string" then return t end
	return "ayu_dark"
end

M.base46 = {
	theme = load_theme(),

	hl_override = {
		Comment = { italic = true },
		["@comment"] = { italic = true },
		-- Visual, CursorLine, CursorLineNr are now set dynamically
		-- in options.lua based on vim.o.background (light/dark aware)
	},
}

-- M.nvdash = { load_on_startup = true }

M.ui = {
  tabufline = {
    lazyload = false
  },
  -- Disable colorify to fix LSP attachment error
  colorify = {
    enabled = false
  }
}

return M
