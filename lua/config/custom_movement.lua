-- File: lua/custom/custom_movement.lua
local M = {}

-- Custom Movement Functions for Neovim

-- Function to get the column of the first non-whitespace character in a line
local function get_first_non_ws_col(line)
    local first_non_ws = string.find(line, "%S")
    if first_non_ws then
        return first_non_ws
    else
        return 1
    end
end

-- Function to get the last column of a line
local function get_last_col(line) return #line end

-- Variable to store the desired column when moving vertically
local desired_col = nil

-- Variable to track if the cursor is at the end of a line
local is_at_line_end = false

-- Function to set the desired column before moving vertically
local function set_desired_col() desired_col = vim.fn.col('.') end

-- Function to restore the desired column after moving vertically
local function restore_col(line)
    local first_non_ws = get_first_non_ws_col(line)
    local last_col = get_last_col(line)

    if desired_col < first_non_ws then
        -- If the desired column is before the first non-whitespace character, move to the first character
        vim.fn.cursor(vim.fn.line('.'), first_non_ws)
    elseif desired_col > last_col then
        -- If the desired column is after the last character, move to the last character
        vim.fn.cursor(vim.fn.line('.'), last_col)
    else
        -- If the desired column is within the line's bounds, move to the desired column
        vim.fn.cursor(vim.fn.line('.'), desired_col)
    end

    -- Update the line end status
    is_at_line_end = (vim.fn.col('.') == last_col)
end

-- Custom function for the 'h' key (move left or jump to the end of the previous non-blank line)
local function custom_h()
    local line = vim.fn.getline('.')
    local first_non_ws = get_first_non_ws_col(line)
    local current_col = vim.fn.col('.')

    if current_col > first_non_ws then
        -- Move cursor one position to the left if it's beyond the first non-whitespace character
        vim.cmd('normal! h')
    elseif current_col == first_non_ws then
        -- If at the first non-whitespace character, jump to the end of the previous non-blank line
        local target_line = vim.fn.line('.') - 1 -- Start checking from the previous line

        -- Loop to find the previous non-blank line
        while target_line >= 1 do
            local line_content = vim.fn.getline(target_line)
            if not line_content:match("^%s*$") then
                break -- Found a non-blank line
            end
            target_line = target_line - 1
        end

        if target_line >= 1 then
            local target_line_content = vim.fn.getline(target_line)
            local target_last_col = get_last_col(target_line_content)
            vim.fn.cursor(target_line, target_last_col) -- Move to the last character of the target line
            desired_col = target_last_col -- Update desired_col to the new position
            is_at_line_end = true -- Set the state to end of line
        end
        -- If no non-blank line is found, do nothing
    end

    -- Update the line end status
    local new_line = vim.fn.getline('.')
    local new_last_col = get_last_col(new_line)
    local new_col = vim.fn.col('.')
    is_at_line_end = (new_col == new_last_col)
end

-- Custom function for the 'l' key (move right or jump to the beginning of the next non-blank line)
local function custom_l()
    local line = vim.fn.getline('.')
    local last_col = get_last_col(line)
    local current_col = vim.fn.col('.')

    if current_col < last_col then
        -- Move cursor one position to the right if it's before the last character
        vim.cmd('normal! l')
    elseif current_col == last_col then
        -- If at the last character, jump to the first non-whitespace character of the next non-blank line
        local target_line = vim.fn.line('.') + 1 -- Start checking from the next line

        -- Loop to find the next non-blank line
        while target_line <= vim.fn.line('$') do
            local line_content = vim.fn.getline(target_line)
            if not line_content:match("^%s*$") then
                break -- Found a non-blank line
            end
            target_line = target_line + 1
        end

        if target_line <= vim.fn.line('$') then
            local target_line_content = vim.fn.getline(target_line)
            local first_non_ws = get_first_non_ws_col(target_line_content)
            vim.fn.cursor(target_line, first_non_ws) -- Move to the first non-whitespace character of the target line
            desired_col = first_non_ws -- Update desired_col to the new position
            is_at_line_end = (first_non_ws == get_last_col(target_line_content)) -- Update state
        end
        -- If no non-blank line is found, do nothing
    end

    -- Update the line end status
    local new_line = vim.fn.getline('.')
    local new_last_col = get_last_col(new_line)
    local new_col = vim.fn.col('.')
    is_at_line_end = (new_col == new_last_col)
