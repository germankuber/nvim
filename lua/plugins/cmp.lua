return {
  {
    "hrsh7th/nvim-cmp", -- Plugin principal de autocompletado
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- Fuente para LSP
      "hrsh7th/cmp-buffer", -- Fuente para el buffer actual
      "hrsh7th/cmp-path", -- Fuente para rutas
      "saadparwaiz1/cmp_luasnip", -- Fuente para snippets
      "L3MON4D3/LuaSnip", -- Manejador de snippets
    },
    config = function()
      local cmp = require "cmp"
      cmp.setup {
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body) -- Usa LuaSnip
          end,
        },
        mapping = {
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-y>"] = cmp.mapping.confirm { select = true },
          ["<C-Space>"] = cmp.mapping.complete(),
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        },
      }
    end,
  },
}
