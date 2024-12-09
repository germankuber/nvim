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
        vim.fn.cursor(vim.fn.line('.'), first_non_ws)
    elseif desired_col > last_col then
        vim.fn.cursor(vim.fn.line('.'), last_col)
    else
        vim.fn.cursor(vim.fn.line('.'), desired_col)
    end

    is_at_line_end = (vim.fn.col('.') == last_col)
end

-- Función para verificar si una línea debe ser omitida (en blanco o comentario)
local function should_skip_line(line_content)
    return line_content:match("^%s*$") or line_content:match("^%s*//")
end

-- Custom function for the 'h' key (move left or jump to the end of the previous non-blank, non-comment line)
local function custom_h()
    local count = vim.v.count1
    local line = vim.fn.getline('.')
    local first_non_ws = get_first_non_ws_col(line)
    local current_col = vim.fn.col('.')

    if current_col > first_non_ws then
        local target_col = math.max(current_col - count, first_non_ws)
        vim.fn.cursor(vim.fn.line('.'), target_col)
    elseif current_col == first_non_ws then
        -- Jump to previous non-blank, non-comment line
        local moved = 0
        local target_line = vim.fn.line('.')

        while moved < count and target_line > 1 do
            target_line = target_line - 1
            local line_content = vim.fn.getline(target_line)
            if not should_skip_line(line_content) then
                moved = moved + 1
            end
        end

        if moved == count and target_line >= 1 then
            local target_line_content = vim.fn.getline(target_line)
            local target_last_col = get_last_col(target_line_content)
            vim.fn.cursor(target_line, target_last_col)
            desired_col = target_last_col
            is_at_line_end = true
        end
    end

    local new_line = vim.fn.getline('.')
    local new_last_col = get_last_col(new_line)
    local new_col = vim.fn.col('.')
    is_at_line_end = (new_col == new_last_col)
end

-- Custom function for the 'l' key (move right or jump to the beginning of the next non-blank, non-comment line)
local function custom_l()
    local count = vim.v.count1
    local line = vim.fn.getline('.')
    local last_col = get_last_col(line)
    local current_col = vim.fn.col('.')

    if current_col < last_col then
        local target_col = math.min(current_col + count, last_col)
        vim.fn.cursor(vim.fn.line('.'), target_col)
    elseif current_col == last_col then
        -- Jump to next non-blank, non-comment line
        local moved = 0
        local target_line = vim.fn.line('.')

        while moved < count and target_line < vim.fn.line('$') do
            target_line = target_line + 1
            local line_content = vim.fn.getline(target_line)
            if not should_skip_line(line_content) then
                moved = moved + 1
            end
        end

        if moved == count and target_line <= vim.fn.line('$') then
            local target_line_content = vim.fn.getline(target_line)
            local first_non_ws = get_first_non_ws_col(target_line_content)
            vim.fn.cursor(target_line, first_non_ws)
            desired_col = first_non_ws
            is_at_line_end = (first_non_ws == get_last_col(target_line_content))
        end
    end

    local new_line = vim.fn.getline('.')
    local new_last_col = get_last_col(new_line)
    local new_col = vim.fn.col('.')
    is_at_line_end = (new_col == new_last_col)
end

-- Custom function for 'j' (move down, skipping blank and comment lines)
local function custom_j()
    set_desired_col()
    local count = vim.v.count1
    local moved = 0
    local target_line = vim.fn.line('.')

    while moved < count and target_line < vim.fn.line('$') do
        target_line = target_line + 1
        local line_content = vim.fn.getline(target_line)
        if not should_skip_line(line_content) then
            moved = moved + 1
        end
    end

    if moved > 0 then
        if is_at_line_end then
            local target_line_content = vim.fn.getline(target_line)
            local target_last_col = get_last_col(target_line_content)
            vim.fn.cursor(target_line, target_last_col)
            desired_col = target_last_col
            is_at_line_end = true
        else
            vim.fn.cursor(target_line, 1)
            local line = vim.fn.getline('.')
            restore_col(line)
        end
    end
end

-- Custom function for 'k' (move up, skipping blank and comment lines)
local function custom_k()
    set_desired_col()
    local count = vim.v.count1
    local moved = 0
    local target_line = vim.fn.line('.')

    while moved < count and target_line > 1 do
        target_line = target_line - 1
        local line_content = vim.fn.getline(target_line)
        if not should_skip_line(line_content) then
            moved = moved + 1
        end
    end

    if moved > 0 then
        if is_at_line_end then
            local target_line_content = vim.fn.getline(target_line)
            local target_last_col = get_last_col(target_line_content)
            vim.fn.cursor(target_line, target_last_col)
            desired_col = target_last_col
            is_at_line_end = true
        else
            vim.fn.cursor(target_line, 1)
            local line = vim.fn.getline('.')
            restore_col(line)
        end
    end
end

-- Variable para rastrear si el modo de movimiento personalizado está habilitado
local custom_movement_enabled = false

function M.is_enabled() return custom_movement_enabled end

function M.toggle_custom_movement()
    if not custom_movement_enabled then
        vim.keymap.set('n', 'h', custom_h, {noremap = true, silent = true})
        vim.keymap.set('n', 'l', custom_l, {noremap = true, silent = true})
        vim.keymap.set('n', 'j', custom_j, {noremap = true, silent = true})
        vim.keymap.set('n', 'k', custom_k, {noremap = true, silent = true})
        custom_movement_enabled = true
        vim.notify("Mode 🔥 activated", vim.log.levels.SUCCESS)
    else
        vim.keymap.del('n', 'h')
        vim.keymap.del('n', 'l')
        vim.keymap.del('n', 'j')
        vim.keymap.del('n', 'k')
        custom_movement_enabled = false
        vim.notify("Mode 🥶 activated", vim.log.levels.INFO)
    end
end

M.toggle_custom_movement()
return M
