return {
    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup(
                {
                    toggler = nil,
                    opleader = nil,
                    mappings = false,
                    padding = true,
                    sticky = true,
                    pre_hook = nil,
                    post_hook = nil
                }
            )
        end,
        lazy = false
    },
    {
        "folke/todo-comments.nvim",
        lazy = false,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim"
        },
        config = function()
            require("todo-comments").setup {}
        end
    }
}
