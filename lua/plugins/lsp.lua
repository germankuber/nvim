return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "jose-elias-alvarez/null-ls.nvim",
            "nvim-telescope/telescope.nvim",
            'andrew-george/telescope-themes',
        },
        config = function()
            require "configs.lspconfig"
        end,
    },
}
