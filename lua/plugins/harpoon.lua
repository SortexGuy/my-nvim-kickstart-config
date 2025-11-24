return {
  'ThePrimeagen/harpoon',
  cond = not vim.g.vscode,
  name = 'harpoon',
  branch = 'harpoon2',
  config = function()
    local harpoon = require 'harpoon'
    -- REQUIRED
    harpoon:setup()
    -- REQUIRED
    local function nmap(map, func, desc)
      vim.keymap.set('n', map, func, { desc = desc })
    end

    -- nmap("<leader>mf", function() harpoon:list():append() end, 'Harpoon: Mark file')
    nmap('<A-f>', function()
      harpoon:list():add()
    end, 'Harpoon: Mark file')
    nmap('<A-m>', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, 'Harpoon: Quick menu')

    nmap('<A-h>', function()
      harpoon:list():select(1)
    end, 'Harpoon: Go to mark 1')
    nmap('<A-u>', function()
      harpoon:list():select(2)
    end, 'Harpoon: Go to mark 2')
    nmap('<A-i>', function()
      harpoon:list():select(3)
    end, 'Harpoon: Go to mark 3')
    nmap('<A-o>', function()
      harpoon:list():select(4)
    end, 'Harpoon: Go to mark 4')

    -- Toggle previous & next buffers stored within Harpoon list
    nmap('<A-p>', function()
      harpoon:list():prev()
    end, 'Harpoon: Go to next mark')
    nmap('<A-n>', function()
      harpoon:list():next()
    end, 'Harpoon: Go to prev mark')

    -- Not harpooned but also good
    nmap('<A-t>', function()
      vim.cmd 'term'
    end, 'Harpoon: Go to prev mark')
  end,
}
