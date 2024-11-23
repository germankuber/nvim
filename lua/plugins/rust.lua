return {
    {
        "simrat39/rust-tools.nvim",
        lazy = false,
        dependencies = {"neovim/nvim-lspconfig", "nvim-lua/plenary.nvim"},
        config = function()
            require("rust-tools").setup({
                tools = {
                    inlay_hints = {
                        auto = true, -- Habilitar automáticamente las hints
                        only_current_line = false,
                        show_parameter_hints = true,
                        parameter_hints_prefix = "<- ",
                        other_hints_prefix = "=> ",
                        highlight = "Comment"
                    }
                },
                server = {
                    on_attach = function(_, bufnr)
                        local opts = {
                            noremap = true,
                            silent = true,
                            buffer = bufnr
                        }
                        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                    end,
                    settings = {
                        ["rust-analyzer"] = {
                            cargo = {allFeatures = true},
                            checkOnSave = {command = "clippy"},
                            procMacro = {enable = true}
                        }
                    }
                }
            })
        end
    }, {
        "rust-lang/rust.vim",
        ft = "rust",
        lazy = false,
        init = function() vim.g.rustfmt_autosave = 1 end
    }, {
        "saecki/crates.nvim",
        ft = {"toml"},
        lazy = false,
        config = function()
            require("crates").setup {completion = {cmp = {enabled = true}}}
            require("cmp").setup.buffer {sources = {{name = "crates"}}}
        end
    }
}
