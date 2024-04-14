return { -- Autoformat
  'stevearc/conform.nvim',
  lazy = false,
  keys = {
    {
      '<leader>ff',
      function()
        require('conform').format { async = true, lsp_fallback = true }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = true,
    format_on_save = function(bufnr)
      -- Disable with a global or buffer-local variable
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end
      return { timeout_ms = 500, lsp_fallback = true }
    end,
    formatters_by_ft = {
      c = { 'clang-format' },
      cpp = { 'clang-format' },
      cmake = { 'cmake-format' },
      bash = { 'shfmt' },
      lua = { 'lua_ls', 'stylua' },
      fish = { 'fish_indent' },
      text = { 'spellcheck' },
      -- Use the "*" filetype to run formatters on all filetypes.
      ['*'] = { 'codespell' },
      -- Use the "_" filetype to run formatters on filetypes that don't
      -- have other formatters configured.
      ['_'] = { 'trim_whitespace' },

      -- Conform can also run multiple formatters sequentially
      -- python = { "isort", "black" },
      --
      -- You can use a sub-list to tell conform to run *until* a formatter
      -- is found.
      -- javascript = { { "prettierd", "prettier" } },
    },
  },
  config = function(_, opts)
    require('conform').setup(opts)

    vim.api.nvim_create_user_command('FormatDisable', function(args)
      if args.bang then
        -- FormatDisable! will disable formatting just for this buffer
        vim.b.disable_autoformat = true
      else
        vim.g.disable_autoformat = true
      end
    end, {
      desc = 'Disable autoformat-on-save',
      bang = true,
    })
    vim.api.nvim_create_user_command('FormatEnable', function()
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
    end, {
      desc = 'Re-enable autoformat-on-save',
    })

    vim.keymap.set(
      'n',
      '<leader>fd',
      '<Cmd>FormatDisable<CR>',
      { desc = 'Conform: Disable' }
    )
    vim.keymap.set(
      'n',
      '<leader>fb',
      '<Cmd>FormatDisable!<CR>',
      { desc = 'Conform: Disable in buffer' }
    )
    vim.keymap.set(
      'n',
      '<leader>fe',
      '<Cmd>FormatEnable<CR>',
      { desc = 'Conform: Enable' }
    )
  end,
}
