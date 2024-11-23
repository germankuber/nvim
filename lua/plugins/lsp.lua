return {
    {
        "neovim/nvim-lspconfig",
        config = function()
            require("lspconfig").rust_analyzer.setup({
                on_attach = function(client, bufnr)
                    -- Keymap for hover documentation
                    vim.keymap.set("n", "K", vim.lsp.buf.hover,
                                   {buffer = bufnr, silent = true})

                    -- Enable inlay hints
                    if client.server_capabilities.inlayHintProvider then
                        vim.lsp.buf.inlay_hint(bufnr, true)
                    end
                end,
                settings = {
                    ["rust-analyzer"] = {
                        cargo = {allFeatures = true}, -- Enable all Cargo features
                        checkOnSave = {command = "clippy"}, -- Use Clippy for linting
                        procMacro = {enable = true}, -- Enable procedural macros
                        inlayHints = {
                            locationLinks = true,
                            typeHints = true, -- Show type hints
                            chainingHints = true, -- Show hints for method chaining
                            parameterHints = true -- Show hints for parameters
                        }
                    }
                }
            })
        end
    }
}
