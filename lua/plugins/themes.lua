-- Colorscheme and transparency.
--
-- NOTE: the kanagawa spec previously used `config = function(opts) ... end`.
-- lazy.nvim calls `config(plugin, opts)`, so `opts` there was bound to the
-- *plugin spec table*, and `require('kanagawa').setup(plugin_spec)` quietly
-- discarded every option below. The signature is `function(_, opts)`.
---@module 'lazy'
---@type LazySpec
return {
  {
    'xiyaowong/transparent.nvim',
    lazy = false,
    priority = 1001, -- must set `vim.g.transparent_enabled` before kanagawa reads it
    opts = {
      extra_groups = {
        'FoldColumn',
        'GitSignsAdd',
        'GitSignsChange',
        'GitSignsDelete',
        'GitSignsTopdelete',
        'GitSignsChangedelete',
        'GitSignsUntracked',
        -- Plugin windows that otherwise paint their own background:
        'NormalFloat',
        'FloatBorder',
        'TelescopePrompt',
        'TelescopeNormal',
        'TelescopeBorder',
      },
    },
  },
  {
    'rebelot/kanagawa.nvim',
    name = 'kanagawa',
    lazy = false,
    priority = 1000, -- load the colorscheme before everything else
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
    config = function(_, opts)
      require('kanagawa').setup(opts)
      require('kanagawa').load 'dragon'
    end,
    -- config = function(opts)
    --   require('kanagawa').setup(opts)
    --   require('kanagawa').load 'dragon'
    -- end,
  },
}
