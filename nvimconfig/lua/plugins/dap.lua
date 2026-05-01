return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio"
    },
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Debug: Start/Continue" },
      { "<F1>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
      { "<F2>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
      { "<F3>", function() require("dap").step_out() end, desc = "Debug: Step Out" },
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
      { "<leader>dB", function() 
        require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: '))
      end, desc = "Debug: Set Breakpoint" },
      { "<F7>", function() require("dapui").toggle() end, desc = "Debug: Toggle UI" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Debug: Toggle UI" },
      { "<leader>de", function() require("dapui").eval() end, desc = "Debug: Eval" },
      { "<leader>dr", function() require("dap").restart() end, desc = "Debug: Restart" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Debug: Terminate" },
      { "<leader>dc", function() require("dap").clear_breakpoints() end, desc = "Debug: Clear Breakpoints" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      
      -- Setup dap-ui
      dapui.setup({
        controls = {
          element = "repl",
          enabled = true,
          icons = {
            disconnect = "",
            pause = "",
            play = "",
            run_last = "",
            step_back = "",
            step_into = "",
            step_out = "",
            step_over = "",
            terminate = ""
          }
        },
        element_mappings = {},
        expand_lines = true,
        floating = {
          border = "single",
          mappings = {
            close = { "q", "<Esc>" }
          }
        },
        force_buffers = true,
        icons = {
          collapsed = "",
          current_frame = "",
          expanded = ""
        },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              { id = "breakpoints", size = 0.25 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 }
            },
            position = "left",
            size = 40
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 }
            },
            position = "bottom",
            size = 10
          }
        },
        mappings = {
          edit = "e",
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          repl = "r",
          toggle = "t"
        },
        render = {
          indent = 1,
          max_value_lines = 100
        }
      })

      -- Setup virtual text
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        only_first_definition = true,
        all_references = false,
        clear_on_continue = false,
        display_callback = function(variable, buf, stackframe, node, options)
          if options.virt_text_pos == 'inline' then
            return ' = ' .. variable.value
          else
            return variable.name .. ' = ' .. variable.value
          end
        end,
        virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',
        all_frames = false,
        virt_lines = false,
        virt_text_win_col = nil
      })

      -- C/C++ with lldb (macOS)
      dap.adapters.lldb = {
        type = "executable",
        command = "/opt/homebrew/Cellar/llvm/21.1.2/bin/lldb-dap",
        name = "lldb"
      }

      -- C/C++ with gdb (Linux/alternative)
      dap.adapters.gdb = {
        type = "executable",
        command = "gdb",
        args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
      }

      -- C/C++ configurations
      dap.configurations.cpp = {
        {
          name = "Launch (lldb)",
          type = "lldb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = function()
            local args_string = vim.fn.input('Arguments: ')
            return vim.split(args_string, " ")
          end,
        },
        {
          name = "Launch",
          type = "gdb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = "${workspaceFolder}",
          stopAtBeginningOfMainSubprogram = false,
          args = function()
            local args_string = vim.fn.input('Arguments: ')
            return vim.split(args_string, " ")
          end,
        },
        {
          name = "Select and attach to process",
          type = "gdb",
          request = "attach",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          pid = function()
            local name = vim.fn.input('Executable name (filter): ')
            return require("dap.utils").pick_process({ filter = name })
          end,
          cwd = '${workspaceFolder}'
        },
        {
          name = 'Attach to gdbserver :1234',
          type = 'gdb',
          request = 'attach',
          target = 'localhost:1234',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}'
        },
      }

      -- Reuse C++ config for C
      dap.configurations.c = dap.configurations.cpp

      -- Auto open/close dap-ui
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Customize breakpoint signs
      vim.fn.sign_define('DapBreakpoint', { text='●', texthl='DapBreakpoint', linehl='', numhl=''})
      vim.fn.sign_define('DapBreakpointCondition', { text='◆', texthl='DapBreakpointCondition', linehl='', numhl=''})
      vim.fn.sign_define('DapBreakpointRejected', { text='○', texthl='DapBreakpoint', linehl='', numhl=''})
      vim.fn.sign_define('DapStopped', { text='→', texthl='DapStopped', linehl='DapStoppedLine', numhl=''})
      vim.fn.sign_define('DapLogPoint', { text='◎', texthl='DapLogPoint', linehl='', numhl=''})

      -- Set breakpoint colors (red dot) - these are fine for both light/dark
      vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#e51400' })
      vim.api.nvim_set_hl(0, 'DapBreakpointCondition', { fg = '#ff9900' })
      vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#00ff00' })
      -- DapStoppedLine is set dynamically in options.lua (light/dark aware)

      -- Keymaps are now defined in the keys table above for lazy loading
    end,
  }
}

