return {
  {
    "stevearc/conform.nvim",
    event = 'BufWritePre', -- enable format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  {
    "VonHeikemen/searchbox.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim"
    },
    keys = {
      { "<leader>fs", ":SearchBoxIncSearch<CR>", desc = "Incremental search" },
      { "<leader>fr", ":SearchBoxReplace<CR>", desc = "Search and replace" },
      { "<leader>fS", ":SearchBoxMatchAll<CR>", desc = "Search all matches" },
    },
    config = function()
      require("searchbox").setup({
        popup = {
          relative = "win",
          position = {
            row = "5%",
            col = "95%",
          },
          size = 30,
          border = {
            style = "rounded",
            text = {
              top = " Search ",
              top_align = "center",
            },
          },
          win_options = {
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
          },
        },
      })
    end,
  },

  {
    "stevearc/aerial.nvim",
    keys = {
      { "<leader>a", "<cmd>AerialToggle<cr>", desc = "Toggle Aerial" },
      { "<leader>o", "<cmd>AerialNavToggle<cr>", desc = "Toggle Aerial Navigation" },
    },
    config = function()
      require("aerial").setup({
        backends = { "lsp", "treesitter", "markdown", "asciidoc", "man" },
        layout = {
          max_width = { 40, 0.25 },
          width = 0.25,
          min_width = 10,
          default_direction = "prefer_right",
        },
        show_guides = true,
        filter_kind = {
          "Class",
          "Constructor",
          "Enum",
          "Function",
          "Interface",
          "Module",
          "Method",
          "Struct",
        },
        guides = {
          mid_item = "├─",
          last_item = "└─",
          nested_top = "│ ",
          whitespace = "  ",
        },
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      -- Ensure C compiler is findable (GUI launches may lack PATH)
      if vim.fn.executable("cc") == 0 and vim.fn.executable("gcc") == 0 then
        local candidates = { "/usr/bin/cc", "/usr/bin/gcc" }
        for _, cc in ipairs(candidates) do
          if vim.uv.fs_stat(cc) then
            vim.env.CC = cc
            break
          end
        end
      end

      -- Auto-install parsers (only missing ones)
      local parsers = { "vim", "lua", "vimdoc", "html", "css", "c", "cpp", "python" }
      local installed = require("nvim-treesitter.info").installed_parsers()
      local to_install = vim.tbl_filter(function(p)
        return not vim.tbl_contains(installed, p)
      end, parsers)
      if #to_install > 0 then
        vim.cmd("TSInstall " .. table.concat(to_install, " "))
      end
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      opts.defaults = opts.defaults or {}
      opts.defaults.file_ignore_patterns = {
        ".git/",
        "node_modules/",
        "%.lock",
        "target/",
        "build/",
        "cmake%-build%-",
        "dist/",
      }
      -- Configure preview options
      opts.defaults.preview = {
        filesize_limit = 25, -- MB
        timeout = 250,
        treesitter = false,
      }
      -- Configure pickers
      opts.pickers = opts.pickers or {}
      opts.pickers.find_files = {
        find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" },
        -- Don't ignore image files in preview
        preview = {
          filesize_hook = function(filepath, bufnr, opts)
            local path = require("plenary.path"):new(filepath)
            if path:stat().size > 1024 * 1024 * 2 then -- 2MB
              return false
            end
            return true
          end,
        },
      }
      -- Configure telescope-sg extension
      opts.extensions = opts.extensions or {}
      opts.extensions.ast_grep = {
        command = {
          "sg",
          "--json=stream",
        },
        grep_open_files = false,
        lang = nil,
      }
      return opts
    end,
    config = function(_, opts)
      require("telescope").setup(opts)
      -- Load telescope-sg extension
      pcall(require("telescope").load_extension, "ast_grep")
    end,
  },

  {
    "Marskey/telescope-sg",
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = {
      { "<leader>fG", "<cmd>Telescope ast_grep<cr>", desc = "AST Grep" },
    },
  },

  {
    "L3MON4D3/LuaSnip",
    config = function()
      require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/lua/snippets"})
      require("luasnip").config.set_config({
        history = true,
        updateevents = "TextChanged,TextChangedI",
        enable_autosnippets = true,
      })
    end,
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },


 
  {
    "bullets-vim/bullets.vim",
    ft = { "markdown", "text", "gitcommit" },
    config = function()
      vim.g.bullets_enabled_file_types = {
        'markdown',
        'text',
        'gitcommit',
        'scratch'
      }
    end,
  },

  {
    "dhruvasagar/vim-table-mode",
    ft = "markdown",
    config = function()
      vim.g.table_mode_corner = '|'
    end,
  },


  {
    "karb94/neoscroll.nvim",
    lazy = false,
    config = function()
      require("neoscroll").setup()
    end,
  },

  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    keys = {
      { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find TODOs" },
      { "<leader>fT", "<cmd>TodoTrouble<cr>", desc = "TODOs in Trouble" },
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous TODO" },
    },
    opts = {
      signs = true,
      keywords = {
        FIX = { icon = " ", color = "#D55E00", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },  -- Vermillion (errors)
        TODO = { icon = " ", color = "#56B4E9" },  -- Sky Blue (info)
        HACK = { icon = " ", color = "#E69F00" },  -- Orange (warnings)
        WARN = { icon = " ", color = "#E69F00", alt = { "WARNING", "XXX" } },  -- Orange (warnings)
        PERF = { icon = " ", color = "#CC79A7", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },  -- Reddish Purple
        NOTE = { icon = " ", color = "#009E73", alt = { "INFO" } },  -- Bluish Green (hints)
        TEST = { icon = "⏲ ", color = "#F0E442", alt = { "TESTING", "PASSED", "FAILED" } },  -- Yellow
        ITEM1 = { icon = "1️⃣ ", color = "#0173B2" },  -- Deep Blue (colorblind safe)
        ITEM2 = { icon = "2️⃣ ", color = "#029E73" },  -- Teal Green (colorblind safe)
        ITEM3 = { icon = "3️⃣ ", color = "#ECE133" },  -- Bright Yellow (colorblind safe)
        ITEM4 = { icon = "4️⃣ ", color = "#CC78BC" },  -- Pink/Magenta (colorblind safe)
      },
      highlight = {
        before = "",
        keyword = "wide",
        after = "fg",
      },
    },
  },

  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    opts = {},
  },

  {
    "folke/which-key.nvim",
    lazy = false,  -- Load immediately to fix space key delay
    opts = {
      win = {
        height = { min = 4, max = 0.5 },  -- max 50% of screen height
      },
    },
  },

  {
    "kevinhwang91/nvim-ufo",
    dependencies = {
      "kevinhwang91/promise-async",
    },
    event = "VeryLazy",
    opts = {
      provider_selector = function(bufnr, filetype, buftype)
        return { "treesitter", "indent" }
      end,
    },
    config = function(_, opts)
      require("ufo").setup(opts)

      -- Set fold column
      vim.o.foldcolumn = "1"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      -- Key mappings
      vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
      vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds, { desc = "Open folds except kinds" })
      vim.keymap.set("n", "zm", require("ufo").closeFoldsWith, { desc = "Close folds with" })
      vim.keymap.set("n", "K", function()
        local winid = require("ufo").peekFoldedLinesUnderCursor()
        if not winid then
          vim.lsp.buf.hover()
        end
      end, { desc = "Peek fold or LSP hover" })
    end,
  },


  {
    "hat0uma/doxygen-previewer.nvim",
    dependencies = { "hat0uma/prelive.nvim" },
    ft = { "c", "cpp", "h", "hpp" },
    cmd = {
      "DoxygenOpen",
      "DoxygenUpdate",
      "DoxygenStop",
      "DoxygenLog",
      "DoxygenTempDoxyfileOpen"
    },
    opts = {},
  },

  {
    "kkoomen/vim-doge",
    build = ":call doge#install()",
    ft = { "c", "cpp", "python", "java", "javascript", "typescript", "lua" },
    keys = {
      { "gc", "<Plug>(doge-generate)", desc = "Generate documentation comment" },
    },
    config = function()
      vim.g.doge_doc_standard_c = 'doxygen_javadoc'
      vim.g.doge_doc_standard_cpp = 'doxygen_javadoc'
      vim.g.doge_mapping = ''  -- Disable default mapping
    end,
  },

  {
    "RRethy/vim-illuminate",
    event = "VeryLazy",
    config = function()
      require("illuminate").configure({
        providers = {
          'lsp',
          'treesitter',
          'regex',
        },
        delay = 100,
        filetypes_denylist = {
          'dirbuf',
          'dirvish',
          'fugitive',
          'NvimTree',
        },
        under_cursor = true,
        large_file_cutoff = 2000,
        large_file_overrides = nil,
        min_count_to_highlight = 1,
      })
    end,
  },

  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = { file_types = { "Avante" } },
        ft = { "Avante" },
      },
    },
    opts = {
      provider = "claude",
      providers = {
        claude = {
          model = "claude-sonnet-4-20250514",
        },
      },
    },
  },

  {
    "3rd/image.nvim",
    ft = { "markdown" },
    opts = {
      backend = "kitty",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = true,
          download_remote_images = true,
          only_render_image_at_cursor = false,
        },
      },
      max_width = 100,
      max_height = 30,
    },
  },

  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        options = {
          "-pdf",
          "-interaction=nonstopmode",
          "-synctex=1",
        },
      }
    end,
  },

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && bash install.sh",
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      view = {
        adaptive_size = true,
        side = "left",
        width = {
          min = 30,
          max = 60,
        },
      },
      renderer = {
        root_folder_label = false,
        highlight_git = true,
        indent_markers = {
          enable = true,
        },
      },
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        api.config.mappings.default_on_attach(bufnr)
        local opts = { buffer = bufnr, noremap = true, silent = true }
        vim.keymap.set("n", "<Left>", api.node.navigate.parent_close, opts)
        vim.keymap.set("n", "<Right>", api.node.open.edit, opts)
        vim.keymap.set("n", "c", function()
          local node = api.tree.get_node_under_cursor()
          if node then
            api.fs.copy.node()
            vim.fn.system({ "tmux", "set-buffer", node.absolute_path })
            vim.notify("Copied: " .. node.name .. " (also to tmux buffer)")
          end
        end, opts)
      end,
    },
  },

}
