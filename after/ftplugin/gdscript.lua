local port = os.getenv 'GDScript_Port' or '6005'
local cmd = vim.lsp.rpc.connect('127.0.0.1', tonumber(port))
local pipe
if jit.os == 'Windows' then
  pipe = [[C:\Temp\godot.pipe]]
else
  pipe = '/home/sortextg/tmp/godot.pipe' -- I use /tmp/godot.pipe
end

vim.lsp.start {
  name = 'Godot',
  cmd = cmd,
  root_dir = vim.fs.dirname(
    vim.fs.find({ 'project.godot', '.git' }, { upward = true })[1]
  ),
  on_attach = function(client, bufnr)
    vim.api.nvim_command('echo serverstart("' .. pipe .. '")')
  end,
}
