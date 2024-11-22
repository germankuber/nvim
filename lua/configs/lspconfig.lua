local lspconfig = require "lspconfig"
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Función para configurar keymaps para cada servidor
local on_attach = function(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }

  -- Keybindings LSP
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>fm", function()
    vim.lsp.buf.format { async = true }
  end, opts)
end

-- Configuración para JSON
lspconfig.jsonls.setup {
  settings = {
    json = {
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
    },
  },
  capabilities = capabilities,
  on_attach = on_attach,
}

-- Configuración para Lua
lspconfig.lua_ls.setup {
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
  capabilities = capabilities,
  on_attach = on_attach,
}

-- LSP para TOML
lspconfig.taplo.setup {
  capabilities = capabilities,
}

-- Configuración genérica para múltiples servidores
local servers = { "html", "cssls", "ts_ls", "pyright", "rust_analyzer" }

for _, server in ipairs(servers) do
  lspconfig[server].setup {
    capabilities = capabilities,
    on_attach = on_attach,
  }
end
