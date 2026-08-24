-- [[ Platform / environment detection ]]
-- Everything here has to run *before* plugins load, because it decides which
-- shell, GUI settings and servers the rest of the config sees.
--
-- Extracted out of `lua/options.lua` so that file stays a plain option list.

-- [[ Windows ]]
-- Prefer PowerShell Core over cmd.exe so `:!`, `:terminal` and plugin `build`
-- steps behave consistently with the Unix side.
if jit.os == 'Windows' and vim.fn.executable 'pwsh' == 1 then
  vim.o.shell = 'pwsh'
  vim.o.shellcmdflag =
    '-NoLogo -NoProfile -ExecutionPolicy Bypass -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
end

-- [[ Godot ]]
-- Godot talks to an external editor over a unix socket / named pipe that it
-- expects to find next to `project.godot`. Start one if we opened Neovim from
-- inside a Godot project (or one directory below it) and it isn't running yet.
local function start_godot_server()
  local cwd = vim.fn.getcwd()
  -- paths to check for project.godot file
  local paths_to_check = { '/', '/../' }

  for _, value in ipairs(paths_to_check) do
    local godot_project_path = cwd .. value
    if vim.uv.fs_stat(godot_project_path .. 'project.godot') then
      -- check if server is already running in godot project path
      if not vim.uv.fs_stat(godot_project_path .. 'server.pipe') then
        vim.fn.serverstart(godot_project_path .. 'server.pipe')
      end
      return
    end
  end
end

start_godot_server()

-- [[ Neovide ]]
if vim.g.neovide then
  vim.g.neovide_no_idle = true
  vim.g.neovide_refresh_rate = 60
  -- Renamed in Neovide 0.13; `neovide_transparency` is the deprecated spelling.
  vim.g.neovide_opacity = 0.85
  -- vim.g.neovide_transparency = 0.85
  vim.o.guifont = 'JetBrainsMono Nerd Font:h14'
end
