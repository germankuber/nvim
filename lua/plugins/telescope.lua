return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "andrew-george/telescope-themes",
            "nvim-telescope/telescope-fzf-native.nvim", -- Improves fuzzy matching
            "nvim-lua/plenary.nvim", -- Required dependency
            "nvim-tree/nvim-web-devicons", -- For file icons
            "folke/tokyonight.nvim", -- A vibrant theme for Telescope
        },
        build = "make", -- Required for telescope-fzf-native.nvim
        lazy = false,
        config = function()
            -- Get builtin schemes list
            local builtin_schemes = require("telescope._extensions.themes").builtin_schemes

            -- Telescope setup
            require("telescope").setup({
                defaults = {
                    -- Layout configuration
                    layout_config = {
                        horizontal = {
                            width = 0.8,
                            height = 0.7,
                            prompt_position = "top", -- Search bar at the top
                        },
                    },
                    sorting_strategy = "ascending", -- Results sorted from top to bottom
                    winblend = 10, -- Slight transparency
                    prompt_prefix = "🔍 ", -- Custom prompt icon
                    selection_caret = " ", -- Custom selection indicator
                },
                extensions = {
                    fzf = {
                        fuzzy = true, -- Enable fuzzy search
                        override_generic_sorter = true, -- FZF for generic sorting
                        override_file_sorter = true, -- FZF for file sorting
                    },
                    themes = {
                        layout_config = {
                            horizontal = {
                                width = 0.8,
                                height = 0.7,
                                prompt_position = "top", -- Search bar at the top
                            },
                        },
                        enable_previewer = true, -- Show preview window
                        enable_live_preview = false, -- Disable live preview
                        ignore = vim.list_extend(builtin_schemes, { "embark" }),
                        light_themes = {
                            ignore = true,
                            keywords = { "light", "day", "frappe" },
                        },
                        dark_themes = {
                            ignore = false,
                            keywords = { "dark", "night", "black" },
                        },
                        persist = {
                            enabled = true,
                            path = vim.fn.stdpath("config") .. "/lua/colorscheme.lua",
                        },
                    },
                },
            })

            -- Load extensions
            -- require("telescope").load"_extension("fzf")
        end,
    },
}