return {
  {
    "kevinhwang91/nvim-ufo",
    lazy = false,
    dependencies = { "kevinhwang91/promise-async" },
    config = function()
      -- Configuración de nvim-ufo
      vim.o.foldcolumn = "1" -- Puedes ajustar este valor
      vim.o.foldlevel = 99 -- Necesario para el proveedor de ufo
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      vim.fn.sign_define("FoldClosed", { text = "▸", texthl = "Folded" })
      vim.fn.sign_define("FoldOpen", { text = "▾", texthl = "Folded" })
      vim.fn.sign_define("FoldSeparator", { text = " ", texthl = "Folded" })
      -- Configura nvim-ufo
      require("ufo").setup()
    end,
  },
}
