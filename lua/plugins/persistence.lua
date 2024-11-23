return {
    -- {
    --     "rmagatti/auto-session",
    --     lazy = false,
    --     config = function()
    --         require("auto-session").setup {
    --             log_level = "error",
    --             auto_session_enable_last_session = true, -- Carga la última sesión automáticamente
    --             auto_save_enabled = true,               -- Guarda la sesión automáticamente al salir
    --             auto_restore_enabled = true,            -- Restaura automáticamente al abrir
    --         }
    --     end,
    -- },
--    {
--         "folke/persistence.nvim",
--         lazy = false,
--         -- dependencies = {"nvim-telescope/telescope.nvim"},
--         config = function()
--             require("persistence").setup({
--                 dir = vim.fn.stdpath("state") .. "/sessions/", -- Save sessions in this directory
--                 options = {"buffers", "curdir", "tabpages", "winsize"} -- What to save
--             })

--             -- Add Telescope integration to list sessions
--             -- require("telescope").load_extension("persisted")
--         end
--     }, 
    {
        "olimorris/persisted.nvim",
        -- dependencies =: {"nvim-telescope/telescope.nvim"},
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
            -- require("telescope").load_extension("persisted")
        end
    }
}
