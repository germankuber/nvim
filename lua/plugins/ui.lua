return {
    {
        'stevearc/dressing.nvim',
        lazy = false,
        config = function()
            require('dressing').setup({
                input = {
                    enabled = true,
                    default_prompt = 'Input:',
                    prompt_align = 'center',
                    insert_only = false,
                    anchor = 'SW',
                    border = 'rounded',
                    relative = 'editor',
                    prefer_width = 40,
                    prefer_height = 10,
                    win_options = {winblend = 0},
                    override = function(conf)
                        conf.col = math.floor((vim.o.columns - conf.width) / 2)
                        conf.row = math.floor(
                                       (vim.o.lines - conf.height) / 2 - 1)
                        return conf
                    end
                }
            })
        end
    }, {
        'glepnir/dashboard-nvim',
        event = 'VimEnter',
        lazy = false,
        config = function()
            require('dashboard').setup {
                theme = 'hyper',
                config = {
                    week_header = {enable = true},
                    shortcut = {
                        {
                            desc = '󰊳 Update',
                            group = '@property',
                            action = 'Lazy update',
                            key = 'u'
                        }, {
                            icon = ' ',
                            icon_hl = '@variable',
                            desc = 'Files',
                            group = 'Label',
                            action = 'Telescope find_files',
                            key = 'f'
                        }, {
                            desc = ' Apps',
                            group = 'DiagnosticHint',
                            action = 'Telescope app',
                            key = 'a'
                        }, {
                            desc = ' dotfiles',
                            group = 'Number',
                            action = 'Telescope dotfiles',
                            key = 'd'
                        }
                    }
                }
            }
            vim.cmd("Dashboard")
        end,
        dependencies = {'nvim-tree/nvim-web-devicons'}
    }, {"MunifTanjim/nui.nvim", lazy = false}, {
        "akinsho/bufferline.nvim",
        version = "*",
        keymaps = false,
        lazy = false,
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            vim.opt.termguicolors = true

            local bl = require("bufferline")

            bl.setup {
                options = {
                    -- Show diagnostics icons and counts
                    diagnostics = "nvim_lsp",
                    diagnostics_indicator = function(count, level)
                        local icon = level:match("error") and " " or ""
                        return " " .. icon .. count
                    end,
                    -- Visual options
                    show_buffer_close_icons = false,
                    show_close_icon = false,
                    show_tab_indicators = true,
                    always_show_bufferline = true,
                    separator_style = "thick",
                    numbers = "ordinal",
                    -- Configure offsets for specific filetypes
                    offsets = {
                        {
                            filetype = "neo-tree",
                            text = "File Explorer",
                            text_align = "center", -- Align the text in the center
                            separator = true
                        }
                    }
                }
            }
        end
    }, {
        'nvim-lualine/lualine.nvim', -- Statusline with mode-based customization
        dependencies = {'nvim-tree/nvim-web-devicons'},
        lazy = false,
        config = function()
            require('lualine').setup({
                options = {
                    theme = 'tokyonight', -- You can change to 'gruvbox', 'dracula', etc.
                    component_separators = {left = '', right = ''},
                    section_separators = {left = '', right = ''},
                    disabled_filetypes = {'NvimTree', 'dashboard', 'packer'}
                },
                sections = {
                    lualine_a = {
                        {
                            'mode',
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
                    lualine_b = {'branch', 'diff'},
                    lualine_c = {'filename'},
                    lualine_x = {'encoding', 'fileformat', 'filetype'},
                    lualine_y = {
                        {
                            function()
                                local jump_config =
                                    require('config.jump_config')
                                return "Jump: " .. jump_config.line_jump
                            end
                        }
                    },
                    lualine_z = {'location'}
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = {'filename'},
                    lualine_x = {'location'},
                    lualine_y = {},
                    lualine_z = {}
                },
                extensions = {'quickfix', 'fugitive'}
            })
        end
    }, {
        'norcalli/nvim-colorizer.lua', -- Highlight colors dynamically
        event = 'BufReadPre',
        lazy = false,
        config = function() require('colorizer').setup() end
    }, {
        "lukas-reineke/indent-blankline.nvim",
        indent = {highlight = highlight, char = "+"},
        config = function() require("ibl").setup() end
    }, {
        "j-hui/fidget.nvim",
        config = function()
            require("fidget").setup({
                display = {
                    render_limit = 16, -- How many LSP messages to show at once
                    done_ttl = 3, -- How long a message should persist after completion
                    done_icon = "✔", -- Icon shown when all LSP progress tasks are complete
                    done_style = "Constant", -- Highlight group for completed LSP tasks
                    progress_ttl = math.huge, -- How long a message should persist when in progress
                    progress_icon = -- Icon shown when LSP progress tasks are in progress
                    {pattern = "dots", period = 1},
                    progress_style = -- Highlight group for in-progress LSP tasks
                    "WarningMsg",
                    group_style = "Title", -- Highlight group for group name (LSP server name)
                    icon_style = "Question", -- Highlight group for group icons
                    priority = 30, -- Ordering priority for LSP notification group
                    skip_history = true, -- Whether progress notifications should be omitted from history
                    format_message = -- How to format a progress message
                    require("fidget.progress.display").default_format_message,
                    format_annote = -- How to format a progress annotation
                    function(msg) return msg.title end,
                    format_group_name = -- How to format a progress notification group's name
                    function(group) return tostring(group) end,
                    overrides = { -- Override options from the default notification config
                        rust_analyzer = {name = "rust-analyzer"}
                    }
                }
            })
            vim.api.nvim_set_hl(0, "FidgetTitle",
                                {bg = "none", blend = 0, fg = "#FFD700"}) -- Título con transparencia
            vim.api.nvim_set_hl(0, "FidgetTask",
                                {bg = "none", blend = 0, fg = "#FFFFFF"}) -- Tarea con transparencia
        end
    },
    
}
