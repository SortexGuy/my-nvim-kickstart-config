-- Entry point.
--
-- Load order matters:
--   1. leader keys   -- must be set before lazy.nvim loads any plugin spec,
--                       otherwise `<leader>` maps resolve against the wrong key
--   2. options       -- pure `vim.o` settings
--   3. platform      -- OS / GUI / Godot detection (needs to run before plugins)
--   4. keybinds      -- leader-independent core maps
--   5. autocmds      -- filetype registration + editor autocommands
--   6. lazy.nvim     -- imports every module under `lua/plugins/`
--
-- See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim

vim.loader.enable()

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require 'options'
require 'platform'
require 'keybinds'
require 'autocmds'

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    lazyrepo,
    lazypath,
  }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- Setting up plugins.
-- `'plugins'` imports every `lua/plugins/*.lua` module; each returns a `LazySpec`
-- (or a list of them). Adding a plugin = adding a file there, nothing to register.
require('lazy').setup('plugins', {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
  change_detection = {
    notify = false,
  },
  -- No plugin here ships as a luarock; skip the hererocks bootstrap and its warning.
  rocks = {
    enabled = false,
  },
  performance = {
    rtp = {
      -- Disable unused built-in vim plugins to shave startup time.
      -- NOTE: `netrwPlugin` is deliberately NOT disabled -- oil.nvim resets
      -- `vim.g.loaded_netrw` so netrw's `gx`-style helpers stay available.
      disabled_plugins = {
        'gzip',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
      },
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
