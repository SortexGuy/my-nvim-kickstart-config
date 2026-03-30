return {
  ---@module 'lazy'
  ---@type LazySpec
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
    config = function(opts)
      require('kanagawa').setup(opts)
      require('kanagawa').load 'dragon'
    end,
  },
  ---@module 'lazy'
  ---@type LazySpec
  { 'xiyaowong/transparent.nvim' },
}
