return {
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate", -- Automatically update Mason registry
        dependencies = {
            "williamboman/mason-lspconfig.nvim" -- Bridges Mason with lspconfig
        },
        config = function()
            require("mason").setup()

            require("mason-lspconfig").setup({
                ensure_installed = {
                    "solidity_ls",
                    "efm",
                    "rust_analyzer", -- j
                    "dockerls", -- Docker
                    "bashls", -- Bash
                    "jsonls", -- JSON
                    "taplo", -- TOML
                    "solidity_ls", -- Solidity
                    "pyright", -- Python
                    "ts_ls", -- TypeScript/JavaScript
                    "omnisharp"
                },
                automatic_installation = true -- Automatically install servers
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
