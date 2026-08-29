-- Luau / Roblox support.
--
-- `luau-lsp.nvim` is an extension around JohnnyMorganz's `luau-lsp` server. It
-- adds the two things the bare server cannot do from Neovim: it downloads the
-- Roblox API type + documentation dumps and passes them to the server, and it
-- keeps a Rojo sourcemap regenerating in the background so that DataModel paths
-- (`game.ReplicatedStorage.Foo`) actually resolve to the files on disk.
--
-- IMPORTANT: this plugin owns the LSP client. `vim.lsp.enable 'luau_lsp'` must
-- never be called on top of it -- mason-lspconfig's `automatic_enable` would do
-- exactly that, so `luau_lsp` is listed in its `exclude` table in
-- `lsp-config.lua`, next to `stylua` and `jdtls`.
--
-- The sourcemap is watched by the *server*, not by Neovim, so it also needs the
-- `didChangeWatchedFiles` capability -- declared in the shared
-- `vim.lsp.config('*', ...)` block in `lsp-config.lua`.
---@module 'lazy'
---@type LazySpec

-- Rokit/Aftman/Foreman put shims for `luau-lsp` and `rojo` on `$PATH`, but a
-- shim only resolves for a tool the *nearest project manifest actually lists* --
-- anywhere else it exits with "Failed to find tool ... in any project manifest
-- file" (the same trap as the stylua shim; see CLAUDE.md). `vim.fn.executable`
-- returns 1 either way, so the manifest has to be read.
--
-- Returns the bare tool name (i.e. "use the shim, it will resolve") when the
-- manifest pins that tool, otherwise nil.
---@param tool string
---@return string?
local function toolchain_tool(tool)
  local manifest = vim.fs.find({ 'rokit.toml', 'aftman.toml', 'foreman.toml' }, {
    upward = true,
    -- Search from the buffer that triggered the load, falling back to the cwd
    -- for `:LuauLsp` in a scratch buffer. This runs from `config`, i.e. when
    -- the first Luau buffer opens, so it sees the real project -- not whatever
    -- directory Neovim happened to start in.
    path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)) or vim.fn.getcwd(),
    stop = vim.uv.os_homedir(),
  })[1]

  if not manifest then
    return nil
  end

  -- Manifest keys are aliases, not necessarily the tool name, so match the
  -- whole `[tools]` section rather than parsing it: `rojo = "rojo-rbx/rojo@7"`.
  local ok, contents = pcall(vim.fn.readfile, manifest)
  if
    ok
    and vim.iter(contents):any(function(line)
      return line:find(tool, 1, true) ~= nil
    end)
  then
    return tool
  end
  return nil
end

-- Prefer the toolchain-pinned server (a Roblox project should typecheck against
-- the luau-lsp version it pins), otherwise fall back to the Mason-installed one.
local function server_path()
  local mason = vim.fn.stdpath 'data' .. '/mason/bin/luau-lsp'
  return toolchain_tool 'luau-lsp' or (vim.uv.fs_stat(mason) and mason) or 'luau-lsp'
end

