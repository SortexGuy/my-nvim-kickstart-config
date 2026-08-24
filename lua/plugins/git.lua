-- Git porcelain. Gutter signs and hunk actions live in `gitsigns.lua`.
---@module 'lazy'
---@type LazySpec
return {
  {
    'tpope/vim-fugitive',
    -- Loaded on first use rather than at startup; every entry point is a command.
    cmd = {
      'G',
      'Git',
      'Gdiffsplit',
      'Gvdiffsplit',
      'Gread',
      'Gwrite',
      'Ggrep',
      'GMove',
      'GDelete',
      'GBrowse',
      'Gclog',
      'Glog',
    },
  },
  {
    -- Teaches fugitive's `:GBrowse` how to build GitHub URLs.
    'tpope/vim-rhubarb',
    dependencies = { 'tpope/vim-fugitive' },
    cmd = { 'GBrowse' },
  },
}
