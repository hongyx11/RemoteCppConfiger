-- neocmakelsp config
-- Server binary: neocmakelsp (installed via `cargo install neocmakelsp`)
local nvlsp = require "nvchad.configs.lspconfig"

return {
  cmd = { "neocmakelsp", "--stdio" },
  filetypes = { "cmake" },
  root_markers = { "CMakeLists.txt", "cmake", ".git" },
  on_attach = nvlsp.on_attach,
  on_init = nvlsp.on_init,
  capabilities = nvlsp.capabilities,
}
