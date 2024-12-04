return {
    -- {
    --     "folke/tokyonight.nvim",
    --     lazy = false, -- Cargar inmediatamente
    --     priority = 1000, -- Asegura que se cargue antes de otros temas
    --     config = function()
    --         require("tokyonight").setup {
    --             style = "storm", -- Estilo de color que te gusta
    --             transparent = false, -- Asegura que no haya transparencia
    --             terminal_colors = true, -- Usar colores en la terminal
    --             dim_inactive = false, -- Desactiva la atenuación en ventanas inactivas
    --             on_highlights = function(hl, c)
    --                 -- Aseguramos que todos los colores sigan el esquema
    --                 hl.Normal = {bg = c.bg, fg = c.fg}
    --                 hl.NormalNC = {bg = c.bg, fg = c.fg_dark}
    --                 -- Otros ajustes de highlight si lo necesitas
    --             end

    --             -- terminal_colors = true, -- Usar colores en la terminal
    --             -- styles = {
    --             --   comments = { italic = true },
    --             --   keywords = { italic = false },
    --             --   functions = { italic = true },
    --             --   variables = {},
    --             -- },
    --             -- sidebars = { "qf", "help", "terminal", "packer" }, -- Ajusta paneles especiales
    --             -- dim_inactive = true, -- Atenúa ventanas inactivas
    --             -- on_highlights = function(hl, c)
    --             --   hl.CursorLine = { bg = c.bg_highlight } -- Ajusta el fondo del cursorline
    --             -- end,
    --         }

    --         vim.cmd("colorscheme tokyonight")
    --     end
    -- }
    {
        'sainnhe/sonokai',
        lazy = false,
        priority = 1000,
        config = function()
            -- Optionally configure and load the colorscheme
            -- directly inside the plugin declaration.
            vim.g.sonokai_enable_italic = true
            vim.cmd.colorscheme('sonokai')
        end
    }
}
