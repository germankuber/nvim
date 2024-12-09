return {
    {
        "sainnhe/sonokai",
        lazy = false,
        priority = 1000,
        config = function()
            vim.g.sonokai_enable_italic = true
            vim.g.sonokai_disable_italic_comment = false
            vim.g.sonokai_transparent_background = 2


            vim.cmd.colorscheme("sonokai")
        end
    }
}
