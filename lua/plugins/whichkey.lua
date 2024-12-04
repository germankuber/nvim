return {
    {
        "echasnovski/mini.nvim",
        version = false, -- Usa la última versión
        config = function()
            require("mini.icons").setup() -- Configuración mínima
        end
    }, {
        "folke/noice.nvim",
        lazy = false,
        dependencies = {"MunifTanjim/nui.nvim", "rcarriga/nvim-notify"},
        config = function()
            require("noice").setup {
                lsp = {
                    override = {
                        ["K"] = false, -- Deshabilitar el mapeo de K en noice.nvim
                    },
                    hover = {
                        enabled = false, -- Deshabilitar la funcionalidad hover de LSP en Noice
                    },
                },
                presets = {
                    bottom_search = false, -- Desactiva búsquedas abajo
                    command_palette = true, -- Usa un panel flotante para comandos
                    long_message_to_split = true,
                    inc_rename = false,
                    lsp_doc_border = true -- Bordes flotantes para LSP
                },
                views = {
                    cmdline_popup = {
                        position = {
                            row = "50%", -- Centrado verticalmente
                            col = "50%" -- Centrado horizontalmente
                        },
                        size = {
                            width = 100, -- Ajusta el ancho del popup
                            height = "auto" -- Deja que la altura sea automática
                        },
                        border = {
                            style = "rounded", -- Bordes redondeados
                            padding = {1, 1} -- Relleno interno
                        }
                    }
                }
            }
             
        end
    }, {
        "folke/which-key.nvim",
        config = function()
            require("which-key").setup {
                windows = {
                    border = "rounded", -- Bordes redondeados
                    position = "center", -- Forzar que aparezca centrado
                    margin = {1, 1, 1, 1}, -- Márgenes alrededor de la ventana
                    padding = {2, 2, 2, 2}, -- Espaciado dentro de la ventana
                    winblend = 10 -- Transparencia para un efecto flotante
                },
                layout = {
                    spacing = 6, -- Espaciado entre columnas
                    align = "center" -- Centrar las teclas
                }
            }

            -- Sobrescribir mapeos conflictivos
            local wk = require("which-key")
            wk.add({}, {mode = "n", prefix = "<gc>"}) -- Desactiva <gc>
            wk.add({}, {mode = "n", prefix = "<gcc>"}) -- Desactiva <gcc>
        end
    }

}
