require("config.lazy")
-- vim.opt.clipboard = "unnamedplus"

-- require "plugins.init"

-- -- Configurar null-ls
-- require "null-ls-config"

-- -- Configuración de LSP

-- local lspconfig = require "lspconfig"
-- local Terminal = require "utils.terminal"

-- -- Configuración de nvim-cmp
-- local cmp = require "cmp"

-- require("tokyonight").setup {
--     style = "night",
--     on_highlights = function(hl, c)
--         hl.Function = {fg = c.blue, italic = false, font = "Victor Mono"} -- Ajusta la fuente
--         hl.CursorLine = {bg = c.bg_highlight} -- Ajusta el fondo del cursorline
--     end
-- }

-- cmp.setup {
--     snippet = {
--         expand = function(args) require("luasnip").lsp_expand(args.body) end
--     },
--     mapping = {
--         ["<C-p>"] = cmp.mapping.select_prev_item(),
--         ["<C-n>"] = cmp.mapping.select_next_item(),
--         ["<C-y>"] = cmp.mapping.confirm {select = true},
--         ["<C-Space>"] = cmp.mapping.complete()
--     },
--     sources = {
--         {name = "nvim_lsp"}, {name = "buffer"}, {name = "path"},
--         {name = "luasnip"}
--     }
-- }

-- -- configs/lspconfig.lua
-- local lspconfig = require("lspconfig")

-- lspconfig.rust_analyzer.setup({
--     settings = {
--         ["rust-analyzer"] = {
--             assist = {importMergeBehavior = "last", importPrefix = "by_self"},
--             cargo = {loadOutDirsFromCheck = true},
--             procMacro = {enable = true},
--             inlayHints = {
--                 chainingHints = true,
--                 parameterHints = true,
--                 typeHints = true
--             }
--         }
--     },
--     on_attach = function(client, bufnr)
--         -- Habilitar inlay hints para Rust
--         require("lsp-inlayhints").on_attach(client, bufnr)
--     end
-- })

-- -- Auto abrir Nvim Tree al inicio
-- vim.api.nvim_create_autocmd("VimEnter", {
--     callback = function() require("nvim-tree.api").tree.open() end
-- })

-- vim.api.nvim_create_autocmd("BufWritePre", {
--     pattern = {"*.lua", "*.toml", "*.json"},
--     callback = function()
--         vim.lsp.buf.format {
--             bufnr = vim.api.nvim_get_current_buf(),
--             timeout_ms = 2000,
--             async = false
--         }
--     end
-- })

-- vim.opt.cursorline = true

-- local wk = require("which-key")

-- local function apply_mappings(group, parent_lhs, wk_mappings)
--     if not group or not group.commands then return end

--     -- Construye el prefijo acumulado
--     local base_lhs = (parent_lhs or "") .. (group.base_lhs or "")

--     -- Agrega el nombre del grupo si está definido
--     if group.title then
--         table.insert(wk_mappings, {base_lhs, group = group.title})
--     end

--     -- Itera sobre los comandos
--     for _, command in ipairs(group.commands) do
--         if command.commands then
--             -- Llama recursivamente para subgrupos
--             apply_mappings(command, base_lhs, wk_mappings)
--         else
--             -- Construye el mapeo individual
--             local lhs = base_lhs .. (command.lhs or "")
--             table.insert(wk_mappings, {lhs, desc = command.desc or ""})

--             -- Opcional: También mapea con vim.api.nvim_set_keymap si quieres soporte directo
--             local mode = command.mode or "n" -- Modo normal por defecto
--             local rhs = command.rhs or ""
--             local opts = {
--                 noremap = command.noremap ~= false,
--                 silent = command.silent ~= false
--             }
--             vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
--         end
--     end
-- end

-- local function load_and_apply_mappings(filepath)
--     local mappings_file = vim.fn.stdpath("config") .. "/lua/" .. filepath
--     local ok, content = pcall(vim.fn.readfile, mappings_file)
--     if not ok then
--         vim.notify("Error reading mappings file: " .. mappings_file,
--                    vim.log.levels.ERROR)
--         return
--     end

--     -- Lee y decodifica el JSON
--     local json_content = table.concat(content, "\n")
--     local mappings = vim.fn.json_decode(json_content)
--     if not mappings then
--         vim.notify("Invalid JSON format in mappings file: " .. mappings_file,
--                    vim.log.levels.ERROR)
--         return
--     end

--     -- Recolecta todos los mapeos en formato de which-key
--     local wk_mappings = {}

