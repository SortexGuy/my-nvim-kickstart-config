return {
  {
    -- Theme inspired by Atom
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    opts = {
      flavour = 'mocha',
      background = { light = 'frappe', dark = 'mocha' },
      transparent_background = true,
      show_end_od_buffer = true,
      term_colors = true,
    },
  },
  {
    'ellisonleao/gruvbox.nvim',
    name = 'gruvbox',
    priority = 1000,
    config = true,
    opts = {
      terminal_colors = true, -- add neovim terminal colors
      undercurl = true,
      underline = true,
      bold = true,
      italic = {
        strings = true,
        emphasis = true,
        comments = true,
        operators = false,
        folds = true,
      },
      strikethrough = true,
      invert_selection = false,
      contrast = '', -- can be "hard", "soft" or empty string
      transparent_mode = true,
    },
  },
  {
    'luisiacc/gruvbox-baby',
    name = 'gruvbox-baby',
    branch = 'main',
    config = function()
      vim.g.gruvbox_baby_string_style = 'italic'
      vim.g.gruvbox_baby_telescope_theme = true
      vim.g.gruvbox_baby_transparent_mode = true
    end,
  },
  {
    'rebelot/kanagawa.nvim',
    name = 'kanagawa',
    opts = {
      undercurl = true, -- enable undercurls
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = true, -- do not set background color
      terminalColors = true, -- define vim.g.terminal_color_{0,17}
    },
  },
  { 'savq/melange-nvim', name = 'melange' },

  -- Themes
  {
    'zaldih/themery.nvim',
    name = 'themery',
    priority = 1000,
    opts = {
      livePreview = true,
      themes = {
        { name = 'Catppuccin Mocha', colorscheme = 'catppuccin' },
        { name = 'Gruvbox', colorscheme = 'gruvbox' },
        { name = 'Gruvbox Baby', colorscheme = 'gruvbox-baby' },
        { name = 'Kanagawa Wave', colorscheme = 'kanagawa-wave' },
        { name = 'Kanagawa Dragon', colorscheme = 'kanagawa-dragon' },
        { name = 'Kanagawa Lotus', colorscheme = 'kanagawa-lotus' },
        { name = 'Melange', colorscheme = 'melange' },
        -- { name = 'Monokai Pro', colorscheme = 'monokai-pro' },
        -- { name = 'Neon Dark', colorscheme = 'neon' },
      },
    },
  },
}
