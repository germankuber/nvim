return {
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        lazy=false,
        config = function() require("copilot").setup({}) end
    }
}
