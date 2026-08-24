-- [[ Setting options ]]
-- Pure editor options only. OS/GUI detection lives in `lua/platform.lua`,
-- autocommands in `lua/autocmds.lua`.
--
-- See `:help vim.o` and `:help option-list`
-- NOTE: You can change these options as you wish!

-- Set to true if you have a Nerd Font installed.
-- Read by lazy.nvim's UI and by several plugin specs, so it has to be set early.
vim.g.have_nerd_font = true

-- Make line numbers default
vim.o.number = true
vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
--  Scheduled so a remote clipboard provider doesn't delay startup.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep search highlighting on; `<Esc>` clears it (see `lua/keybinds.lua`)
vim.o.hlsearch = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'` and `:help 'listchars'`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

vim.o.wrap = false

-- Indentation defaults. `vim-sleuth` / `guess-indent.nvim` override these per
-- buffer when a file's existing style disagrees; `lua/autocmds.lua` narrows
-- JS/TS to 2 spaces.
vim.o.tabstop = 4 -- A TAB character looks like 4 spaces
vim.o.shiftwidth = 4 -- Number of spaces inserted when indenting
vim.o.softtabstop = 4 -- Number of spaces inserted instead of a TAB character
vim.o.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character

vim.opt.spelllang = { 'en_us', 'es' }
