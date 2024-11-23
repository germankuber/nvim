return {

    {
        'SuperBo/fugit2.nvim',
        lazy = false,
        opts = {width = 100},
        dependencies = {
            'MunifTanjim/nui.nvim', "lewis6991/gitsigns.nvim",
            'nvim-tree/nvim-web-devicons', 'nvim-lua/plenary.nvim',
            'sindrets/diffview.nvim', -- Aquí agregamos diffview.nvim
            {
                'chrisgrieser/nvim-tinygit', -- Opcional: para vista de PRs en GitHub
                dependencies = {'stevearc/dressing.nvim'}
            }
        },
        cmd = {'Fugit2', 'Fugit2Diff', 'Fugit2Graph'},
    }, {
        'f-person/git-blame.nvim',
        lazy = false,
        config = function()
            vim.g.gitblame_enabled = 0
            vim.cmd("GitBlameDisable")
            vim.g.gitblame_delay = 50
        end
    }, {
        "NeogitOrg/neogit",
        lazy = false,
        dependencies = {
            "nvim-lua/plenary.nvim", -- required
            "sindrets/diffview.nvim", -- optional - Diff integration
            -- Only one of these is needed.
            "nvim-telescope/telescope.nvim", -- optional
            "ibhagwan/fzf-lua", -- optional
            "echasnovski/mini.pick" -- optional
        },
        config = true
    }, {
        'sindrets/diffview.nvim',
        dependencies = {'nvim-lua/plenary.nvim'},
        opts = {
            enhanced_diff_hl = true -- Opcional: mejora el resaltado del diff
        },
        cmd = {
            'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles',
            'DiffviewFocusFiles'
        }
    }
}
