return {
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate", -- Automatically update Mason registry
        dependencies = {
            "neovim/nvim-lspconfig", -- Must be loaded BEFORE mason-lspconfig
            "williamboman/mason-lspconfig.nvim", -- Bridges Mason with lspconfig
            "jay-babu/mason-nvim-dap.nvim" -- Bridges Mason with nvim-dap
        },
        config = function()
            require("mason").setup()

            require("mason-lspconfig").setup({
                ensure_installed = {
                    "solidity_ls",
                    "efm",
                    "rust_analyzer",
                    "dockerls", -- Docker
                    "bashls", -- Bash
                    "jsonls", -- JSON
                    "taplo", -- TOML
                    "pyright", -- Python
                    "ts_ls", -- TypeScript/JavaScript
                    "omnisharp", -- C# (OmniSharp)
                },
                automatic_installation = true,
            })

            require("mason-nvim-dap").setup({
                ensure_installed = {
                    "netcoredbg", -- .NET Core debugger
                },
                automatic_installation = true,
            })
        end
    },
 {
    "jay-babu/mason-null-ls.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "nvimtools/none-ls.nvim",   -- null‑ls renombrado
    },
    opts = {
      ensure_installed = {
        -- python
        "black",
        "isort",
        "ruff",

        -- lua
        "stylua",

        -- web
        "prettierd",

        -- shell
        "shfmt",
        "shellcheck",
      },
      automatic_installation = true,
    },
  },

}
