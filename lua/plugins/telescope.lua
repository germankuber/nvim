return {
    {"tpope/vim-fugitive", event = "VeryLazy"}, {
        'nvim-telescope/telescope-project.nvim',
        dependencies = {'nvim-telescope/telescope.nvim'}
    }, {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "tpope/vim-fugitive", "nvim-telescope/telescope-frecency.nvim",
            "olimorris/persisted.nvim", "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-ui-select.nvim",
            "isak102/telescope-git-file-history.nvim",
            "debugloop/telescope-undo.nvim", "nvim-tree/nvim-web-devicons", {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
                cond = vim.fn.executable("make") == 1
            }, "andrew-george/telescope-themes"

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
                    winblend = 0,
                    prompt_prefix = "🔍 ",
                    selection_caret = "➡️ "
                },
                pickers = {
                    code_action = {
                        theme = "cursor" -- You can use "dropdown", "cursor", or other themes
                    }
                },
                extensions = {
                    ['ui-select'] = {
                        require('telescope.themes').get_dropdown({
                            winblend = 10,
                            layout_config = {prompt_position = 'top'},
                            border = true,
                            previewer = false
                        })
                    },
                    undo = {
                        -- telescope-undo.nvim config, see below
                    },
                    project = {
                        base_dirs = {
                            {path = vim.fn.expand("~/Documents/Repositories")} -- Usa la ruta absoluta correcta
                        },
                        hidden_files = true,
                        order_by = "asc",
                        search_by = "title",
                        sync_with_nvim = true
                    },
                    git_file_history = {
                        open_command = "edit", -- Aseguramos el uso de :edit
                        mappings = {}
                    },
                    -- copilot_chat = {
                    --     open = function(prompt_bufnr)
                    --         actions.close(prompt_bufnr)
                    --         vim.cmd('CopilotChat')
                    --     end,
                    -- },
                    persisted = {layout_config = {width = 0.55, height = 0.55}},
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
                            keywords = {"light", "day", "frappe"}
                        },
                        dark_themes = {
                            ignore = false,
                            keywords = {"dark", "night", "black"}
                        },
                        persist = {
                            enabled = true,
                            path = vim.fn.stdpath("config") ..
                                "/lua/colorscheme.lua"
                        }

                    }
                }
            })

            -- Cargar extensiones
            -- require('telescope').load_extension('copilot_chat')
            require("telescope").load_extension("frecency")
            require("telescope").load_extension("fzf")
            require("telescope").load_extension("themes")
            require("telescope").load_extension("persisted")
            require("telescope").load_extension("git_file_history")
            require("telescope").load_extension("aerial")
            require("telescope").load_extension("undo")
            require("telescope").load_extension("project")
            require('telescope').load_extension('ui-select')

        end
    }

}
