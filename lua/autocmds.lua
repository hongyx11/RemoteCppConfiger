require "nvchad.autocmds"

-- Redirect NvChad's theme writer from lua/chadrc.lua to lua/theme_state.lua
-- so theme switches don't show up as repo modifications.
do
	local ok, utils = pcall(require, "nvchad.utils")
	if ok and utils.replace_word then
		local original = utils.replace_word
		local theme_state = vim.fn.stdpath("config") .. "/lua/theme_state.lua"
		local chadrc = vim.fn.stdpath("config") .. "/lua/chadrc.lua"
		utils.replace_word = function(old, new, filepath)
			if (filepath == nil or filepath == chadrc) and type(new) == "string" then
				local theme = new:match('^"(.+)"$')
				if theme then
					local f = io.open(theme_state, "w")
					if f then
						f:write('return "' .. theme .. '"\n')
						f:close()
					end
					return
				end
			end
			return original(old, new, filepath)
		end
	end
end

-- Auto-open NvimTree on startup (DISABLED)
-- vim.api.nvim_create_autocmd("VimEnter", {
--   callback = function()
--     -- Only open if no file arguments were passed
--     if vim.fn.argc() == 0 then
--       vim.schedule(function()
--         require("nvim-tree.api").tree.open()
--       end)
--     end
--   end,
-- })

-- Open markdown link under cursor with 'fo'
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(ev)
    vim.keymap.set("n", "fo", function()
      require("markview.links").open()
    end, { buffer = ev.buf, desc = "Open link under cursor" })
  end,
})

-- Sync yank to tmux buffer
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    if vim.v.event.operator == "y" then
      local text = table.concat(vim.v.event.regcontents, "\n")
      vim.fn.system({ "tmux", "set-buffer", text })
    end
  end,
})

-- Auto-reload files changed on disk
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  command = "checktime",
})

-- LaTeX render in markdown
require("custom.latex-render").setup()

-- CUDA filetype detection
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.cu", "*.cuh" },
  callback = function()
    vim.bo.filetype = "cuda"
  end,
})
