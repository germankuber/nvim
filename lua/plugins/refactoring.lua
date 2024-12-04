return {{
    "aznhe21/actions-preview.nvim",
    lazy = false,
    config = function()
        require("actions-preview").setup({
            diff = {
                algorithm = "patience",
                ignore_whitespace = true
            },
            telescope = require("telescope.themes").get_dropdown {
                winblend = 10
            }
        })

    end
}}
