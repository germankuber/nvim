return {
  {
    "RRethy/vim-illuminate",
    lazy = false,
    config = function()
      require("illuminate").configure {
        -- Opciones de configuración (opcional)
        providers = {
          "lsp",
          "regex",
        },
        delay = 200,
        filetypes_denylist = {
          "dirvish",
          "fugitive",
          "NvimTree",
          "packer",
          "qf",
          "help",
        },
        -- Puedes agregar más opciones si lo deseas
      }
    end,
  },
}
