return {
    {
        "olimorris/persisted.nvim",
        lazy = false,
        config = function()
            require("persisted").setup({
                save_dir = vim.fn.stdpath("state") .. "/sessions/",
                autoload = true,
                autosave = true,
                use_git_branch = true,
                ignored_dirs = {
                    { "~", exact = true },
                    { "/tmp", exact = false },
                },
                telescope = {
                    before_source = function()
                        -- Close all existing buffers before loading session
                        vim.cmd("%bdelete")
                    end,
                    after_source = nil,
                },
            })
        end,
    },
}
