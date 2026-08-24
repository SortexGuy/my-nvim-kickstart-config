-- [[ Basic Keymaps ]]
-- Only leader-independent, plugin-independent maps live here. Leader-prefixed
-- maps belong with the plugin that provides them (telescope's `<leader>s*`,
-- conform's `<leader>f*`, gitsigns' `<leader>h*`, ...), and the leader groups
-- themselves are documented in `lua/plugins/which-key.lua`.
--
-- See `:help vim.keymap.set()`

local function nmap(key, cmd, opts)
  vim.keymap.set('n', key, cmd, opts)
end

-- `<Space>` is the leader; make sure it never does anything on its own.
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Clear search highlighting on <Esc>
nmap('<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- Move the visual selection up and down, reindenting as it lands
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Keep the cursor centred while scrolling and while walking search results
nmap('<C-d>', '<C-d>zz', { desc = 'Half page down (centred)' })
nmap('<C-u>', '<C-u>zz', { desc = 'Half page up (centred)' })
nmap('n', 'nzzzv', { desc = 'Next search result (centred)' })
nmap('N', 'Nzzzv', { desc = 'Previous search result (centred)' })
-- nmap('<C-o>', '<C-S-6>')

-- Remap for dealing with word wrap
nmap('k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
nmap('j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
-- NOTE: `vim.diagnostic.goto_prev()` / `goto_next()` are deprecated and are
-- removed in Neovim 0.13 -- `vim.diagnostic.jump()` replaces both.
nmap('[d', function()
  vim.diagnostic.jump { count = -1 }
end, { desc = 'Go to previous diagnostic message' })
nmap(']d', function()
  vim.diagnostic.jump { count = 1 }
end, { desc = 'Go to next diagnostic message' })
-- nmap('[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
-- nmap(']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
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

-- Open a terminal in the current window. (Previously defined, unrelated to
-- anything else it lived next to, inside the harpoon plugin spec.)
nmap('<A-t>', '<cmd>term<CR>', { desc = 'Open a terminal' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  NOTE: when tmux is running, `vim-tmux-navigator` claims these same keys via
--  its own lazy `keys` spec so the motion continues across tmux panes.
--  See `:help wincmd` for a list of all window commands
nmap('<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
nmap('<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
nmap('<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
nmap('<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
