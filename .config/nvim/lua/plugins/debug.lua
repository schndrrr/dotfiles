return {
	"mfussenegger/nvim-dap",
	dependencies = { "rcarriga/nvim-dap-ui", "nvim-neotest/nvim-nio" },
	config = function()
		local dap, dapui = require("dap"), require("dapui")

    dapui.setup({})

		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end

		vim.keymap.set("n", "<Leader>dc", dap.continue, {})
		vim.keymap.set("n", "<Leader>db", dap.toggle_breakpoint, {})
		vim.keymap.set("n", "<Leader>du", dapui.toggle, {})

		dap.adapters["pwa-node"] = {
			type = "server",
			host = "localhost",
			port = "${port}",
			executable = {
				command = "node",
				args = { "../../../.jsdebugger/js-debug/src/dapDebugServer.js", "${port}" },
			},
		}
		dap.configurations.javascript = {
			{
				type = "pwa-node",
				request = "attach",
				name = "Auto Attach",
				cwd = vim.fn.getcwd(),
			},
		}
	end,
}
