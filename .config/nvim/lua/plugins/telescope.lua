return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim"
  },
  keys = {
    { 
      "<Leader>U",
      "<cmd>Telescope buffers<cr>",
      desc = "Find open buffers"
    },
    {
      "<Leader>f",
      "<cmd>Telescope find_files<cr>",
      desc = "find files"
    },
    {
      "<Leader>g",
      "<cmd>Telescope live_grep<cr>",
      desc = "live grep files"
    }
  },
  config = function()
    require("telescope").setup({
      defaults = {
        vimgrep_arguments = {
          "rg", "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case",
          "--hidden", "--glob", "!.git/"
        },
        file_ignore_patterns = { "node_modules", ".git/" },
        prompt_prefix = "> ",
        selection_caret = "> ",
        path_display = { "truncate" },
      },
      pickers = {
        live_grep = {
          additional_args = function(opts)
            return { "--hidden", "--glob", "!.git/" }
          end,
        },
      },
    })
  end,
}
