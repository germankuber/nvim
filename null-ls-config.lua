-- ~/.config/nvim/lua/null-ls-config.lua

local null_ls = require("null-ls")

null_ls.setup({
  debug = true, -- Habilitar depuración
  sources = {
    null_ls.builtins.formatting.stylua, -- Formateador para Lua
    null_ls.builtins.formatting.taplo,  -- Formateador para TOML
  },
  on_attach = function(client, bufnr)
    print("null-ls on_attach called for buffer " .. bufnr)
    if client.supports_method("textDocument/formatting") then
      print("Client supports formatting")
      -- Crear un grupo de autocmd para formatear al guardar
      local group = vim.api.nvim_create_augroup("LspFormatting", { clear = true })

      vim.api.nvim_create_autocmd("BufWritePre", {
        group = group,
        buffer = bufnr,
        callback = function()
          print("Formatting before save")
          vim.lsp.buf.format({
            bufnr = bufnr,
            timeout_ms = 2000,
            async = false,
          })
        end,
      })
    else
      print("Client does not support formatting")
    end
  end,
})

