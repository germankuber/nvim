-- funny_clipboard.lua

local M = {}

-- Dependencies
local has_telescope, telescope = pcall(require, 'telescope')
if not has_telescope then
    vim.notify("Telescope is not installed. Please install Telescope to use FunnyClipboard.", vim.log.levels.ERROR)
    return
end

local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local previewers = require('telescope.previewers')

-- Clipboard storage file path
local clipboard_file = vim.fn.stdpath('data') .. '/funny_clipboard.json'

-- Function to load clipboard data from the JSON file
local function load_clipboard()
    local file = io.open(clipboard_file, "r")
    if not file then return {} end
    local content = file:read("*a")
    file:close()
    local status, data = pcall(vim.fn.json_decode, content)
    if status and type(data) == 'table' then
        return data
    else
        vim.notify("Failed to decode clipboard data. Starting with an empty clipboard.", vim.log.levels.WARN)
        return {}
    end
end

-- Function to save clipboard data to the JSON file
local function save_clipboard(data)
    local file = io.open(clipboard_file, "w")
    if file then
        file:write(vim.fn.json_encode(data))
        file:close()
    else
        vim.notify("Error saving clipboard data.", vim.log.levels.ERROR)
    end
end

-- Initialize clipboard by loading existing data
M.clipboard = load_clipboard()

-- Function to add a new entry to the clipboard
function M.add(text, category, filetype)
    table.insert(M.clipboard, { text = text, category = category, filetype = filetype or 'text', timestamp = os.time() })
    save_clipboard(M.clipboard)
end

-- Function to retrieve clipboard entries by category
function M.get_by_category(category)
    local results = {}
    for _, item in ipairs(M.clipboard) do
        if item.category == category then
            table.insert(results, item)
        end
    end
    return results
end

-- Function to retrieve all unique categories
function M.get_categories()
    local categories = {}
    for _, item in ipairs(M.clipboard) do
        if not vim.tbl_contains(categories, item.category) then
            table.insert(categories, item.category)
        end
    end
    return categories
end

-- Function to sanitize text by replacing newlines with "\n" to prevent errors in Telescope
local function sanitize_text(text)
    return text:gsub("\n", "\\n")
end

-- General function to open a Telescope picker
local function open_picker(opts)
    pickers.new({}, {
        prompt_title = opts.prompt_title,
        finder = opts.finder,
        sorter = sorters.get_generic_fuzzy_sorter(),
        previewer = opts.previewer,
        attach_mappings = opts.attach_mappings,
        initial_mode = 'normal',
    }):find()
end

-- Function to copy text with category and automatically detect filetype
function M.copy_with_category()
    vim.cmd('stopinsert')

    local mode = vim.fn.mode()
    local text
    if mode:sub(1,1) == 'v' then
        vim.cmd('noau normal! "vy"')
        text = vim.fn.getreg('v')
    else
        vim.cmd('noau normal! yy')
        text = vim.fn.getreg('"')
    end

    vim.ui.input({ prompt = 'Category: ' }, function(category)
        if category and category ~= '' then
            local filetype = vim.bo.filetype
            M.add(text, category, filetype)
            vim.notify("Copied with category: " .. category .. (filetype and (", filetype: " .. filetype) or ""), vim.log.levels.INFO)
        else
            vim.notify("Empty category. Text not saved.", vim.log.levels.WARN)
        end
    end)
end

