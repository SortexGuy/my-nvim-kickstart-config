---@module 'lazy'
---@type LazySpec
return {
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
    dependencies = {
      -- NOTE: `williamboman/mason*` moved to the `mason-org` organisation with
      -- the v2 release. GitHub still redirects the old paths, but the canonical
      -- names are used here so `:Lazy` reports the right repo.
      -- Must be loaded before dependants.
      { 'mason-org/mason.nvim', opts = {} },
      { 'mason-org/mason-lspconfig.nvim' },
      -- { 'williamboman/mason.nvim', config = true },
      -- { 'williamboman/mason-lspconfig.nvim' },
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- LSP progress messages in the bottom right
      { 'j-hui/fidget.nvim', opts = {} },

      {
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
          library = {
            -- Neovim ships `vim.uv` (luv) type definitions since 0.10, so the
            -- separate `luvit-meta` plugin is no longer needed.
            { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
            -- { path = 'luvit-meta/library', words = { 'vim%.uv' } },
          },
        },
      },
      -- { 'Bilal2453/luvit-meta', lazy = true },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set(
              'n',
              keys,
              func,
              { buffer = event.buf, desc = 'LSP: ' .. desc }
            )
          end

          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map(
            'gI',
            require('telescope.builtin').lsp_implementations,
            '[G]oto [I]mplementation'
          )
          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map(
            '<leader>D',
            require('telescope.builtin').lsp_type_definitions,
            'Type [D]efinition'
          )
          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map(
            '<leader>ds',
            require('telescope.builtin').lsp_document_symbols,
            '[D]ocument [S]ymbols'
          )
          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map(
            '<leader>ws',
            require('telescope.builtin').lsp_dynamic_workspace_symbols,
            '[W]orkspace [S]ymbols'
          )

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          -- Opens a popup that displays documentation about the word under your cursor
          --  See `:help K` for why this keymap.
          map('K', vim.lsp.buf.hover, 'Hover Documentation')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if
            client
            and client:supports_method(
              vim.lsp.protocol.Methods.textDocument_documentHighlight
            )
          then
            local highlight_augroup =
              vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup(
                'kickstart-lsp-detach',
                { clear = true }
              ),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds {
                  group = 'kickstart-lsp-highlight',
                  buffer = event2.buf,
                }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if
            client
            and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint)
          then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(
                not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }
              )
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- [[ Shared capabilities ]]
      -- `vim.lsp.config('*', ...)` (Neovim 0.11+) merges into *every* server
      -- config, which replaces the old "build a capabilities table and pass it
      -- to each server" dance. blink.cmp registers its own completion
      -- capabilities the same way from its `plugin/` file, and both merge.
      --
      -- Two things have to be added here:
      --   * the folding range capability nvim-ufo needs -- without it ufo
      --     silently falls back to indent folds;
      --   * dynamic registration of `didChangeWatchedFiles`, which luau-lsp
      --     uses to notice that Rojo rewrote `sourcemap.json` (see
      --     `lua/plugins/luau.lua`). Without it the server keeps serving the
      --     DataModel tree it read at startup.
      vim.lsp.config('*', {
        capabilities = {
          textDocument = {
            foldingRange = {
              dynamicRegistration = false,
              lineFoldingOnly = true,
            },
          },
          workspace = {
            didChangeWatchedFiles = {
              dynamicRegistration = true,
            },
          },
        },
      })

      -- local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- capabilities = vim.tbl_deep_extend(
      --   'force',
      --   capabilities,
      --   require('cmp_nvim_lsp').default_capabilities()
      -- )

      -- Function to provide the driver arg to clangd in Windows
      local function get_clangd_driver_for_windows()
        if jit.os ~= 'Windows' or not vim.fn.executable 'c++' then
          return '--background-index'
        end
        return '--query-driver=' .. vim.fn.exepath 'c++.exe'
      end

      -- [[ Per-server overrides ]]
      -- Keys must be `nvim-lspconfig` server names. Anything listed here is
      -- also handed to mason-tool-installer's `ensure_installed` below.
      ---@type table<string, vim.lsp.Config>
      local servers = {
        clangd = {
          cmd = { 'clangd', get_clangd_driver_for_windows() },
        },

        ts_ls = {
          -- NOTE: the previous block here used `typescript-tools.nvim` option
          -- names (`tsserver_file_preferences`, `separate_diagnostic_server`,
          -- `expose_as_code_action`, ...). `ts_ls` is plain
          -- typescript-language-server and ignores all of them, so the inlay
          -- hint and preference settings below are the same intent expressed
          -- in the shape `ts_ls` actually reads. The original is kept at the
          -- bottom of this table for reference.
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = 'all',
                includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = false,
                includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                includeInlayPropertyDeclarationTypeHints = false,
                includeInlayFunctionLikeReturnTypeHints = false,
                includeInlayEnumMemberValueHints = true,
              },
              preferences = {
                quotePreference = 'auto',
                importModuleSpecifierEnding = 'auto',
                jsxAttributeCompletionStyle = 'auto',
                includeAutomaticOptionalChainCompletions = true,
                includeCompletionsForImportStatements = true,
                includeCompletionsWithSnippetText = true,
                includeCompletionsWithClassMemberSnippets = true,
                includeCompletionsWithObjectLiteralMethodSnippets = true,
                useLabelDetailsInCompletionEntries = true,
                allowIncompleteCompletions = true,
                displayPartsForJSDoc = true,
                generateReturnInDocTemplate = true,
                allowRenameOfImportPath = true,
                providePrefixAndSuffixTextForRename = true,
                allowTextChangesInNewFiles = true,
                provideRefactorNotApplicableReason = true,
                disableLineTextInReferences = true,
              },
              format = {
                insertSpaceAfterCommaDelimiter = true,
                insertSpaceAfterConstructor = false,
                insertSpaceAfterSemicolonInForStatements = true,
                insertSpaceBeforeAndAfterBinaryOperators = true,
                insertSpaceAfterKeywordsInControlFlowStatements = true,
                insertSpaceAfterFunctionKeywordForAnonymousFunctions = true,
                insertSpaceBeforeFunctionParenthesis = false,
                insertSpaceAfterOpeningAndBeforeClosingNonemptyParenthesis = false,
                insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets = false,
                insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces = true,
                insertSpaceAfterOpeningAndBeforeClosingEmptyBraces = true,
                insertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces = false,
                insertSpaceAfterOpeningAndBeforeClosingJsxExpressionBraces = false,
                insertSpaceAfterTypeAssertion = false,
                placeOpenBraceOnNewLineForFunctions = false,
                placeOpenBraceOnNewLineForControlBlocks = false,
                semicolons = 'ignore',
                indentSwitchCase = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = 'all',
                includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = false,
                includeInlayVariableTypeHintsWhenTypeMatchesName = false,
                includeInlayPropertyDeclarationTypeHints = false,
                includeInlayFunctionLikeReturnTypeHints = false,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },

          -- Previous (typescript-tools.nvim shaped) settings -- inert under `ts_ls`:
          -- settings = {
          --   -- Performance settings
          --   separate_diagnostic_server = true,
          --   publish_diagnostic_on = 'insert_leave',
          --   tsserver_max_memory = 'auto',
          --   tsserver_format_options = { ... },
          --   tsserver_file_preferences = { ... },
          --   -- Feature settings
          --   expose_as_code_action = 'all',
          --   complete_function_calls = false,
          --   include_completions_with_insert_text = true,
          --   code_lens = 'off',
          -- },
        },

        -- lua_ls = {
        --   settings = {
        --     Lua = {
        --       completion = {
        --         callSnippet = 'Replace',
        --       },
        --       telemetry = { enable = false },
        --       -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
        --       diagnostics = { disable = { 'missing-fields' } },
        --     },
        --   },
        -- },
        lua_ls = {
          on_init = function(client)
            if client.workspace_folders then
              local path = client.workspace_folders[1].name
              if
                path ~= vim.fn.stdpath 'config'
                and (
                  vim.uv.fs_stat(path .. '/.luarc.json')
                  or vim.uv.fs_stat(path .. '/.luarc.jsonc')
                )
              then
                return
              end
            end

            client.config.settings.Lua =
              vim.tbl_deep_extend('force', client.config.settings.Lua, {
                runtime = {
                  version = 'LuaJIT',
                  path = { 'lua/?.lua', 'lua/?/init.lua' },
                },
                workspace = {
                  checkThirdParty = false,
                  library = vim.tbl_extend(
                    'force',
                    vim.tbl_filter(function(d)
                      return not d:match(vim.fn.stdpath 'config' .. '/?a?f?t?e?r?')
                    end, vim.api.nvim_get_runtime_file('', true)),
                    {
                      '${3rd}/luv/library',
                      '${3rd}/busted/library',
                    }
                  ),
                },
              })
          end,
          settings = {
            Lua = {},
          },
        },
      }

      -- Mason itself is set up by its own lazy spec above (`opts = {}`), so it
      -- is already initialised by the time this runs.
      -- require('mason').setup()

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
        -- Formatters used by conform.nvim (see lua/plugins/conform.lua).
        -- Names here are Mason package names, which sometimes differ from
        -- conform's formatter names (`cmakelang` provides the `cmake-format`
        -- binary that conform's `cmake_format` runs).
        'codespell',
        'prettierd',
        'cmakelang',
        'goimports',
        'shfmt',
        'fourmolu',
        'sqlfmt',
        -- Java: the JDT bundles nvim-jdtls loads (see `jdtls.lua`). The
        -- language server itself (`jdtls`) is installed by Mason too, but is
        -- deliberately kept out of `automatic_enable` below.
        'java-debug-adapter',
        'java-test',
        -- Luau: the server binary luau-lsp.nvim drives. It is deliberately not
        -- in the `servers` table above, because everything in that table also
        -- gets `vim.lsp.enable`d -- which is exactly what luau-lsp.nvim
        -- forbids. See `lua/plugins/luau.lua`.
        'luau-lsp',
        -- Not Mason-installable on purpose:
        --   gofmt        (ships with the Go toolchain)
        --   rustfmt      (rustup component)
        --   fish_indent  (part of the fish shell)
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      -- NOTE: mason-lspconfig v2 dropped the `handlers` table and the
      -- `automatic_installation` option entirely. `automatic_enable` now does
      -- the work: every server Mason has installed is passed to
      -- `vim.lsp.enable()` for us, picking up both the `vim.lsp.config('*')`
      -- defaults above and the per-server overrides applied below.
      require('mason-lspconfig').setup {
        ensure_installed = {},
        -- `automatic_enable` hands every Mason-installed server to
        -- `vim.lsp.enable()`. That is what restores gopls / rust_analyzer /
        -- tailwindcss / html / astro etc., which stopped being enabled at all
        -- when v2 dropped `handlers`.
        --
        -- `stylua` is excluded on purpose: nvim-lspconfig ships a `stylua`
        -- LSP config, and mason installs the stylua *binary* for conform (see
        -- `ensure_installed` above), so automatic_enable would otherwise
        -- attach a second Lua formatting client on top of conform's.
        --
        -- `jdtls` is excluded for a different reason: nvim-jdtls starts it
        -- itself, per project root and with its own `-data` workspace (see
        -- `lua/plugins/jdtls.lua`). Letting `vim.lsp.enable` start it as well
        -- would put two eclipse.jdt.ls clients on every Java buffer.
        --
        -- `luau_lsp` is the same story: luau-lsp.nvim registers and starts its
        -- own client (under the name `luau-lsp`, with the Roblox type dumps
        -- and sourcemap arguments it computes). Letting mason-lspconfig enable
        -- nvim-lspconfig's plain `luau_lsp` config alongside it attaches a
        -- second, Roblox-blind client to every `.luau` buffer -- see
        -- `lua/plugins/luau.lua`.
        automatic_enable = {
          exclude = { 'stylua', 'jdtls', 'luau_lsp' },
        },
        -- automatic_enable = true,
        -- automatic_installation = true,
        -- handlers = {
        --   function(server_name)
        --     local server = servers[server_name] or {}
        --     server.capabilities =
        --       vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
        --     vim.lsp.config(server_name, server)
        --   end,
        -- },
      }

      -- Apply our overrides on top of the config nvim-lspconfig ships, then
      -- make sure the servers we explicitly care about are enabled even if
      -- Mason did not install them (e.g. a system-wide `clangd`).
      for name, server in pairs(servers) do
        vim.lsp.config(name, server)
        vim.lsp.enable(name)
      end

      -- [[ Servers Mason does not manage ]]
      -- nvim-lspconfig ships configs for all three, so enabling them by name is
      -- enough: Neovim starts them on the matching filetype and reuses one
      -- client per project root.
      --
      -- `gdscript` connects to a running Godot editor over TCP -- see
      -- `lua/platform.lua`, which starts the matching `server.pipe`.
      vim.lsp.enable 'gdscript'
      -- vim.lsp.config('gdscript', { capabilities = capabilities, settings = {} })

      if jit.os ~= 'Windows' then
        -- Hyprland and fish. Previously these were hand-rolled `vim.lsp.start`
        -- calls inside BufEnter autocommands; the shipped configs already carry
        -- the right `cmd`, `filetypes` and `root_markers` (and pass `--stdio`
        -- to hyprls, which the old inline `cmd` omitted).
        if vim.fn.executable 'hyprls' == 1 then
          vim.lsp.enable 'hyprls'
        end
        if vim.fn.executable 'fish-lsp' == 1 then
          vim.lsp.enable 'fish_lsp'
        end

        -- vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
        --   pattern = { '.*/hypr/.*%.conf', '*.hl', 'hypr*.conf' },
        --   callback = function(event)
        --     vim.lsp.start {
        --       name = 'hyprlang',
        --       cmd = { 'hyprls' },
        --       root_dir = vim.fn.getcwd(),
        --     }
        --   end,
        -- })
        -- vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
        --   pattern = { '.*/fish/.*%.sh', '*.fish' },
        --   callback = function(event)
        --     vim.lsp.start {
        --       name = 'fish-lsp',
        --       cmd = { 'fish-lsp', 'start' },
        --       filetypes = { 'fish' },
        --       root_dir = vim.fn.getcwd(),
        --     }
        --   end,
        -- })
      end
    end,
  },
}
