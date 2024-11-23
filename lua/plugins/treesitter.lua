return {
 {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate", -- Descarga y actualiza los parsers
  config = function()
    require("nvim-treesitter.configs").setup {
      ensure_installed = { "rust", "lua", "json", "html", "css", "javascript", "typescript" }, -- Ajusta según tus necesidades
      highlight = {
        enable = true, -- Activa el resaltado de sintaxis
        -- additional_vim_regex_highlighting = false,
      },
    }
  end,
}
}
