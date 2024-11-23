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
  -- {
  --   "NvChad/NvChad",
  --   lazy = false,
  --   branch = "v2.5",
  --   import = "nvchad.plugins",
  -- },

  { import = "plugins" },
}, lazy_config)

-- Load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

-- require "options"
-- require "nvchad.autocmds"

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
local Terminal = require "utils.terminal"

-- Configuración de nvim-cmp
local cmp = require "cmp"

require("tokyonight").setup {
  style = "night",
  on_highlights = function(hl, c)
    hl.Function = { fg = c.blue, italic = false, font = "Victor Mono" } -- Ajusta la fuente
    hl.CursorLine = { bg = c.bg_highlight } -- Ajusta el fondo del cursorline
  end,
}


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

vim.opt.cursorline = true
local wk = require("which-key")

local function apply_mappings(group, parent_lhs, wk_mappings)
  if not group or not group.commands then
    return
  end

  -- Construye el prefijo acumulado
  local base_lhs = (parent_lhs or "") .. (group.base_lhs or "")

  -- Agrega el nombre del grupo si está definido
  if group.title then
    table.insert(wk_mappings, { base_lhs, group = group.title })
  end

  -- Itera sobre los comandos
  for _, command in ipairs(group.commands) do
    if command.commands then
      -- Llama recursivamente para subgrupos
      apply_mappings(command, base_lhs, wk_mappings)
    else
      -- Construye el mapeo individual
      local lhs = base_lhs .. (command.lhs or "")
      table.insert(wk_mappings, { lhs, desc = command.desc or "" })

      -- Opcional: También mapea con vim.api.nvim_set_keymap si quieres soporte directo
      local mode = command.mode or "n" -- Modo normal por defecto
      local rhs = command.rhs or ""
      local opts = {
        noremap = command.noremap ~= false,
        silent = command.silent ~= false,
      }
      vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
    end
  end
end

local function load_and_apply_mappings(filepath)
  local mappings_file = vim.fn.stdpath("config") .. "/lua/" .. filepath
  local ok, content = pcall(vim.fn.readfile, mappings_file)
  if not ok then
    vim.notify("Error reading mappings file: " .. mappings_file, vim.log.levels.ERROR)
    return
  end

  -- Lee y decodifica el JSON
  local json_content = table.concat(content, "\n")
  local mappings = vim.fn.json_decode(json_content)
  if not mappings then
    vim.notify("Invalid JSON format in mappings file: " .. mappings_file, vim.log.levels.ERROR)
    return
  end

  -- Recolecta todos los mapeos en formato de which-key
  local wk_mappings = {}

  -- Procesa cada grupo del JSON
  for _, group in ipairs(mappings) do
    apply_mappings(group, nil, wk_mappings)
  end

  -- Registra los mapeos usando wk.add
  wk.add(wk_mappings)
end

-- Llama a la función con el archivo JSON
load_and_apply_mappings("mappings/mappings.json")