return {
  'lopi-py/luau-lsp.nvim',
  -- The plugin's own `plugin/luau-lsp.lua` starts the server from a `FileType
  -- luau` autocmd, which lazy.nvim re-emits after loading -- so `ft` is enough
  -- and nothing needs to run at startup.
  ft = 'luau',
  cmd = 'LuauLsp',
  keys = {
    -- All of these need a Luau buffer, so they are `ft`-scoped rather than
    -- global. Declaring them here (instead of inside `config`) is what keeps
    -- the plugin from being pulled in at startup.
    {
      '<leader>ls',
      '<cmd>LuauLsp regenerate_sourcemap<cr>',
      ft = 'luau',
      desc = 'Luau: regenerate [S]ourcemap',
    },
    {
      '<leader>lt',
      '<cmd>LuauLsp refresh_types<cr>',
      ft = 'luau',
      desc = 'Luau: refresh [T]ypes (ignore cache)',
    },
    {
      '<leader>lb',
      '<cmd>LuauLsp bytecode<cr>',
      ft = 'luau',
      desc = 'Luau: show [B]ytecode',
    },
    {
      '<leader>lr',
      '<cmd>LuauLsp compiler_remarks<cr>',
      ft = 'luau',
      desc = 'Luau: compiler [R]emarks',
    },
    {
      '<leader>lc',
      '<cmd>LuauLsp codegen<cr>',
      ft = 'luau',
      desc = 'Luau: [C]odegen (native assembly)',
    },
    {
      '<leader>ll',
      '<cmd>LuauLsp log<cr>',
      ft = 'luau',
      desc = 'Luau: open plugin [L]og',
    },
  },
  ---@type luau-lsp.Config.Partial
  opts = {
    platform = {
      -- 'roblox' pulls the Roblox API definitions and enables DataModel-aware
      -- intellisense. Switch to 'standard' (per project, see the `.nvim.lua`
      -- note at the bottom of this file) for plain Luau / Lune projects.
      type = 'roblox',
    },

    sourcemap = {
      enabled = true,
      -- Runs `rojo sourcemap --watch --output sourcemap.json <project>
      -- --include-non-scripts` when the server initialises, and leaves it
      -- running: edits to the Rojo tree re-resolve instance paths without a
      -- restart. `:LuauLsp regenerate_sourcemap` (<leader>ls) restarts it if
      -- the watcher ever dies.
      autogenerate = true,
      -- `rojo_path` is filled in by `config` below (toolchain shim vs. a plain
      -- `rojo` on `$PATH`).
      rojo_project_file = 'default.project.json',
      -- Non-script instances (Folders, RemoteEvents, ValueBase, ...) end up in
      -- the sourcemap too, so `ReplicatedStorage.Remotes.Foo` type-checks
      -- rather than resolving to `any`.
      include_non_scripts = true,
      sourcemap_file = 'sourcemap.json',
      -- For a non-Rojo tree (Argon, Wally-vendored, a custom script), set
      -- `generator_cmd` per project instead -- it replaces the whole rojo
      -- invocation and must write `sourcemap_file` itself, e.g.
      --   generator_cmd = { 'argon', 'sourcemap', '--watch', '--non-scripts' },
    },

    types = {
      -- 'PluginSecurity' is the level Studio's own script editor uses: it
      -- exposes plugin-only APIs without the internal RobloxScriptSecurity
      -- members that no user code can call anyway.
      roblox_security_level = 'PluginSecurity',
      -- Extra `.d.luau` files, keyed by the alias they are required under
      -- (a leading `@` is added for you). Remote URLs are cached for a day;
      -- `<leader>lt` refetches them. e.g.
      --   definition_files = { testez = 'https://.../testez.d.luau' },
      definition_files = {},
      documentation_files = {},
    },

    fflags = {
      -- Start the server with `--no-flags-enabled` and then turn on only what
      -- Roblox itself currently ships, so local typechecking matches what
      -- Studio does rather than whatever is unreleased in the Luau tree.
      enable_by_default = false,
      sync = true,
      -- The new type solver is still in preview; flip this per project when
      -- you want to try it.
      enable_new_solver = false,
      override = {},
    },

    plugin = {
      -- Companion Studio plugin: streams the live DataModel over localhost so
      -- instances that only exist in the place file (not in the Rojo tree)
      -- still autocomplete. Harmless when Studio is not running -- the server
      -- just listens. Install it from:
      -- https://create.roblox.com/store/asset/10913122509/Luau-Language-Server-Companion
      -- Native Script Sync file discovery uses `fd` or `rg` from `$PATH`.
      enabled = true,
      port = 3667,
    },

    server = {
      -- `path` is filled in by `config` below, not here.
      -- base_luaurc = 'path/to/.luaurc', -- baseline config for projects without one
    },
  },
  ---@param opts luau-lsp.Config.Partial
  config = function(_, opts)
    -- Binary resolution deliberately happens here rather than in `opts`: this
    -- file's table is built at startup (when `lazy.setup 'plugins'` imports it),
    -- while `config` only runs once a Luau buffer is opened -- by which point
    -- the project, and therefore the right toolchain manifest, is known.
    opts.server.path = server_path()
    opts.sourcemap.rojo_path = toolchain_tool 'rojo' or 'rojo'

    require('luau-lsp').setup(opts)

    -- Server-side settings go through `vim.lsp.config` under the *plugin's*
    -- client name, `luau-lsp` (not nvim-lspconfig's `luau_lsp`). The schema is
    -- the same one the VS Code extension exposes; see
    -- https://github.com/folke/neoconf.nvim/blob/main/schemas/luau_lsp.json
    vim.lsp.config('luau-lsp', {
      settings = {
        ['luau-lsp'] = {
          completion = {
            -- Close blocks for you, the way Studio's editor does.
            autocompleteEnd = true,
            addParentheses = true,
            addTabstopAfterParentheses = true,
            fillCallArguments = true,
            imports = {
              -- Auto-import: completing `Players` inserts the matching
              -- `local Players = game:GetService 'Players'` at the top, and
              -- completing a module inserts its `require`.
              enabled = true,
              suggestServices = true,
              suggestRequires = true,
              requireStyle = 'auto',
              separateGroupsWithLine = true,
              -- Never offer a require into a Wally package's internal
              -- `_Index` tree -- always import the top-level alias.
              ignoreGlobs = { '**/_Index/**' },
            },
          },

          inlayHints = {
            -- Kept conservative: return/parameter types are the useful ones in
            -- Luau, variable types just repeat what is on the line. Toggle the
            -- whole lot per buffer with <leader>th (see `lsp-config.lua`).
            parameterNames = 'literals',
            parameterTypes = true,
            functionReturnTypes = true,
            variableTypes = false,
            hideHintsForErrorTypes = true,
            hideHintsForMatchingParameterNames = true,
            typeHintMaxLength = 50,
          },

          hover = {
            -- Hover shows the precise sourcemap-derived instance types...
            strictDatamodelTypes = true,
            multilineFunctionDefinitions = true,
            showTableKinds = false,
          },

          diagnostics = {
            -- ...while diagnostics deliberately do not: with strict DataModel
            -- types on, anything the sourcemap cannot see (instances created
            -- at runtime, `WaitForChild` results) reports as an error. Off,
            -- `game`/`script`/`workspace` fall back to `any`.
            -- https://github.com/JohnnyMorganz/luau-lsp/issues/83
            strictDatamodelTypes = false,
            -- Re-check dependent modules when a required module changes;
            -- whole-workspace diagnostics stay off because they are expensive
            -- on a large place.
            includeDependents = true,
            workspace = false,
          },

          -- Needed for project-wide "find references" and rename to see files
          -- that are not currently open.
          index = {
            enabled = true,
            maxFiles = 10000,
          },

          -- Wally installs every transitive dependency under `_Index`; without
          -- this, one broken package floods the quickfix list.
          ignoreGlobs = { '**/_Index/**' },
        },
      },
    })
  end,

  -- Per-project overrides go in a `.nvim.lua` at the project root (see
  -- `:help 'exrc'`), which can narrow any of the above without touching this
  -- file:
  --
  --   require('luau-lsp').config {
  --     platform = { type = 'standard' },
  --     sourcemap = { rojo_project_file = 'dev.project.json' },
  --   }
  --
  -- Verify a setup with `:checkhealth luau-lsp`.
}
