return {
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        ---@type Flash.Config
        opts = {},
        -- stylua: ignore
        keys = {
            {"s", mode = {"n", "x", "o"}, function()
                    require("flash").jump()
                end, desc = "Flash"},
            {"S", mode = {"n", "x", "o"}, function()
                    require("flash").treesitter()
                end, desc = "Flash Treesitter"},
            {"r", mode = "o", function()
                    require("flash").remote()
                end, desc = "Remote Flash"},
            {"R", mode = {"o", "x"}, function()
                    require("flash").treesitter_search()
                end, desc = "Treesitter Search"},
            {"<c-s>", mode = {"c"}, function()
                    require("flash").toggle()
                end, desc = "Toggle Flash Search"}
        }
    },
    -- {
    --     'andymass/vim-matchup',
    --     setup = function()
    --         -- may set any options here
    --         vim.g.matchup_matchparen_offscreen = {method = "popup"}
    --     end
    -- }
    {
        "stevearc/aerial.nvim",
        opts = {},
        -- Optional dependencies
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons"
        },
        setup = function()
            require("aerial").setup(
                {
                    -- Default symbol kinds to display; modify as needed
                    filter_kind = {
                        "Class",
                        "Constructor",
                        "Enum",
                        "Function",
                        "Interface",
                        "Module",
                        "Method",
                        "Struct"
                    }
                }
            )
        end
    }
}
