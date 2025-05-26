return 
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = "all",                    -- Install all supported languages
        highlight = {
          enable = true,                             -- Enable syntax highlighting
          additional_vim_regex_highlighting = false, -- Use Tree-sitter only
          disable = { "latex", },
        },
        indent = {
          enable = true, -- Enable Tree-sitter-based indentation
        },
      })
    end,
  }
