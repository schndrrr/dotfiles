return {
	{
		"mrcjkb/rustaceanvim",
		version = "^6", -- Recommended
		lazy = false, -- This plugin is already lazy
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
			local mason_registry = require("mason-registry")

			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "vtsls", "vue_ls" },
				automatic_installation = true,
			})

			local capabilities = cmp_nvim_lsp.default_capabilities()
			local on_attach = function(client, bufnr) end

			vim.diagnostic.config({ virtual_text = true })
			vim.keymap.set("n", "<leader>k", vim.lsp.buf.hover, {})

			local vue_language_server_path = vim.fn.stdpath("data")
				.. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
			local vue_plugin = {
				name = "@vue/typescript-plugin",
				location = vue_language_server_path,
				languages = { "vue" },
				configNamespace = "typescript",
			}
			lspconfig.vtsls.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				init_options = {
					plugins = { vue_plugin },
				},
				filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
			})

			lspconfig.vue_ls.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				-- more config can be added if needed
			})

			-- Existing setups...
			lspconfig.pyright.setup({
				on_attach = on_attach,
				capabilities = capabilities,
			})

			lspconfig.lua_ls.setup({
				on_attach = on_attach,
				capabilities = capabilities,
				settings = {
					Lua = { diagnostics = { globals = { "vim" } } },
				},
			})
		end,
	},
}
