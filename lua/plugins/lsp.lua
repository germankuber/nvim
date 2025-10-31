return {
{
    "stevearc/conform.nvim",
    dependencies = "williamboman/mason.nvim",
    opts = {
      -- qué usar por filetype
      formatters_by_ft = {
        python      = { "isort", "black" },
        lua         = { "stylua" },
        javascript  = { "prettierd" },
        typescript  = { "prettierd" },
        json        = { "prettierd" },
        sh          = { "shfmt" },
        cs          = { "csharpier", "dotnet_format" },
      },
      notify_on_error = true,
      -- Ajustes específicos de formateadores
      formatters = {
        -- Evitar que CSharpier haga saltos de línea tan agresivos
        csharpier = {
          prepend_args = { "--width", "140" },
        },
      },

      -- auto‑formato al guardar (opcional)
      -- format_on_save = function(bufnr)
      --   return { lsp_fallback = true, timeout_ms = 3000 }
      -- end,
    },
  },{
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "b0o/schemastore.nvim",
    },
    config = function()
      require "configs.lspconfig"
    end,
  },
{ "stevanmilic/nvim-lspimport" },
 {"b0o/schemastore.nvim"}, {
    "pmizio/typescript-tools.nvim",
    dependencies = {"nvim-lua/plenary.nvim", "neovim/nvim-lspconfig"},
    opts = {}
}}