-- Function to paste text based on selected category using Telescope
function M.paste_with_category()
    vim.cmd('stopinsert')

    local categories = M.get_categories()
    if vim.tbl_isempty(categories) then
        vim.notify("No categories available in the clipboard.", vim.log.levels.WARN)
        return
    end

    local function select_category(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        M.paste_selection(selection[1])
    end

    local function on_esc(prompt_bufnr)
        actions.close(prompt_bufnr)
    end

    open_picker({
        prompt_title = "Select Category",
        finder = finders.new_table { results = categories },
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(select_category)
            map('i', '<Esc>', on_esc)
            map('n', '<Esc>', on_esc)
            return true
        end,
    })
end

-- Helper function to paste the selected text from a category
function M.paste_selection(category)
    local items = M.get_by_category(category)
    if vim.tbl_isempty(items) then
        vim.notify("No items found for category: " .. category, vim.log.levels.WARN)
        return
    end

    local entries = {}
    for _, item in ipairs(items) do
        table.insert(entries, item.text)
    end

    local function paste_entry(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        local lines = vim.split(selection[1], "\n")
        vim.api.nvim_put(lines, 'l', true, true)
        vim.notify("Pasted text from category: " .. category, vim.log.levels.INFO)
    end

    local function on_esc(prompt_bufnr)
        actions.close(prompt_bufnr)
        M.paste_with_category()
    end

    local function define_preview(self, entry)
        for _, item in ipairs(M.clipboard) do
            if item.text == entry[1] then
                vim.api.nvim_buf_set_option(self.state.bufnr, 'filetype', item.filetype or 'text')
                break
            end
        end
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(entry[1], "\n"))
    end

    open_picker({
        prompt_title = "Select Text to Paste",
        finder = finders.new_table { results = entries },
        previewer = previewers.new_buffer_previewer({ define_preview = define_preview }),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(paste_entry)
            map('i', '<Esc>', on_esc)
            map('n', '<Esc>', on_esc)
            return true
        end,
    })
end

-- Function to list all clipboard entries using Telescope
function M.list_clipboard()
    vim.cmd('stopinsert')

    if vim.tbl_isempty(M.clipboard) then
        vim.notify("Clipboard is empty.", vim.log.levels.INFO)
        return
    end

    local entries = {}
    for i, item in ipairs(M.clipboard) do
        local sanitized_text = sanitize_text(item.text)
        table.insert(entries, string.format("[%d] [%s] %s", i, item.category, sanitized_text))
    end

    local function define_preview(self, entry)
        local index = tonumber(entry[1]:match("^%[(%d+)%]"))
        if index and M.clipboard[index] then
            vim.api.nvim_buf_set_option(self.state.bufnr, 'filetype', M.clipboard[index].filetype or 'text')
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(M.clipboard[index].text, "\n"))
        else
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, {"No preview available."})
        end
    end

    open_picker({
        prompt_title = "FunnyClipboard - Clipboard Entries",
        finder = finders.new_table { results = entries },
        previewer = previewers.new_buffer_previewer({ define_preview = define_preview }),
        attach_mappings = function(_, _)
            return true
        end,
    })
end

