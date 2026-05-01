-- ~/.config/nvim/lua/custom/configs/lua_ls.lua
return {
  cmd = {
    "/data/project/yuxilab/yuxihong/workspace/kk/lua-language-server/bin/lua-language-server"
  },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT"
      },
      diagnostics = {
        globals = { "vim" }
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false
      },
      telemetry = {
        enable = false
      }
    }
  }
}