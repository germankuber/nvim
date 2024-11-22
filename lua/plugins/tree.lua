return {
    {
      "nvim-tree/nvim-tree.lua",
      lazy = false, -- Cargar inmediatamente
      dependencies = { "nvim-tree/nvim-web-devicons" }, -- Iconos opcionales
      config = function()
        require("nvim-tree").setup({
          -- Configuración básica
          view = {
            width = 30,
            side = "left",
            number = true,
            relativenumber = true,
          },
          filters = {
            dotfiles = false, -- Mostrar archivos ocultos
          },
          git = {
            enable = true, -- Mostrar iconos de Git
          },
          renderer = {
            group_empty = true, -- Agrupar carpetas vacías
          },
        })
      end,
    },
  }
  