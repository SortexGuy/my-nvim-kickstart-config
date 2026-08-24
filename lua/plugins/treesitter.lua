-- [[ Configure Treesitter ]]
--
-- IMPORTANT: this config targets the **`main` branch rewrite** of
-- nvim-treesitter, which is what is currently installed. The rewrite is a
-- deliberate, incompatible break from the old `master` branch:
--
--   * `require('nvim-treesitter.configs').setup{}` is gone. `setup{}` on the
--     `main` branch accepts exactly one option, `install_dir` -- passing
--     `ensure_installed` / `highlight` / `indent` / `textobjects` to it is
--     silently ignored.
--   * highlighting, folding and indentation are enabled by Neovim itself
--     (`vim.treesitter.start()`, `foldexpr`, `indentexpr`), not by the plugin.
--   * parsers install into `stdpath('data')/site/parser`, not into the plugin
--     directory.
--   * it cannot be lazy-loaded, and it needs the `tree-sitter` CLI (>= 0.26.1)
--     on `$PATH` plus a C compiler.
--
-- See `:help nvim-treesitter` and the `master` branch spec kept at the bottom
-- of this file.
---@module 'lazy'
---@type LazySpec
return {
  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    -- The rewrite explicitly does not support lazy-loading.
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local ts = require 'nvim-treesitter'

      -- Parsers to keep installed. `install()` is asynchronous and is a no-op
      -- for anything already present, so it is cheap to call on every startup.
      local ensure_installed = {
        'bash',
        'c',
        'html',
        'rust',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'vim',
        'vimdoc',
        'gdscript',
        'godot_resource',
        'gdshader',
        -- Filetypes this config has dedicated tooling for:
        'javascript',
        'typescript',
        'tsx',
        'json',
        -- NOTE: there is no separate `jsonc` parser upstream -- the `json`
        -- parser handles it, and listing it produced a "skipping unsupported
        -- language" warning on every startup.
        -- 'jsonc',
        'yaml',
        'toml',
        'query',
        'diff',
        'fish',
        'hyprlang',
      }

      ts.setup {
        -- Prepended to 'runtimepath', so these parsers win over any bundled
        -- with Neovim itself.
        install_dir = vim.fn.stdpath 'data' .. '/site',
      }

      ts.install(ensure_installed)

      -- Replaces the old `auto_install = true`.
      local auto_install = true

      -- Replaces the old top-level `disable = function(lang, buf) ... end`:
      -- skip treesitter entirely on very large files, where parsing costs more
      -- than the highlighting is worth.
      local max_filesize = 500 * 1024 -- 500 KB
      local function is_too_big(buf)
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
        return ok and stats and stats.size > max_filesize
      end

      local function start(buf, lang)
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end

        -- Highlighting. Provided by Neovim; see `:help treesitter-highlight`.
        pcall(vim.treesitter.start, buf, lang)

        -- Indentation. Provided by nvim-treesitter but still marked
        -- experimental upstream -- comment this out if a language indents
        -- badly and fall back to the built-in indent rules.
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

        -- NOTE: folding is deliberately NOT set here. nvim-ufo owns
        -- 'foldmethod'/'foldexpr' (see `lua/plugins/ufo.lua`) and already
        -- falls back to a treesitter/indent provider when the LSP has no
        -- folding ranges. Setting `vim.wo.foldexpr` here would fight it.
      end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('user-treesitter', { clear = true }),
        desc = 'Enable treesitter highlighting and indentation',
        callback = function(ev)
          if is_too_big(ev.buf) then
            return
          end

          local lang = vim.treesitter.language.get_lang(ev.match)
          if not lang then
            return
          end

          local config = require 'nvim-treesitter.config'
          if vim.tbl_contains(config.get_installed 'parsers', lang) then
            start(ev.buf, lang)
          elseif auto_install and vim.tbl_contains(config.get_available(), lang) then
            ts.install(lang):await(function()
              vim.schedule(function()
                start(ev.buf, lang)
              end)
            end)
          end
        end,
      })
    end,
  },

  {
    -- Syntax aware text objects: select, move and swap.
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('nvim-treesitter-textobjects').setup {
        select = {
          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,
        },
        move = {
          -- whether to set jumps in the jumplist
          set_jumps = true,
        },
      }

      local select = require 'nvim-treesitter-textobjects.select'
      local move = require 'nvim-treesitter-textobjects.move'
      local swap = require 'nvim-treesitter-textobjects.swap'

      -- On the `main` branch every mapping is defined by hand instead of via a
      -- `keymaps = {}` table. These mirror the previous `master` config.
      -- You can use the capture groups defined in textobjects.scm
      local textobjects = {
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      }
      for lhs, query in pairs(textobjects) do
        vim.keymap.set({ 'x', 'o' }, lhs, function()
          select.select_textobject(query, 'textobjects')
        end, { desc = 'Select ' .. query })
      end

      local moves = {
        goto_next_start = { [']m'] = '@function.outer', [']]'] = '@class.outer' },
        goto_next_end = { [']M'] = '@function.outer', [']['] = '@class.outer' },
        goto_previous_start = { ['[m'] = '@function.outer', ['[['] = '@class.outer' },
        goto_previous_end = { ['[M'] = '@function.outer', ['[]'] = '@class.outer' },
      }
      for fn, maps in pairs(moves) do
        for lhs, query in pairs(maps) do
          vim.keymap.set({ 'n', 'x', 'o' }, lhs, function()
            move[fn](query, 'textobjects')
          end, { desc = fn:gsub('_', ' ') .. ' ' .. query })
        end
      end

      vim.keymap.set('n', '<leader>a', function()
        swap.swap_next '@parameter.inner'
      end, { desc = 'Swap parameter with next' })
      vim.keymap.set('n', '<leader>A', function()
        swap.swap_previous '@parameter.inner'
      end, { desc = 'Swap parameter with previous' })
    end,
  },
}

