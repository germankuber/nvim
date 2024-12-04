local null_ls = require("null-ls")

null_ls.setup(
    {
        debug = true,
        sources = {
            null_ls.builtins.formatting.stylua,
            null_ls.builtins.formatting.taplo,
            null_ls.builtins.formatting.stylua,
            null_ls.builtins.formatting.prettier.with(
                {
                    filetypes = {"json", "jsonc"}
                }
            )
        },
        on_attach = function(client, bufnr)
            if client.supports_method("textDocument/formatting") then
                local group = vim.api.nvim_create_augroup("LspFormatting", {clear = true})
                vim.api.nvim_create_autocmd(
                    "BufWritePre",
                    {
                        group = group,
                        buffer = bufnr,
                        callback = function()
                            vim.lsp.buf.format(
                                {
                                    bufnr = bufnr,
                                    timeout_ms = 2000,
                                    async = false
                                }
                            )
                        end
                    }
                )
            end
        end
    }
)
