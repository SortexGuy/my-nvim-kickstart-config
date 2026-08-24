-- Quick marks for the handful of files you are actually working in.
--
-- The keymaps used to be created inside `config`, which meant harpoon loaded on
-- every startup. Declaring them as `keys` defers loading until first use;
-- `harpoon:setup()` still runs before the mapping fires.
---@module 'lazy'
---@type LazySpec
return {
  'ThePrimeagen/harpoon',
  name = 'harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = {},
  keys = {
    {
      '<A-f>',
      function()
        require('harpoon'):list():add()
      end,
      desc = 'Harpoon: Mark file',
    },
    {
      '<A-m>',
      function()
        local harpoon = require 'harpoon'
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      desc = 'Harpoon: Quick menu',
    },
    {
      '<A-h>',
      function()
        require('harpoon'):list():select(1)
      end,
      desc = 'Harpoon: Go to mark 1',
    },
    {
      '<A-u>',
      function()
        require('harpoon'):list():select(2)
      end,
      desc = 'Harpoon: Go to mark 2',
    },
    {
      '<A-i>',
      function()
        require('harpoon'):list():select(3)
      end,
      desc = 'Harpoon: Go to mark 3',
    },
    {
      '<A-o>',
      function()
        require('harpoon'):list():select(4)
      end,
      desc = 'Harpoon: Go to mark 4',
    },
    {
      '<A-p>',
      function()
        require('harpoon'):list():prev()
      end,
      desc = 'Harpoon: Go to previous mark',
    },
    {
      '<A-n>',
      function()
        require('harpoon'):list():next()
      end,
      desc = 'Harpoon: Go to next mark',
    },
  },
  config = function(_, opts)
    require('harpoon'):setup(opts)
  end,
}

-- NOTE: this file also used to define `<A-t>` ("open a terminal"), which has
-- nothing to do with harpoon and was unreachable until harpoon loaded. It now
-- lives in `lua/keybinds.lua` with the other core maps.
