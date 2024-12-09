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
    -- {
    --     "kosayoda/nvim-lightbulb",
    --     config = function()
    --         require("nvim-lightbulb").setup(
    --             {
    --                 autocmd = {enabled = true},
    --                 sign = {enabled = false, priority = 10},
    --                 virtual_text = {
    --                     enabled = false,
    --                     text = "\u{f0626}",
    --                     lens_text = "🔎",
    --                     hl = "LightBulbFloatWin",
    --                     win_opts = {
    --                         focusable = true
    --                     }
    --                 },
    --                 status_text = {enabled = false}
    --             }
    --         )
    --     end
    -- }
}
