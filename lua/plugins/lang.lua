-- Per-language extras. Anything that only matters for one ecosystem lives here
-- rather than in the general-purpose files.
---@module 'lazy'
---@type LazySpec
return {
  {
    -- Godot / GDScript filetype support. The matching LSP client and the
    -- `server.pipe` that Godot connects to are set up in `lsp-config.lua` and
    -- `lua/platform.lua`.
    'habamax/vim-godot',
    event = 'VeryLazy',
  },

  {
    -- Typecheck a TypeScript project without leaving Neovim.
    'dmmulroy/tsc.nvim',
    -- Previously loaded at startup just to register three keymaps.
    cmd = { 'TSC', 'TSCOpen', 'TSCClose', 'TSCStopWatch' },
    keys = {
      { '<leader>te', '<cmd>TSC<cr>', desc = 'TSC: typecheck project' },
      { '<leader>to', '<cmd>TSCOpen<cr>', desc = 'TSC: open results' },
      { '<leader>tc', '<cmd>TSCClose<cr>', desc = 'TSC: close results' },
    },
    opts = {
      auto_open_qflist = false,
      auto_close_qflist = false,
      auto_focus_qflist = false,
      auto_start_watch_mode = false,
      -- Renders results through trouble.nvim -- see `trouble.lua`.
      use_trouble_qflist = true,
      use_diagnostics = false,
      run_as_monorepo = false,
      max_tsconfig_files = 20,
      enable_progress_notifications = true,
      enable_error_notifications = true,
      flags = {
        watch = true,
      },
      hide_progress_notifications_from_history = true,
      pretty_errors = true,
    },
  },

  {
    -- Inlay hints for servers that support them, with `:InlayHintsToggle`.
    -- NOTE: `lsp-config.lua` also binds `<leader>th` to the built-in
    -- `vim.lsp.inlay_hint` toggle; this plugin adds the commands and the
    -- per-server plumbing on top.
    'MysticalDevil/inlay-hints.nvim',
    event = 'LspAttach',
    dependencies = { 'neovim/nvim-lspconfig' },
    opts = {
      commands = { enable = true }, -- Enable InlayHints commands, include `InlayHintsToggle`, `InlayHintsEnable` and `InlayHintsDisable`
      autocmd = { enable = false }, -- Enable the inlay hints on `LspAttach` event
    },
  },

  {
    -- Disabled: `rust_analyzer` via Mason covers the current workflow. Enable
    -- this instead (and exclude `rust_analyzer` from mason-lspconfig's
    -- `automatic_enable`) if you want rustaceanvim to own the client.
    'mrcjkb/rustaceanvim',
    enabled = false,
    version = '^6', -- Recommended
    lazy = false, -- This plugin is already lazy
  },

  {
    'S1M0N38/love2d.nvim',
    enabled = false,
    event = 'VeryLazy',
    opts = {},
    keys = {
      { '<leader>v', ft = 'lua', desc = 'LÖVE' },
      { '<leader>vv', '<cmd>LoveRun<cr>', ft = 'lua', desc = 'Run LÖVE' },
      { '<leader>vs', '<cmd>LoveStop<cr>', ft = 'lua', desc = 'Stop LÖVE' },
    },
  },
}
