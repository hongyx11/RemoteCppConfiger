-- cmake-language-server config
-- Server binary: cmake-language-server (installed via `uv tool install`)
local nvlsp = require "nvchad.configs.lspconfig"

return {
  cmd = { "cmake-language-server" },
  filetypes = { "cmake" },
  root_markers = { "CMakeLists.txt", "cmake", ".git" },
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
  init_options = {
    buildDirectory = "build",
  },
}
