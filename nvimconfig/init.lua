vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

if vim.env.SSH_TTY or vim.env.ZELLIJ then
  local osc52 = require "vim.ui.clipboard.osc52"
  local cache = {
    ["+"] = { lines = {}, regtype = "v" },
    ["*"] = { lines = {}, regtype = "v" },
  }

  local function copy(reg)
    local osc52_copy = osc52.copy(reg)

    return function(lines, regtype)
      cache[reg] = {
        lines = vim.list_slice(lines),
        regtype = regtype or "v",
      }
      osc52_copy(lines)
    end
  end

  local function paste(reg)
    return function()
      local item = cache[reg]
      return { vim.list_slice(item.lines), item.regtype }
    end
  end

  vim.g.clipboard = {
    name = "OSC 52 copy only",
    copy = {
      ["+"] = copy("+"),
      ["*"] = copy("*"),
    },
    paste = {
      ["+"] = paste("+"),
      ["*"] = paste("*"),
    },
  }
end

-- vim.opt.colorcolumn = "120"
-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "autocmds"
require "mappings"
