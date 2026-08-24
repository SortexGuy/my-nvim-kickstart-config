-- Keep secrets off screen when a `.env` file is open (including in telescope
-- previews).
---@module 'lazy'
---@type LazySpec
return {
  'laytan/cloak.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  -- NOTE: the previous spec passed `config = function(opts) require('cloak').setup(opts) end`.
  -- lazy.nvim calls `config(plugin, opts)`, so that first argument was the
  -- *plugin spec*, not the options table -- cloak was being set up with the
  -- wrong table and fell back to its defaults. Letting lazy.nvim call
  -- `setup(opts)` itself avoids the whole class of mistake.
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
  -- config = function(opts)
  --   require('cloak').setup(opts)
  -- end,
}
