-- ~/.config/nvim/init.lua vim.o.foldmethod = "indent"
-- foldsettings for ufo
vim.o.foldcolumn = '1' -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

vim.g.mapleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")
-- ========== Plugin-Konfiguration ==========
require("Comment").setup()
require("nvim-autopairs").setup {}
  require('ufo').setup({
    provider_selector = function(bufnr, filetype, buftype)
        return {'treesitter', 'indent'}
    end
})

vim.opt.termguicolors = true

-- ========== Sonstige Neovim-Einstellungen ==========
-- Zeilennummern
vim.opt.number = true
vim.opt.relativenumber = true

-- Spaces > Tabs
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

-- Suchverhalten
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Dateipfade bei Splits
vim.opt.splitright = true
vim.opt.splitbelow = true
-- ========== Keybindings ==========

vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })
vim.keymap.set("i", "jk", "<ESC>", { noremap = true })

-- Disable this for a while so i can build better habbits
-- vim.keymap.set("n", "J", "5j", { noremap = true })
-- vim.keymap.set("n", "K", "5k", { noremap = true })

vim.keymap.set("n", "<c-k>", ":wincmd k<CR>")
vim.keymap.set("n", "<c-j>", ":wincmd j<CR>")
vim.keymap.set("n", "<c-h>", ":wincmd h<CR>")
vim.keymap.set("n", "<c-l>", ":wincmd l<CR>")

vim.keymap.set("n", "<leader>Z", ":CodeCompanionActions<CR>")
vim.keymap.set("n", "<leader>r", ":b#<CR>")
-- vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")

vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

-- ========= nvim-cmp Setup =========
local cmp = require("cmp")

cmp.setup({
  snippet = {
    -- Hier definierst du, wie Snippets expanded werden (z. B. via LuaSnip)
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },
  mapping = {
    -- Beispielmappings für Tab- oder Enter-Steuerung
    -- Hier nur ein Minimalbeispiel:
    ["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    ["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
    ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Enter wählt Vorschlag aus
  },
  sources = cmp.config.sources({
    { name = "nvim_lsp" }, -- LSP-Vorschläge
    { name = "luasnip" },  -- Snippet-Vorschläge
  }, {
    { name = "buffer" },   -- optional: Vorschläge aus dem offenen Buffer
    { name = "path" },     -- optional: Dateipfade, wenn du tippen willst
  }),
})

local wk = require("which-key")
vim.api.nvim_create_autocmd({"LspAttach"}, {
  callback = function()
    wk.register({
      g = {
        name = "Goto",
        d = { vim.lsp.buf.definition, "Go to definition" },
        r = { require("telescope.builtin").lsp_references,
          "Open a telescope window with references" },
      },
    }, { buffer = 0 })
  end
})
