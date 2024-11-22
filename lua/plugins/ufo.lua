return {
  {
    "kevinhwang91/nvim-ufo",
    lazy = false,
    dependencies = { "kevinhwang91/promise-async" },
    config = function()
      -- Configuración básica
      vim.o.foldcolumn = "1"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      -- Configura los símbolos de plegado
      require("ufo").setup {
        fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
          local newVirtText = {}
          local suffix = ("   %d lines "):format(endLnum - lnum)
          local sufWidth = vim.fn.strdisplaywidth(suffix)
          local targetWidth = width - sufWidth
          local curWidth = 0
          for _, chunk in ipairs(virtText) do
            local chunkText = chunk[1]
            local chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if targetWidth > curWidth + chunkWidth then
              table.insert(newVirtText, chunk)
            else
              chunkText = truncate(chunkText, targetWidth - curWidth)
              table.insert(newVirtText, { chunkText, chunk[2] })
              chunkWidth = vim.fn.strdisplaywidth(chunkText)
              -- Ensure `suffix` is added
              curWidth = curWidth + chunkWidth
              break
            end
            curWidth = curWidth + chunkWidth
          end
          table.insert(newVirtText, { suffix, "MoreMsg" })
          return newVirtText
        end,
      }

      -- Define los símbolos globales de plegado
      vim.fn.sign_define("FoldClosed", { text = "▸", texthl = "Folded" })
      vim.fn.sign_define("FoldOpen", { text = "▾", texthl = "Folded" })
      vim.fn.sign_define("FoldSeparator", { text = " ", texthl = "Folded" })
    end,
  },
}
