vim.api.nvim_set_keymap("n", "<C-u>", "", { noremap = true, silent = true }) -- Deshabilitar en modo normal
vim.api.nvim_set_keymap("v", "<C-u>", "", { noremap = true, silent = true }) -- Deshabilitar en modo visual
vim.api.nvim_set_keymap("i", "<C-u>", "", { noremap = true, silent = true }) -- Deshabilitar en modo inserción
vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
-- bootstrap lazy and all plugins
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

-- load theme
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

-- Configurar LSP para Lua
local lspconfig = require "lspconfig"

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
        -- Asegúrate de que el formateo está habilitado
        if client.supports_method "textDocument/formatting" then
            -- Opcional: Otras configuraciones específicas de LSP
        end
    end,
}
-- Configurar LSP para TOML usando Taplo
lspconfig.taplo.setup {}

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.lua", "*.toml" },
    callback = function()
        vim.lsp.buf.format {
            bufnr = vim.api.nvim_get_current_buf(),
            timeout_ms = 2000,
            async = false,
        }
    end,
})

require("cmp").setup {
    -- other setup
    sources = {
        { name = "copilot" },
        { name = "nvim_lsp" },
        { name = "luasnip" },
        -- other sources
    },
}

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
}
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        require("nvim-tree.api").tree.open()
    end,
})
vim.api.nvim_set_keymap("o", "<C-u>", "<Plug>(VM-Find-Under)", {})
vim.api.nvim_set_keymap("n", "<C-u>", "<Plug>(VM-Find-Under)", {})         -- Modo normal: seleccionar palabra bajo el cursor
vim.api.nvim_set_keymap("x", "<C-u>", "<Plug>(VM-Find-Subword-Under)", {}) -- Modo visual: seleccionar texto arbitrario
