local M = {}

local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

function M.save_session()
    local popup = Popup({
        enter = true,
        focusable = true,
        border = {
            style = "rounded",
            text = {
                top = " Save Session ",
                top_align = "center",
            },
        },
        position = "50%",
        size = {
            width = 40,
            height = 2,
        },
        win_options = {
            winblend = 10,
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
        },
    })

    popup:mount()

    -- Set up the buffer for input
    vim.api.nvim_buf_set_option(popup.bufnr, "buftype", "prompt")
    vim.fn.prompt_setprompt(popup.bufnr, "Session Name: ")

    -- Handle input on Enter
    popup:map("i", "<CR>", function()
        local session_name = vim.trim(vim.fn.getline(1))
        if session_name == "" then
            vim.notify("Session name cannot be empty!", vim.log.levels.ERROR)
        else
            local session_path = vim.fn.stdpath("state") .. "/sessions/" .. session_name .. ".vim"
            vim.cmd("mksession! " .. session_path)
            vim.notify("Session saved: " .. session_name, vim.log.levels.INFO)
        end
        popup:unmount()
        vim.api.nvim_command("stopinsert") -- Exit insert mode after saving
    end, { noremap = true, silent = true })

    -- Close the popup on Escape
    popup:map("i", "<Esc>", function()
        vim.notify("Session save canceled", vim.log.levels.INFO)
        popup:unmount()
        vim.api.nvim_command("stopinsert") -- Exit insert mode after canceling
    end, { noremap = true, silent = true })

    popup:on(event.BufLeave, function()
        popup:unmount()
        vim.api.nvim_command("stopinsert") -- Ensure exit from insert mode on leave
    end)
end

function M.load_session()
    local session_name = vim.fn.input("Session Name to Load: ")
    if session_name == "" then
        vim.notify("Session name cannot be empty!", vim.log.levels.ERROR)
        return
    end

    local session_path = vim.fn.stdpath("state") .. "/sessions/" .. session_name .. ".vim"
    if vim.fn.filereadable(session_path) == 0 then
        vim.notify("Session not found: " .. session_name, vim.log.levels.ERROR)
        return
    end

    vim.cmd("source " .. session_path)
    vim.notify("Session loaded: " .. session_name, vim.log.levels.INFO)
end

return M
