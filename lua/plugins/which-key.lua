-- Shows pending keybinds in a popup.
--
-- This is also the index of the leader prefixes this config uses -- add a group
-- here whenever a new `<leader>x` namespace is introduced, otherwise the popup
-- shows a bare key with no label.
---@module 'lazy'
---@type LazySpec
return {
  'folke/which-key.nvim',
  event = 'VeryLazy', -- was 'VimEnter'; nothing needs it before the UI settles
  opts = {},
  config = function(_, opts)
    local wk = require 'which-key'
    wk.setup(opts)

    -- document existing key chains
    wk.add {
      { '<leader>c', group = '[C]ode' },
      { '<leader>c_', hidden = true },
      { '<leader>d', group = '[D]ocument' },
      { '<leader>d_', hidden = true },
      -- conform.nvim: <leader>ff format, <leader>fd/fb/fe disable/enable
      { '<leader>f', group = '[F]ormat' },
      { '<leader>f_', hidden = true },
      { '<leader>g', group = '[G]it' },
      { '<leader>g_', hidden = true },
      { '<leader>h', group = 'Git [H]unk' },
      { '<leader>h_', hidden = true },
      -- nvim-jdtls: buffer-local, only bound in Java buffers
      { '<leader>j', group = '[J]ava (jdtls)' },
      { '<leader>j_', hidden = true },
      -- cmake-tools.nvim: buffer-local, only bound in c/cpp/cmake buffers
      { '<leader>m', group = 'C[M]ake' },
      { '<leader>m_', hidden = true },
      { '<leader>r', group = '[R]ename' },
      { '<leader>r_', hidden = true },
      { '<leader>s', group = '[S]earch' },
      { '<leader>s_', hidden = true },
      -- toggles (blame, deleted, inlay hints) plus tsc.nvim's <leader>te/to/tc
      { '<leader>t', group = '[T]oggle / [T]ypecheck' },
      { '<leader>t_', hidden = true },
      { '<leader>w', group = '[W]orkspace' },
      { '<leader>w_', hidden = true },
      -- trouble.nvim
      { '<leader>x', group = 'Trouble (diagnostics)' },
      { '<leader>x_', hidden = true },
    }

    -- register which-key VISUAL mode
    -- required for visual <leader>hs (hunk stage) to work
    wk.add({
      { '<leader>', group = 'VISUAL <leader>', mode = 'v' },
      { '<leader>h', desc = 'Git [H]unk', mode = 'v' },
    }, { mode = 'v' })
  end,
}
