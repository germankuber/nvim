return {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "onsails/lspkind.nvim"  -- Agregamos lspkind.nvim como dependencia
    },
    config = function()
      local cmp = require("cmp")
      local lspkind = require("lspkind")
  
      cmp.setup({
        mapping = {
          ["<C-j>"] = cmp.mapping.select_next_item({
            behavior = cmp.SelectBehavior.Insert
          }),
          ["<C-k>"] = cmp.mapping.select_prev_item({
            behavior = cmp.SelectBehavior.Insert
          }),
          ["<C-l>"] = cmp.mapping.confirm({
            select = true
          })
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 10 },  -- Funciones LSP
          { name = "buffer",    priority = 7 },  -- Texto del buffer
          { name = "path",      priority = 5 },  -- Rutas de archivos
          { name = "luasnip",   priority = 3 }   -- Snippets
        }),
        sorting = {
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            function(entry1, entry2)
              local kind_priority = {
                [cmp.lsp.CompletionItemKind.Function] = 1,
                [cmp.lsp.CompletionItemKind.Text]     = 2,
                [cmp.lsp.CompletionItemKind.Snippet]  = 3
              }
              local kind1 = entry1:get_kind()
              local kind2 = entry2:get_kind()
              return (kind_priority[kind1] or 100) < (kind_priority[kind2] or 100)
            end,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order
          }
        },
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",  -- Muestra tanto ícono como texto
            maxwidth = 50,         -- Ancho máximo de la ventana emergente
            ellipsis_char = "..."  -- Caracter para indicar texto truncado
            -- Puedes ajustar otras opciones de configuración de lspkind aquí si lo deseas
          })
        }
      })
    end
  }
  