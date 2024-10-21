-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

if jit.os == 'Windows' and vim.fn.executable 'pwsh' then
  vim.o.shell = 'pwsh'
  vim.o.shellcmdflag =
    '-NoLogo -NoProfile -ExecutionPolicy Bypass -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
end

-- Set to true if you have a Nerd Font installed
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

vim.wo.wrap = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0

if vim.g.neovide then
  vim.g.neovide_no_idle = true
  vim.g.neovide_refresh_rate = 60
  vim.g.neovide_transparency = 0.85
  vim.o.guifont = 'JetBrainsMono Nerd Font:h14' -- text below applies for VimScript
end

vim.filetype.add {
  pattern = { ['.*/hypr/.*%.conf'] = 'hyprlang' },
}

vim.opt.spelllang = { 'en_us', 'es' }
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'html', 'markdown', 'text' },
  callback = function()
    local vol = vim.opt_local

    vol.wrap = true
    vol.spell = true
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' },
  callback = function()
    vim.opt_local.tabstop = 2
  end,
})
