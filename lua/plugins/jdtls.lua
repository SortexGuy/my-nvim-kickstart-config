-- Java / eclipse.jdt.ls.
--
-- jdtls is *not* configured through `vim.lsp.enable` like every other server in
-- `lsp-config.lua`: the language server needs one client per project root and a
-- persistent `-data` workspace directory, which is what `nvim-jdtls` manages.
-- It also adds the JDT-only extensions LSP has no request for (organize
-- imports, extract method, run/debug a single test).
--
-- Because of that, `jdtls` is excluded from mason-lspconfig's `automatic_enable`
-- in `lsp-config.lua` -- enabling both would start two clients on every buffer.
---@module 'lazy'

local mason = vim.fn.stdpath 'data' .. '/mason'

-- Where JDT keeps its index. Keyed on the *full* project path so that two
-- checkouts named `backend` don't share (and constantly invalidate) one index,
-- and kept outside `stdpath('cache')` so clearing Neovim's cache doesn't throw
-- away a 10-minute Maven import.
local function workspace_dir(root)
  local name = vim.fn.fnamemodify(root, ':t')
  return vim.fs.normalize '~/.cache/jdtls/workspace'
    .. '/'
    .. name
    .. '-'
    .. vim.fn.sha256(root):sub(1, 12)
end

-- The reactor/repository root, not the nearest module. Markers that only ever
-- appear at the top of a project are tried first, so opening
-- `service/src/main/java/Foo.java` in a multi-module Maven build imports the
-- whole build the way IntelliJ does, instead of importing `service/` alone.
local function project_root()
  return vim.fs.root(0, {
    'settings.gradle',
    'settings.gradle.kts',
    'mvnw',
    'gradlew',
    '.git',
  }) or vim.fs.root(0, { 'pom.xml', 'build.gradle', 'build.gradle.kts' })
end

-- The JDK jdtls itself runs on, and the one JDT compiles against when a
-- project doesn't pin its own.
--
-- Mason's launcher falls back to `$JAVA_HOME` and then to whatever `java` is on
-- `$PATH`, and neither is reliable here: sdkman works by editing `$PATH` and
-- `$JAVA_HOME` from `~/.sdkman/bin/sdkman-init.sh`, which a login shell sources
-- but a desktop launcher, Neovide, or a bare tmux pane does not. In those,
-- `java` is Fedora's `/usr/lib/jvm/java-25-openjdk` instead of the version
-- `sdk default java` selected. Resolving the `current` symlink by hand pins
-- jdtls to the sdkman default however Neovim was started.
--
-- NOTE: eclipse.jdt.ls needs Java 21+ to *run*. If the sdkman default is set to
-- an older JDK, Mason's launcher refuses to start and says so -- that is the
-- right failure, since the alternative is jdtls silently running on a different
-- JDK than the rest of your toolchain. Java 8/11/17 *projects* are fine: they
-- are handled by `java.configuration.runtimes` below.
local function default_java_home()
  local current = vim.fs.normalize '~/.sdkman/candidates/java/current'
  if vim.uv.fs_stat(current .. '/bin/java') then
    return vim.uv.fs_realpath(current) or current
  end
  return vim.env.JAVA_HOME and vim.fs.normalize(vim.env.JAVA_HOME) or nil
end

-- JDT wants to be told about every JDK it may compile against, by execution
-- environment name. Read the major version out of each JDK's `release` file
-- rather than parsing directory names, which differ between sdkman
-- (`21.0.11-tem`) and the distro packages (`java-25-openjdk`).
local function java_runtimes()
  local java_home = default_java_home()
  local runtimes, seen = {}, {}

  local candidates = {}
  vim.list_extend(
    candidates,
    vim.fn.glob(vim.fs.normalize '~/.sdkman/candidates/java/*', true, true)
  )
  vim.list_extend(candidates, vim.fn.glob('/usr/lib/jvm/*', true, true))

  for _, path in ipairs(candidates) do
    local real = vim.uv.fs_realpath(path) or path
    -- No `javac` means it's a JRE (or the `current` symlink we already saw).
    if not seen[real] and vim.uv.fs_stat(real .. '/bin/javac') then
      seen[real] = true
      local release = io.open(real .. '/release', 'r')
      local version = release and release:read('*a'):match 'JAVA_VERSION="([^"]+)"'
      if release then
        release:close()
      end
      local major = version and version:match '^(%d+)'
      if major then
        table.insert(runtimes, {
          -- Java 8 and older use the `JavaSE-1.x` spelling.
          name = tonumber(major) <= 8 and ('JavaSE-1.' .. major) or ('JavaSE-' .. major),
          path = real,
          default = java_home ~= nil and vim.uv.fs_realpath(java_home) == real,
        })
      end
    end
  end

  return runtimes
