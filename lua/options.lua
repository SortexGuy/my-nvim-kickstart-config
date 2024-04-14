-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

if jit.os == 'Windows' and vim.fn.executable 'pwsh' then
  vim.o.shell = 'pwsh'
  vim.o.shellcmdflag =
    '-NoLogo -NoProfile -ExecutionPolicy Bypass -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
end

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

vim.wo.wrap = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

if vim.g.neovide then
  vim.g.neovide_no_idle = true
  vim.g.neovide_refresh_rate = 60
  vim.g.neovide_transparency = 0.85
  vim.o.guifont = 'JetBrainsMono Nerd Font:h14' -- text below applies for VimScript
end
