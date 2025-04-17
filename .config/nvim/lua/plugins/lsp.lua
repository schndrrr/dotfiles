return
{
  {
    'mrcjkb/rustaceanvim',
    version = '^6', -- Recommended
    lazy = false,   -- This plugin is already lazy
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local cmp_nvim_lsp = require("cmp_nvim_lsp")

      -- Mason Setup
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls" },
        automatic_installation = true,
      })

      local capabilities = cmp_nvim_lsp.default_capabilities()
      local on_attach = function(client, bufnr)
        local opts = { noremap = true, silent = true, buffer = bufnr }
        -- Gehe zur Definition
        vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = bufnr, noremap = true, silent = true })
        -- vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = bufnr, noremap = true, silent = true })
        vim.keymap.set("n", "gi", "<cmd>Telescope lsp_references<CR>",opts)
        -- vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr, noremap = true, silent = true })
      end

      vim.diagnostic.config({ virtual_text = true })
      vim.keymap.set("n", "<leader>k", vim.lsp.buf.hover, {})

      -- TSServer Setup
      lspconfig.ts_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })

    -- "Verbesserte" Capabilities für Autocompletion
    local capabilities = cmp_nvim_lsp.default_capabilities()


    -- Python Setup (Pyright)
    lspconfig.pyright.setup({
      on_attach = on_attach,
      capabilities = capabilities,
    })

    -- Lua Setup
    lspconfig.lua_ls.setup({
      on_attach = on_attach,
      capabilities = capabilities,
      settings = { -- typisches Lua "neovim" Setup
        Lua = {
          diagnostics = { globals = { "vim" } },
        },
      },
    })
    end
  },
  }
