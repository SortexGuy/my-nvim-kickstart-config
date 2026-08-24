-- Text manipulation plugins: indentation detection, comments, casing,
-- increment/decrement and HTML tag pairing.
---@module 'lazy'
---@type LazySpec
return {
  {
    -- `:Subvert`, `crs`/`crc`/`crm`... -- case-preserving search & replace.
    'tpope/vim-abolish',
    event = 'VeryLazy',
  },

  {
    -- Detect tabstop and shiftwidth automatically
    'NMAC427/guess-indent.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {},
  },

  -- NOTE: `vim-sleuth` does the same job as `guess-indent.nvim` above, but with
  -- a slower VimScript scan on every buffer. Running both means the second one
  -- to fire wins, which makes indentation bugs hard to reason about, so sleuth
  -- is disabled. Re-enable it (and disable guess-indent) if you prefer it.
  -- 'tpope/vim-sleuth',

  {
    -- NOTE: Comment.nvim has been archived upstream. Neovim 0.10+ ships
    -- built-in commenting (`gc` operator, `gcc` line, `gc` in visual mode via
    -- `:help commenting`), which covers most of this plugin -- the parts it
    -- does not cover are `gb`/`gbc` block comments and the `gco`/`gcO`/`gcA`
    -- insert-mode helpers. It is kept for those, but is now lazy-loaded on the
    -- keys instead of at startup.
    'numToStr/Comment.nvim',
    keys = {
      { 'gc', mode = { 'n', 'x' }, desc = 'Comment toggle linewise' },
      { 'gb', mode = { 'n', 'x' }, desc = 'Comment toggle blockwise' },
      { 'gcc', mode = 'n', desc = 'Comment toggle current line' },
      { 'gbc', mode = 'n', desc = 'Comment toggle current block' },
      { 'gco', mode = 'n', desc = 'Comment insert below' },
      { 'gcO', mode = 'n', desc = 'Comment insert above' },
      { 'gcA', mode = 'n', desc = 'Comment insert end of line' },
    },
    opts = {},
  },

  {
    -- Increment / decrement numbers, dates, booleans and more.
    'monaqa/dial.nvim',
    -- Previously the keymaps were created inside `config`, which forced the
    -- plugin to load on every startup. Declaring them as `keys` defers loading
    -- until one is actually pressed.
    keys = {
      {
        '<A-k>',
        function()
          require('dial.map').manipulate('increment', 'normal')
        end,
        mode = 'n',
        desc = 'Dial: increment',
      },
      {
        '<A-j>',
        function()
          require('dial.map').manipulate('decrement', 'normal')
        end,
        mode = 'n',
        desc = 'Dial: decrement',
      },
      {
        'g<C-a>',
        function()
          require('dial.map').manipulate('increment', 'gnormal')
        end,
        mode = 'n',
        desc = 'Dial: increment (g)',
      },
      {
        'g<C-x>',
        function()
          require('dial.map').manipulate('decrement', 'gnormal')
        end,
        mode = 'n',
        desc = 'Dial: decrement (g)',
      },
      {
        '<C-a>',
        function()
          require('dial.map').manipulate('increment', 'visual')
        end,
        mode = 'v',
        desc = 'Dial: increment',
      },
      {
        '<C-x>',
        function()
          require('dial.map').manipulate('decrement', 'visual')
        end,
        mode = 'v',
        desc = 'Dial: decrement',
      },
      {
        'g<C-a>',
        function()
          require('dial.map').manipulate('increment', 'gvisual')
        end,
        mode = 'v',
        desc = 'Dial: increment (g)',
      },
      {
        'g<C-x>',
        function()
          require('dial.map').manipulate('decrement', 'gvisual')
        end,
        mode = 'v',
        desc = 'Dial: decrement (g)',
      },
    },
  },

  {
    -- Auto close and rename HTML/JSX tags.
    'windwp/nvim-ts-autotag',
    -- NOTE: the previous spec put a top-level `filetypes = { ... }` key in the
    -- lazy spec. lazy.nvim has no such key (`ft` is the lazy-loading one), so
    -- it did nothing, and `config = true` meant the plugin set itself up with
    -- its own defaults anyway. Current versions detect supported filetypes
    -- themselves; per-filetype overrides go under `opts.per_filetype`.
    ft = {
      'astro',
      'javascript',
      'javascriptreact',
      'typescript',
      'typescriptreact',
      'html',
      'xml',
      'svelte',
      'vue',
      'markdown',
    },
    opts = {},
    -- filetypes = {
    --   'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'html',
    -- },
    -- config = true,
  },
}
