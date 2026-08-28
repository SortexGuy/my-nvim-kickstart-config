-- CMake workflow (configure / build / run / debug / test) without leaving Neovim,
-- modelled on vscode-cmake-tools.
--
-- Only does anything in a directory that actually has a `CMakeLists.txt`, so it
-- is safe to load for every C/C++ buffer. Related config lives elsewhere:
--   * `conform.lua` formats `CMakeLists.txt` with `cmake_format`
--   * `lsp-config.lua` owns the `clangd` client that consumes the
--     `compile_commands.json` this plugin links into the project root
---@module 'lazy'
---@type LazySpec
return {
  'Civitasv/cmake-tools.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  -- Loading on filetype (rather than on the commands alone) is what makes
  -- `cmake_regenerate_on_save` and the virtual-text target hint work without
  -- having to run a `:CMake*` command first.
  ft = { 'c', 'cpp', 'cmake' },
  cmd = {
    'CMakeGenerate',
    'CMakeBuild',
    'CMakeRun',
    'CMakeDebug',
    'CMakeRunTest',
    'CMakeQuickStart',
    'CMakeSettings',
    'CMakeSelectBuildType',
    'CMakeSelectBuildTarget',
    'CMakeSelectLaunchTarget',
  },
  -- Buffer-local, like the jdtls maps: the `<leader>m` namespace only exists in
  -- buffers where CMake is plausible. See `which-key.lua` for the group label.
  keys = {
    -- stylua: ignore start
    { '<leader>mg', '<cmd>CMakeGenerate<cr>',          ft = { 'c', 'cpp', 'cmake' }, desc = 'CMake: [G]enerate' },
    { '<leader>mb', '<cmd>CMakeBuild<cr>',             ft = { 'c', 'cpp', 'cmake' }, desc = 'CMake: [B]uild' },
    { '<leader>mr', '<cmd>CMakeRun<cr>',               ft = { 'c', 'cpp', 'cmake' }, desc = 'CMake: [R]un' },
    { '<leader>md', '<cmd>CMakeDebug<cr>',             ft = { 'c', 'cpp', 'cmake' }, desc = 'CMake: [D]ebug' },
    { '<leader>mc', '<cmd>CMakeClean<cr>',             ft = { 'c', 'cpp', 'cmake' }, desc = 'CMake: [C]lean' },
    { '<leader>mT', '<cmd>CMakeRunTest<cr>',           ft = { 'c', 'cpp', 'cmake' }, desc = 'CMake: run [T]ests (ctest)' },
    { '<leader>ma', '<cmd>CMakeLaunchArgs<cr>',        ft = { 'c', 'cpp', 'cmake' }, desc = 'CMake: launch [A]rgs' },
    { '<leader>mt', '<cmd>CMakeSelectBuildType<cr>',   ft = { 'c', 'cpp', 'cmake' }, desc = 'CMake: select build [T]ype' },
    { '<leader>ms', '<cmd>CMakeSelectBuildTarget<cr>', ft = { 'c', 'cpp', 'cmake' }, desc = 'CMake: [S]elect build target' },
    { '<leader>ml', '<cmd>CMakeSelectLaunchTarget<cr>',ft = { 'c', 'cpp', 'cmake' }, desc = 'CMake: select [L]aunch target' },
    { '<leader>mk', '<cmd>CMakeSelectKit<cr>',         ft = { 'c', 'cpp', 'cmake' }, desc = 'CMake: select [K]it' },
    { '<leader>mo', '<cmd>CMakeOpenExecutor<cr>',      ft = { 'c', 'cpp', 'cmake' }, desc = 'CMake: [O]pen executor window' },
    { '<leader>mx', '<cmd>CMakeStopExecutor<cr>',      ft = { 'c', 'cpp', 'cmake' }, desc = 'CMake: stop e[X]ecutor' },
    { '<leader>mi', '<cmd>CMakeSettings<cr>',          ft = { 'c', 'cpp', 'cmake' }, desc = 'CMake: settings popup' },
    -- stylua: ignore end
  },
  opts = {
    cmake_command = 'cmake',
    ctest_command = 'ctest',
    -- Honour `CMakePresets.json` when the project ships one; falls back to
    -- kits/variants otherwise.
    cmake_use_preset = true,
    -- Re-configure automatically after writing a `CMakeLists.txt`.
    cmake_regenerate_on_save = true,
    -- `clangd` (see `lsp-config.lua`) needs `compile_commands.json`; without
    -- this flag it only ever sees the fallback flags.
    cmake_generate_options = { '-DCMAKE_EXPORT_COMPILE_COMMANDS=1' },
    cmake_build_options = {},
    -- One directory per build type, so switching Debug <-> Release does not
    -- force a full rebuild. Supports `${kit}` / `${kitGenerator}` /
    -- `${variant:xx}` macros; the upstream default is `out/${variant:buildType}`.
    cmake_build_directory = 'build/${variant:buildType}',
    cmake_compile_commands_options = {
      -- Symlink the generated `compile_commands.json` into the project root so
      -- clangd finds it with no per-project `.clangd` file.
      action = 'soft_link',
      target = vim.uv.cwd,
    },
    cmake_kits_path = nil,
    cmake_variants_message = {
      short = { show = true },
      long = { show = true, max_length = 40 },
    },
    -- `:CMakeDebug` hands off to nvim-dap (`debug.lua`). codelldb is *not* in
    -- mason-nvim-dap's `ensure_installed` there -- add it, or `:MasonInstall
    -- codelldb`, before this will attach.
    cmake_dap_configuration = {
      name = 'cpp',
      type = 'codelldb',
      request = 'launch',
      stopOnEntry = false,
      runInTerminal = true,
      console = 'integratedTerminal',
    },
    -- NOTE: cmake-tools can drive overseer.nvim or toggleterm.nvim instead, but
    -- neither is installed in this config. So: build output goes to the
    -- quickfix list (which trouble.nvim can then render), and the program
    -- itself runs in a plain terminal split.
    cmake_executor = {
      name = 'quickfix',
      opts = {},
      default_opts = {
        quickfix = {
          show = 'always',
          position = 'belowright',
          size = 10,
          encoding = 'utf-8',
          auto_close_when_success = true,
        },
      },
    },
    cmake_runner = {
      name = 'terminal',
      opts = {},
      default_opts = {
        terminal = {
          name = 'Main Terminal',
          -- Must be unique and non-blank, otherwise the terminals misbehave.
          prefix_name = '[CMakeTools]: ',
          split_direction = 'horizontal',
          split_size = 11,
          single_terminal_per_instance = true,
          single_terminal_per_tab = true,
          keep_terminal_static_location = true,
          auto_resize = true,
          start_insert = false,
          focus = false,
          do_not_add_newline = false,
        },
      },
    },
    cmake_notifications = {
      runner = { enabled = true },
      executor = { enabled = true },
      spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
      refresh_rate_ms = 100,
    },
    -- Shows the target owning the current file at the right-hand edge.
    cmake_virtual_text_support = true,
    cmake_use_scratch_buffer = false,
  },
}
