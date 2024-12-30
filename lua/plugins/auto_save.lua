return {
    {
        "okuuva/auto-save.nvim",
        version = "^1.0.0", -- see https://devhints.io/semver, alternatively use '*' to use the latest tagged release
        cmd = "ASToggle", -- optional for lazy loading on command
        event = {"InsertLeave", "TextChanged","BufLeave"}, -- optional for lazy loading on trigger events
        opts = {}
    }
} 

