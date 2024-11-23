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
                }
            }
        end
    },  {
      "folke/which-key.nvim",
      config = function()
        local which_key = require("which-key")
  
        which_key.setup {
          window = {
            border = "none",   -- Desactiva los bordes de WhichKey predeterminado
            padding = { 0, 0, 0, 0 }, -- Sin relleno adicional
          },
        }
  
        -- Usamos `nui.nvim` para crear un popup flotante
        local NuiPopup = require("nui.popup")
  
        -- Crear un popup flotante para WhichKey
        local popup = NuiPopup({
          position = "50%", -- Centrado vertical y horizontalmente
          size = {
            width = 60,  -- Ajusta según prefieras
            height = 15, -- Ajusta según prefieras
          },
          border = {
            style = "rounded", -- Bordes redondeados
          },
        })
  
        -- Vinculamos el popup a WhichKey
        vim.api.nvim_create_autocmd("User", {
          pattern = "WhichKey",
          callback = function()
            popup:mount()
          end,
        })
  
        vim.api.nvim_create_autocmd("User", {
          pattern = "WhichKeyLeave",
          callback = function()
            popup:unmount()
          end,
        })
      end,
    },
}
