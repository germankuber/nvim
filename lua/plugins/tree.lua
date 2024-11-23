return {
  {
    "nvim-tree/nvim-tree.lua",
    lazy = false, -- Cargar inmediatamente
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- Iconos opcionales
    config = function()
      require("nvim-tree").setup({
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")
          local function opts(desc)
            return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
          end

          -- Mapear <CR> para abrir nodos (archivos o carpetas)

        end,
        view = {
          width = 30,
          side = "left",
          number = true,
          relativenumber = true,
        },
        filters = {
          dotfiles = false,
        },
        git = {
          enable = true,
        },
        renderer = {
          group_empty = true,
        },
      })
    end,
  },
}
