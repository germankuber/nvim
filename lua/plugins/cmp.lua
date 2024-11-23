return {
    {
        "hrsh7th/nvim-cmp", -- Plugin principal de autocompletado
        dependencies = {
            "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip"
        },
        config = function()
            local cmp = require("cmp")
            cmp.setup({
                mapping = {
                    ["<Tab>"] = cmp.mapping.select_next_item(), -- Mover al siguiente ítem
                    ["<S-Tab>"] = cmp.mapping.select_prev_item(), -- Mover al ítem previo
                    ["<CR>"] = cmp.mapping.confirm({select = true}) -- Confirmar selección
                },
                sources = {
                    {name = "nvim_lsp"}, -- Autocompletado desde LSP
                    {name = "buffer"}, -- Autocompletado desde el buffer abierto
                    {name = "path"} -- Autocompletado para rutas de archivo
                }
            })
        end
    }

}
