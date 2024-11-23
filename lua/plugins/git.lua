return {
    {
        'f-person/git-blame.nvim',
        lazy = false,
        config = function() vim.g.gitblame_delay = 50 end
    }, {
        'sindrets/diffview.nvim',
        lazy = false,

        dependencies = 'nvim-lua/plenary.nvim',
        config = function() require('diffview').setup() end
    }

}
