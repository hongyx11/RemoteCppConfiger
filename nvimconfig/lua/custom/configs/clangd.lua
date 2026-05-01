return {
  cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu", "--completion-style=detailed", "--function-arg-placeholders=true" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_markers = { "compile_commands.json", "compile_flags.txt", ".clangd", ".git" },
  capabilities = vim.lsp.protocol.make_client_capabilities(),
  on_attach = function(client, bufnr)
    -- Custom on_attach functionality


    -- Enable document highlight if supported
    if client.server_capabilities.documentHighlightProvider then
      local group = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = bufnr,
        group = group,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd("CursorMoved", {
        buffer = bufnr,
        group = group,
        callback = vim.lsp.buf.clear_references,
      })
    end

    -- Add custom keymaps for C++ specific actions
    local opts = { buffer = bufnr, silent = true }
    vim.keymap.set("n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", opts)
    vim.keymap.set("n", "<leader>ct", "<cmd>ClangdTypeHierarchy<cr>", opts)
    vim.keymap.set("n", "<leader>cs", "<cmd>ClangdSymbolInfo<cr>", opts)
  end,
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },
  settings = {
    clangd = {
      fallbackFlags = { "-std=c++14" },
    },
  },
}
