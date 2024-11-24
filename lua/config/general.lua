require("config.lazy")
require("config.bookmarks")
require("config.telescope_buffers")
require("config.terminal")
require("config.sessions")
require('config.jump_config')
require('config.sound')


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
-- Context lines around the cursor
vim.o.scrolloff = 5 -- Keep some context lines above/below the cursor
vim.o.sidescrolloff = 5 -- Keep some context lines to the left/right

-- Redrawing and cursor enhancements
vim.o.lazyredraw = false -- Ensure no delay in screen redrawing
vim.o.cursorline = true -- Highlight the current line
vim.o.cursorcolumn = true -- Highlight the current column

-- Cursor appearance based on mode
vim.o.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

-- Dynamic cursorline and cursorcolumn highlighting
vim.cmd([[
  augroup CursorLineColumnEnhancements
    autocmd!
    " Highlight cursorline and cursorcolumn with specific colors in Insert mode
    autocmd InsertEnter * hi CursorLine guibg=#3e4451
    autocmd InsertEnter * hi CursorColumn guibg=#3e4451
    autocmd InsertLeave * hi CursorLine guibg=#1e1e2e
    autocmd InsertLeave * hi CursorColumn guibg=#1e1e2e
    " Ensure cursorline and cursorcolumn stay enabled in all modes
    autocmd InsertEnter,InsertLeave * set cursorline cursorcolumn
  augroup END
]])

-- Background color adjustment in Insert mode
vim.cmd([[
  hi InsertModeBg guibg=#282c34
  augroup InsertModeBackground
    autocmd!
    autocmd InsertEnter * hi Normal guibg=#1e1e2e
    autocmd InsertLeave * hi Normal guibg=#11111b
  augroup END
]])

-- Basic configuration for nvim-ufo
vim.o.foldcolumn = '1'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
 

vim.opt.virtualedit = "onemore" -- Allow cursor one more position past EOL, but we handle this with mappings















-- -- Custom Movement Functions for Neovim

-- -- Function to get the column of the first non-whitespace character in a line
-- local function get_first_non_ws_col(line)
--   local first_non_ws = string.find(line, "%S")
--   if first_non_ws then
--       return first_non_ws
--   else
--       return 1
--   end
-- end

-- -- Function to get the last column of a line
-- local function get_last_col(line)
--   return #line
-- end

-- -- Variable to store the desired column when moving vertically
-- local desired_col = nil

-- -- Variable to track if the cursor is at the end of a line
-- local is_at_line_end = false

-- -- Function to set the desired column before moving vertically
-- local function set_desired_col()
--   desired_col = vim.fn.col('.')
-- end

-- -- Function to restore the desired column after moving vertically
-- local function restore_col(line)
--   local first_non_ws = get_first_non_ws_col(line)
--   local last_col = get_last_col(line)
  
--   if desired_col < first_non_ws then
--       -- If the desired column is before the first non-whitespace character, move to the first character
--       vim.fn.cursor(vim.fn.line('.'), first_non_ws)
--   elseif desired_col > last_col then
--       -- If the desired column is after the last character, move to the last character
--       vim.fn.cursor(vim.fn.line('.'), last_col)
--   else
--       -- If the desired column is within the line's bounds, move to the desired column
--       vim.fn.cursor(vim.fn.line('.'), desired_col)
--   end
  
--   -- Update the line end status
--   is_at_line_end = (vim.fn.col('.') == last_col)
-- end

-- -- Custom function for the 'h' key (move left or jump to the end of the previous non-blank line)
-- local function custom_h()
--   local line = vim.fn.getline('.')
--   local first_non_ws = get_first_non_ws_col(line)
--   local current_col = vim.fn.col('.')
  
--   if current_col > first_non_ws then
--       -- Move cursor one position to the left if it's beyond the first non-whitespace character
--       vim.cmd('normal! h')
--   elseif current_col == first_non_ws then
--       -- If at the first non-whitespace character, jump to the end of the previous non-blank line
--       local target_line = vim.fn.line('.') - 1  -- Start checking from the previous line
      
--       -- Loop to find the previous non-blank line
--       while target_line >= 1 do
--           local line_content = vim.fn.getline(target_line)
--           if not line_content:match("^%s*$") then
--               break  -- Found a non-blank line
--           end
--           target_line = target_line - 1
--       end
      
--       if target_line >= 1 then
--           local target_line_content = vim.fn.getline(target_line)
--           local target_last_col = get_last_col(target_line_content)
--           vim.fn.cursor(target_line, target_last_col)  -- Move to the last character of the target line
--           desired_col = target_last_col  -- Update desired_col to the new position
--           is_at_line_end = true  -- Set the state to end of line
--       end
--       -- If no non-blank line is found, do nothing
--   end
  
--   -- Update the line end status
--   local new_line = vim.fn.getline('.')
--   local new_last_col = get_last_col(new_line)
--   local new_col = vim.fn.col('.')
--   is_at_line_end = (new_col == new_last_col)
-- end

-- -- Custom function for the 'l' key (move right or jump to the beginning of the next non-blank line)
-- local function custom_l()
--   local line = vim.fn.getline('.')
--   local last_col = get_last_col(line)
--   local current_col = vim.fn.col('.')
  
