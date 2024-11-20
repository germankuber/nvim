return {
    {
        "nvim-tree/nvim-web-devicons",
    },
    {
        "mg979/vim-visual-multi",
        branch = "master",
        lazy = false,
    },
    {
        "rmagatti/auto-session",
        lazy = false,
        config = function()
            require("auto-session").setup {
                log_level = "info",
                auto_session_enabled = true,
                auto_save_enabled = true,
                auto_restore_enabled = true,
                auto_session_use_git_branch = true, -- Opcional, sesiones separadas por ramas de Git
            }
        end,
    },

    {
        "nvim-lua/plenary.nvim",
        lazy = false,
    },
    {
        "stevearc/conform.nvim",
        -- event = 'BufWritePre', -- uncomment for format on save
        opts = require "configs.conform",
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "jose-elias-alvarez/null-ls.nvim", -- Integración de formateadores y linters
            "simrat39/rust-tools.nvim",
            "nvim-telescope/telescope.nvim",
            "nvim-lua/plenary.nvim", -- Dependencia de null-ls
        },
    },
    {
        "simrat39/rust-tools.nvim",
        -- event = 'BufWritePre', -- uncomment for format on save
        dependencies = {
            "neovim/nvim-lspconfig",
            "nvim-lua/plenary.nvim",
        },
        config = function()
            local rt = require "rust-tools"

            rt.setup {
                server = {
                    on_attach = function(_, bufnr) end,
                },
                tools = {
                    rust_analyzer = {
                        enable = true,
                    },
                    reload_workspace_from_cargo_toml = true,
                    inlay_hints = {
                        auto = true,
                        highlight = "Comment",
                    },
                },
            }

            -- rt.hover_actions.hover_actions()
        end,
    },

    {
        "neovim/nvim-lspconfig",
        config = function()
            require "configs.lspconfig"
        end,
    },

    {
        "mrcjkb/rustaceanvim",
        version = "^5",
        lazy = false,
        ft = "rust",
        config = function()
            local mason_registry = require "mason-registry"
            local codelldb = mason_registry.get_package "codelldb"
            local extension_path = codelldb:get_install_path() .. "/extension/"
            local codelldb_path = extension_path .. "adapter/codelldb"
            local liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"
            local cfg = require "rustaceanvim.config"

            vim.g.rustaceanvim = {
                dap = {
                    adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
                },
            }
        end,
    },

    {
        "rust-lang/rust.vim",
        ft = "rust",
        init = function()
            vim.g.rustfmt_autosave = 1
        end,
    },

    {
        "mfussenegger/nvim-dap",
        config = function()
            local dap, dapui = require "dap", require "dapui"
            dap.listeners.before.attach.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                dapui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                dapui.close()
            end
        end,
    },

    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
        },
        config = function()
            require("dapui").setup()
        end,
    },

    {
        "saecki/crates.nvim",
        ft = { "toml" },
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

    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
    },
    {
        "hrsh7th/nvim-cmp",
    },
    {
        "hrsh7th/cmp-nvim-lsp",
    },
    {
        "hrsh7th/cmp-vsnip",
    },
    {
        "hrsh7th/vim-vsnip",
    },
    {
        "hrsh7th/vim-vsnip-integ",
    },
    {
        "hrsh7th/cmp-path",
    },
    {
        "hrsh7th/cmp-buffer",
    },
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            vim.opt.termguicolors = true

            local bl = require "bufferline"

            bl.setup {
                options = {
                    diagnostics_indicator = function(count, level)
                        local icon = level:match "error" and " " or ""
                        return " " .. icon .. count
                    end,
                    show_buffer_close_icons = false,
                    show_close_icon = false,
                    show_tab_indicators = true,
                    always_show_bufferline = true,
                    separator_style = "thick",
                    numbers = "ordinal",
                    offsets = {
                        {
                            filetype = "neo-tree",
                            text = "File Explorer",
                            separator = true,
                        },
                    },
                },
            }
        end,
    },
    {
        "zbirenbaum/copilot-cmp",
        event = "InsertEnter",
        lazy = false,
        config = function()
            require("copilot_cmp").setup()
        end,
        dependencies = {
            "zbirenbaum/copilot.lua",
            cmd = "Copilot",
            config = function()
                require("copilot").setup {
                    suggestion = { enabled = false },
                    panel = { enabled = false },
                }
            end,
        },
    },
}
