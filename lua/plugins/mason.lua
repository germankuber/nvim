return {
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate", -- Automatically update Mason registry
        dependencies = {
            "williamboman/mason-lspconfig.nvim" -- Bridges Mason with lspconfig
        },
        config = function()
            -- Setup Mason
            require("mason").setup()

            -- Setup Mason-LSPConfig
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
                    "ts_ls" -- TypeScript/JavaScript
                },
                automatic_installation = true -- Automatically install servers
            })
        end
    }

}
