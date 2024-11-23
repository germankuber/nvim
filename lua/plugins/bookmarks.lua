return {
    {
        "tomasky/bookmarks.nvim",
        lazy = false,
        
        config = function() require("bookmarks").setup() end
    }
}
