-- ~/.config/nvim/lua/null-ls-config.lua

local null_ls = require("null-ls")

null_ls.setup({
  sources = {
    -- Formateadores
    null_ls.builtins.formatting.stylua, -- Para archivos .lua
    null_ls.builtins.formatting.taplo,  -- Para archivos .toml
  },
  -- Habilitar el formateo al guardar
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      -- Crea un grupo de autocmd para formatear al guardar
      vim.api.nvim_clear_autocmds({ group = "FormatOnSave", buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true }),
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({
            bufnr = bufnr,
            timeout_ms = 2000,
          })
        end,
      })
    end
  end,
})

