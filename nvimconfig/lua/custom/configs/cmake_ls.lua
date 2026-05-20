-- neocmakelsp config
-- Server binary: neocmakelsp (installed via Mason)
local nvlsp = require "nvchad.configs.lspconfig"

return {
  cmd = { "neocmakelsp", "stdio" },
  filetypes = { "cmake" },
  root_markers = { ".neocmake.toml", ".git", "build", "cmake" },
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
}
