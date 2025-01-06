return { --   {
--     "brenton-leighton/multiple-cursors.nvim",
--     -- Puedes añadir configuraciones específicas de multiple-cursors aquí si es necesario
--     -- config = function()
--     --     -- Ejemplo de configuración de multiple-cursors.nvim
--     --     vim.g.multiple_cursors_use_default_mapping = 0 -- Desactiva mapeos por defecto si usas Hydra
--     --     -- Puedes definir tus propios mapeos si lo prefieres
--     -- end
-- },
{
    "brenton-leighton/multiple-cursors.nvim",
    version = "*", -- Use the latest tagged version
    opts = {}, -- This causes the plugin setup function to be called
    -- keys = {
    --   {"<C-j>", "<Cmd>MultipleCursorsAddDown<CR>", mode = {"n", "x"}, desc = "Add cursor and move down"},
    --   {"<C-k>", "<Cmd>MultipleCursorsAddUp<CR>", mode = {"n", "x"}, desc = "Add cursor and move up"},

    --   {"<C-Up>", "<Cmd>MultipleCursorsAddUp<CR>", mode = {"n", "i", "x"}, desc = "Add cursor and move up"},
    --   {"<C-Down>", "<Cmd>MultipleCursorsAddDown<CR>", mode = {"n", "i", "x"}, desc = "Add cursor and move down"},

    --   {"<C-LeftMouse>", "<Cmd>MultipleCursorsMouseAddDelete<CR>", mode = {"n", "i"}, desc = "Add or remove cursor"},

    --   {"<Leader>a", "<Cmd>MultipleCursorsAddMatches<CR>", mode = {"n", "x"}, desc = "Add cursors to cword"},
    --   {"<Leader>A", "<Cmd>MultipleCursorsAddMatchesV<CR>", mode = {"n", "x"}, desc = "Add cursors to cword in previous area"},

    --   {"<Leader>d", "<Cmd>MultipleCursorsAddJumpNextMatch<CR>", mode = {"n", "x"}, desc = "Add cursor and jump to next cword"},
    --   {"<Leader>D", "<Cmd>MultipleCursorsJumpNextMatch<CR>", mode = {"n", "x"}, desc = "Jump to next cword"},

    --   {"<Leader>l", "<Cmd>MultipleCursorsLock<CR>", mode = {"n", "x"}, desc = "Lock virtual cursors"},
    -- },
    -- config = function()
    --     -- Ejemplo de configuración de multiple-cursors.nvim
    --     vim.g.multiple_cursors_use_default_mapping = 0 -- Desactiva mapeos por defecto si usas Hydra
    --     -- Puedes definir tus propios mapeos si lo prefieres
    -- end
}, {"nvimtools/hydra.nvim"} --   {
--     "smoka7/multicursors.nvim",
--     event = "VeryLazy",
--     dependencies = {
--         'nvimtools/hydra.nvim',
--     },
--     opts = {
--       updatetime = 5
--     },
--     cmd = { 'MCstart', 'MCvisual', 'MCclear', 'MCpattern', 'MCvisualPattern', 'MCunderCursor' },
--     config = function()
--       require("multicursors").setup({
--         updatetime = 5
--       })
--     end
-- }
}
