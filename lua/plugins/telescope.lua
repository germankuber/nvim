return {
    {
        "ibhagwan/fzf-lua",
        lazy = false,
        dependencies = {"nvim-tree/nvim-web-devicons"} -- Opcional, para íconos bonitos
    }, {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim", -- Dependencia requerida
            "nvim-tree/nvim-web-devicons", -- Para íconos de archivos
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make", -- Asegura la compilación de la extensión
                cond = vim.fn.executable("make") == 1 -- Solo si 'make' está disponible
            }, "andrew-george/telescope-themes", -- Extensión de temas para Telescope
            {
                "isak102/telescope-git-file-history.nvim",
                dependencies = {"nvim-telescope/telescope.nvim"}
            }
        },
        config = function()
            -- Configuración de Telescope
            require("telescope").setup({
                defaults = {
                    layout_config = {
                        horizontal = {
                            width = 0.8,
                            height = 0.7,
                            prompt_position = "top" -- Barra de búsqueda en la parte superior
                        }
                    },
                    sorting_strategy = "ascending", -- Ordenar resultados de arriba hacia abajo
                    winblend = 10, -- Transparencia ligera
                    prompt_prefix = "🔍 ", -- Icono personalizado para el prompt
                    selection_caret = " " -- Indicador de selección personalizado
                },
                extensions = {
                    fzf = {
                        fuzzy = true, -- habilita la coincidencia difusa
                        override_generic_sorter = true, -- reemplaza el clasificador genérico
                        override_file_sorter = true, -- reemplaza el clasificador de archivos
                        case_mode = "smart_case" -- "ignore_case" | "respect_case" | "smart_case"
                    },
                    extensions = {
                        git_file_history = {

                            debug = false -- Desactiva la depuración si no es necesaria
                        }
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
            require("telescope").load_extension("fzf")
            require("telescope").load_extension("git_file_history")
            require("telescope").load_extension("themes")

        end
    }
}
