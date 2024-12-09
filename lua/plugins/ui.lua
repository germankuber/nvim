return {
    -- {
    --     "xiyaowong/transparent.nvim",
    --     config = function()
    --         require("transparent").setup(
    --             {
    --                 enable = true,
    --                 extra_groups = {
    --                     "NormalFloat",
    --                     "NvimTreeNormal"
    --                 },
    --                 exclude = {}
    --             }
    --         )
    --     end
    -- },
    {
        "j-hui/fidget.nvim",
        opts = {}
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true
        -- use opts = {} for passing setup options
        -- this is equivalent to setup({}) function
    },
    {
        "ojroques/nvim-bufdel",
        config = function()
            require("bufdel").setup(
                {
                    next = "alternate", -- Cambia al buffer alternativo
                    quit = true -- Cierra la ventana si es la última
                }
            )
        end
    },
    {
        "rmagatti/goto-preview",
        event = "BufEnter",
        config = true,
        config = function()
            require("goto-preview").setup(
                {
                    width = 120, -- Width of the floating window
                    height = 25 -- Height of the floating window
                    -- :
                }
            )
        end
    },
    {
        "toppair/peek.nvim",
        event = {"VeryLazy"},
        build = "deno task --quiet build:fast",
        config = function()
            require("peek").setup()
            vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
            vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
        end
    },
    {
        "romgrk/barbar.nvim",
        dependencies = {"nvim-tree/nvim-web-devicons"}, -- Opcional para íconos
        config = function()
            vim.g.barbar_auto_setup = false -- Configuración manual
            require("bufferline").setup(
                {
                    auto_hide = false, -- Muestra siempre la barra, incluso con un solo buffer
                    icons = {buffer_index = true, filetype = {enabled = true}}
                }
            )
        end
    }, -- , {'mrjones2014/smart-splits.nvim'}, {
    --     'stevearc/dressing.nvim',
    --     lazy = false,
    --     config = function()
    --         require('dressing').setup({
    --             input = {
    --                 enabled = true,
    --                 default_prompt = 'Input:',
    --                 prompt_align = 'center',
    --                 insert_only = false,
    --                 anchor = 'SW',
    --                 border = 'rounded',
    --                 relative = 'editor',
    --                 prefer_width = 40,
    --                 prefer_height = 10,
    --                 win_options = {winblend = 0},
    --                 override = function(conf)
    --                     conf.col = math.floor((vim.o.columns - conf.width) / 2)
    --                     conf.row = math.floor(
    --                                    (vim.o.lines - conf.height) / 2 - 1)
    --                     return conf
    --                 end
    --             }
    --         })
    --     end
    -- },
    {
        "glepnir/dashboard-nvim",
        event = "VimEnter",
        lazy = false,
        config = function()
            require("dashboard").setup {
                theme = "hyper",
                config = {
                    week_header = {enable = true},
                    shortcut = {
                        {
                            desc = "󰊳 Update",
                            group = "update",
                            action = "Lazy update",
                            key = "u"
                        },
                        {
                            desc = "⚡️ Sync",
                            group = "sync",
                            action = "Lazy sync",
                            key = "s"
                        },
                        {
                            icon = " ",
                            icon_hl = "@variable",
                            desc = "Files",
                            group = "Label",
                            action = "Telescope find_files",
                            key = "f"
                        }, --  {
                        --     desc = ' Apps',
                        --     group = 'DiagnosticHint',
                        --     action = 'Telescope app',
                        --     key = 'a'
                        -- },
                        -- {
                        --     desc = ' dotfiles',
                        --     group = 'Number',
                        --     action = 'Telescope dotfiles',
                        --     key = 'd'
                        -- },
                        {
                            desc = "🗂️ projects",
                            group = "Number",
                            action = "Telescope project",
                            key = "p"
                        }
                    }
                }
            }
            vim.cmd("Dashboard")
        end,
        dependencies = {"nvim-tree/nvim-web-devicons"}
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {},
        config = function()
            local function set_indent_blankline_for_rust()
                vim.api.nvim_set_hl(0, "IndentBlanklineIndent1", {fg = "#E06C75", nocombine = true})
                vim.api.nvim_set_hl(0, "IndentBlanklineIndent2", {fg = "#E5C07B", nocombine = true})
                vim.api.nvim_set_hl(0, "IndentBlanklineIndent3", {fg = "#98C379", nocombine = true})
                vim.api.nvim_set_hl(0, "IndentBlanklineIndent4", {fg = "#56B6C2", nocombine = true})
                vim.api.nvim_set_hl(0, "IndentBlanklineIndent5", {fg = "#61AFEF", nocombine = true})
                vim.api.nvim_set_hl(0, "IndentBlanklineIndent6", {fg = "#C678DD", nocombine = true})

                require("ibl").setup(
                    {
                        scope = {enabled = false},
                        indent = {
                            char = "│",
                            highlight = {
                                "IndentBlanklineIndent1",
                                "IndentBlanklineIndent2",
                                "IndentBlanklineIndent3",
                                "IndentBlanklineIndent4",
                                "IndentBlanklineIndent5",
                                "IndentBlanklineIndent6"
                            }
                        }
                    }
                )
            end

            local function restore_indent_blankline_to_default()
                vim.api.nvim_set_hl(0, "IndentBlanklineIndent1", {})
                vim.api.nvim_set_hl(0, "IndentBlanklineIndent2", {})
                vim.api.nvim_set_hl(0, "IndentBlanklineIndent3", {})
                vim.api.nvim_set_hl(0, "IndentBlanklineIndent4", {})
                vim.api.nvim_set_hl(0, "IndentBlanklineIndent5", {})
                vim.api.nvim_set_hl(0, "IndentBlanklineIndent6", {})

                require("ibl").setup(
                    {
                        indent = {
                            char = "│",
                            highlight = {"IndentBlanklineChar"}
                        }
                    }
                )
            end

            vim.api.nvim_create_autocmd(
                "FileType",
                {
                    pattern = "rust",
                    callback = function()
                        set_indent_blankline_for_rust()
                    end
                }
            )

            vim.api.nvim_create_autocmd(
                "BufUnload",
                {
                    pattern = "*.rs",
                    callback = function()
                        restore_indent_blankline_to_default()
                    end
                }
            )
        end
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        lazy = false,
        config = function()
            require("treesitter-context").setup(
                {
                    max_lines = 1,
                    multiline_threshold = 2
                }
            )
        end
    },
    {
        "nvim-lualine/lualine.nvim", -- Statusline with mode-based customization
        dependencies = {"nvim-tree/nvim-web-devicons"},
        lazy = false,
        config = function()
            require("lualine").setup(
                {
                    options = {
                        theme = "sonokai", 
                        component_separators = {left = "", right = ""},
                        section_separators = {left = "", right = ""},
                        disabled_filetypes = {"NvimTree", "dashboard", "packer"}
                    },
                    sections = {
                        lualine_a = {
                            {
                                "mode",
                                fmt = function(mode)
                                    local modes = {
                                        INSERT = "INSERT 🚀",
                                        NORMAL = "NORMAL 🌟",
                                        VISUAL = "VISUAL ✍️",
                                        REPLACE = "REPLACE 🔄"
                                    }
                                    return modes[mode] or mode
                                end
                            }
                        },
                        lualine_b = {"branch", "diff"},
                        lualine_c = {"filename"},
                        -- lualine_x = {"encoding", "fileformat", "filetype"},
                        lualine_x = { "filetype"},
                        lualine_y = {
                            {
                                function()
                                    return "⛽️" .. require("config.gas_lualine").gas_value()
                                end,
                                -- color = require("config.gas_lualine").gas_color(),
                                padding = {left = 1, right = 1},
                                -- separator = {
                                --     left = "",
                                --     color = require("config.gas_lualine").gas_color()
                                -- }
                            },
                            {
                                function()
                                    local cm = require("config.custom_movement")
                                    if cm.is_enabled() then
                                        return "🔥"
                                    else
                                        return "🥶"
                                    end
                                end,
                                -- color = {fg = "#FF4500"},
                                padding = {left = 1, right = 1},
                                -- separator = {
                                --     left = "",
                                --     color = {bg = "#000000", fg = "#FFFFFF"}
                                -- }
                            },
                            {
                                function()
                                    local jump_config = require("config.jump_config")
                                    return "Jump: " .. jump_config.line_jump
                                end,
                                padding = {left = 1, right = 1}
                            }
                        },
                        lualine_z = {"location"}
                    },
                    inactive_sections = {
                        lualine_a = {},
                        lualine_b = {},
                        lualine_c = {"filename"},
                        lualine_x = {"location"},
                        lualine_y = {},
                        lualine_z = {}
                    },
                    extensions = {"quickfix", "fugitive"}
                }
            )
        end
    }
}