-- Function to delete a category and all its entries
function M.delete_category()
    vim.cmd('stopinsert')

    local function delete_category_picker()
        local categories = M.get_categories()
        if vim.tbl_isempty(categories) then
            vim.notify("No categories available to delete.", vim.log.levels.INFO)
            return
        end

        local function delete_category_action(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            vim.ui.select({"Yes", "No"}, { prompt = "Delete all entries in category '" .. selection[1] .. "'?" }, function(choice)
                if choice == "Yes" then
                    M.clipboard = vim.tbl_filter(function(item)
                        return item.category ~= selection[1]
                    end, M.clipboard)
                    save_clipboard(M.clipboard)
                    vim.notify("Deleted all entries in category: " .. selection[1], vim.log.levels.INFO)
                    delete_category_picker()
                else
                    delete_category_picker()
                end
            end)
        end

        local function on_esc(prompt_bufnr)
            actions.close(prompt_bufnr)
        end

        open_picker({
            prompt_title = "Select Category to Delete",
            finder = finders.new_table { results = categories },
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(delete_category_action)
                map('i', '<Esc>', on_esc)
                map('n', '<Esc>', on_esc)
                return true
            end,
        })
    end

    delete_category_picker()
end

-- Function to delete a specific clipboard entry
function M.delete_entry()
    vim.cmd('stopinsert')

    local function delete_entry_picker()
        if vim.tbl_isempty(M.clipboard) then
            vim.notify("Clipboard is empty. No entries to delete.", vim.log.levels.INFO)
            return
        end

        local entries = {}
        for i, item in ipairs(M.clipboard) do
            local sanitized_text = sanitize_text(item.text)
            table.insert(entries, string.format("[%d] [%s] %s", i, item.category, sanitized_text))
        end

        local function delete_entry_action(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            local index = tonumber(selection[1]:match("^%[(%d+)%]"))
            if index and M.clipboard[index] then
                actions.close(prompt_bufnr)
                vim.ui.select({"Yes", "No"}, { prompt = "Delete this entry?" }, function(choice)
                    if choice == "Yes" then
                        table.remove(M.clipboard, index)
                        save_clipboard(M.clipboard)
                        vim.notify("Deleted entry #" .. index, vim.log.levels.INFO)
                        delete_entry_picker()
                    else
                        delete_entry_picker()
                    end
                end)
            else
                actions.close(prompt_bufnr)
                vim.notify("Invalid selection.", vim.log.levels.ERROR)
            end
        end

        local function define_preview(self, entry)
            local index = tonumber(entry[1]:match("^%[(%d+)%]"))
            if index and M.clipboard[index] then
                vim.api.nvim_buf_set_option(self.state.bufnr, 'filetype', M.clipboard[index].filetype or 'text')
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(M.clipboard[index].text, "\n"))
            else
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, {"No preview available."})
            end
        end

        local function on_esc(prompt_bufnr)
            actions.close(prompt_bufnr)
        end

        open_picker({
            prompt_title = "Select Entry to Delete",
            finder = finders.new_table { results = entries },
            previewer = previewers.new_buffer_previewer({ define_preview = define_preview }),
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(delete_entry_action)
                map('i', '<Esc>', on_esc)
                map('n', '<Esc>', on_esc)
                return true
            end,
        })
    end

    delete_entry_picker()
end

-- Function to copy a specific clipboard entry to the system clipboard
function M.copy_entry()
    vim.cmd('stopinsert')

    if vim.tbl_isempty(M.clipboard) then
        vim.notify("Clipboard is empty. No entries to copy.", vim.log.levels.WARN)
        return
    end

    local entries = {}
    for i, item in ipairs(M.clipboard) do
        local sanitized_text = sanitize_text(item.text)
        table.insert(entries, string.format("[%d] [%s] %s", i, item.category, sanitized_text))
    end

    local function copy_entry(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        local index = tonumber(selection[1]:match("^%[(%d+)%]"))
        if index and M.clipboard[index] then
            vim.fn.setreg('+', M.clipboard[index].text)
            vim.notify("Copied entry #" .. index .. " to system clipboard.", vim.log.levels.INFO)
        else
            vim.notify("Invalid selection.", vim.log.levels.ERROR)
        end
    end

    local function define_preview(self, entry)
        local index = tonumber(entry[1]:match("^%[(%d+)%]"))
        if index and M.clipboard[index] then
            vim.api.nvim_buf_set_option(self.state.bufnr, 'filetype', M.clipboard[index].filetype or 'text')
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(M.clipboard[index].text, "\n"))
        else
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, {"No preview available."})
        end
    end

    local function on_esc(prompt_bufnr)
        actions.close(prompt_bufnr)
    end

    open_picker({
        prompt_title = "Select Entry to Copy to Clipboard",
        finder = finders.new_table { results = entries },
        previewer = previewers.new_buffer_previewer({ define_preview = define_preview }),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(copy_entry)
            map('i', '<Esc>', on_esc)
            map('n', '<Esc>', on_esc)
            return true
        end,
    })
end

