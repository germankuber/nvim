return {
    -- {
    --     "zbirenbaum/copilot.lua",
    --     cmd = "Copilot",
    --     lazy = false,
    --     event = "InsertEnter",
    --     config = function()
    --         require("copilot").setup(
    --             {
    --                 panel = {enabled = true, auto_refresh = true},
    --                 suggestion = {enabled = true, auto_trigger = true},
    --                 panel = {enabled = true}
    --             }
    --         )
    --     end
    -- },
    --  {
    --     "zbirenbaum/copilot-cmp",
    --     dependencies = {"zbirenbaum/copilot.lua"},
    --     config = function() require("copilot_cmp").setup() end
    -- },
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        lazy = false,
        branch = "main",
        dependencies = {
            {"github/copilot.vim"},
            {"nvim-lua/plenary.nvim"}
        },
        build = "make tiktoken",
        config = function()
            require("CopilotChat").setup({})
        end
    }
}
