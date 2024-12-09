return {
    {
        "nvimdev/lspsaga.nvim",
        config = function()
            require("lspsaga").setup(
                {
                    ui = {
                        sign = false,
                        enable = false,
                        virtual_text = false
                    }
                }
            )
        end,
        dependencies = {
            "nvim-treesitter/nvim-treesitter", -- optional
            "nvim-tree/nvim-web-devicons" -- optional
        }
    }
}
