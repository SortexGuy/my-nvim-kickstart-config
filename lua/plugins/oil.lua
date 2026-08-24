---@module 'lazy'
---@type LazySpec
return {
  'stevearc/oil.nvim',
  -- enabled = false,
  -- Must load eagerly: oil replaces netrw as the directory handler, so it has
  -- to be in place before Neovim opens a directory argument (`nvim .`).
  lazy = false,
  opts = {
    default_file_explorer = true,
    columns = {
      'icon',
      'size',
      'mtime',
    },
    buf_options = {
      buflisted = false,
      bufhidden = 'hide',
    },
    win_options = {
      wrap = false,
      signcolumn = 'no',
      cursorcolumn = false,
      foldcolumn = '0',
      spell = false,
      list = false,
      conceallevel = 3,
      concealcursor = 'nvic',
    },
    delete_to_trash = false,
    skip_confirm_for_simple_edits = false,
    prompt_save_on_select_new_entry = true,
    cleanup_delay_ms = 2000,
    keymaps = {
      ['g?'] = 'actions.show_help',
      ['<CR>'] = 'actions.select',
      ['<C-s>'] = 'actions.select_vsplit',
      ['<C-h>'] = 'actions.select_split',
      ['<C-t>'] = 'actions.select_tab',
      ['<C-p>'] = 'actions.preview',
      ['<C-c>'] = 'actions.close',
      ['<C-l>'] = 'actions.refresh',
      ['-'] = 'actions.parent',
      ['_'] = 'actions.open_cwd',
      ['`'] = 'actions.cd',
      ['~'] = 'actions.tcd',
      ['gs'] = 'actions.change_sort',
      ['gx'] = 'actions.open_external',
      ['g.'] = 'actions.toggle_hidden',
      ['g\\'] = 'actions.toggle_trash',
    },
    use_default_keymaps = true,
    view_options = {
      show_hidden = true,
    },
    float = {
      padding = 2,
      border = 'rounded',
      win_options = {
        winblend = 0,
      },
    },
    preview = {
      -- max_width = {100, 0.8} means "the lesser of 100 columns or 80% of total"
      max_width = 0.9,
      -- min_width = {40, 0.4} means "the greater of 40 columns or 40% of total"
      min_width = { 40, 0.4 },
      -- max_height = {80, 0.9} means "the lesser of 80 columns or 90% of total"
      max_height = 0.9,
      -- min_height = {5, 0.1} means "the greater of 5 columns or 10% of total"
      min_height = { 5, 0.1 },
      border = 'rounded',
      update_on_cursor_moved = true,
    },
  },
  keys = {
    { '-', '<cmd>Oil<cr>', desc = 'Open parent directory' },
  },
  config = function(_, opts)
    require('oil').setup(opts)
    -- Let netrw's helper commands (`gx` and friends) work again after oil has
    -- claimed the directory-browsing role. See the note in `init.lua` about
    -- why `netrwPlugin` is not in lazy's `disabled_plugins`.
    vim.g.loaded_netrw = nil
  end,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
}
