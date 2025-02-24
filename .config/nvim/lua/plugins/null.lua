return
{
  "jose-elias-alvarez/null-ls.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "jay-babu/mason-null-ls.nvim",
  },
  config = function()
    -- null-ls und mason-null-ls Setup
    local null_ls = require("null-ls")

    -- Mason-null-ls Setup
    require("mason-null-ls").setup({
      -- Hier kannst du Pakete angeben, die automatisch installiert werden sollen
      ensure_installed = { "prettierd" },
      automatic_installation = true,   -- installiert fehlende Tools automatisch
    })

    -- null-ls Setup
    null_ls.setup({
      sources = {
        -- Prettier via 'prettierd' (schneller Daemon)
        null_ls.builtins.formatting.prettierd,
      },
    })
  end,
}
