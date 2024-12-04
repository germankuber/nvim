return {
    -- {
    --     "zbirenbaum/copilot.lua",
    --     cmd = "Copilot",
    --     event = "InsertEnter",
    
    --     config = function()
    --         require("copilot").setup({
    --             panel = {enabled = true, auto_refresh = true},
    --             suggestion = {enabled = true, auto_trigger = true},
    --             panel = {enabled = true}
    --         })
    --     end
    -- }, {
    --     "zbirenbaum/copilot-cmp",
    --     dependencies = {"zbirenbaum/copilot.lua"},
    --     config = function() require("copilot_cmp").setup() end
    -- },
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        lazy = false,
        branch = "canary",
        dependencies = {
            {"github/copilot.vim"}, -- or zbirenbaum/copilot.lua
            {"nvim-lua/plenary.nvim"} -- for curl, log wrapper
        },
        build = "make tiktoken", -- Only on MacOS or Linux
        config = function() require("CopilotChat").setup({}) end
        -- See Commands section for default commands if you want to lazy load on them
    }
}
