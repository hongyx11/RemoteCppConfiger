require("nvchad.configs.lspconfig").defaults()

-- HTML and CSS servers
local servers = { "html", "cssls" }
for _, lsp in ipairs(servers) do
  vim.lsp.config[lsp] = {
    on_attach = function(client, bufnr)
      -- Add any common on_attach configuration here
    end,
    capabilities = vim.lsp.protocol.make_client_capabilities(),
  }
end

-- Setup pyright with custom configuration
local pyright_config = require("custom.configs.pyright")
vim.lsp.config("pyright", pyright_config)
vim.lsp.enable("pyright")

-- C/C++ Language Server Configuration (clangd)
local clangd_config = require("custom.configs.clangd")
vim.lsp.config("clangd", clangd_config)
vim.lsp.enable("clangd")

-- Setup lua-language-server with custom configuration
local lua_ls_config = require("custom.configs.lua_ls")
vim.lsp.config("lua_ls", lua_ls_config)
vim.lsp.enable("lua_ls")

-- Setup CMake Language Server
local neocmake_capabilities = vim.lsp.protocol.make_client_capabilities()
neocmake_capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.config("neocmake", {
  cmd = { "neocmakelsp", "stdio" },
  capabilities = neocmake_capabilities,
  filetypes = { "cmake" },
  root_markers = { ".neocmake.toml", ".git", "build", "cmake" },
})
vim.lsp.enable("neocmake")


-- Diagnostic configuration
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})

-- read :h vim.lsp.config for changing options of lsp servers 