--     -- Procesa cada grupo del JSON
--     for _, group in ipairs(mappings) do
--         apply_mappings(group, nil, wk_mappings)
--     end

--     -- Registra los mapeos usando wk.add
--     wk.add(wk_mappings)
-- end

-- -- Llama a la función con el archivo JSON
-- load_and_apply_mappings("mappings/mappings.json")

-- require('bookmarks').setup {
--     -- sign_priority = 8,  --set bookmark sign priority to cover other sign
--     save_file = vim.fn.expand "$HOME/.bookmarks", -- bookmarks save file path
--     keywords = {
--         ["@t"] = "✅", -- mark annotation startswith @t ,signs this icon as `Todo`
--         ["@w"] = "⚠️ ", -- mark annotation startswith @w ,signs this icon as `Warn`
--         ["@f"] = "⛏ ", -- mark annotation startswith @f ,signs this icon as `Fix`
--         ["@n"] = " " -- mark annotation startswith @n ,signs this icon as `Note`
--     }

-- }
-- require('telescope').load_extension('bookmarks')

-- require("lspconfig").rust_analyzer.setup({
--     settings = {
--         ["rust-analyzer"] = {
--             cargo = {allFeatures = true},
--             checkOnSave = {command = "clippy"},
--             procMacro = {enable = true}
--         }
--     }
-- })

-- vim.o.scrolloff = 5 -- Keep some context lines above/below the cursor
-- vim.o.sidescrolloff = 5 -- Keep some context lines to the left/right
-- vim.o.lazyredraw = false -- Ensure no delay in screen redrawing

-- vim.cmd([[
--   augroup InsertModeEnhancements
--     autocmd!
--     " Highlight cursorline in Insert mode
--     autocmd InsertEnter * hi CursorLine guibg=#3e4451
--     autocmd InsertLeave * hi CursorLine guibg=NONE
--     " Change cursorline visibility based on mode
--     autocmd InsertEnter * set cursorline
--     autocmd InsertLeave * set nocursorline
--   augroup END
-- ]])
-- vim.o.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

-- vim.cmd([[
--   " Change background when entering Insert mode
--   hi InsertModeBg guibg=#282c34
--   augroup InsertModeBackground
--     autocmd!
--    autocmd InsertEnter * hi Normal guibg=#1e1e2e
--     autocmd InsertLeave * hi Normal guibg=#11111b
--   augroup END
-- ]])

-- -- Configuración básica para nvim-ufo
-- vim.o.foldcolumn = '1'
-- vim.o.foldlevel = 99
-- vim.o.foldlevelstart = 99
-- vim.o.foldenable = true

-- -- Configuración de nvim-ufo
-- require('ufo').setup({
--     fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
--         local newVirtText = {}
--         local suffix = (' 󰁂 %d '):format(endLnum - lnum)
--         local sufWidth = vim.fn.strdisplaywidth(suffix)
--         local targetWidth = width - sufWidth
--         local curWidth = 0
--         for _, chunk in ipairs(virtText) do
--             local chunkText = chunk[1]
--             local chunkWidth = vim.fn.strdisplaywidth(chunkText)
--             if targetWidth > curWidth + chunkWidth then
--                 table.insert(newVirtText, chunk)
--             else
--                 chunkText = truncate(chunkText, targetWidth - curWidth)
--                 table.insert(newVirtText, {chunkText, chunk[2]})
--                 break
--             end
--             curWidth = curWidth + chunkWidth
--         end
--         table.insert(newVirtText, {suffix, 'MoreMsg'})
--         return newVirtText
--     end
-- })

-- require('diffview').setup({
--     enhanced_diff_hl = true, -- Opcional, resalta mejor las diferencias.
--     use_icons = true -- Opcional, usa íconos si están disponibles.
-- })
-- -- require('telescope').load_exten
-- -- sion('fzf')
-- local overlay = vim.api.nvim_create_buf(false, true)

-- require("notify").setup({
--     stages = "slide", -- Use the fade_in_slide_out animation
--     timeout = 600, -- Duration for notifications (in milliseconds)
--     background_colour = "#000000", -- Background color for notifications
--     icons = {
--         ERROR = "",
--         WARN = "",
--         INFO = "",
--         DEBUG = "",
--         TRACE = "✎"
--     }
-- })

-- vim.api.nvim_set_hl(0, "NotifySUCCESS", {fg = "#00ff00", bg = "#000000"}) -- Green for success

-- local neogit = require('neogit')
-- neogit.setup {}

-- vim.o.clipboard = "unnamedplus"

