local M = {}
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local snapshot_root = vim.fn.stdpath("data") .. "/file_versions"
local previewers = require("telescope.previewers")

-- Global variable to store the current file path
local current_filepath = nil

-- Custom previewer that loads the content into a buffer without opening the file
local function custom_previewer(filepath)
    return previewers.new_buffer_previewer({
        define_preview = function(self, entry, status)
            local full_path = filepath .. "/" .. entry.value
            if vim.fn.filereadable(full_path) == 1 then
                local lines = vim.fn.readfile(full_path)
                vim.api
                    .nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
                vim.api.nvim_buf_set_option(self.state.bufnr, "filetype",
                                            vim.fn.fnamemodify(full_path, ":e"))
                vim.api.nvim_buf_set_option(self.state.bufnr, "modifiable",
                                            false) -- Make the buffer read-only
            else
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false,
                                           {"File not found: " .. full_path})
            end
        end
    })
end
local function find_local_versioning_popup()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local ok, value = pcall(vim.api.nvim_buf_get_var, buf, "LocalVersioningTelescope")
        if ok and value == "LocalVersionReplace" then
            return buf
        end
    end
    return nil -- No se encontró ningún buffer con esta etiqueta
end
local function close_local_versioning_popup()
    local popup_buf = find_local_versioning_popup()
    if popup_buf then
        vim.api.nvim_buf_delete(popup_buf, { force = true })
    else
        vim.notify("No LocalVersionReplace popup found.", vim.log.levels.WARN)
    end
end
-- Function to count the number of different lines between two files
local function count_diff_lines(current_file, version_file)
    local diff_output = vim.fn.systemlist({
        "diff", "-U0", current_file, version_file
    })
    local diff_count = 0
    for _, line in ipairs(diff_output) do
        if vim.startswith(line, "@@") then diff_count = diff_count + 1 end
    end
    return diff_count
end

-- Function to open the selected version in diffview
local function diff_version(selection)
    if not selection then
        vim.notify("No version selected.", vim.log.levels.ERROR)
        return
    end
    if not current_filepath or current_filepath == "" then
        vim.notify("No file path available for diff.", vim.log.levels.ERROR)
        return
    end
    vim.cmd("vert diffsplit " .. vim.fn.shellescape(current_filepath) .. " " ..
                vim.fn.shellescape(selection.path))
end

local function reload_buffer(filepath)
    local buffers = vim.api.nvim_list_bufs()
    for _, buf in ipairs(buffers) do
        if vim.api.nvim_buf_get_name(buf) == filepath then
            vim.api.nvim_buf_call(buf, function()
                vim.cmd("edit!") -- Reload the buffer
            end)
            return
        end
    end
    vim.notify("No matching buffer found for: " .. filepath, vim.log.levels.WARN)
end

local function replace_with_version(selection)

    if not selection then
        vim.notify("No version selected.", vim.log.levels.ERROR)
        return
    end
    if vim.fn.filereadable(selection.path) ~= 1 then
        vim.notify("Selected version file is not readable.",
                   vim.log.levels.ERROR)
        return
    end
    if not current_filepath or current_filepath == "" then
        vim.notify("No file path available for replacement.",
                   vim.log.levels.ERROR)
        return
    end
    close_local_versioning_popup()
    -- Read the content of the selected version
    local lines = vim.fn.readfile(selection.path)

    -- Replace the content of the current buffer
    vim.api.nvim_buf_set_option(0, 'modifiable', true) -- Make sure buffer is modifiable
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(0, 'modifiable', false) -- Make buffer read-only again

    -- Write directly to the current file path
    local success, err = pcall(function()
        vim.fn.writefile(lines, current_filepath)
    end)

    if success then
        vim.notify("File replaced with version: " .. selection.display,
                   vim.log.levels.INFO)
        -- Close Telescope and reload the buffer

        reload_buffer(current_filepath)
    else
        vim.notify("Error replacing file: " .. err, vim.log.levels.ERROR)
    end
end

-- Function to handle key mappings for the Telescope picker (List Versions)
local function attach_mappings_list(prompt_bufnr, map)
    -- Ensure Telescope opens in normal mode
    vim.cmd("stopinsert")

    -- Function to open the selected version in diffview
    local function diff_version_action()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        diff_version(selection)
    end

    -- Function to replace the current file with the selected version
    local function replace_version_action()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        replace_with_version(selection)
    end

    -- Map <CR> to diff_version and <C-r> to replace_version
    map("i", "<CR>", diff_version_action) -- Enter: Open diffview
    map("n", "<CR>", diff_version_action)
    map("i", "<C-r>", replace_version_action) -- Ctrl+r: Replace with the selected version
    map("n", "<C-r>", replace_version_action)

    return true
end

-- General function to open Telescope picker
local function list_versions()
    current_filepath = vim.api.nvim_buf_get_name(0)
    if current_filepath == "" then
        vim.notify("No file detected. Please save the buffer first.",
                   vim.log.levels.ERROR)
        return
    end

    local file_dir = vim.fn.fnamemodify(current_filepath, ":h")
    local version_dir = snapshot_root .. "/" .. vim.fn.sha256(file_dir)

    if vim.fn.isdirectory(version_dir) == 0 or
        #vim.fn.globpath(version_dir, "*", false, true) == 0 then
        vim.notify("No versions found for this file.", vim.log.levels.ERROR)
        return
    end

    require("telescope.builtin").find_files({
        prompt_title = "File Versions (with Diff Lines)",
        cwd = version_dir,
        find_command = {"ls", "-t"},
        initial_mode = "normal",
        attach_mappings = function(prompt_bufnr, map)
            vim.api.nvim_buf_set_var(prompt_bufnr, "LocalVersioningTelescope", "LocalVersionReplace")
            vim.api.nvim_exec_autocmds("User", { pattern = "LocalVersioningTelescope" })

            attach_mappings_list(prompt_bufnr, map)
            return true
        end,
        entry_maker = function(entry)
            local match = string.match(entry, "-(%d+).")
            if match then
                local year, month, day, hour, minute, second = match:match(
                                                                   "(%d%d%d%d)(%d%d)(%d%d)(%d%d)(%d%d)(%d%d)")
                local diff_count = count_diff_lines(current_filepath,
                                                    version_dir .. "/" .. entry)
                return {
                    value = entry,
                    display = string.format("%s-%s-%s %s:%s:%s (%d diff lines)",
                                            year, month, day, hour, minute,
                                            second, diff_count),
                    ordinal = entry,
                    path = version_dir .. "/" .. entry
                }
            end
            return {
                value = entry,
                display = entry,
                ordinal = entry,
                path = version_dir .. "/" .. entry
            }
        end,
        previewer = custom_previewer(version_dir)
    })
end

-- Define user commands
vim.api.nvim_create_user_command('LocalVersionList',
                                 function() list_versions() end, {nargs = 0})

vim.api.nvim_create_user_command('LocalVersionDiff', function()
    local selection = action_state.get_selected_entry()
    diff_version(selection)
end, {nargs = 0})

vim.api.nvim_create_user_command('LocalVersionReplace', function()
    

    local selection = action_state.get_selected_entry()
    replace_with_version(selection)
end, {nargs = 0})

return M
