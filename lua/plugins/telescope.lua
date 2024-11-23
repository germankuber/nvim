return {
    -- {
    --     "ibhagwan/fzf-lua",
    --     lazy = false,
    --     dependencies = { "nvim-tree/nvim-web-devicons" }
    -- },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
                cond = vim.fn.executable("make") == 1
            },
            "andrew-george/telescope-themes",
          
        },
        config = function()
            -- Configuración de Telescope
            require("telescope").setup({
                defaults = {
                    layout_config = {
                        horizontal = {
                            width = 0.8,
                            height = 0.7,
                            prompt_position = "top"
                        }
                    },
                    sorting_strategy = "ascending",
                    winblend = 10,
                    prompt_prefix = "🔍 ",
                    selection_caret = " "
                },
                extensions = {
                    -- copilot_chat = {
                    --     open = function(prompt_bufnr)
                    --         actions.close(prompt_bufnr)
                    --         vim.cmd('CopilotChat')
                    --     end,
                    -- },
                    
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = "smart_case"
                    },
                    themes = {
                        layout_config = {
                            horizontal = {
                                width = 0.8,
                                height = 0.7,
                                prompt_position = "top"
                            }
                        },
                        enable_previewer = true,
                        enable_live_preview = false,
                        ignore = vim.list_extend(require(
                                                     "telescope._extensions.themes").builtin_schemes,
                                                 {"embark"}),
                        light_themes = {
                            ignore = true,
                            keywords = { "light", "day", "frappe" }
                        },
                        dark_themes = {
                            ignore = false,
                            keywords = { "dark", "night", "black" }
                        },
                        persist = {
                            enabled = true,
                            path = vim.fn.stdpath("config") ..
                                "/lua/colorscheme.lua"
                        },
                        mappings = {
                            down = "<C-n>",
                            up = "<C-p>",
                            accept = "<C-y>"
                        }
                    }
                }
            })

            -- Cargar extensiones
            -- require('telescope').load_extension('copilot_chat')
            require("telescope").load_extension("fzf")
            require("telescope").load_extension("themes")
        end
    },
    
}
