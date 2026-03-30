return {
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      { 'j-hui/fidget.nvim', opts = {} },
      'hrsh7th/cmp-nvim-lsp',

      {
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {
          library = {
            { path = 'luvit-meta/library', words = { 'vim%.uv' } }, -- Load luvit types when the `vim.uv` word is found
          },
        },
      },
      { 'Bilal2453/luvit-meta', lazy = true },
    },
    config = function(_, opts)
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
            and client.supports_method(
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
            and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint)
          then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(
                not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }
              )
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend(
        'force',
        capabilities,
        require('cmp_nvim_lsp').default_capabilities()
      )
      -- Setup required for ufo
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }

      -- Function to provide the driver arg to clangd in Windows
      local function get_clangd_driver_for_windows()
        if jit.os ~= 'Windows' or not vim.fn.executable 'c++' then
          return '--background-index'
        end
        return '--query-driver=' .. vim.fn.exepath 'c++.exe'
      end

      ---@type table<string, vim.lsp.Config>
      local servers = {
        clangd = {
          cmd = { 'clangd', get_clangd_driver_for_windows() },
        },
        ts_ls = {
          settings = {
            -- Performance settings
            separate_diagnostic_server = true,
            publish_diagnostic_on = 'insert_leave',
            tsserver_max_memory = 'auto',

            -- Formatting preferences (from default_format_options)
            tsserver_format_options = {
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

            -- File preferences (combining your inlay hints with default preferences)
            tsserver_file_preferences = {
              -- Your current inlay hint settings
              includeInlayParameterNameHints = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = true,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = false,
              includeInlayVariableTypeHintsWhenTypeMatchesName = false,
              includeInlayPropertyDeclarationTypeHints = false,
              includeInlayFunctionLikeReturnTypeHints = false,
              includeInlayEnumMemberValueHints = true,

              -- Important default preferences
              quotePreference = 'auto',
              importModuleSpecifierEnding = 'auto',
              jsxAttributeCompletionStyle = 'auto',
              allowTextChangesInNewFiles = true,
              providePrefixAndSuffixTextForRename = true,
              allowRenameOfImportPath = true,
              includeAutomaticOptionalChainCompletions = true,
              provideRefactorNotApplicableReason = true,
              generateReturnInDocTemplate = true,
              includeCompletionsForImportStatements = true,
              includeCompletionsWithSnippetText = true,
              includeCompletionsWithClassMemberSnippets = true,
              includeCompletionsWithObjectLiteralMethodSnippets = true,
              useLabelDetailsInCompletionEntries = true,
              allowIncompleteCompletions = true,
              displayPartsForJSDoc = true,
              disableLineTextInReferences = true,
            },

            -- Feature settings
            expose_as_code_action = 'all',
            complete_function_calls = false,
            include_completions_with_insert_text = true,
            code_lens = 'off',
          },
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

      require('mason').setup()
      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = {},
        automatic_installation = true,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for tsserver)
            server.capabilities =
              vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            vim.lsp.config(server_name, server)
          end,
        },
      }

      vim.lsp.config('gdscript', { capabilities = capabilities, settings = {} })

      if jit.os ~= 'Windows' then
        -- Hyprlang LSP
        vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
          pattern = { '.*/hypr/.*%.conf', '*.hl', 'hypr*.conf' },
          callback = function(event)
            vim.lsp.start {
              name = 'hyprlang',
              cmd = { 'hyprls' },
              root_dir = vim.fn.getcwd(),
            }
          end,
        })
        -- Fish LSP
        vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
          pattern = { '.*/fish/.*%.sh', '*.fish' },
          callback = function(event)
            vim.lsp.start {
              name = 'fish-lsp',
              cmd = { 'fish-lsp', 'start' },
              filetypes = { 'fish' },
              root_dir = vim.fn.getcwd(),
            }
          end,
        })
      end
    end,
  },
}
