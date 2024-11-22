vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true

-- Bootstrap Lazy.nvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
vim.o.sessionoptions = "buffers,curdir,tabpages,winsize,localoptions"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.g.VM_default_mappings = 1
vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- Load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require "plugins" -- Asegúrate de que tus plugins estén cargados

-- Configurar null-ls
require "null-ls-config"

-- Configuración de LSP

local lspconfig = require "lspconfig"

local capabilities = require("cmp_nvim_lsp").default_capabilities()
lspconfig.jsonls.setup {
  settings = {
    json = {
      schemas = require("schemastore").json.schemas(), -- Mueve esto aquí
      validate = { enable = true },
    },
  },
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
}
-- LSP para Lua
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
  on_attach = function(client, bufnr)
    if client.supports_method "textDocument/formatting" then
      vim.keymap.set("n", "<leader>fm", vim.lsp.buf.format, { buffer = bufnr })
    end
  end,
  capabilities = capabilities,
}

-- LSP para TOML
lspconfig.taplo.setup {
  capabilities = capabilities,
}

-- Configuración de nvim-cmp
local cmp = require "cmp"

cmp.setup {
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
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
    { name = "luasnip" },
  },
}

-- Rust tools setup
require("rust-tools").setup {
  server = {
    capabilities = capabilities,
    on_attach = function(_, bufnr)
      -- local opts = { noremap = true, silent = true, buffer = bufnr }
      -- vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "LSP Rename" }))
      -- vim.keymap.set(
      --   "n",
      --   "<leader>ra",
      --   vim.lsp.buf.code_action,
      --   vim.tbl_extend("force", opts, { desc = "Code actions" })
      -- )
      -- vim.keymap.set(
      --   "n",
      --   "<leader>rg",
      --   vim.lsp.buf.code_action_group,
      --   vim.tbl_extend("force", opts, { desc = "Code actions group" })
      -- )
      -- vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      -- vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    end,
    settings = {
      ["rust-analyzer"] = {
        cargo = { allFeatures = true },
        checkOnSave = { command = "clippy" },
      },
    },
  },
}

-- Configuración de Nvim Tree
require("nvim-tree").setup {
  view = {
    width = 50,
    number = true,
    relativenumber = true,
  },
  update_focused_file = {
    enable = true,
    update_cwd = true,
  },
  git = {
    enable = true,
    ignore = false,
    timeout = 500,
  },
  filters = {
    dotfiles = false,
    custom = {
      "^.cargo$",
      "^.git$", -- Filter out .git directory
      "^.github$", -- Filter out .github directory
      "^.idea$", -- Filter out .idea directory
      "^target$", -- Filter out target directory
      "^.DS_Store$", -- Filter out .DS_Store file
    },
  },
  renderer = {
    group_empty = true,
  },
}

-- Auto abrir Nvim Tree al inicio
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("nvim-tree.api").tree.open()
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.lua", "*.toml", "*.json" },
  callback = function()
    vim.lsp.buf.format {
      bufnr = vim.api.nvim_get_current_buf(),
      timeout_ms = 2000,
      async = false,
    }
  end,
})
