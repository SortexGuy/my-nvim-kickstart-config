return {
  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',
  {
    'ThePrimeagen/harpoon',
    branch = "harpoon2",
    deps = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      local harpoon = require 'harpoon'
      harpoon:setup()

      vim.keymap.set("n", "<leader>ma", function() harpoon:list():append() end)
      vim.keymap.set("n", "<A-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

      vim.keymap.set("n", "<A-h>", function() harpoon:list():select(1) end)
      vim.keymap.set("n", "<A-u>", function() harpoon:list():select(2) end)
      vim.keymap.set("n", "<A-i>", function() harpoon:list():select(3) end)
      vim.keymap.set("n", "<A-o>", function() harpoon:list():select(4) end)

      -- vim.keymap.set("n", "<A-t>", function() harpoon:list(): end)

      -- Toggle previous & next buffers stored within Harpoon list
      vim.keymap.set("n", "<A-S-P>", function() harpoon:list():prev() end)
      vim.keymap.set("n", "<A-S-N>", function() harpoon:list():next() end)

      -- basic telescope configuration
      local conf = require("telescope.config").values
      local function toggle_telescope(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(file_paths, item.value)
        end

        require("telescope.pickers").new({}, {
          prompt_title = "Harpoon",
          finder = require("telescope.finders").new_table({
            results = file_paths,
          }),
          previewer = conf.file_previewer({}),
          sorter = conf.generic_sorter({}),
        }):find()
      end

      vim.keymap.set("n", "<A-S-E>", function() toggle_telescope(harpoon:list()) end,
        { desc = "Open harpoon window" })
    end,
  },
}