-- Function to paste a specific clipboard entry directly into the buffer
function M.paste_entry()
    vim.cmd('stopinsert')

    if vim.tbl_isempty(M.clipboard) then
        vim.notify("Clipboard is empty. No entries to paste.", vim.log.levels.WARN)
        return
    end

    local entries = {}
    for i, item in ipairs(M.clipboard) do
        local sanitized_text = sanitize_text(item.text)
        table.insert(entries, string.format("[%d] [%s] %s", i, item.category, sanitized_text))
    end

    local function paste_entry(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        local index = tonumber(selection[1]:match("^%[(%d+)%]"))
        if index and M.clipboard[index] then
            local lines = vim.split(M.clipboard[index].text, "\n")
            vim.api.nvim_put(lines, 'l', true, true)
            vim.notify("Pasted entry #" .. index .. " from category: " .. M.clipboard[index].category, vim.log.levels.INFO)
        else
            vim.notify("Invalid selection.", vim.log.levels.ERROR)
        end
    end

    local function define_preview(self, entry)
        local index = tonumber(entry[1]:match("^%[(%d+)%]"))
        if index and M.clipboard[index] then
            vim.api.nvim_buf_set_option(self.state.bufnr, 'filetype', M.clipboard[index].filetype or 'text')
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(M.clipboard[index].text, "\n"))
        else
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, {"No preview available."})
        end
    end

    local function on_esc(prompt_bufnr)
        actions.close(prompt_bufnr)
    end

    open_picker({
        prompt_title = "Select Entry to Paste",
        finder = finders.new_table { results = entries },
        previewer = previewers.new_buffer_previewer({ define_preview = define_preview }),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(paste_entry)
            map('i', '<Esc>', on_esc)
            map('n', '<Esc>', on_esc)
            return true
        end,
    })
end

-- Function to delete all clipboard entries
function M.delete_all_entries()
    vim.cmd('stopinsert')

    if vim.tbl_isempty(M.clipboard) then
        vim.notify("Clipboard is already empty.", vim.log.levels.INFO)
        return
    end

    vim.ui.select({"Yes", "No"}, { prompt = "Are you sure you want to delete **all** clipboard entries?" }, function(choice)
        if choice == "Yes" then
            M.clipboard = {}
            save_clipboard(M.clipboard)
            vim.notify("All clipboard entries have been deleted.", vim.log.levels.INFO)
        else
            vim.notify("Deletion of all clipboard entries canceled.", vim.log.levels.INFO)
        end
    end)
end

-- Function to create user commands
function M.setup_commands()
    vim.api.nvim_create_user_command('FunnyClipboardWithCategoryCopy', M.copy_with_category, { desc = "Copy text with a category and automatic filetype detection" })
    vim.api.nvim_create_user_command('FunnyClipboardWithCategoryPaste', M.paste_with_category, { desc = "Paste text by selecting a category" })
    vim.api.nvim_create_user_command('FunnyClipboardWithCategoryList', M.list_clipboard, { desc = "List all clipboard entries with categories using Telescope" })
    vim.api.nvim_create_user_command('FunnyClipboardWithCategoryDeleteCategory', M.delete_category, { desc = "Delete a category and all its clipboard entries" })
    vim.api.nvim_create_user_command('FunnyClipboardWithCategoryDeleteEntry', M.delete_entry, { desc = "Delete a specific clipboard entry" })
    vim.api.nvim_create_user_command('FunnyClipboardWithCategoryCopyEntry', M.copy_entry, { desc = "Copy a specific clipboard entry to the system clipboard" })
    vim.api.nvim_create_user_command('FunnyClipboardPaste', M.paste_entry, { desc = "Paste a specific clipboard entry directly into the buffer" })
    vim.api.nvim_create_user_command('FunnyClipboardWithCategoryDeleteAll', M.delete_all_entries, { desc = "Delete all clipboard entries" })
end

-- Initialize the plugin by setting up commands
function M.setup()
    M.setup_commands()
end

-- Automatically setup when the module is required
M.setup()

return M
