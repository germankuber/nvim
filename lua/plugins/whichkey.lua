return {
    {
        "folke/noice.nvim",
        lazy = false,
        dependencies = {"MunifTanjim/nui.nvim", "rcarriga/nvim-notify"},
        config = function()
            require("noice").setup {
                -- Configuración para ventanas flotantes globales
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
              },
            }
        end
    }, {
        "folke/which-key.nvim",
        lazy = false,
        config = function()
            require("which-key").setup {
                window = {
                    border = "rounded", -- Bordes redondeados
                    position = "center", -- Mostrar en el centro de la pantalla
                    margin = {1, 1, 1, 1},
                    padding = {2, 2, 2, 2},
                    winblend = 10
                }
            }
        end
    }
}
