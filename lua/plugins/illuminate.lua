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

      -- Mapeos de teclas para vim-illuminate
      vim.keymap.set("n", "<leader>n", function()
        require("illuminate").goto_next_reference(false)
      end, { desc = "Next reference" })

      vim.keymap.set("n", "<leader>N", function()
        require("illuminate").goto_prev_reference(false)
      end, { desc = "Previous reference" })
    end,
  },
}
