require("nvchad.configs.lspconfig").defaults()

local nvlsp = require "nvchad.configs.lspconfig"
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

if not vim.env.PATH:find(mason_bin, 1, true) then
  vim.env.PATH = mason_bin .. ":" .. vim.env.PATH
end

local function with_defaults(config)
  return vim.tbl_deep_extend("force", {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }, config or {})
end

local function setup_lsp(name, config)
  vim.lsp.config(name, config)
  vim.lsp.enable(name)
end

-- Python: *.py
local pyright_config = require("custom.configs.pyright")
setup_lsp("pyright", with_defaults(vim.tbl_deep_extend("force", pyright_config, {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
})))

-- C/C++/CUDA: *.c, *.cc, *.cpp, *.cxx, headers, *.cu, *.cuh
local clangd_config = require("custom.configs.clangd")
setup_lsp("clangd", clangd_config)

-- Lua: *.lua
local lua_ls_config = require("custom.configs.lua_ls")
setup_lsp("lua_ls", with_defaults(vim.tbl_deep_extend("force", lua_ls_config, {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
})))

-- CMake: CMakeLists.txt, *.cmake
local neocmake_capabilities = vim.lsp.protocol.make_client_capabilities()
neocmake_capabilities.textDocument.completion.completionItem.snippetSupport = true

setup_lsp("neocmake", with_defaults({
  cmd = { "neocmakelsp", "stdio" },
  capabilities = neocmake_capabilities,
  filetypes = { "cmake" },
  root_markers = { ".neocmake.toml", "CMakeLists.txt", ".git", "build", "cmake" },
}))

-- YAML: *.yaml, *.yml
setup_lsp("yamlls", with_defaults({
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
  root_markers = { ".git" },
}))

-- Shell: *.sh, *.bash, shell rc files
setup_lsp("bashls", with_defaults({
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh", "bash", "zsh" },
  root_markers = { ".git" },
}))

-- HTML and CSS
setup_lsp("html", with_defaults({
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html" },
  root_markers = { "package.json", ".git" },
}))
setup_lsp("cssls", with_defaults({
  cmd = { "vscode-css-language-server", "--stdio" },
  filetypes = { "css", "scss", "less" },
  root_markers = { "package.json", ".git" },
}))

local managed_servers = {
  bashls = true,
  clangd = true,
  neocmake = true,
  pyright = true,
  yamlls = true,
}

local allowed_by_filetype = {
  bash = { bashls = true },
  c = { clangd = true },
  cmake = { neocmake = true },
  cpp = { clangd = true },
  cuda = { clangd = true },
  python = { pyright = true },
  sh = { bashls = true },
  yaml = { yamlls = true },
  ["yaml.docker-compose"] = { yamlls = true },
  ["yaml.gitlab"] = { yamlls = true },
  zsh = { bashls = true },
}

vim.api.nvim_create_autocmd({ "FileType", "LspAttach" }, {
  callback = function(ev)
    vim.schedule(function()
      local allowed = allowed_by_filetype[vim.bo[ev.buf].filetype]
      if not allowed then
        return
      end

      for _, client in ipairs(vim.lsp.get_clients({ bufnr = ev.buf })) do
        if managed_servers[client.name] and not allowed[client.name] then
          vim.lsp.stop_client(client.id, true)
        end
      end
    end)
  end,
})


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
