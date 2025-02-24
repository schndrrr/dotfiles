return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- options: latte, frappe, macchiato, mocha
        term_colors = true,
        transparent_background = true,
        integrations = {
          treesitter = true,
          lsp_trouble = true,
          lualine = false, -- Disable lualine to avoid the error
          cmp = true,
          gitsigns = true,
          telescope = true,
          neogit = true,
          notify = false,
          nvimtree = {
            enabled = true,
            show_root = false,
          },
          dashboard = true,
          markdown = true,
          which_key = true,
        },
      })
      vim.cmd.colorscheme "catppuccin"
    end,
  }
