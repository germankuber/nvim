return {
    {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    lazy = false,
    autostart = true,
    event = "InsertEnter",
    config = function()
        require("copilot").setup({
            panel = {
                enabled = true,
                auto_refresh = true
            },
            suggestion = {
                enabled = true,
                auto_trigger = true
            },
            panel = {
                enabled = true
            }
        })
    end
}, {
    "zbirenbaum/copilot-cmp",
    dependencies = {"zbirenbaum/copilot.lua"},
    autostart = true,
    config = function()
        require("copilot_cmp").setup({
            sources = {{
                name = "copilot",
                group_index = 2
            }, {
                name = "nvim_lsp",
                group_index = 2
            }, {
                name = "path",
                group_index = 2
            }, {
                name = "luasnip",
                group_index = 2
            }}
        })
    end
}, {
    "CopilotC-Nvim/CopilotChat.nvim",
    lazy = false,
    branch = "main",
    dependencies = {{"github/copilot.vim"}, {"nvim-lua/plenary.nvim"}},
    build = "make tiktoken",
    config = function()
        require("CopilotChat").setup({})
    end
}
}
