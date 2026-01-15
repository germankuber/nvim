return {
{
    "stevearc/conform.nvim",
    dependencies = "williamboman/mason.nvim",
    opts = {
      formatters_by_ft = {
        python      = { "isort", "black" },
        lua         = { "stylua" },
        javascript  = { "prettierd" },
        typescript  = { "prettierd" },
        json        = { "prettierd" },
        sh          = { "shfmt" },
        cs          = { "csharpier" },
      },
      formatters = {
        csharpier = {
          command = "csharpier",
          args = { "format", "--write-stdout" },
          stdin = true,
          cwd = require("conform.util").root_file({ ".csharpierrc.json", ".csharpierrc", "*.sln", "*.csproj" }),
        },
      },
      -- Format on save
      format_on_save = {
        timeout_ms = 5000,
        lsp_fallback = true,
      },
    },
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