end

-- Extra JDT bundles: the debug adapter, the JUnit test runner, and the
-- decompiler that backs `contentProvider.preferred = 'fernflower'`. Each is a
-- Mason package (`java-debug-adapter`, `java-test`, `vscode-java-decompiler`);
-- the globs come back empty and everything else still works if one is missing.
local function bundles()
  local jars = vim.fn.glob(
    mason
      .. '/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar',
    true,
    true
  )

  for _, jar in
    ipairs(vim.fn.glob(mason .. '/packages/java-test/extension/server/*.jar', true, true))
  do
    -- Everything in that directory is a real OSGi bundle except these two:
    -- java-test launches the runner and the jacoco agent as separate
    -- processes, and loading them as bundles makes the JDT import fail.
    local base = vim.fs.basename(jar)
    if
      base ~= 'com.microsoft.java.test.runner-jar-with-dependencies.jar'
      and base ~= 'jacocoagent.jar'
    then
      table.insert(jars, jar)
    end
  end

  vim.list_extend(
    jars,
    vim.fn.glob(mason .. '/packages/vscode-java-decompiler/server/*.jar', true, true)
  )

  return jars
end

---@param bufnr integer
---@param has_bundles boolean whether the java-debug/java-test JDT bundles loaded
local function on_attach(bufnr, has_bundles)
  local jdtls = require 'jdtls'

  local map = function(keys, func, desc, mode)
    vim.keymap.set(mode or 'n', keys, func, { buffer = bufnr, desc = 'Java: ' .. desc })
  end

  -- The generic LSP maps (gd, gr, K, <leader>rn, <leader>ca, ...) already come
  -- from the `LspAttach` autocmd in `lsp-config.lua`. Only the JDT-specific
  -- extensions live here, under the `<leader>j` namespace.
  map('<leader>jo', jdtls.organize_imports, '[O]rganize imports')
  map('<leader>jv', jdtls.extract_variable, 'Extract [V]ariable')
  map('<leader>jc', jdtls.extract_constant, 'Extract [C]onstant')
  map('<leader>jv', function()
    jdtls.extract_variable(true)
  end, 'Extract [V]ariable', 'v')
  map('<leader>jc', function()
    jdtls.extract_constant(true)
  end, 'Extract [C]onstant', 'v')
  map('<leader>jm', function()
    jdtls.extract_method(true)
  end, 'Extract [M]ethod', 'v')
  -- Re-read pom.xml / build.gradle after editing dependencies.
  map('<leader>ju', '<Cmd>JdtUpdateConfig<CR>', '[U]pdate project config')
  map('<leader>jr', '<Cmd>JdtRestart<CR>', '[R]estart jdtls')

  -- `vscode.java.resolveMainClass` and the test runner are contributed by the
  -- java-debug / java-test bundles, not by jdtls itself. Without them
  -- `setup_dap_main_class_configs` just logs "no LSP client supports
  -- vscode.java.resolveMainClass", so skip the whole block until Mason has
  -- finished installing them (it does so on first start -- restart once).
  if has_bundles and package.loaded['dap'] then
    -- Registers the `java` adapter with nvim-dap and adds one configuration
    -- per `main` class. `hotcodereplace` reloads changed classes into a
    -- running debuggee, the same as IntelliJ's "Reload Changed Classes".
    jdtls.setup_dap { hotcodereplace = 'auto', config_overrides = {} }
    -- Main classes found before the Maven/Gradle import finishes are
    -- incomplete; `:JdtUpdateDebugConfig` re-runs this on demand.
    require('jdtls.dap').setup_dap_main_class_configs()

    map('<leader>jt', jdtls.test_nearest_method, '[T]est nearest method')
    map('<leader>jT', jdtls.test_class, '[T]est class')
  end
