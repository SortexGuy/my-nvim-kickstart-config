return {
	{
		-- Theme inspired by Atom
		'catppuccin/nvim',
		name = 'catppuccin',
		priority = 1000,
		opts = {
			flavour = 'mocha',
			background = {
				light = 'frappe',
				dark = 'mocha',
			},
			transparent_background = false,
			show_end_od_buffer = true,
			term_colors = true,
		},
	},
	{
		'loctvl842/monokai-pro.nvim',
		name = 'monokai-pro',
		priority = 1000,
		opts = {
			transparent_background = false,
			terminal_colors = true,
			devicons = true, -- highlight the icons of `nvim-web-devicons`
			styles = {
				comment = { italic = true },
				keyword = { italic = true }, -- any other keyword
				type = { italic = true }, -- (preferred) int, long, char, etc
				-- storageclass = { italic = true },  -- static, register, volatile, etc
				-- structure = { italic = true },     -- struct, union, enum, etc
				-- parameter = { italic = true },     -- parameter pass in function
				annotation = { italic = true },
				tag_attribute = { italic = true }, -- attribute of tag in reactjs
			},
			filter = "spectrum",       -- classic | octagon | pro | machine | ristretto | spectrum
			-- inc_search = "background",           -- underline | background
			background_clear = {
				"telescope",
			},
			plugins = {
				bufferline = {
					underline_selected = false,
					underline_visible = false,
				},
				indent_blankline = {
					context_highlight = "pro", -- default | pro
					context_start_underline = true,
				},
			},
		},
	},

	-- Themes
	{
		'zaldih/themery.nvim',
		name = 'themery',
		priority = 1000,
		opts = {
			livePreview = true,
			themeConfigFile = "~/.config/nvim/lua/custom/theme.lua",
			themes = {
				{ name = "Catppuccin Mocha", colorscheme = "catppuccin", },
				{ name = "Monokai Pro",      colorscheme = "monokai-pro", },
			},
		},
	},
};
