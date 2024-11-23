return {
  {
    "folke/tokyonight.nvim",
    lazy = false, -- Cargar inmediatamente
    priority = 1000, -- Asegura que se cargue antes de otros temas
    config = function()
      require("tokyonight").setup {
        style = "night", -- Opciones: "night", "storm", "day", "moon"
        transparent = false, -- Fondo transparente
        terminal_colors = true, -- Usar colores en la terminal
        styles = {
          comments = { italic = true },
          keywords = { italic = false },
          functions = { italic = true },
          variables = {},
        },
        sidebars = { "qf", "help", "terminal", "packer" }, -- Ajusta paneles especiales
        dim_inactive = true, -- Atenúa ventanas inactivas
        on_highlights = function(hl, c)
          hl.CursorLine = { bg = c.bg_highlight } -- Ajusta el fondo del cursorline
        end,
      }
      vim.cmd("colorscheme tokyonight")
    end,
  },
}