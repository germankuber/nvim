return {
{
    "stevearc/conform.nvim",
    dependencies = "williamboman/mason.nvim",
    config = function()
      local conform = require("conform")
      conform.setup({
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
            command = vim.fn.expand("~/.dotnet/tools/csharpier"),
            args = function(_, ctx)
              return { "format", "--write-stdout", "--stdin-path", ctx.filename }
            end,
            stdin = true,
            cwd = require("conform.util").root_file({ ".csharpierrc.json", "*.sln", "*.csproj" }),
          },
        },
        format_on_save = function(bufnr)
          local ft = vim.bo[bufnr].filetype
          -- C# uses csharpier only, no LSP fallback
          if ft == "cs" then
            return {
              timeout_ms = 5000,
              lsp_fallback = false,
            }
          end
          return {
            timeout_ms = 3000,
            lsp_fallback = true,
          }
        end,
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
