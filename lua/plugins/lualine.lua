return {
    {
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
        'RRethy/vim-illuminate', -- Highlight word under cursor
        event = {'BufReadPost', 'BufNewFile'},
        lazy = false,
        config = function()
            require('illuminate').configure({under_cursor = true, delay = 200})
        end
    }, {
        "declancm/cinnamon.nvim",
        enabled = false,
        event = "VeryLazy",
        lazy = false,
        config = function()
            require("cinnamon").setup({
                keymaps = {
                    extra = true -- Use the updated option
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
