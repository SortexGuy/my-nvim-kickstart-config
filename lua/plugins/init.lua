return {
  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',
  'tpope/vim-abolish',
  -- {
  --   -- Set lualine as statusline
  --   'nvim-lualine/lualine.nvim',
  --   -- See `:help lualine.txt`
  --   opts = {
  --     options = {
  --       icons_enabled = false,
  --       -- theme = 'onedark',
  --       component_separators = '|',
  --       section_separators = '',
  --     },
  --   },
  -- },
  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help indent_blankline.txt`
    main = 'ibl',
    opts = {
      indent = { char = '┊' },
      scope = { enabled = true },
    },
  },
  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },
  -- Highlight todo, notes, etc in comments
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },
  -- {
  --   'Exafunction/codeium.nvim',
  --   dependencies = {
  --     'nvim-lua/plenary.nvim',
  --     'hrsh7th/nvim-cmp',
  --   },
  --   config = function()
  --     require('codeium').setup {}
  --   end,
  -- },
  {
    'supermaven-inc/supermaven-nvim',
    opts = {
      -- keymaps = {
      --   accept_suggestion = '<Tab>',
      --   clear_suggestion = '<C-]>',
      --   accept_word = '<C-j>',
      -- },
      -- ignore_filetypes = { cpp = true },
      -- color = {
      --   suggestion_color = '#ffffff',
      --   cterm = 244,
      -- },
      disable_inline_completion = true, -- disables inline completion for use with cmp
      disable_keymaps = true, -- disables built in keymaps for more manual control
    },
  },
  'ThePrimeagen/vim-be-good',
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
      autocmd = { enable = true }, -- Enable the inlay hints on `LspAttach` event
    },
  },
}
