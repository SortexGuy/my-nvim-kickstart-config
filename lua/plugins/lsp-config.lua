return {
  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    'williamboman/mason.nvim',
    priority = 100,
    lazy = false,
    opts = {},
  },
  {
    'williamboman/mason-lspconfig.nvim',
    priority = 90,
    lazy = false,
    opts = {
      auto_install = true,
      ensure_installed = { 'lua_ls' },
    },
  },
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    priority = 80,
    lazy = false,
    dependencies = {
      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },
}
