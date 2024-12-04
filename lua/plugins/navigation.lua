return {
    -- {
    --     'andymass/vim-matchup',
    --     setup = function()
    --         -- may set any options here
    --         vim.g.matchup_matchparen_offscreen = {method = "popup"}
    --     end
    -- }
    {
        'stevearc/aerial.nvim',
        opts = {},
        -- Optional dependencies
        dependencies = {
            "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons"
        },
        setup = function()
            require('aerial').setup({
                -- Default symbol kinds to display; modify as needed
                filter_kind = {
                    "Class", "Constructor", "Enum", "Function", "Interface",
                    "Module", "Method", "Struct"
                }
            })
        end
    }
}
