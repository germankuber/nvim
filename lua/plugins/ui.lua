return {
    {"MunifTanjim/nui.nvim", lazy = false}, {
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
                    theme = 'tokyonight' -- Or another theme
                },
                sections = {
                    lualine_a = {
                        {
                            'mode',
                            fmt = function(mode)
                                if mode == "INSERT" then
                                    return "INSERT MODE 🚀"
                                end
                                return mode
                            end
                        }
                    }
                }
            })
        end
    }, {
        'norcalli/nvim-colorizer.lua', -- Highlight colors dynamically
        event = 'BufReadPre',
        lazy = false,
        config = function() require('colorizer').setup() end
    }
}
