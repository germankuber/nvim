return {

    {
        "neovim/nvim-lspconfig",
        lazy = false,
        dependencies = {
            "jose-elias-alvarez/null-ls.nvim", "nvim-telescope/telescope.nvim",
            'andrew-george/telescope-themes'
        },
        -- config = function() require "configs.lspconfig" end
    }

}
