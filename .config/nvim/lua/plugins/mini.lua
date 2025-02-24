return {
  'echasnovski/mini.nvim',
  version = false,
  config = function()
    require('mini.map').setup()
    require('mini.ai').setup()
    require('mini.surround').setup()

    vim.keymap.set('n', '<leader>mc', MiniMap.close)
    vim.keymap.set('n', '<leader>mf', MiniMap.toggle_focus)
    vim.keymap.set('n', '<leader>mo', MiniMap.open)
    vim.keymap.set('n', '<leader>mr', MiniMap.refresh)
    vim.keymap.set('n', '<leader>ms', MiniMap.toggle_side)
    vim.keymap.set('n', '<leader>mt', MiniMap.toggle)
  end,
}
