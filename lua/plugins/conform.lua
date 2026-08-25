return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>ff',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = true,
    format_on_save = function(bufnr)
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = { c = true, cpp = true }
      local lsp_format_opt
      if disable_filetypes[vim.bo[bufnr].filetype] then
        lsp_format_opt = 'never'
      else
        lsp_format_opt = 'fallback'
      end
      -- Disable with a global or buffer-local variable
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end
      return {
        timeout_ms = 500,
        lsp_format = lsp_format_opt,
      }
    end,
    -- NOTE on list semantics: a plain list runs *every* formatter in it, in
    -- order. To mean "the first one that is installed", add
    -- `stop_after_first = true` -- which is what the prettierd/prettier pairs
    -- below actually want. `go` deliberately keeps both: goimports fixes the
    -- import block, gofmt formats the rest.
    formatters_by_ft = {
      c = { 'clang-format' },
      cpp = { 'clang-format' },
      -- Conform's formatter is named `cmake_format`; `cmake-format` (with a
      -- dash) matched nothing and made every CMake save fail.
      cmake = { 'cmake_format' },
      -- cmake = { 'cmake-format' },
      go = { 'goimports', 'gofmt' },
      bash = { 'shfmt' },
      sh = { 'shfmt' },
      -- `lua_ls` is a language server, not a conform formatter -- listing it
      -- here just produced an "unknown formatter" error on every Lua save.
      -- LSP formatting is already handled by `lsp_format = 'fallback'` above.
      lua = { 'stylua' },
      -- lua = { 'lua_ls', 'stylua' },
      rust = { 'rustfmt', lsp_format = 'fallback' },
      fish = { 'fish_indent' },
      -- `spellcheck` is not a conform formatter either; codespell (below)
      -- already covers this for every filetype.
      -- text = { 'spellcheck' },
      javascript = { 'prettierd', 'prettier', stop_after_first = true },
      javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
      typescript = { 'prettierd', 'prettier', stop_after_first = true },
      typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
      json = { 'prettierd', 'prettier', stop_after_first = true },
      jsonc = { 'prettierd', 'prettier', stop_after_first = true },
      css = { 'prettierd', 'prettier', stop_after_first = true },
      html = { 'prettierd', 'prettier', stop_after_first = true },
      yaml = { 'prettierd', 'prettier', stop_after_first = true },
      markdown = { 'prettierd', 'prettier', stop_after_first = true },
      haskell = { 'fourmolu' },
      -- No java entry, so `lsp_format = 'fallback'` hands format-on-save to
      -- jdtls, which formats to Eclipse defaults. On a project that is also
      -- opened in IntelliJ that produces a reformat war over shared files --
      -- uncomment this to leave Java files alone, or point jdtls at an
      -- exported Eclipse formatter profile (see `java.format.settings.url`
      -- in `lua/plugins/jdtls.lua`).
      java = { lsp_format = 'never' },
      sql = { 'sqlfmt' },
      -- Use the "*" filetype to run formatters on all filetypes.
      -- codespell is installed by Mason (see lsp-config.lua), but the entry
      -- stays gated on the binary existing: before Mason's first install
      -- finishes an unconditional entry makes *every* buffer report a
      -- formatting error on save (`notify_on_error` is on).
      ['*'] = vim.fn.executable 'codespell' == 1 and { 'codespell' } or {},
      -- ['*'] = { 'codespell' },
      -- Use the "_" filetype to run formatters on filetypes that don't
      -- have other formatters configured.
      ['_'] = { 'trim_whitespace' },

      -- Conform can also run multiple formatters sequentially
      -- python = { "isort", "black" },
      --
      -- You can use a sub-list to tell conform to run *until* a formatter
      -- is found.
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
