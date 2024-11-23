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


function M.list_and_delete_sessions()
    local sessions_dir = vim.fn.stdpath("state") .. "/sessions/"
    local session_files = vim.fn.globpath(sessions_dir, "*.vim", false, true)

    if #session_files == 0 then
        vim.notify("No sessions found.", vim.log.levels.INFO)
        return
    end

    local sessions = {}
    for _, file in ipairs(session_files) do
        table.insert(sessions, vim.fn.fnamemodify(file, ":t:r")) -- Add file names without extensions
    end

    -- Custom function to find the index of an element in a table
    local function find_index(tbl, value)
        for i, v in ipairs(tbl) do
            if v == value then
                return i
            end
        end
        return nil
    end

    require("telescope.pickers").new({}, {
        prompt_title = "Delete Sessions",
        finder = require("telescope.finders").new_table({
            results = sessions,
        }),
        sorter = require("telescope.config").values.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            map("i", "<CR>", function()
                local selected = require("telescope.actions.state").get_selected_entry(prompt_bufnr)

                if selected then
                    local session_path = sessions_dir .. selected.value .. ".vim"
                    local success, err = os.remove(session_path)

                    if success then
                        vim.notify("Session deleted: " .. selected.value, vim.log.levels.INFO)
                        -- Remove the deleted session from the list
                        local index = find_index(sessions, selected.value)
                        if index then
                            table.remove(sessions, index)
                        end

                        if #sessions == 0 then
                            -- Close the popup if no sessions remain
                            vim.notify("No more sessions left.", vim.log.levels.INFO)
                            require("telescope.actions").close(prompt_bufnr)
                        else
                            -- Update the Telescope finder dynamically
                            require("telescope.actions.state").get_current_picker(prompt_bufnr):refresh(
                                require("telescope.finders").new_table({ results = sessions }),
                                { reset_prompt = true }
                            )
                        end
                    else
                        vim.notify("Failed to delete session: " .. err, vim.log.levels.ERROR)
                    end
                end
            end)
            return true
        end,
    }):find()
end

return M
