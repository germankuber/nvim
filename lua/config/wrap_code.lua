-- ~/.config/nvim/lua/myplugins/wrap.lua

--------------------------------------------------------------------
-- A simpler approach to wrapping the current visual selection
-- in a pair of symbols. We yank the selection, build the wrapped
-- string, and then replace the selection.
--------------------------------------------------------------------

local M = {}

-- Map of opening symbols to their closing counterparts
local pairs_map = {
    ["("] = ")",
    ["{"] = "}",
    ["["] = "]",
    ["<"] = ">",
    ["'"] = "'",
    ['"'] = '"',
}

--------------------------------------------------------------------
-- Helper function: Yank the currently highlighted visual selection
-- into a temporary register and return it as a Lua string.
--------------------------------------------------------------------
function M.get_visual_selection()
    -- Save whatever is in the default register
    local saved_reg = vim.fn.getreg('"')
    local saved_regtype = vim.fn.getregtype('"')

    -- Yank the visual selection into register z
    -- `gv` reselects the last visual area, `"zy` yanks into register z
    vim.cmd('normal! gv"zy')

    -- Retrieve the yanked text
    local content = vim.fn.getreg('z')

    -- Restore the default register
    vim.fn.setreg('"', saved_reg, saved_regtype)

    return content
end

--------------------------------------------------------------------
-- Helper function: Replace the previously visual-selected text
-- with new_text. We'll reselect the last visual area (gv) and then
-- do a change operation (c) to paste the new text in place.
--------------------------------------------------------------------
function M.replace_visual_selection(new_text)
    -- Reselect the last visual selection
    vim.cmd('normal! gv')

    -- Delete the selection to the black hole register ("_) 
    -- and enter insert mode to paste
    vim.cmd('normal! "_c')

    -- Use the Neovim Lua API to put new_text in place
    vim.api.nvim_put({ new_text }, "c", true, true)
end

--------------------------------------------------------------------
-- Main function to wrap the current visual selection with a symbol.
-- For example, selecting text and pressing "(" will produce
-- (selected_text).
--------------------------------------------------------------------
function M.wrap_selection(symbol)
    local close_symbol = pairs_map[symbol]
    if not close_symbol then
        print("Unsupported symbol for wrapping: " .. tostring(symbol))
        return
    end

    -- Yank the visual selection into Lua
    local content = M.get_visual_selection()

    -- Build the new wrapped string
    local wrapped_text = symbol .. content .. close_symbol

    -- Replace the old selection with the wrapped version
    M.replace_visual_selection(wrapped_text)
end

--------------------------------------------------------------------
-- Setup keymaps in visual mode. Pressing these keys in visual mode
-- will wrap the selected text with the corresponding pairs.
--------------------------------------------------------------------
function M.setup()
    vim.keymap.set('v', '(', function() M.wrap_selection('(') end, { noremap = true, silent = true })
    vim.keymap.set('v', '{', function() M.wrap_selection('{') end, { noremap = true, silent = true })
    vim.keymap.set('v', '[', function() M.wrap_selection('[') end, { noremap = true, silent = true })
    vim.keymap.set('v', '<', function() M.wrap_selection('<') end, { noremap = true, silent = true })
    vim.keymap.set('v', '"', function() M.wrap_selection('"') end, { noremap = true, silent = true })
    vim.keymap.set('v', "'", function() M.wrap_selection("'") end, { noremap = true, silent = true })
end

M.setup()

return M
