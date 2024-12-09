return {
    {
        "mrcjkb/rustaceanvim",
        version = "^5",
        dependencies = {"nvim-lua/plenary.nvim", "mfussenegger/nvim-dap"}, 
        ["rust-analyzer"] = {
            server = { 
                default_settings = {
                    ["rust-analyzer"] = {
                        assist = {
                            importGranularity = "module",
                            importPrefix = "by_self"
                        },
                        cargo = {
                            loadOutDirsFromCheck = true
                        }, 
                        procMacro = {
                            enable = true
                        },
                        lens = {
                            enable = true
                        },
                        diagnostics = {
                            enable = true,
                            disabled = {},
                            enableExperimental = true
                        },
                        inlayHints = {
                            enable = true,
                            typeHints = {
                                enable = true,
                                showParameterHints = true,
                                parameterHintsPrefix = "<- ",
                                otherHintsPrefix = "=> "
                            },
                            -- lifetimeElisionHints = {
                            --     enable = "always"
                            -- },
                            chainingHints = true,
                            maxLength = 25
                        },
                        codeLens = {
                            enable = true
                        }
                    }
                }
            },
            cargo = {allFeatures = true}
        }
    },
    {
        "kosayoda/nvim-lightbulb",
        config = function()
            require("nvim-lightbulb").setup(
                {
                    autocmd = {enabled = true},
                    sign = {enabled = true, priority = 10},
                    virtual_text = {
                        enabled = false,
                        text = "\u{f0626}",
                        lens_text = "🔎",
                        hl = "LightBulbFloatWin",
                        win_opts = {
                            focusable = true
                        }
                    },
                    status_text = {enabled = false}
                }
            )
        end
    }
    -- {
    --     "simrat39/rust-tools.nvim",
    --     lazy = false,
    --     dependencies = {"neovim/nvim-lspconfig", "nvim-lua/plenary.nvim"},
    --     config = function()
    --         require("rust-tools").setup({
    --             tools = {
    --                 inlay_hints = {
    --                     auto = true, -- Automatically enable hints
    --                     only_current_line = false, -- Show hints for the entire file
    --                     show_parameter_hints = true, -- Show parameter hints
    --                     right_align = false, -- Do not align hints to the right
    --                     max_len_align = false, -- Do not align hints based on max length
    --                     parameter_hints_prefix = "", -- No prefix for parameter hints
    --                     other_hints_prefix = ": " -- Prefix for other hints (e.g., types)
    --                 }
    --             },
    --             server = {
    --                 on_attach = function(_, bufnr)
    --                     local opts = {
    --                         noremap = true,
    --                         silent = true,
    --                         buffer = bufnr
    --                     }
    --                 end,
    --                 settings = {
    --                     ["rust-analyzer"] = {
    --                         cargo = {allFeatures = true}, -- Enable all Cargo features
    --                         checkOnSave = {command = "clippy"}, -- Run Clippy on save
    --                         procMacro = {enable = true} -- Enable procedural macros
    --                     }
    --                 }
    --             }
    --         })
    --     end
    -- }
    --  {
    --     "rust-lang/rust.vim",
    --     ft = "rust",
    --     lazy = false,
    --     init = function() vim.g.rustfmt_autosave = 1 end
    -- }, {
    --     "saecki/crates.nvim",
    --     ft = {"toml"},
    --     lazy = false,
    --     config = function()
    --         require("crates").setup {completion = {cmp = {enabled = true}}}
    --         require("cmp").setup.buffer {sources = {{name = "crates"}}}
    --     end
    -- }
}
