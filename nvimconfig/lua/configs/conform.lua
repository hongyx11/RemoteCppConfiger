local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "black", "autopep8", stop_after_first = true },
    c = { "clang-format" },
    cpp = { "clang-format" },
    cuda = { "clang-format" },
    cmake = { "cmake_format" },
    tex = { "tex-fmt" },
    -- css = { "prettier" },
    -- html = { "prettier" },
  },

  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
