return {{
    'willothy/moveline.nvim',
    build = 'make'
}, {
    "petertriho/nvim-scrollbar",
    config = function()
        require("scrollbar").setup()
    end
}, {
    "simonmclean/triptych.nvim",
    event = "VeryLazy",
    dependencies = {"nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "antosha417/nvim-lsp-file-operations"},
    opts = {},
    config = function()
        require("triptych").setup()
    end
}, {
    "sphamba/smear-cursor.nvim",
    opts = {}
}, {
    "j-hui/fidget.nvim",
    opts = {}
}, {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true
}, {
    "ojroques/nvim-bufdel",
    config = function()
        require("bufdel").setup({
            next = "alternate",
            quit = true
        })
    end
}, {
    "rmagatti/goto-preview",
    event = "BufEnter",
    config = true,
    config = function()
        require("goto-preview").setup({
            width = 120,
            height = 25

        })
    end
}, {
    "toppair/peek.nvim",
    event = {"VeryLazy"},
    build = "deno task",
    config = function()
        require("peek").setup()
        vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
        vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    end
}, {
    "romgrk/barbar.nvim",
    dependencies = {"nvim-tree/nvim-web-devicons"},
    config = function()
        vim.g.barbar_auto_setup = false
        require("bufferline").setup({
            auto_hide = false,
            icons = {
                buffer_index = true,
                filetype = {
                    enabled = true
                }
            }
        })
    end
}, {
    "s1n7ax/nvim-window-picker",
    name = "window-picker",
    event = "VeryLazy",
    version = "2.*",
    config = function()
        require"window-picker".setup({
            hint = "floating-big-letter"
        })
        vim.api.nvim_create_user_command("PickWindow", function()
            local win_id = require("window-picker").pick_window()
            if win_id then
                vim.api.nvim_set_current_win(win_id)
            end
        end, {
            desc = "Pick and switch to a window"
        })
    end
}, {"mrjones2014/smart-splits.nvim"}, {
    "stevearc/dressing.nvim",
    lazy = false,
    config = function()
        require("dressing").setup({
            input = {
                enabled = true,
                default_prompt = "Input:",
                prompt_align = "center",
                insert_only = false,
                anchor = "SW",
                border = "rounded",
                relative = "editor",
                prefer_width = 40,
                prefer_height = 10,
                win_options = {
                    winblend = 0
                },
                override = function(conf)
                    conf.col = math.floor((vim.o.columns - conf.width) / 2)
                    conf.row = math.floor((vim.o.lines - conf.height) / 2 - 1)
                    return conf
                end
            }
        })
    end
}, {
    "glepnir/dashboard-nvim",
    event = "VimEnter",
    lazy = false,
    config = function()
        require("dashboard").setup {
            theme = "hyper",
            config = {
                week_header = {
                    enable = true
                },
                shortcut = {{
                    desc = "󰊳 Update",
                    group = "update",
                    action = "Lazy update",
                    key = "u"
                }, {
                    desc = "⚡️ Sync",
                    group = "sync",
                    action = "Lazy sync",
                    key = "s"
                }, {
                    icon = " ",
                    icon_hl = "@variable",
                    desc = "Files",
                    group = "Label",
                    action = "Telescope find_files",
                    key = "f"
                }, {
                    desc = "🗂️ projects",
                    group = "Number",
                    action = "Telescope project",
                    key = "p"
                }}
            }
        }
    end,
    dependencies = {"nvim-tree/nvim-web-devicons"}
}, {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()

        local function set_indent_blankline_for_rust()
            vim.api.nvim_set_hl(0, "IndentBlanklineIndent1", {
                fg = "#E06C75",
                nocombine = true
            })
            vim.api.nvim_set_hl(0, "IndentBlanklineIndent2", {
                fg = "#E5C07B",
                nocombine = true
            })
            vim.api.nvim_set_hl(0, "IndentBlanklineIndent3", {
                fg = "#98C379",
                nocombine = true
            })
            vim.api.nvim_set_hl(0, "IndentBlanklineIndent4", {
                fg = "#56B6C2",
                nocombine = true
            })
            vim.api.nvim_set_hl(0, "IndentBlanklineIndent5", {
                fg = "#61AFEF",
                nocombine = true
            })
            vim.api.nvim_set_hl(0, "IndentBlanklineIndent6", {
                fg = "#C678DD",
                nocombine = true
            })

            require("ibl").setup({
                scope = {
                    enabled = true,
                    show_start = true,
                    highlight = {"IndentBlanklineScope"}
                },
                indent = {
                    char = "│",
                    highlight = {"IndentBlanklineIndent1", "IndentBlanklineIndent2", "IndentBlanklineIndent3",
                                 "IndentBlanklineIndent4", "IndentBlanklineIndent5", "IndentBlanklineIndent6"}
                }
            })
        end

        local function restore_indent_blankline_to_default()

            require("ibl").setup({
                scope = {
                    enabled = false
                },
                indent = {
                    char = "│",
                    highlight = {"IndentBlanklineChar"}
                }
            })
        end

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "rust",
            callback = function()
                set_indent_blankline_for_rust()
            end
        })

        vim.api.nvim_create_autocmd("BufUnload", {
            pattern = "*.rs",
            callback = function()
                restore_indent_blankline_to_default()
            end
        })

        vim.api.nvim_set_hl(0, "IndentBlanklineScope", {
            fg = "#FFFFFF",
            bg = "#3b4261",
            underline = true
        })
    end
}, {
    "nvim-treesitter/nvim-treesitter-context",
    lazy = false,
    config = function()
        require("treesitter-context").setup({
            max_lines = 1,
            multiline_threshold = 2
        })
    end
}, {
    "nvim-lualine/lualine.nvim",
    dependencies = {"nvim-tree/nvim-web-devicons"},
    lazy = false,
    config = function()
        require("lualine").setup({
            options = {
                theme = "sonokai",
                component_separators = {
                    left = "",
                    right = ""
                },
                section_separators = {
                    left = "",
                    right = ""
                },
                disabled_filetypes = {"NvimTree", "dashboard", "packer"},
                globalstatus = true
            },
            sections = {
                lualine_a = {{
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
                }},
                lualine_b = {"branch", "diff"},
                lualine_c = {"filename"},

                lualine_x = {"filetype"},
                lualine_y = {{
                    function()
                        return "⛽️" .. require("config.gas_lualine").gas_value()
                    end,

                    padding = {
                        left = 1,
                        right = 1
                    }

                }, {
                    function()
                        local cm = require("config.custom_movement")
                        if cm.is_enabled() then
                            return "🔥"
                        else
                            return "🥶"
                        end
                    end,

                    padding = {
                        left = 1,
                        right = 1
                    }

                }, {
                    function()
                        local jump_config = require("config.jump_config")
                        return "Jump: " .. jump_config.line_jump
                    end,
                    padding = {
                        left = 1,
                        right = 1
                    }
                }},
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
        })
    end
}, {"lucastavaresa/SingleComment.nvim"}}
