return {
    {
        "simrat39/rust-tools.nvim",
        lazy = false,
        dependencies = {
            "neovim/nvim-lspconfig",
            "nvim-lua/plenary.nvim",
        },
        config = function()
            require("rust-tools").setup {
                server = {
                    on_attach = function(_, bufnr)
                        local opts = { noremap = true, silent = true, buffer = bufnr }
                        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
                        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
                    end,
                    settings = {
                        ["rust-analyzer"] = {
                            cargo = { allFeatures = true },
                            checkOnSave = { command = "clippy" },
                        },
                    },
                },
            }
        end,
    },
    {
        "rust-lang/rust.vim",
        ft = "rust",
        lazy = false,
        init = function()
            vim.g.rustfmt_autosave = 1
        end,
    },
    {
        "saecki/crates.nvim",
        ft = { "toml" },
        lazy = false,
        config = function()
            require("crates").setup {
                completion = {
                    cmp = {
                        enabled = true,
                    },
                },
            }
            require("cmp").setup.buffer {
                sources = { { name = "crates" } },
            }
        end,
    },
}
