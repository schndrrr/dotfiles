return {
  'stevearc/conform.nvim',
  keys = {
    {
      '<Leader>F',
      function()
        require('conform').format({ async = true })
      end,
      desc = 'Format with Conform',
    },
  },
  config = function()
    require('conform').setup {
      format_on_save = false,
      formatters_by_ft = {
        lua         = { 'stylua' },
        python      = { 'black' },
        sh          = { 'shfmt' },
        markdown    = { 'prettier' },
        yaml        = { 'prettier' },
        json        = { 'prettier' },
        javascript  = { 'prettier' },
        typescript  = { 'prettier' },
        javascriptreact  = { 'prettier' },
        typescriptreact  = { 'prettier' },
        html        = { 'prettier' },
        css         = { 'prettier' },
        scss        = { 'prettier' },
        less        = { 'prettier' },
        graphql     = { 'prettier' },
        go          = { 'goimports' },
        rust        = { 'rustfmt' },
        c           = { 'clang_format' },
        cpp         = { 'clang_format' },
        sql         = { 'sql_formatter' },
        vue         = { 'prettier' },
      },
    }
  end,
}

