return {
  {
    'rebelot/kanagawa.nvim',
    cond = not vim.g.vscode,
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
    cond = not vim.g.vscode,
    config = function()
      vim.cmd.colorscheme 'pywal16'
    end,
  },
}
