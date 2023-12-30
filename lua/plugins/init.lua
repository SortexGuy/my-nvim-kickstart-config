return {
	require 'plugins.misc-first',
	require 'plugins.lsp-config',
	require 'plugins.nvim-cmp',
	require 'plugins.which-key',
	require 'plugins.gitsigns',
	require 'plugins.themes',
	{
		-- Set lualine as statusline
		'nvim-lualine/lualine.nvim',
		-- See `:help lualine.txt`
		opts = {
			options = {
				icons_enabled = false,
				-- theme = 'onedark',
				component_separators = '|',
				section_separators = '',
			},
		},
	},
	{
		-- Add indentation guides even on blank lines
		'lukas-reineke/indent-blankline.nvim',
		-- Enable `lukas-reineke/indent-blankline.nvim`
		-- See `:help indent_blankline.txt`
		main = 'ibl',
		opts = {
			indent = { char = '┊' },
			scope = { enabled = true },
		},
	},
	-- "gc" to comment visual regions/lines
	{ 'numToStr/Comment.nvim', opts = {} },
	require 'plugins.telescope',
	require 'plugins.treesitter',
	require 'plugins.oil',
	{
		"Exafunction/codeium.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"hrsh7th/nvim-cmp",
		},
		config = function()
			require("codeium").setup({
			})
		end
	},
	'ThePrimeagen/vim-be-good',
};
