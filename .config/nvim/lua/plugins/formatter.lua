return {
  'stevearc/conform.nvim',
  opts = {},
  config = function ()
    require("conform").setup({
  formatters_by_ft = {
    lua = { "prettier" },
    -- Conform will run multiple formatters sequentially
    python = { "isort", "black" },
    -- You can customize some of the format options for the filetype (:help conform.format)
    rust = { "rustfmt", lsp_format = "fallback" },
    -- Conform will run the first available formatter
    javascript = { "prettierd", "prettier", stop_after_first = true },
    less = { "prettierd", "prettier", stop_after_first = true },
    typescript = { "prettierd", "prettier", stop_after_first = true },
    json = { "prettierd", "prettier", stop_after_first = true },

  },
})
vim.keymap.set("n", "<leader>F", function()
  require("conform").format({ async = true })
end, { noremap = true, silent = true, desc = "Format current buffer" })
  end
}
