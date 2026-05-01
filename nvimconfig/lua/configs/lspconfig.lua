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

-- C/C++ Language Server Configuration
-- Toggle between clangd and ccls by setting this variable
-- Priority: vim.g.cpp_lsp > environment variable VIM_CPP_LSP > default "clangd"
local cpp_lsp = vim.g.cpp_lsp or vim.env.VIM_CPP_LSP or "clangd"

if cpp_lsp == "ccls" then
  -- Setup ccls with custom configuration
  local ccls_config = require("custom.configs.ccls")
  vim.lsp.config("ccls", ccls_config)
  vim.lsp.enable("ccls")
else
  -- Setup clangd with custom configuration (default)
  local clangd_config = require("custom.configs.clangd")
  vim.lsp.config("clangd", clangd_config)
  vim.lsp.enable("clangd")
end

-- Setup lua-language-server with custom configuration
local lua_ls_config = require("custom.configs.lua_ls")
vim.lsp.config("lua_ls", lua_ls_config)
vim.lsp.enable("lua_ls")


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
