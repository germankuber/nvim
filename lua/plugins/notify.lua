return {
    {
        "rcarriga/nvim-notify",
        lazy = false,
        config = function()
            vim.notify = require("notify")
            require("notify").setup({
                stages = "fade", -- Otras opciones: fade_in_slide_out, static
                timeout = 3000, -- Tiempo de duración del popup
                background_colour = "#000000"
            })
        end
    }
}
