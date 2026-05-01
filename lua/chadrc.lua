-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "github_light",

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
