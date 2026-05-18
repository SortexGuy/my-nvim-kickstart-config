return {
  ---@module 'lazy'
  ---@type LazySpec
  {
    'xiyaowong/transparent.nvim',
    opts = {
      extra_groups = {
        'FoldColumn',
        'GitSignsAdd',
        'GitSignsChange',
        'GitSignsDelete',
        'GitSignsTopdelete',
        'GitSignsChangedelete',
        'GitSignsUntracked',
      },
    },
  },
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
      transparent = vim.g.transparent_enabled,
      terminalColors = true, -- define vim.g.terminal_color_{0,17}
    },
    config = function(opts)
      require('kanagawa').setup(opts)
      require('kanagawa').load 'dragon'
    end,
  },
}
