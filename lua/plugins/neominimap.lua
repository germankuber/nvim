return {
    {
        "Isrothy/neominimap.nvim",
        version = "v3.*.*",
        enabled = true,
        keymaps = false,
        lazy = false, -- NOTE: NO NEED to Lazy load
        init = function()
            vim.opt.wrap = false
            vim.opt.sidescrolloff = 36 -- Set a large value
            ---@type Neominimap.UserConfig
            vim.g.neominimap = {
                auto_enable = true,
                mark = {
                    enabled = true, ---@type boolean
                    mode = "icon", ---@type Neominimap.Handler.Annotation.Mode
                    priority = 10, ---@type integer
                    key = "m", ---@type string
                    show_builtins = false ---@type boolean -- shows the builtin marks like [ ] < >
                }
            }
        end
    }
}
