require "config.init"

require "commands"
require "options"

require "config.sound"
require "plugins.run_with_alarm"
require "local_versioning"
require "telescope_versioning"

local builtin = require("telescope.builtin")

local function open_diagnostic_with_popup(prompt_bufnr, map)
    local action_set = require("telescope.actions.set")
    local actions = require("telescope.actions")

    -- Define the custom action
    local function open_and_show_diagnostic(selected_entry)
        actions.close(prompt_bufnr) -- Close Telescope
        -- Jump to the location of the diagnostic
        vim.api.nvim_set_current_win(selected_entry.bufnr)
        vim.api.nvim_win_set_cursor(0, {selected_entry.lnum, selected_entry.col - 1})
        -- Open the diagnostic popup
        vim.diagnostic.open_float(nil, {
            scope = "line"
        })
    end

    -- Apply the custom action
    action_set.select:replace(open_and_show_diagnostic)
    return true
end

-- Create custom diagnostics commands
vim.api.nvim_create_user_command("ListWarnings", function()
    builtin.diagnostics({
        severity = vim.diagnostic.severity.WARN,
        attach_mappings = open_diagnostic_with_popup
    })
end, {
    desc = "List global warnings using Telescope"
})

vim.api.nvim_create_user_command("ListErrors", function()
    builtin.diagnostics({
        severity = vim.diagnostic.severity.ERROR,
        attach_mappings = open_diagnostic_with_popup
    })
end, {
    desc = "List global errors using Telescope"
})

-- local Hydra = require("hydra")

-- Hydra({
--     name = "Multiple Cursor",
--     mode = "n", -- Modo normal
--     body = "<leader>sms", -- Tecla que activa el modo Hydra
--     heads = {{"l", '<cmd>:MultipleCursorsAddJumpNextMatch<CR>', {
--         desc = "Next line cursor",
--         exit = false
--     }}, {"k", '<cmd>:MultipleCursorsAddUp<CR>', {
--         desc = "Previous line cursor",
--         exit = false
--     }}, {"j", '<cmd>:MultipleCursorsAddDown<CR>', {
--         desc = "Next Match",
--         exit = false
--     }}, {"<Esc>", nil, {
--         desc = "Salir de Hydra",
--         exit = true
--     }}},
--     config = {
--         invoke_on_body = true,
--         hint = {
--             border = "single",
--             position = "middle"
--         },
--         on_enter = function()
--             vim.notify("Modo Hydra Activado", vim.log.levels.INFO)
--         end,
--         on_exit = function()
--             vim.notify("Modo Hydra Desactivado", vim.log.levels.INFO)
--         end,
--         hint = {
--             -- "window" | "cmdline" | "statusline" | "statuslinemanual"
--             --   "window": show hint in a floating window
--             --   "cmdline": show hint in the echo area
--             --   "statusline": show auto-generated hint in the status line
--             --   "statuslinemanual": Do not show a hint, but return a custom status
--             --                       line hint from require("hydra.statusline").get_hint()
--             type = "window", -- defaults to "window" if `hint` is passed to the hydra
--             -- otherwise defaults to "cmdline"

--             -- set the position of the hint window. one of:
--             --    top-left   |   top    |  top-right
--             --  -------------+----------+--------------
--             --   middle-left |  middle  | middle-right
--             --  -------------+----------+--------------
--             --   bottom-left |  bottom  | bottom-right
--             position = "middle",

--             -- Offset of the floating window from the nearest editor border
--             offset = 0,

--             -- options passed to `nvim_open_win()`, see :h nvim_open_win()
--             -- Lets you set border, header, footer, etc etc.
--             float_opts = {
--                 -- row, col, height, width, relative, and anchor should not be
--                 -- overridden
--                 -- style = "minimal",
--                 -- relative="win",
--                 -- -- row= 10,
--                 -- -- col= 10,
--                 -- width= 120,
--                 -- height= 3,
--                 focusable = false,
--                 noautocmd = true
--             },

--             -- show the hydras name (or "HYDRA:" if not given a name), at the
--             -- beginning of an auto-generated hint
--             show_name = true,

--             -- if set to true, this will prevent the hydra's hint window from displaying
--             -- immediately.
--             -- Note: you can still show the window manually by calling Hydra.hint:show()
--             -- and manually close it with Hydra.hint:close()
--             hide_on_load = false,

--             -- Table from function names to function. Functions should return
--             -- a string. These functions can be used in hints with %{func_name}
--             -- more in :h hydra-hint
--             funcs = {}
--         }
--     }
-- })
local moveline = require('moveline')
vim.keymap.set('n', '<C-y>', moveline.up)
vim.keymap.set('n', '<C-v>', moveline.down)
vim.keymap.set('v', '<C-y>', moveline.block_up)
vim.keymap.set('v', '<C-v>', moveline.block_down)

vim.keymap.set('n', '<C-u>', '<cmd>:MultipleCursorsAddUp<CR>')
vim.keymap.set('n', '<C-b>', '<cmd>:MultipleCursorsAddDown<CR>')
vim.keymap.set('n', '<C-n>', '<cmd>:MultipleCursorsAddJumpNextMatch<CR>')
vim.keymap.set('n', '<C-i>', '<cmd>lua require("multiple-cursors").align()<CR>')

vim.keymap.set('n', 'D', '"_dd', {
    noremap = true,
    silent = true
})

vim.keymap.set('v', 'D', '"_d', {
    noremap = true,
    silent = true
})


vim.cmd([[highlight Visual guibg=#A0D9B4 guifg=#000000]])
vim.o.scrolloff = 15
vim.opt.clipboard = "unnamedplus"

local opts = { noremap = true, silent = true }
vim.keymap.set('n', 'd', '"_d', opts)
vim.keymap.set('v', 'd', '"_d', opts)
vim.keymap.set('n', 'x', '"_x', opts)
vim.keymap.set('v', 'x', '"_x', opts)
