-- [[ Basic Keymaps ]]
-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
-- Set highlight on search, but clear on pressing <Esc> in normal mode

local function nmap(key, cmd, opts)
  vim.keymap.set('n', key, cmd, opts)
end

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

vim.opt.hlsearch = true
nmap('<Esc>', '<cmd>nohlsearch<CR>')

-- For moving lines up and down
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

nmap('<C-d>', '<C-d>zz')
nmap('<C-u>', '<C-u>zz')
nmap('n', 'nzzzv')
nmap('N', 'Nzzzv')
-- nmap('<C-o>', '<C-S-6>')

-- Remap for dealing with word wrap
nmap('k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
nmap('j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
nmap('[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
nmap(']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
nmap(
  '<leader>e',
  vim.diagnostic.open_float,
  { desc = 'Open floating diagnostic message' }
)
nmap('<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
nmap('<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
nmap('<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
nmap('<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
nmap('<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

if vim.g.vscode then
  local keymap = vim.keymap.set
  local opts = { noremap = true, silent = true }

  -- remap leader key
  keymap('n', '<Space>', '', opts)
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '

  -- yank to system clipboard
  keymap({ 'n', 'v' }, '<leader>y', '"+y', opts)

  -- paste from system clipboard
  keymap({ 'n', 'v' }, '<leader>p', '"+p', opts)

  -- better indent handling
  keymap('v', '<', '<gv', opts)
  keymap('v', '>', '>gv', opts)

  -- move text up and down
  keymap('v', 'J', ':m .+1<CR>==', opts)
  keymap('v', 'K', ':m .-2<CR>==', opts)
  keymap('x', 'J', ":move '>+1<CR>gv-gv", opts)
  keymap('x', 'K', ":move '<-2<CR>gv-gv", opts)

  -- paste preserves primal yanked piece
  keymap('v', 'p', '"_dP', opts)

  -- removes highlighting after escaping vim search
  keymap('n', '<Esc>', '<Esc>:noh<CR>', opts)

  ----

  -- call vscode commands from neovim

  -- general keymaps
  keymap(
    { 'n', 'v' },
    '<leader>t',
    "<cmd>lua require('vscode').action('workbench.action.terminal.toggleTerminal')<CR>"
  )
  keymap(
    { 'n', 'v' },
    '<leader>b',
    "<cmd>lua require('vscode').action('editor.debug.action.toggleBreakpoint')<CR>"
  )
  keymap(
    { 'n', 'v' },
    '<leader>d',
    "<cmd>lua require('vscode').action('editor.action.showHover')<CR>"
  )
  keymap(
    { 'n', 'v' },
    '<leader>a',
    "<cmd>lua require('vscode').action('editor.action.quickFix')<CR>"
  )
  keymap(
    { 'n', 'v' },
    '<leader>sp',
    "<cmd>lua require('vscode').action('workbench.actions.view.problems')<CR>"
  )
  keymap(
    { 'n', 'v' },
    '<leader>cn',
    "<cmd>lua require('vscode').action('notifications.clearAll')<CR>"
  )
  keymap(
    { 'n', 'v' },
    '<leader>ff',
    "<cmd>lua require('vscode').action('workbench.action.quickOpen')<CR>"
  )
  keymap(
    { 'n', 'v' },
    '<leader>cp',
    "<cmd>lua require('vscode').action('workbench.action.showCommands')<CR>"
  )
  keymap(
    { 'n', 'v' },
    '<leader>pr',
    "<cmd>lua require('vscode').action('code-runner.run')<CR>"
  )
  keymap(
    { 'n', 'v' },
    '<leader>fd',
    "<cmd>lua require('vscode').action('editor.action.formatDocument')<CR>"
  )

  -- harpoon keymaps
  keymap(
    { 'n', 'v' },
    '<leader>ha',
    "<cmd>lua require('vscode').action('vscode-harpoon.addEditor')<CR>"
  )
  keymap(
    { 'n', 'v' },
    '<leader>ho',
    "<cmd>lua require('vscode').action('vscode-harpoon.editorQuickPick')<CR>"
  )
  keymap(
    { 'n', 'v' },
    '<leader>he',
    "<cmd>lua require('vscode').action('vscode-harpoon.editEditors')<CR>"
  )
  keymap(
    { 'n', 'v' },
    '<leader>h1',
    "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor1')<CR>"
  )
  keymap(
    { 'n', 'v' },
    '<leader>h2',
    "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor2')<CR>"
  )
  keymap(
    { 'n', 'v' },
    '<leader>h3',
    "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor3')<CR>"
  )
  keymap(
    { 'n', 'v' },
    '<leader>h4',
    "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor4')<CR>"
  )
  keymap(
    { 'n', 'v' },
    '<leader>h5',
    "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor5')<CR>"
  )
  keymap(
    { 'n', 'v' },
    '<leader>h6',
    "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor6')<CR>"
  )
  keymap(
    { 'n', 'v' },
    '<leader>h7',
    "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor7')<CR>"
  )
  keymap(
    { 'n', 'v' },
    '<leader>h8',
    "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor8')<CR>"
  )
  keymap(
    { 'n', 'v' },
    '<leader>h9',
    "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor9')<CR>"
  )

  -- project manager keymaps
  keymap(
    { 'n', 'v' },
    '<leader>pa',
    "<cmd>lua require('vscode').action('projectManager.saveProject')<CR>"
  )
  keymap(
    { 'n', 'v' },
    '<leader>po',
    "<cmd>lua require('vscode').action('projectManager.listProjectsNewWindow')<CR>"
  )
  keymap(
    { 'n', 'v' },
    '<leader>pe',
    "<cmd>lua require('vscode').action('projectManager.editProjects')<CR>"
  )
end
