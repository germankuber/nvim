return {
{
    "stevearc/conform.nvim",
    dependencies = "williamboman/mason.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          python      = { "isort", "black" },
          lua         = { "stylua" },
          javascript  = { "prettierd" },
          typescript  = { "prettierd" },
          json        = { "prettierd" },
          sh          = { "shfmt" },
          cs          = { "csharpier" },
        },
        format_on_save = {
          timeout_ms = 5000,
          lsp_fallback = true,
        },
      })
    end,
  },
  -- omnisharp-extended-lsp.nvim removed - now using roslyn.nvim
  {
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
  {
    "pmizio/typescript-tools.nvim",
    dependencies = {"nvim-lua/plenary.nvim"},
    opts = {}
  },
}
