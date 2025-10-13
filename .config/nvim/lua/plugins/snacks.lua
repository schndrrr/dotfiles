return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	config = function()
		require("snacks").setup({
			picker = {
				enabled = true,
			},
		})
	end,
	keys = {
		{
			"<Leader>U",
			function()
				require("snacks").picker.buffers()
			end,
			desc = "Find open buffers",
		},
		{
			"<Leader>f",
			function()
				require("snacks").picker.files()
			end,
			desc = "find files",
		},
		{
			"<Leader>g",
			function()
				require("snacks").picker.grep()
			end,
			desc = "live grep files",
		},
		{
			"<Leader>cc",
			function()
				require("snacks").picker.colorschemes()
			end,
			desc = "Change Colorscheme on the fly",
		},
		{
			"<Leader>h",
			function()
				Snacks.picker.help()
			end,
			desc = "Help tags",
		},
		{
			"<Leader>R",
			function()
				Snacks.picker.resume()
			end,
			desc = "Resume last picker",
		},
		{
			"<Leader>ss",
			function()
				Snacks.picker.lsp_symbols()
			end,
			desc = "LSP symbols",
		},
		{
			"<Leader>sd",
			function()
				Snacks.picker.diagnostics()
			end,
			desc = "Diagnostics",
		},
		{
			'<leader>s"',
			function()
				Snacks.picker.registers()
			end,
			desc = "Registers",
		},
		{
			"<leader>s/",
			function()
				Snacks.picker.search_history()
			end,
			desc = "Search History",
		},
		{
			"<leader>sm",
			function()
				Snacks.picker.marks()
			end,
			desc = "Marks",
		},
	},
}
