-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    -- 'leoluz/nvim-dap-go',
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'
    dap.set_log_level 'TRACE'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_setup = true,
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        -- 'delve',
      },
    }

    local function nmap(key, func, opts_table)
      vim.keymap.set('n', key, func, opts_table)
    end

    -- Basic debugging keymaps, feel free to change to your liking!
    nmap('<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
    nmap('<F1>', dap.step_into, { desc = 'Debug: Step Into' })
    nmap('<F2>', dap.step_over, { desc = 'Debug: Step Over' })
    nmap('<F3>', dap.step_out, { desc = 'Debug: Step Out' })
    nmap('<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    nmap('<leader>B', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Debug: Set Breakpoint' })

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    for _, adapterType in ipairs { 'node', 'chrome', 'msedge' } do
      local pwaType = 'pwa-' .. adapterType

      dap.adapters[pwaType] = {
        type = 'server',
        host = 'localhost',
        port = '${port}',
        executable = {
          command = 'node',
          args = {
            vim.fn.stdpath 'data'
              .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js',
            '${port}',
          },
        },
      }

      -- this allow us to handle launch.json configurations
      -- which specify type as "node" or "chrome" or "msedge"
      dap.adapters[adapterType] = function(cb, config)
        local nativeAdapter = dap.adapters[pwaType]

        config.type = pwaType

        if type(nativeAdapter) == 'function' then
          nativeAdapter(cb, config)
        else
          cb(nativeAdapter)
        end
      end
    end

    local enter_launch_url = function()
      local co = coroutine.running()
      return coroutine.create(function()
        vim.ui.input(
          { prompt = 'Enter URL: ', default = 'http://localhost:' },
          function(url)
            if url == nil or url == '' then
              return
            else
              coroutine.resume(co, url)
            end
          end
        )
      end)
    end

    for _, language in ipairs {
      'typescript',
      'javascript',
      'typescriptreact',
      'javascriptreact',
      'vue',
    } do
      dap.configurations[language] = {
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Launch file using Node.js (nvim-dap)',
          program = '${file}',
          cwd = '${workspaceFolder}',
        },
        {
          type = 'pwa-node',
          request = 'attach',
          name = 'Attach to process using Node.js (nvim-dap)',
          processId = require('dap.utils').pick_process,
          cwd = '${workspaceFolder}',
        },
        -- requires ts-node to be installed globally or locally
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Launch file using Node.js with ts-node/register (nvim-dap)',
          program = '${file}',
          cwd = '${workspaceFolder}',
          runtimeArgs = { '-r', 'ts-node/register' },
        },
        {
          type = 'pwa-chrome',
          request = 'launch',
          name = 'Launch Chrome (nvim-dap)',
          url = enter_launch_url,
          webRoot = '${workspaceFolder}',
          sourceMaps = true,
        },
        {
          type = 'pwa-msedge',
          request = 'launch',
          name = 'Launch Edge (nvim-dap)',
          url = enter_launch_url,
          webRoot = '${workspaceFolder}',
          sourceMaps = true,
        },
      }
    end

    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    nmap('<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    -- require('dap-go').setup()
  end,
}
