return{
    {
        "lewis6991/gitsigns.nvim",
        lazy = false, -- Cargar inmediatamente
        config = function()
          require("gitsigns").setup {
            -- Configuración básica, ajusta según tus necesidades
            signs = {
              add = { text = "+" },
              change = { text = "~" },
              delete = { text = "_" },
              topdelete = { text = "‾" },
              changedelete = { text = "~" },
            },
          }
        end,
      }
}