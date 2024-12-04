return {
    {
        "benfowler/telescope-luasnip.nvim",
        lazy = false,
        module = "telescope._extensions.luasnip"
    },
    {
        "L3MON4D3/LuaSnip",
        dependencies = {"rafamadriz/friendly-snippets"},
        lazy = false,
        config = function()
            require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/lua/config/snippets"})
            luasnip = require("luasnip")        
            vim.keymap.set(
                {"i", "s"},
                "<Tab>",
                function()
                    if luasnip.expand_or_jumpable() then
                        return luasnip.expand_or_jump()
                    else
                        return "<Tab>"
                    end
                end,
                {expr = true, silent = true}
            )

            vim.keymap.set(
                {"i", "s"},
                "<S-Tab>",
                function()
                    if luasnip.jumpable(-1) then
                        return luasnip.jump(-1)
                    else
                        return "<S-Tab>"
                    end
                end,
                {expr = true, silent = true}
            )
        end
    }
}