--   if current_col < last_col then
--       -- Move cursor one position to the right if it's before the last character
--       vim.cmd('normal! l')
--   elseif current_col == last_col then
--       -- If at the last character, jump to the first non-whitespace character of the next non-blank line
--       local target_line = vim.fn.line('.') + 1  -- Start checking from the next line
      
--       -- Loop to find the next non-blank line
--       while target_line <= vim.fn.line('$') do
--           local line_content = vim.fn.getline(target_line)
--           if not line_content:match("^%s*$") then
--               break  -- Found a non-blank line
--           end
--           target_line = target_line + 1
--       end
      
--       if target_line <= vim.fn.line('$') then
--           local target_line_content = vim.fn.getline(target_line)
--           local first_non_ws = get_first_non_ws_col(target_line_content)
--           vim.fn.cursor(target_line, first_non_ws)  -- Move to the first non-whitespace character of the target line
--           desired_col = first_non_ws  -- Update desired_col to the new position
--           is_at_line_end = (first_non_ws == get_last_col(target_line_content))  -- Update state
--       end
--       -- If no non-blank line is found, do nothing
--   end
  
--   -- Update the line end status
--   local new_line = vim.fn.getline('.')
--   local new_last_col = get_last_col(new_line)
--   local new_col = vim.fn.col('.')
--   is_at_line_end = (new_col == new_last_col)
-- end

-- -- Custom function for the 'j' key (move down, skipping blank lines)
-- local function custom_j()
--   set_desired_col()  -- Store the current column before moving
--   local target_line = vim.fn.line('.') + 1  -- Start checking from the next line
  
--   if is_at_line_end then
--       -- If currently at the end of a line, jump to the end of the next non-blank line
--       while target_line <= vim.fn.line('$') do
--           local line_content = vim.fn.getline(target_line)
--           if not line_content:match("^%s*$") then
--               break  -- Found a non-blank line
--           end
--           target_line = target_line + 1
--       end
      
--       if target_line <= vim.fn.line('$') then
--           local target_line_content = vim.fn.getline(target_line)
--           local target_last_col = get_last_col(target_line_content)
--           vim.fn.cursor(target_line, target_last_col)  -- Move to the last character of the target line
--           desired_col = target_last_col  -- Update desired_col to the new position
--           is_at_line_end = true  -- Remain in end-of-line mode
--       end
--       -- If no non-blank line is found, do nothing
--   else
--       -- If not at the end of a line, perform standard vertical movement
--       -- Loop to find the next non-blank line
--       while target_line <= vim.fn.line('$') do
--           local line_content = vim.fn.getline(target_line)
--           if not line_content:match("^%s*$") then
--               break  -- Found a non-blank line
--           end
--           target_line = target_line + 1
--       end
      
--       if target_line <= vim.fn.line('$') then
--           -- Move to the target line
--           vim.fn.cursor(target_line, 1)  -- Move to the first character (will be adjusted)
--           local line = vim.fn.getline('.')
--           restore_col(line)  -- Adjust the column based on the new line
--       end
--   end
-- end

-- -- Custom function for the 'k' key (move up, skipping blank lines)
-- local function custom_k()
--   set_desired_col()  -- Store the current column before moving
--   local target_line = vim.fn.line('.') - 1  -- Start checking from the previous line
  
--   if is_at_line_end then
--       -- If currently at the end of a line, jump to the end of the previous non-blank line
--       while target_line >= 1 do
--           local line_content = vim.fn.getline(target_line)
--           if not line_content:match("^%s*$") then
--               break  -- Found a non-blank line
--           end
--           target_line = target_line - 1
--       end
      
--       if target_line >= 1 then
--           local target_line_content = vim.fn.getline(target_line)
--           local target_last_col = get_last_col(target_line_content)
--           vim.fn.cursor(target_line, target_last_col)  -- Move to the last character of the target line
--           desired_col = target_last_col  -- Update desired_col to the new position
--           is_at_line_end = true  -- Remain in end-of-line mode
--       end
--       -- If no non-blank line is found, do nothing
--   else
--       -- If not at the end of a line, perform standard vertical movement
--       -- Loop to find the previous non-blank line
--       while target_line >= 1 do
--           local line_content = vim.fn.getline(target_line)
--           if not line_content:match("^%s*$") then
--               break  -- Found a non-blank line
--           end
--           target_line = target_line - 1
--       end
      
--       if target_line >= 1 then
--           -- Move to the target line
--           vim.fn.cursor(target_line, 1)  -- Move to the first character (will be adjusted)
--           local line = vim.fn.getline('.')
--           restore_col(line)  -- Adjust the column based on the new line
--       end
--   end
-- end

-- -- Map the movement keys to the custom functions in normal mode
-- vim.keymap.set('n', 'h', custom_h, { noremap = true, silent = true })
-- vim.keymap.set('n', 'l', custom_l, { noremap = true, silent = true })
-- vim.keymap.set('n', 'j', custom_j, { noremap = true, silent = true })
-- vim.keymap.set('n', 'k', custom_k, { noremap = true, silent = true })
 
 

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

vim.api.nvim_set_hl(0, "NotifySUCCESS", {fg = "#00ff00", bg = "#000000"}) -- Green for success

-- local neogit = require('neogit')
-- neogit.setup {}

-- vim.o.clipboard = "unnamedplus"

