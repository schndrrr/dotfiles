-- ~/.config/nvim/init.lua vim.o.foldmethod = "indent"
vim.o.foldlevel = 99

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

vim.keymap.set("n", "<c-k>", ":wincmd k<CR>")
vim.keymap.set("n", "<c-j>", ":wincmd j<CR>")
vim.keymap.set("n", "<c-h>", ":wincmd h<CR>")
vim.keymap.set("n", "<c-l>", ":wincmd l<CR>")
require("lazy").setup("plugins")
-- ========== Plugin-Konfiguration ==========
-- Beispiel: Comment
require("Comment").setup()
-- Beispiel: nvim-autopairs
require("nvim-autopairs").setup {}

vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
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

-- codecompanion
vim.keymap.set("n", "<leader>Z", ":CodeCompanionActions<CR>")


vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })
-- "jk" im Insert-Modus -> ESC
vim.keymap.set("i", "jk", "<ESC>", { noremap = true })

-- "J" im Normal-Modus -> 5 Zeilen nach unten
vim.keymap.set("n", "J", "5j", { noremap = true })

-- "K" im Normal-Modus -> 5 Zeilen nach oben
vim.keymap.set("n", "K", "5k", { noremap = true })


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

