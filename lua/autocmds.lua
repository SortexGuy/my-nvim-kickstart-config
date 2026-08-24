-- [[ Filetype registration and autocommands ]]
-- Extracted out of `lua/options.lua`. Plugin-owned autocommands stay with their
-- plugin spec (LSP attach, treesitter, ufo, conform...); only editor-wide ones
-- belong here.

local augroup = function(name)
  return vim.api.nvim_create_augroup('user-' .. name, { clear = true })
end

-- Hyprland config files aren't detected by Neovim's built-in filetype rules.
vim.filetype.add {
  pattern = { ['.*/hypr/.*%.conf'] = 'hyprlang' },
}

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = augroup 'highlight-yank',
  callback = function()
    -- `vim.highlight` is the deprecated alias, removed in Neovim 0.13.
    vim.hl.on_yank()
  end,
})

-- Prose: soft wrap and spell checking.
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Enable wrap and spell for prose filetypes',
  group = augroup 'prose',
  pattern = { 'html', 'markdown', 'text', 'gitcommit' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- The global default is 4 spaces (see `lua/options.lua`); the JS/TS ecosystem
-- overwhelmingly uses 2, and prettier is configured to emit 2 (see conform).
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Use 2-space indentation for JS/TS',
  group = augroup 'js-indent',
  pattern = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'json',
    'jsonc',
  },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})
