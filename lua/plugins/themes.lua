return {
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

  {
    'uZer/pywal16.nvim',
    enabled = false,
    config = function()
      vim.cmd.colorscheme 'pywal16'
    end,
  },
}
