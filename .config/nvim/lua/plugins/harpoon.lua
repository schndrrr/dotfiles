return {
  "ThePrimeagen/harpoon",
  branch = "master",   -- Use "harpoon2" for Harpoon 2
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    -- Require the modules
    local mark = require("harpoon.mark")
    local ui = require("harpoon.ui")

    -- Set up keymappings
    vim.keymap.set("n", "<leader>a", mark.add_file, { desc = "Harpoon: Add file" })
    vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu, { desc = "Harpoon: Toggle menu" })

    -- Navigate to specific marks (1-4)
    -- vim.keymap.set("n", "<C-z>", function() ui.nav_file(1) end, { desc = "Harpoon: Go to file 1" })
    -- vim.keymap.set("n", "<C-u>", function() ui.nav_file(2) end, { desc = "Harpoon: Go to file 2" })
    -- vim.keymap.set("n", "<C-i>", function() ui.nav_file(3) end, { desc = "Harpoon: Go to file 3" })
    -- vim.keymap.set("n", "<C-o>", function() ui.nav_file(4) end, { desc = "Harpoon: Go to file 4" })

    -- Cycle through marks
    vim.keymap.set("n", "<C-n>", ui.nav_next, { desc = "Harpoon: Next file" })
    vim.keymap.set("n", "<C-p>", ui.nav_prev, { desc = "Harpoon: Previous file" })
  end,
}