end

local function attach()
  -- `:Lazy load nvim-jdtls` (and the force-load smoke test in CLAUDE.md) calls
  -- this outside a Java buffer, where it would happily start a language server
  -- on whatever repository happens to be open.
  if vim.bo.filetype ~= 'java' then
    return
  end

  local root = project_root()
  if not root then
    return
  end

  local jdtls = require 'jdtls'

  -- `vim.lsp.config('*', ...)` is only merged into servers started through
  -- `vim.lsp.enable`, and jdtls is started by hand -- so pull the shared
  -- capability table out of it explicitly. That is where both nvim-ufo's
  -- folding range capability (`lsp-config.lua`) and blink.cmp's completion
  -- capabilities (its own `plugin/` file) are registered.
  local shared = vim.lsp.config['*'] or {}
  local capabilities = vim.tbl_deep_extend(
    'force',
    vim.lsp.protocol.make_client_capabilities(),
    shared.capabilities or {}
  )

  local extended = vim.deepcopy(jdtls.extendedClientCapabilities)
  -- Lets jdtls resolve an auto-import as part of accepting a completion item
  -- instead of sending the edit separately.
  extended.resolveAdditionalTextEditsSupport = true

  local jars = bundles()
  local java_home = default_java_home()

  local cmd = {
    -- Mason's launcher script picks the right equinox launcher jar and
    -- `config_*` directory for this OS/arch, so none of that has to be
    -- hard-coded here (it also already passes `-Xms1G`,
    -- `--add-modules=ALL-SYSTEM` and the `--add-opens` flags).
    mason .. '/bin/jdtls',
    '-data',
    workspace_dir(root),
    -- Lombok is bundled with Mason's jdtls package but not enabled by default;
    -- without the agent every generated getter/setter/builder shows up as an
    -- undefined symbol.
    '--jvm-arg=-javaagent:' .. mason .. '/packages/jdtls/lombok.jar',
    -- 1G (the value in most snippets) is not enough for a real Maven reactor.
    -- 3G leaves room for IntelliJ on a 16G box.
    '--jvm-arg=-Xmx3G',
    '--jvm-arg=-XX:+UseG1GC',
    '--jvm-arg=-XX:GCTimeRatio=4',
    '--jvm-arg=-XX:AdaptiveSizePolicyWeight=90',
    '--jvm-arg=-Dsun.zip.disableMemoryMapping=true',
    '--jvm-arg=-Dlog.level=WARNING',
  }

  if java_home then
    -- Overrides the launcher's `$JAVA_HOME`-then-`$PATH` lookup. Visible in
    -- `:LspInfo`, which makes "which JDK is this actually running on?"
    -- answerable without reading the environment Neovim was started with.
    table.insert(cmd, 2, '--java-executable=' .. java_home .. '/bin/java')
  end

  ---@type vim.lsp.ClientConfig
  local config = {
    name = 'jdtls',
    cmd = cmd,
    -- Merged onto Neovim's own environment, not a replacement for it. Anything
    -- jdtls forks -- most importantly the Gradle daemon -- reads `$JAVA_HOME`
    -- rather than our `--java-executable`, so set it here too.
    cmd_env = java_home and { JAVA_HOME = java_home } or nil,
    root_dir = root,
    capabilities = capabilities,
    flags = { allow_incremental_sync = true },
    init_options = {
      bundles = jars,
      extendedClientCapabilities = extended,
    },
    on_attach = function(_, bufnr)
      on_attach(bufnr, #jars > 0)
    end,
    settings = {
      java = {
        -- NOTE on sharing state with IntelliJ: JDT's index cannot be read from
        -- IDEA's (`.idea/`, `~/.cache/JetBrains/**/index`) -- they are
        -- different formats, so jdtls always builds its own, once, into the
        -- `-data` directory above. What the two *do* share is everything below
        -- the build tool: `~/.m2/repository` (and `~/.gradle/caches`), so every
        -- dependency jar and sources jar IDEA has already downloaded is reused
        -- as-is and the first import is mostly index time, not download time.
        configuration = {
          -- Ask before re-importing when pom.xml/build.gradle changes, rather
          -- than kicking off a full reload on every keystroke in a POM.
          updateBuildConfiguration = 'interactive',
          runtimes = java_runtimes(),
        },
        import = {
          maven = { enabled = true },
          gradle = {
            enabled = true,
            -- IntelliJ's "Gradle JVM". Left unset, the daemon picks up
            -- whatever `java` the language server process inherited.
            java = { home = java_home },
          },
          exclusions = {
            '**/node_modules/**',
            '**/.metadata/**',
            '**/archetype-resources/**',
            '**/META-INF/maven/**',
            -- IntelliJ's project metadata and its compiler output. `target/`
            -- and `build/` are deliberately *not* excluded: annotation
            -- processors (Lombok, MapStruct, QueryDSL) emit real sources into
            -- `target/generated-sources`, and excluding them breaks
            -- goto-definition on generated types.
            '**/.idea/**',
            '**/out/**',
          },
        },
        maven = { downloadSources = true, updateSnapshots = false },
        eclipse = { downloadSources = true },
        -- Step into library code even when no sources jar exists.
        references = { includeDecompiledSources = true },
        contentProvider = { preferred = 'fernflower' },
        signatureHelp = { enabled = true, description = { enabled = true } },
        -- Code lenses re-resolve on every change and are the usual cause of
        -- jdtls pegging a core in a large project.
        implementationsCodeLens = { enabled = false },
        referencesCodeLens = { enabled = false },
        inlayHints = { parameterNames = { enabled = 'literals' } },
        completion = {
          favoriteStaticMembers = {
            'org.hamcrest.MatcherAssert.assertThat',
            'org.hamcrest.Matchers.*',
            'org.junit.jupiter.api.Assertions.*',
            'org.junit.jupiter.api.Assumptions.*',
            'org.mockito.Mockito.*',
            'org.mockito.ArgumentMatchers.*',
            'org.assertj.core.api.Assertions.*',
            'java.util.Objects.requireNonNull',
            'java.util.Objects.requireNonNullElse',
          },
          filteredTypes = {
            'com.sun.*',
            'io.micrometer.shaded.*',
            'java.awt.*',
            'jdk.*',
            'sun.*',
          },
        },
        sources = {
          -- Never collapse imports into `import java.util.*` -- IntelliJ's
          -- default threshold is 5, which produces a diff war between the two
          -- editors on the same file.
          organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 },
        },
        codeGeneration = {
          toString = {
            template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
          },
          useBlocks = true,
          hashCodeEquals = { useJava7Objects = true },
        },
        format = {
          enabled = true,
          -- Point this at an Eclipse formatter profile if the project has one
          -- (IntelliJ can export its scheme via
          -- Settings > Code Style > Java > gear > Export > Eclipse XML Profile),
          -- otherwise jdtls formats to Eclipse defaults and format-on-save
          -- will fight IntelliJ's reformat over the same files.
          -- settings = { url = root .. '/eclipse-formatter.xml' },
        },
      },
    },
  }

  jdtls.start_or_attach(config)
end

---@type LazySpec
return {
  'mfussenegger/nvim-jdtls',
  ft = 'java',
  dependencies = {
    -- Loaded first so the capabilities they register in `vim.lsp.config('*')`
    -- exist by the time `attach()` reads them. `ft` lazy-loading fires on
    -- `FileType`, which is *before* blink.cmp's own `VimEnter` trigger, so
    -- without this `nvim Foo.java` would start jdtls with no completion
    -- capabilities at all.
    'neovim/nvim-lspconfig',
    'saghen/blink.cmp',
    -- Optional, but nvim-jdtls only registers the `java` debug adapter if
    -- nvim-dap is already loaded when it attaches.
    'mfussenegger/nvim-dap',
  },
  config = function()
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('jdtls-attach', { clear = true }),
      pattern = 'java',
      callback = attach,
    })
    -- lazy.nvim loaded this plugin *from* the FileType event, so the autocmd
    -- above missed the buffer that triggered the load. Start it by hand.
    attach()
  end,
}
