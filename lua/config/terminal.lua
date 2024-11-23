local M = {}
local Popup = require("nui.popup")
local popup_terminal = nil -- Keep track of the popup terminal
local is_hidden = false -- Track if the terminal is minimized

-- Toggle terminal function
function M.toggle()
    if popup_terminal then
        if is_hidden then
            -- Restore the terminal
            popup_terminal:show()
            is_hidden = false
        else
            -- Minimize the terminal
            popup_terminal:hide()
            is_hidden = true
        end
        return
    end

    -- Create a new popup terminal
    popup_terminal = Popup({
        enter = true,
        focusable = true,
        border = {
            style = "rounded",
            text = {top = " Terminal ", top_align = "center"}
        },
        position = "50%",
        size = {width = 140, height = 30},
        win_options = {
            winblend = 10,
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder"
        }
    })

    -- Mount the popup
    popup_terminal:mount()
    vim.cmd("startinsert!")

    -- Open the terminal inside the popup and get the buffer number
    local term_bufnr = popup_terminal.bufnr
    if term_bufnr and term_bufnr > 0 then
        vim.fn.termopen(os.getenv("SHELL") or "/bin/sh") -- Open terminal in the popup buffer

        -- Set key mappings for the terminal buffer
        vim.api.nvim_buf_set_keymap(term_bufnr, "t", "<Esc>", [[<C-\><C-n>]],
                                    {noremap = true, silent = true}) -- Exit terminal mode
    else
        vim.notify("Failed to create terminal buffer", vim.log.levels.ERROR)
        popup_terminal:unmount()
        popup_terminal = nil
        return
    end

    -- Close the popup when focus is lost
    popup_terminal:on("BufLeave", function()
        popup_terminal:hide()
        is_hidden = true
    end)
end

return M