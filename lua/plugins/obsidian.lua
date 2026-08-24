---@module 'lazy'
---@type LazySpec
return {
  {
    -- NOTE: `epwalsh/obsidian.nvim` was archived by its author; development
    -- continues at `obsidian-nvim/obsidian.nvim`. Still disabled here, but
    -- pointed at the maintained fork so enabling it doesn't pull dead code.
    'obsidian-nvim/obsidian.nvim',
    -- 'epwalsh/obsidian.nvim',
    enabled = false,
    version = '*',
    lazy = true,
    ft = 'markdown',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    opts = {
      workspaces = {
        {
          name = 'Absolute',
          path = '~/Documents/Obsidian/Absolute',
        },
      },
    },
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    enabled = true,
    ft = { 'markdown' },
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = 'cd app && yarn install',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
    ft = { 'markdown' },
  },
}
