return {
    {
        "olimorris/persisted.nvim",
        lazy = false,
        config = function()
            require("persisted").setup({
                save_dir = vim.fn.stdpath("state") .. "/sessions/", -- Where sessions are stored
                autoload = true, -- Don't autoload sessions
                telescope = {
                    before_source = nil, -- Function to run before sourcing the session
                    after_source = nil -- Function to run after sourcing the session
                }
            })

        end
    }

}
