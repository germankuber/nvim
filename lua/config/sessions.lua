local M = {}

local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")
local conf = require("telescope.config").values

-- Function to parse session file and extract open files
local function parse_session_files(session_path)
    local files = {}
    local session_content = vim.fn.readfile(session_path)

    for _, line in ipairs(session_content) do
        local file = line:match("edit%s+(.+)")
        if not file then file = line:match("tabedit%s+(.+)") end
        if not file then file = line:match("vsplit%s+(.+)") end
        if not file then file = line:match("split%s+(.+)") end
        if file then
            file = file:gsub('^["\']', ''):gsub('["\']$', '')
            table.insert(files, file)
        end
    end

    return files
end

-- Custom function to find the index of a session in a table based on 'name'
local function find_index(tbl, value)
    for i, v in ipairs(tbl) do if v.name == value then return i end end
    return nil
end

-- Save a session
function M.save_session()
    local popup = Popup({
        enter = true,
        focusable = true,
        border = {
            style = "rounded",
            text = {top = " Save Session ", top_align = "center"}
        },
        position = "50%",
        size = {width = 40, height = 2},
        win_options = {
            winblend = 10,
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder"
        }
    })

    popup:mount()

    vim.api.nvim_buf_set_option(popup.bufnr, "buftype", "prompt")
    vim.fn.prompt_setprompt(popup.bufnr, "")

    vim.cmd("startinsert!")

    popup:map("i", "<CR>", function()
        local session_name = vim.trim(vim.fn.getline("."))
        if session_name == "" then
            vim.notify("Session name cannot be empty!", "error",
                       {title = "Session"})
        else
            local sessions_dir = vim.fn.stdpath("state") .. "/sessions/"
            if vim.fn.isdirectory(sessions_dir) == 0 then
                vim.fn.mkdir(sessions_dir, "p")
            end
            local session_path = sessions_dir .. session_name .. ".vim"
            vim.cmd("mksession! " .. session_path)
            vim.g.current_session_name = session_name
            vim.notify("Session saved: " .. session_name, "success",
                       {title = "Session", highlight = "NotifySUCCESS", icon = "✔️"})
        end
        popup:unmount()
        vim.cmd("stopinsert")
    end, {noremap = true, silent = true})

    popup:map("i", "<Esc>", function()
        vim.notify("Session save canceled", "warn", {title = "Session"})
        popup:unmount()
        vim.cmd("stopinsert")
    end, {noremap = true, silent = true})

    popup:on(event.BufLeave, function()
        popup:unmount()
        -- vim.notify("Session save canceled", "warn", { title = "Session" })
        vim.cmd("stopinsert")
    end)
end

-- Load a session
function M.load_session()
    local session_name = vim.fn.input("Session Name to Load: ")
    if session_name == "" then
        vim.notify("Session name cannot be empty!", "error", {title = "Session"})
        return
    end

    local session_path =
        vim.fn.stdpath("state") .. "/sessions/" .. session_name .. ".vim"
    if vim.fn.filereadable(session_path) == 0 then
        vim.notify("Session not found: " .. session_name, "error",
                   {title = "Session"})
        return
    end

    vim.cmd("source " .. session_path)
    vim.g.current_session_name = session_name -- Set the loaded session as current
    vim.notify("Session loaded: " .. session_name, "info", {title = "Session"})
end

-- List and delete sessions with file details
function M.list_and_delete_sessions()
    local sessions_dir = vim.fn.stdpath("state") .. "/sessions/"
    local session_files = vim.fn.globpath(sessions_dir, "*.vim", false, true)

    if #session_files == 0 then
        vim.notify("No sessions found.", "info", {title = "Session"})
        return
    end

    local sessions = {}
    for _, file in ipairs(session_files) do
        local session_name = vim.fn.fnamemodify(file, ":t:r")
        local files = parse_session_files(file)
        local files_preview = table.concat(files, ", ")
        table.insert(sessions, {name = session_name, files = files_preview})
    end

    pickers.new({}, {
        prompt_title = "Delete Sessions",
        finder = finders.new_table({
            results = sessions,
            entry_maker = function(entry)
                return {
                    value = entry.name,
                    display = string.format("%s -> Files: %s", entry.name,
                                            entry.files),
                    ordinal = entry.name .. entry.files
                }
            end
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            map("i", "<CR>", function()
                local selected = actions_state.get_selected_entry(prompt_bufnr)

                if selected then
                    local session_path =
                        sessions_dir .. selected.value .. ".vim"
                    local success, err = os.remove(session_path)

                    if success then
                        vim.notify("Session deleted: " .. selected.value,
                                   "error", {title = "Session", timeout = 1000})
                        local index = find_index(sessions, selected.value)
                        if index then
                            table.remove(sessions, index)
                        end

                        if #sessions == 0 then
                            vim.notify("No more sessions left.", "info",
                                       {title = "Session"})
                            actions.close(prompt_bufnr)
                        else
                            actions_state.get_current_picker(prompt_bufnr):refresh(
                                finders.new_table({
                                    results = sessions,
                                    entry_maker = function(entry)
                                        return {
                                            value = entry.name,
                                            display = string.format(
                                                "%s -> Files: %s", entry.name,
                                                entry.files),
                                            ordinal = entry.name .. entry.files
                                        }
                                    end
                                }), {reset_prompt = true})
                        end
                    else
                        vim.notify("Failed to delete session: " .. err, "error",
                                   {title = "Session"})
                    end
                end
            end)
            return true
        end
    }):find()
end

-- Overwrite the current session
function M.overwrite_current_session()
    local session_name = vim.g.current_session_name
    if not session_name or session_name == "" then
        vim.notify("No active session to overwrite!", "error",
                   {title = "Session"})
        return
    end

    local session_path =
        vim.fn.stdpath("state") .. "/sessions/" .. session_name .. ".vim"
    vim.cmd("mksession! " .. session_path)
    vim.notify("Session overwritten: " .. session_name, "info",
               {title = "Session"})
end

return M
