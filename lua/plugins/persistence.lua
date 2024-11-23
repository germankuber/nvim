return {
    {
        "MunifTanjim/nui.nvim",
        lazy = false
    },
    {
        "folke/persistence.nvim",
        lazy = false,
        config = function()
            require("persistence").setup({
                dir = vim.fn.stdpath("state") .. "/sessions/", -- Save sessions in this directory
                options = {"buffers", "curdir", "tabpages", "winsize"} -- What to save
            })

            -- Add Telescope integration to list sessions
            require("telescope").load_extension("persisted")
        end
    }, {
        "olimorris/persisted.nvim",
        dependencies = {"nvim-telescope/telescope.nvim"},
        lazy = false,
        config = function()
            require("persisted").setup({
                save_dir = vim.fn.stdpath("state") .. "/sessions/", -- Where sessions are stored
                autoload = false, -- Don't autoload sessions
                telescope = {
                    before_source = nil, -- Function to run before sourcing the session
                    after_source = nil -- Function to run after sourcing the session
                }
            })

            -- Telescope session integration
            require("telescope").load_extension("persisted")
        end
    }
}