end

-- Custom function for the 'j' key (move down, skipping blank lines)
local function custom_j()
    set_desired_col() -- Store the current column before moving
    local target_line = vim.fn.line('.') + 1 -- Start checking from the next line

    if is_at_line_end then
        -- If currently at the end of a line, jump to the end of the next non-blank line
        while target_line <= vim.fn.line('$') do
            local line_content = vim.fn.getline(target_line)
            if not line_content:match("^%s*$") then
                break -- Found a non-blank line
            end
            target_line = target_line + 1
        end

        if target_line <= vim.fn.line('$') then
            local target_line_content = vim.fn.getline(target_line)
            local target_last_col = get_last_col(target_line_content)
            vim.fn.cursor(target_line, target_last_col) -- Move to the last character of the target line
            desired_col = target_last_col -- Update desired_col to the new position
            is_at_line_end = true -- Remain in end-of-line mode
        end
        -- If no non-blank line is found, do nothing
    else
        -- If not at the end of a line, perform standard vertical movement
        -- Loop to find the next non-blank line
        while target_line <= vim.fn.line('$') do
            local line_content = vim.fn.getline(target_line)
            if not line_content:match("^%s*$") then
                break -- Found a non-blank line
            end
            target_line = target_line + 1
        end

        if target_line <= vim.fn.line('$') then
            -- Move to the target line
            vim.fn.cursor(target_line, 1) -- Move to the first character (will be adjusted)
            local line = vim.fn.getline('.')
            restore_col(line) -- Adjust the column based on the new line
        end
    end
end

-- Custom function for the 'k' key (move up, skipping blank lines)
local function custom_k()
    set_desired_col() -- Store the current column before moving
    local target_line = vim.fn.line('.') - 1 -- Start checking from the previous line

    if is_at_line_end then
        -- If currently at the end of a line, jump to the end of the previous non-blank line
        while target_line >= 1 do
            local line_content = vim.fn.getline(target_line)
            if not line_content:match("^%s*$") then
                break -- Found a non-blank line
            end
            target_line = target_line - 1
        end

        if target_line >= 1 then
            local target_line_content = vim.fn.getline(target_line)
            local target_last_col = get_last_col(target_line_content)
            vim.fn.cursor(target_line, target_last_col) -- Move to the last character of the target line
            desired_col = target_last_col -- Update desired_col to the new position
            is_at_line_end = true -- Remain in end-of-line mode
        end
        -- If no non-blank line is found, do nothing
    else
        -- If not at the end of a line, perform standard vertical movement
        -- Loop to find the previous non-blank line
        while target_line >= 1 do
            local line_content = vim.fn.getline(target_line)
            if not line_content:match("^%s*$") then
                break -- Found a non-blank line
            end
            target_line = target_line - 1
        end

        if target_line >= 1 then
            -- Move to the target line
            vim.fn.cursor(target_line, 1) -- Move to the first character (will be adjusted)
            local line = vim.fn.getline('.')
            restore_col(line) -- Adjust the column based on the new line
        end
    end
end

-- Function to toggle custom movement mode
function M.toggle_custom_movement()
    if not custom_movement_enabled then
        -- Enable custom movement mode
        vim.keymap.set('n', 'h', custom_h, {noremap = true, silent = true})
        vim.keymap.set('n', 'l', custom_l, {noremap = true, silent = true})
        vim.keymap.set('n', 'j', custom_j, {noremap = true, silent = true})
        vim.keymap.set('n', 'k', custom_k, {noremap = true, silent = true})
        custom_movement_enabled = true
        print("Custom movement mode enabled")
    else
        -- Disable custom movement mode by removing the custom key mappings
        vim.keymap.del('n', 'h')
        vim.keymap.del('n', 'l')
        vim.keymap.del('n', 'j')
        vim.keymap.del('n', 'k')
        custom_movement_enabled = false
        print("Custom movement mode disabled")
    end
end

-- -- Function to initialize custom movement mode (optional)
-- function M.setup()
--     -- Map a key to toggle custom movement mode, e.g., <leader>m
--     vim.keymap.set('n', '<leader>m', toggle_custom_movement, { noremap = true, silent = true })

--     -- Optionally, set the initial state of custom movement mode
--     -- Uncomment the following line if you want the mode to be enabled by default on startup
--     -- toggle_custom_movement()
-- end

return M
