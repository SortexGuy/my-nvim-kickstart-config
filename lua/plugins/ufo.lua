---@module 'lazy'
---@type LazySpec
return {
  'kevinhwang91/nvim-ufo',
  -- ufo owns 'foldmethod'/'foldexpr' for the whole config -- `treesitter.lua`
  -- deliberately does not set a treesitter foldexpr so the two don't fight.
  -- The LSP folding-range capability ufo needs is declared in
  -- `lsp-config.lua` via `vim.lsp.config('*', ...)`.
  event = { 'BufReadPost', 'BufNewFile' },
  dependencies = { 'kevinhwang91/promise-async' },
  opts = {
    filetype_exclude = {
      'help',
      'alpha',
      'dashboard',
      'neo-tree',
      'Trouble',
      'lazy',
      'mason',
    },
  },
  config = function(_, opts)
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('local_detach_ufo', { clear = true }),
      pattern = opts.filetype_exclude,
      callback = function()
        require('ufo').detach()
      end,
    })

    vim.opt.foldenable = true
    vim.opt.foldcolumn = 'auto:3' -- '0' is not bad
    vim.opt.foldlevelstart = 99
    vim.opt.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
    vim.opt.fillchars = [[eob: ,fold: ,foldopen:,foldsep:|,foldclose:]]
    -- vim.opt.fillchars = [[eob: ,fold: ,foldopen:,foldsep:|,foldclose:]]

    require('ufo').setup(opts)
  end,
}
