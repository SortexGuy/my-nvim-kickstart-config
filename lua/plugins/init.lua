return {
  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',
  'tpope/vim-abolish',
  {
    'laytan/cloak.nvim',
    opts = {
      enabled = true,
      cloak_character = '*',
      -- The applied highlight group (colors) on the cloaking, see `:h highlight`.
      highlight_group = 'Comment',
      cloak_length = nil, -- Provide a number if you want to hide the true length of the value.
      try_all_patterns = true,
      cloak_telescope = true,
      cloak_on_leave = true,
      patterns = {
        {
          file_pattern = '.env*',
          cloak_pattern = '=.+',
          replace = nil,
        },
      },
    },
    config = function(opts)
      require('cloak').setup(opts)
    end,
  },
  { 'NMAC427/guess-indent.nvim', opts = {} },
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {
      indent = { char = '┊' },
      scope = { enabled = true },
    },
  },
  { 'numToStr/Comment.nvim', opts = {} },
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },
  {
    'NvChad/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup {
        filetypes = { '*' },
        user_default_options = {
          RGB = true, -- #RGB hex codes
          RRGGBB = true, -- #RRGGBB hex codes
          names = true, -- "Name" codes like Blue or blue
          RRGGBBAA = false, -- #RRGGBBAA hex codes
          AARRGGBB = false, -- 0xAARRGGBB hex codes
          rgb_fn = false, -- CSS rgb() and rgba() functions
          hsl_fn = false, -- CSS hsl() and hsla() functions
          css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
          css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn
          -- Available modes for `mode`: foreground, background,  virtualtext
          mode = 'background', -- Set the display mode.
          -- Available methods are false / true / "normal" / "lsp" / "both"
          -- True is same as normal
          tailwind = false, -- Enable tailwind colors
          -- parsers can contain values used in |user_default_options|
          sass = { enable = false, parsers = { 'css' } }, -- Enable sass colors
          virtualtext = '■',
          -- update color values even if buffer is not focused
          -- example use: cmp_menu, cmp_docs
          always_update = false,
        },
        -- all the sub-options of filetypes apply to buftypes
        buftypes = {},
      }
    end,
  },
  {
    'monaqa/dial.nvim',
    config = function()
      local dial_map = require 'dial.map'
      vim.keymap.set('n', '<A-k>', function()
        dial_map.manipulate('increment', 'normal')
      end)
      vim.keymap.set('n', '<A-j>', function()
        dial_map.manipulate('decrement', 'normal')
      end)
      vim.keymap.set('n', 'g<C-a>', function()
        dial_map.manipulate('increment', 'gnormal')
      end)
      vim.keymap.set('n', 'g<C-x>', function()
        dial_map.manipulate('decrement', 'gnormal')
      end)
      vim.keymap.set('v', '<C-a>', function()
        dial_map.manipulate('increment', 'visual')
      end)
      vim.keymap.set('v', '<C-x>', function()
        dial_map.manipulate('decrement', 'visual')
      end)
      vim.keymap.set('v', 'g<C-a>', function()
        dial_map.manipulate('increment', 'gvisual')
      end)
      vim.keymap.set('v', 'g<C-x>', function()
        dial_map.manipulate('decrement', 'gvisual')
      end)
    end,
  },
  {
    'MysticalDevil/inlay-hints.nvim',
    event = 'LspAttach',
    dependencies = { 'neovim/nvim-lspconfig' },
    opts = {
      commands = { enable = true }, -- Enable InlayHints commands, include `InlayHintsToggle`, `InlayHintsEnable` and `InlayHintsDisable`
      autocmd = { enable = false }, -- Enable the inlay hints on `LspAttach` event
    },
  },
  { 'habamax/vim-godot', event = 'VimEnter' },
  {
    'windwp/nvim-ts-autotag',
    filetypes = {
      'javascript',
      'javascriptreact',
      'typescript',
      'typescriptreact',
      'html',
    },
    config = true,
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
  {
    'mrcjkb/rustaceanvim',
    enabled = false,
    version = '^6', -- Recommended
    lazy = false, -- This plugin is already lazy
  },
  -- tsc.lua
  {
    'dmmulroy/tsc.nvim',
    config = function()
      require('tsc').setup {
        auto_open_qflist = false,
        auto_close_qflist = false,
        auto_focus_qflist = false,
        auto_start_watch_mode = false,
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
      }
      vim.keymap.set('n', '<leader>te', ':TSC<CR>')
      vim.keymap.set('n', '<leader>to', ':TSCOpen<CR>')
      vim.keymap.set('n', '<leader>tc', ':TSCClose<CR>')
    end,
  },
}