-- [[ Previous `master` branch configuration ]]
-- Kept for reference / rollback. To go back, replace the specs above with this
-- one *and* pin `branch = 'master'` -- without the pin lazy.nvim follows the
-- default branch, which is now the `main` rewrite.
--
-- return {
--   'nvim-treesitter/nvim-treesitter',
--   branch = 'master',
--   dependencies = {
--     'nvim-treesitter/nvim-treesitter-textobjects',
--   },
--   build = ':TSUpdate',
--   opts = {
--     ensure_installed = {
--       'bash', 'c', 'html', 'rust', 'lua', 'luadoc', 'markdown', 'vim',
--       'vimdoc', 'gdscript', 'godot_resource', 'gdshader',
--     },
--     auto_install = true,
--     highlight = { enable = true },
--     indent = { enable = true },
--     textobjects = {
--       select = {
--         enable = true,
--         lookahead = true,
--         keymaps = {
--           ['aa'] = '@parameter.outer',
--           ['ia'] = '@parameter.inner',
--           ['af'] = '@function.outer',
--           ['if'] = '@function.inner',
--           ['ac'] = '@class.outer',
--           ['ic'] = '@class.inner',
--         },
--       },
--       move = {
--         enable = true,
--         set_jumps = true,
--         goto_next_start = { [']m'] = '@function.outer', [']]'] = '@class.outer' },
--         goto_next_end = { [']M'] = '@function.outer', [']['] = '@class.outer' },
--         goto_previous_start = { ['[m'] = '@function.outer', ['[['] = '@class.outer' },
--         goto_previous_end = { ['[M'] = '@function.outer', ['[]'] = '@class.outer' },
--       },
--       swap = {
--         enable = true,
--         swap_next = { ['<leader>a'] = '@parameter.inner' },
--         swap_previous = { ['<leader>A'] = '@parameter.inner' },
--       },
--     },
--     disable = function(lang, buf)
--       local max_filesize = 500 * 1024 -- 500 KB
--       local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
--       if ok and stats and stats.size > max_filesize then
--         return true
--       end
--     end,
--   },
--   config = function(_, opts)
--     require('nvim-treesitter.configs').setup(opts)
--   end,
-- }
