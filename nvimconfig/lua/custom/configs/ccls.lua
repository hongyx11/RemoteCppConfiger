return {
  cmd = { "/data/project/yuxilab/yuxihong/workspace/kk/ccls/ccls/build/ccls" },
  filetypes = { "c", "cpp", "objc", "objcpp" },
  root_dir = { "compile_commands.json", "compile_flags.txt", ".ccls-root", ".ccls", ".git" },
  capabilities = vim.lsp.protocol.make_client_capabilities(),
  init_options = {
    cache = {
      directory = vim.fn.stdpath("cache") .. "/ccls",
    },
    highlight = {
      lsRanges = true,
    },
    -- Enable semantic highlighting
    completion = {
      placeholder = true,
    },
    -- Index settings
    index = {
      threads = 0, -- Use all available threads
      comments = 2, -- Include comments in index
      onChange = true, -- Re-index on file change
    },
    -- Clang settings
    clang = {
      extraArgs = { "-std=c++17" },
      resourceDir = "",
    },
  },
  settings = {
    ccls = {
      semantic = {
        enabled = true,
      },
    },
  },
}