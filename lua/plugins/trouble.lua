-- Pretty list for diagnostics, references, quickfix, ...
--
-- NOTE: this is the **v3** configuration. Every option in the previous spec
-- (`position`, `height`, `mode`, `action_keys`, `fold_open`, `signs`, ...)
-- belonged to trouble v2 and is ignored by the installed version -- v3 replaced
-- them with `modes`, `win`, `keys` and `icons`. The old table is kept at the
-- bottom of this file.
--
-- The previous spec also defined no keymaps at all, so the list could only be
-- reached via `:Trouble`; the `keys` below restore the usual bindings and let
-- lazy.nvim defer loading until one is pressed.
---@module 'lazy'
---@type LazySpec
return {
  'folke/trouble.nvim',
  cmd = 'Trouble',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  ---@type trouble.Config
  opts = {
    auto_close = false, -- auto close when there are no items
    auto_preview = true, -- automatically open preview when on an item
    focus = false, -- focus the window when opened
    follow = true, -- follow the current item
    multiline = true, -- render multi-line messages
    indent_guides = true, -- show indent guides
    cycle_results = true, -- cycle item list when reaching beginning or end of list
    win = { border = 'single' }, -- window configuration for floating windows
    modes = {
      -- `tsc.nvim` writes its results to the quickfix list and asks trouble to
      -- render it (`use_trouble_qflist = true`), so keep the qflist mode handy.
      diagnostics = {
        auto_open = false,
      },
    },
  },
  keys = {
    {
      '<leader>xx',
      '<cmd>Trouble diagnostics toggle<cr>',
      desc = 'Trouble: Diagnostics (workspace)',
    },
    {
      '<leader>xX',
      '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
      desc = 'Trouble: Diagnostics (buffer)',
    },
    {
      '<leader>xs',
      '<cmd>Trouble symbols toggle focus=false<cr>',
      desc = 'Trouble: Symbols',
    },
    {
      '<leader>xl',
      '<cmd>Trouble lsp toggle focus=false win.position=right<cr>',
      desc = 'Trouble: LSP definitions / references',
    },
    {
      '<leader>xL',
      '<cmd>Trouble loclist toggle<cr>',
      desc = 'Trouble: Location list',
    },
    {
      '<leader>xq',
      '<cmd>Trouble qflist toggle<cr>',
      desc = 'Trouble: Quickfix list',
    },
  },
}

-- [[ Previous trouble v2 options ]]
-- Inert under v3; kept for reference.
--
-- opts = {
--   position = 'bottom', -- position of the list can be: bottom, top, left, right
--   height = 10, -- height of the trouble list when position is top or bottom
--   width = 50, -- width of the list when position is left or right
--   -- icons = true, -- use devicons for filenames
--   mode = 'workspace_diagnostics',
--   severity = nil, -- nil (ALL) or vim.diagnostic.severity.ERROR | WARN | INFO | HINT
--   fold_open = '', -- icon used for open folds
--   fold_closed = '', -- icon used for closed folds
--   group = true, -- group results by file
--   padding = true, -- add an extra new line on top of the list
--   cycle_results = true,
--   action_keys = {
--     close = 'q',
--     cancel = '<esc>',
--     refresh = 'r',
--     jump = { '<cr>', '<tab>', '<2-leftmouse>' },
--     open_split = { '<c-x>' },
--     open_vsplit = { '<c-v>' },
--     open_tab = { '<c-t>' },
--     jump_close = { 'o' },
--     toggle_mode = 'm',
--     switch_severity = 's',
--     toggle_preview = 'P',
--     hover = 'K',
--     preview = 'p',
--     open_code_href = 'c',
--     close_folds = { 'zM', 'zm' },
--     open_folds = { 'zR', 'zr' },
--     toggle_fold = { 'zA', 'za' },
--     previous = 'k',
--     next = 'j',
--     help = '?',
--   },
--   multiline = true,
--   indent_lines = true,
--   win_config = { border = 'single' },
--   auto_open = false,
--   auto_close = false,
--   auto_preview = true,
--   auto_fold = false,
--   auto_jump = { 'lsp_definitions' },
--   include_declaration = {
--     'lsp_references', 'lsp_implementations', 'lsp_definitions',
--   },
--   signs = {
--     error = '', warning = '', hint = '', information = '', other = '',
--   },
--   use_diagnostic_signs = false,
-- }
