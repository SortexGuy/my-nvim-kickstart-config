return {
  -- Autocompletion
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  dependencies = {
    -- Snippet Engine & its associated nvim-cmp source
    {
      'L3MON4D3/LuaSnip',
      build = (function()
        -- Build Step is needed for regex support in snippets.
        -- This step is not supported in many windows environments.
        -- Remove the below condition to re-enable on windows.
        if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
          return
        end
        return 'make install_jsregexp'
      end)(),
    },
    'saadparwaiz1/cmp_luasnip',

    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',
    -- Adds a number of user-friendly snippets
    'rafamadriz/friendly-snippets',
    'onsails/lspkind.nvim',
  },
  config = function()
    -- [[ Configure nvim-cmp ]]
    -- See `:help cmp`
    local cmp = require 'cmp'
    local luasnip = require 'luasnip'
    require('luasnip.loaders.from_vscode').lazy_load()
    luasnip.config.setup {}
    local lspkind = require 'lspkind'

    -- Truncate suggestions width
    local ELLIPSIS_CHAR = '…'

    local format = function(_, item)
      local content = item.menu
      if content == nil then
        return item
      end

      -- Get the width of the current window.
      local win_width = vim.api.nvim_win_get_width(0)
      -- Set the max content width based on either: 'fixed_width'
      -- or a percentage of the window width, in this case 20%.
      -- We subtract 10 from 'fixed_width' to leave room for 'kind' fields.
      local max_content_width = math.floor(win_width * 0.2)
      -- Truncate the completion entry text if it's longer than the
      -- max content width. We subtract 3 from the max content width
      -- to account for the "..." that will be appended to it.
      if #content > max_content_width then
        item.menu = vim.fn.strcharpart(content, 0, max_content_width - 1) .. ELLIPSIS_CHAR
      else
        item.menu = content .. (' '):rep(max_content_width - #content)
      end
      return item
    end

    cmp.setup {
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      formatting = {
        format = lspkind.cmp_format {
          mode = 'symbol_text',
          maxwidth = function()
            -- Get the width of the current window.
            local win_width = vim.api.nvim_win_get_width(0)

            -- Set the max content width based on either: 'fixed_width'
            -- or a percentage of the window width, in this case 20%.
            -- We subtract 10 from 'fixed_width' to leave room for 'kind' fields.
            local max_content_width = math.floor(win_width * 0.15)
            return max_content_width
          end,
          ellipsis_char = ELLIPSIS_CHAR,
          show_labelDetails = true, -- show labelDetails in menu. Disabled by default
          menu = {
            buffer = '[Buffer] ',
            nvim_lsp = '[LSP] ',
            luasnip = '[LuaSnip] ',
            nvim_lua = '[Lua] ',
            latex_symbols = '[Latex] ',
          },
          before = format,
        },
      },
      completion = {
        completeopt = 'menu,menuone,noinsert',
      },
      -- For an understanding of why these mappings were
      -- chosen, you will need to read `:help ins-completion`
      --
      -- No, but seriously. Please read `:help ins-completion`, it is really good!
      mapping = cmp.mapping.preset.insert {
        -- Select the [n]ext item
        ['<C-n>'] = cmp.mapping.select_next_item(),
        -- Select the [p]revious item
        ['<C-p>'] = cmp.mapping.select_prev_item(),

        -- Scroll the documentation window [b]ack / [f]orward
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),

        -- Accept ([y]es) the completion.
        --  This will auto-import if your LSP supports it.
        --  This will expand snippets if the LSP sent a snippet.
        ['<C-y>'] = cmp.mapping.confirm { select = true },

        -- Manually trigger a completion from nvim-cmp.
        --  Generally you don't need this, because nvim-cmp will display
        --  completions whenever it has completion options available.
        ['<C-Space>'] = cmp.mapping.complete {},

        -- Think of <c-l> as moving to the right of your snippet expansion.
        --  So if you have a snippet that's like:
        --  function $name($args)
        --    $body
        --  end
        --
        -- <c-l> will move you to the right of each of the expansion locations.
        -- <c-h> is similar, except moving you backwards.
        ['<C-l>'] = cmp.mapping(function()
          if luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          end
        end, { 'i', 's' }),
        ['<C-h>'] = cmp.mapping(function()
          if luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
          end
        end, { 'i', 's' }),

        -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
        --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
      },
      sources = {
        { name = 'supermaven' },
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'path' },
        { name = 'buffer' },
      },
    }
  end,
}
