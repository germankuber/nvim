return {
    {
        "FabijanZulj/blame.nvim",
        lazy = false,
        config = function()
            require("blame").setup {}
        end,
        opts = {blame_options = {"-w"}}
    },
    {
        "SuperBo/fugit2.nvim",
        lazy = false,
        opts = {width = 100},
        dependencies = {
            "MunifTanjim/nui.nvim",
            "lewis6991/gitsigns.nvim",
            "nvim-tree/nvim-web-devicons",
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
            {
                "chrisgrieser/nvim-tinygit",
                dependencies = {"stevearc/dressing.nvim"}
            }
        },
        cmd = {"Fugit2", "Fugit2Diff", "Fugit2Graph"}
    },
    {
        "sindrets/diffview.nvim",
        dependencies = {"nvim-lua/plenary.nvim"},
        opts = {
            enhanced_diff_hl = true
        },
        cmd = {
            "DiffviewOpen",
            "DiffviewClose",
            "DiffviewToggleFiles",
            "DiffviewFocusFiles"
        }
    }
}
