-- ~/.config/nvim/lua/convertWeth.lua

local M = {}

-- Module name for requiring within commands
M.module_name = "convertWeth" -- Ensure this name matches the file path

-- Variables to store buffers and windows
M.popup_win = nil
M.menu_win = nil
M.input_win = nil
M.current_values = { weth = "", wei = "", gwei = "" }
M.current_conversion_type = nil
M.current_conversion_base = nil

-- Helper function to create a popup window
local function create_popup(lines, width, height, border, modifiable, on_open)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    
    -- Always set 'modifiable' to true before setting lines
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    
    -- Then, set 'modifiable' and 'readonly' based on the parameter
    vim.api.nvim_buf_set_option(buf, 'modifiable', modifiable)
    vim.api.nvim_buf_set_option(buf, 'readonly', not modifiable)

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        col = math.floor((vim.o.columns - width) / 2),
        row = math.floor((vim.o.lines - height) / 2),
        style = "minimal",
        border = border or "rounded",
    })

    if on_open then
        on_open(buf, win)
    end

    return buf, win
end

-- Helper function to add highlights
local function add_highlights(buf, highlights)
    for _, hl in ipairs(highlights) do
        vim.api.nvim_buf_add_highlight(buf, -1, hl.group, hl.line, hl.col_start, hl.col_end)
    end
end

-- Helper function to set keymaps
local function set_keymaps(buf, mappings)
    local opts = { nowait = true, noremap = true, silent = true }
    for mode, maps in pairs(mappings) do
        for key, cmd in pairs(maps) do
            vim.api.nvim_buf_set_keymap(buf, mode, key, cmd, opts)
        end
    end
end

-- Helper functions for conversions
local function multiply_by_power_of_10(number, power)
    if number == "0" then return "0" end
    return number .. string.rep("0", power)
end

local function divide_by_power_of_10(number, power)
    if #number <= power then return "0" end
    return number:sub(1, #number - power)
end

-- Conversion functions
local function ConvertWethFromWeth(weth)
    local wei = multiply_by_power_of_10(weth, 18)
    local gwei = multiply_by_power_of_10(weth, 9)
    M.current_values = { weth = weth, wei = wei, gwei = gwei }
    return M.current_values
end

local function ConvertWethFromWei(wei)
    local weth = divide_by_power_of_10(wei, 18)
    local gwei = divide_by_power_of_10(wei, 9)
    M.current_values = { weth = weth, wei = wei, gwei = gwei }
    return M.current_values
end

local function ConvertWethFromGwei(gwei)
    local weth = divide_by_power_of_10(gwei, 9)
    local wei = multiply_by_power_of_10(gwei, 9)
    M.current_values = { weth = weth, wei = wei, gwei = gwei }
    return M.current_values
end

-- Function to handle conversion based on type
local function handle_conversion(number, base)
    if base == "WETH" then
        return ConvertWethFromWeth(number)
    elseif base == "WEI" then
        return ConvertWethFromWei(number)
    elseif base == "GWEI" then
        return ConvertWethFromGwei(number)
    else
        error("Unsupported conversion base: " .. base)
    end
end

-- Function to show the conversion results popup
local function show_conversion_popup(number, base)
    -- Attempt to handle the conversion
    local status_ok, results = pcall(handle_conversion, number, base)
    if not status_ok then
        vim.notify(results, vim.log.levels.ERROR)
        return
    end

    local lines = {
        "  Conversion Results:",
        "",
        "  [1]. WETH:      " .. results.weth,
        "  [2]. GWEI:      " .. results.gwei,
        "  [3]. WEI:       " .. results.wei
    }

    -- Close the menu popup if it's open
    if M.menu_win and vim.api.nvim_win_is_valid(M.menu_win) then
        vim.api.nvim_win_close(M.menu_win, true)
        M.menu_win = nil
        M.menu_buf = nil
    end

    -- Create the conversion popup
    M.popup_buf, M.popup_win = create_popup(lines, 70, #lines + 2, "rounded", false, function(buf, win)
        -- Ensure Normal mode
        vim.api.nvim_win_set_option(win, 'cursorline', true)
        vim.cmd("stopinsert")
    end)

    -- Add highlights
    add_highlights(M.popup_buf, {
        { group = "Title", line = 0, col_start = 2, col_end = -1 },    -- "Conversion Results:"
        { group = "Special", line = 2, col_start = 3, col_end = 9 },   -- [1]. WETH:
        { group = "Special", line = 3, col_start = 3, col_end = 9 },   -- [2]. GWEI:
        { group = "Special", line = 4, col_start = 3, col_end = 9 },   -- [3]. WEI:
    })

    -- Set keymaps within the popup
    set_keymaps(M.popup_buf, {
        ['n'] = {
            ['1'] = '<cmd>ConvertWethCopyWeth<CR>',
            ['2'] = '<cmd>ConvertWethCopyGwei<CR>',
            ['3'] = '<cmd>ConvertWethCopyWei<CR>',
            ['<Esc>'] = '<cmd>ConvertWethToggle<CR>',
        }
    })

    -- Prevent entering insert mode
    set_keymaps(M.popup_buf, {
        ['n'] = {
            ['i'] = '<Nop>',
            ['a'] = '<Nop>',
            ['I'] = '<Nop>',
            ['A'] = '<Nop>',
        }
    })
end

-- Function to show the conversion menu popup
local function show_menu_popup()
    local lines = {
        "  Currency Conversion Menu:",
        "",
        "  [1] Convert from WETH",
        "  [2] Convert from WEI",
        "  [3] Convert from GWEI",
        "",
        "Press the corresponding number to choose an option."
    }

    -- Create the menu popup
    M.menu_buf, M.menu_win = create_popup(lines, 50, #lines + 2, "rounded", false, function(buf, win)
        -- Ensure Normal mode
        vim.api.nvim_win_set_option(win, 'cursorline', true)
        vim.cmd("stopinsert")
    end)

    -- Add highlights
    add_highlights(M.menu_buf, {
        { group = "Title", line = 0, col_start = 2, col_end = -1 },    -- "Currency Conversion Menu:"
        { group = "Special", line = 2, col_start = 3, col_end = 19 },  -- [1] Convert from WETH
        { group = "Special", line = 3, col_start = 3, col_end = 19 },  -- [2] Convert from WEI
        { group = "Special", line = 4, col_start = 3, col_end = 19 },  -- [3] Convert from GWEI
    })

    -- Set keymaps within the menu popup
    set_keymaps(M.menu_buf, {
        ['n'] = {
            ['1'] = '<cmd>ConvertWethFromWethInteractive<CR>',
            ['2'] = '<cmd>ConvertWethFromWeiInteractive<CR>',
            ['3'] = '<cmd>ConvertWethFromGweiInteractive<CR>',
            ['<Esc>'] = '<cmd>ConvertWethMenu<CR>',
        }
    })
end

-- Function to show the input popup for interactive conversions
local function show_input_popup(conversion_func, base, prompt)
    local lines = { prompt, "" }
    M.input_buf, M.input_win = create_popup(lines, 50, 3, "rounded", true, function(buf, win)
        -- Move cursor to the second line
        vim.api.nvim_win_set_cursor(win, { 2, 0 })
        -- Enter insert mode
        vim.cmd("startinsert")
    end)

    -- Add highlights
    add_highlights(M.input_buf, {
        { group = "Title", line = 0, col_start = 2, col_end = -1 },    -- e.g., "Enter a WETH amount:"
    })

    -- Set keymaps within the input popup
    set_keymaps(M.input_buf, {
        ['n'] = {
            ['<Esc>'] = '<cmd>ConvertWethCloseInput<CR>',
        },
        ['i'] = {
            ['<CR>'] = '<cmd>ConvertWethProcessInput<CR>',
        },
    })
end

-- Function to close the input popup
function M.ConvertWethCloseInput()
    if M.input_win and vim.api.nvim_win_is_valid(M.input_win) then
        vim.api.nvim_win_close(M.input_win, true)
        M.input_win = nil
        M.input_buf = nil
    end
end

-- Function to process the user's input
function M.ConvertWethProcessInput()
    if not (M.input_buf and vim.api.nvim_buf_is_valid(M.input_buf)) then
        vim.notify("Input buffer is not valid.", vim.log.levels.ERROR)
        return
    end

    -- Get the input from the buffer
    local input = vim.api.nvim_buf_get_lines(M.input_buf, 1, 2, false)[1]
    -- Close the input popup
    M.ConvertWethCloseInput()

    -- Validate the input
    local valid = false
    if M.current_conversion_base == "WETH" or M.current_conversion_base == "WEI" or M.current_conversion_base == "GWEI" then
        valid = input:match("^%d+$") ~= nil
    end

    if not valid then
        vim.notify("Invalid number for " .. M.current_conversion_base, vim.log.levels.ERROR)
        return
    end

    -- Perform the conversion based on the type
    if M.current_conversion_type == "ConvertWethFromWethInteractive" then
        M.ConvertWethFromWeth(input)
    elseif M.current_conversion_type == "ConvertWethFromWeiInteractive" then
        M.ConvertWethFromWei(input)
    elseif M.current_conversion_type == "ConvertWethFromGweiInteractive" then
        M.ConvertWethFromGwei(input)
    else
        vim.notify("Unknown conversion type.", vim.log.levels.ERROR)
    end

    -- Clear the conversion information
    M.current_conversion_type = nil
    M.current_conversion_base = nil
end

-- Functions to copy values to the clipboard and notify the user
function M.copy_weth()
    if M.current_values.weth ~= "" then
        vim.fn.setreg('+', M.current_values.weth)
        vim.notify("Copied WETH value: " .. M.current_values.weth, vim.log.levels.INFO)
        M.toggle_popup()
    else
        vim.notify("No WETH value to copy.", vim.log.levels.WARN)
    end
end

function M.copy_wei()
    if M.current_values.wei ~= "" then
        vim.fn.setreg('+', M.current_values.wei)
        vim.notify("Copied WEI value: " .. M.current_values.wei, vim.log.levels.INFO)
        M.toggle_popup()
    else
        vim.notify("No WEI value to copy.", vim.log.levels.WARN)
    end
end

function M.copy_gwei()
    if M.current_values.gwei ~= "" then
        vim.fn.setreg('+', M.current_values.gwei)
        vim.notify("Copied GWEI value: " .. M.current_values.gwei, vim.log.levels.INFO)
        M.toggle_popup()
    else
        vim.notify("No GWEI value to copy.", vim.log.levels.WARN)
    end
end

-- Function to toggle the conversion results popup
function M.toggle_popup()
    if M.popup_win and vim.api.nvim_win_is_valid(M.popup_win) then
        -- If the conversion popup is open, close it
        vim.api.nvim_win_close(M.popup_win, true)
        M.popup_win = nil
    else
        -- Check if there is a previous conversion
        if M.current_values.weth ~= "" or M.current_values.wei ~= "" or M.current_values.gwei ~= "" then
            -- Create the lines for the popup based on current values
            local lines = {
                "  Conversion Results:",
                "",
                "  [1]. WETH:      " .. M.current_values.weth,
                "  [2]. GWEI:      " .. M.current_values.gwei,
                "  [3]. WEI:       " .. M.current_values.wei
            }

            -- Create the conversion popup
            M.popup_buf, M.popup_win = create_popup(lines, 70, #lines + 2, "rounded", false, function(buf, win)
                -- Ensure Normal mode
                vim.api.nvim_win_set_option(win, 'cursorline', true)
                vim.cmd("stopinsert")
            end)

            -- Add highlights
            add_highlights(M.popup_buf, {
                { group = "Title", line = 0, col_start = 2, col_end = -1 },    -- "Conversion Results:"
                { group = "Special", line = 2, col_start = 3, col_end = 9 },   -- [1]. WETH:
                { group = "Special", line = 3, col_start = 3, col_end = 9 },   -- [2]. GWEI:
                { group = "Special", line = 4, col_start = 3, col_end = 9 },   -- [3]. WEI:
            })

            -- Set keymaps within the popup
            set_keymaps(M.popup_buf, {
                ['n'] = {
                    ['1'] = '<cmd>ConvertWethCopyWeth<CR>',
                    ['2'] = '<cmd>ConvertWethCopyGwei<CR>',
                    ['3'] = '<cmd>ConvertWethCopyWei<CR>',
                    ['<Esc>'] = '<cmd>ConvertWethToggle<CR>',
                }
            })

            -- Prevent entering insert mode
            set_keymaps(M.popup_buf, {
                ['n'] = {
                    ['i'] = '<Nop>',
                    ['a'] = '<Nop>',
                    ['I'] = '<Nop>',
                    ['A'] = '<Nop>',
                }
            })
        else
            -- If there is no previous conversion
            vim.notify("No conversion has been made yet.", vim.log.levels.WARN)
        end
    end
end

-- Function to toggle the conversion menu popup
function M.toggle_menu_popup()
    if M.menu_win and vim.api.nvim_win_is_valid(M.menu_win) then
        -- If the menu popup is open, close it
        vim.api.nvim_win_close(M.menu_win, true)
        M.menu_win = nil
        M.menu_buf = nil
    else
        -- Open the menu popup
        show_menu_popup()
    end
end

-- Direct conversion functions
function M.ConvertWethFromWeth(number)
    show_conversion_popup(number, "WETH")
    -- Removed the toggle_menu_popup() call to prevent reopening the menu
end

function M.ConvertWethFromWei(number)
    show_conversion_popup(number, "WEI")
    -- Removed the toggle_menu_popup() call to prevent reopening the menu
end

function M.ConvertWethFromGwei(number)
    show_conversion_popup(number, "GWEI")
    -- Removed the toggle_menu_popup() call to prevent reopening the menu
end

-- Interactive conversion functions
function M.ConvertWethFromWethInteractive()
    -- Close the menu popup if it's open
    if M.menu_win and vim.api.nvim_win_is_valid(M.menu_win) then
        vim.api.nvim_win_close(M.menu_win, true)
        M.menu_win = nil
        M.menu_buf = nil
    end
    M.current_conversion_type = "ConvertWethFromWethInteractive"
    M.current_conversion_base = "WETH"
    show_input_popup("ConvertWethFromWethInteractive", "WETH", "Enter a WETH amount:")
end

function M.ConvertWethFromWeiInteractive()
    -- Close the menu popup if it's open
    if M.menu_win and vim.api.nvim_win_is_valid(M.menu_win) then
        vim.api.nvim_win_close(M.menu_win, true)
        M.menu_win = nil
        M.menu_buf = nil
    end
    M.current_conversion_type = "ConvertWethFromWeiInteractive"
    M.current_conversion_base = "WEI"
    show_input_popup("ConvertWethFromWeiInteractive", "WEI", "Enter a WEI amount:")
end

function M.ConvertWethFromGweiInteractive()
    -- Close the menu popup if it's open
    if M.menu_win and vim.api.nvim_win_is_valid(M.menu_win) then
        vim.api.nvim_win_close(M.menu_win, true)
        M.menu_win = nil
        M.menu_buf = nil
    end
    M.current_conversion_type = "ConvertWethFromGweiInteractive"
    M.current_conversion_base = "GWEI"
    show_input_popup("ConvertWethFromGweiInteractive", "GWEI", "Enter a GWEI amount:")
end

-- Setup function to register commands
function M.setup()
    -- Direct conversion commands
    vim.api.nvim_create_user_command("ConvertWethFromWeth", function(args)
        M.ConvertWethFromWeth(args.args)
    end, { nargs = 1, desc = "Convert from WETH to GWEI and WEI" })

    vim.api.nvim_create_user_command("ConvertWethFromWei", function(args)
        M.ConvertWethFromWei(args.args)
    end, { nargs = 1, desc = "Convert from WEI to WETH and GWEI" })

    vim.api.nvim_create_user_command("ConvertWethFromGwei", function(args)
        M.ConvertWethFromGwei(args.args)
    end, { nargs = 1, desc = "Convert from GWEI to WETH and WEI" })

    -- Interactive conversion commands
    vim.api.nvim_create_user_command("ConvertWethFromWethInteractive", function()
        M.ConvertWethFromWethInteractive()
    end, { nargs = 0, desc = "Interactive conversion from WETH" })

    vim.api.nvim_create_user_command("ConvertWethFromWeiInteractive", function()
        M.ConvertWethFromWeiInteractive()
    end, { nargs = 0, desc = "Interactive conversion from WEI" })

    vim.api.nvim_create_user_command("ConvertWethFromGweiInteractive", function()
        M.ConvertWethFromGweiInteractive()
    end, { nargs = 0, desc = "Interactive conversion from GWEI" })

    -- Commands to copy values to the clipboard
    vim.api.nvim_create_user_command("ConvertWethCopyWeth", function()
        M.copy_weth()
    end, { nargs = 0, desc = "Copy WETH value to clipboard" })

    vim.api.nvim_create_user_command("ConvertWethCopyWei", function()
        M.copy_wei()
    end, { nargs = 0, desc = "Copy WEI value to clipboard" })

    vim.api.nvim_create_user_command("ConvertWethCopyGwei", function()
        M.copy_gwei()
    end, { nargs = 0, desc = "Copy GWEI value to clipboard" })

    -- Commands to toggle popups
    vim.api.nvim_create_user_command("ConvertWethToggle", function()
        M.toggle_popup()
    end, { nargs = 0, desc = "Toggle the conversion results popup" })

    vim.api.nvim_create_user_command("ConvertWethMenu", function()
        M.toggle_menu_popup()
    end, { nargs = 0, desc = "Show the Currency Conversion Menu" })

    -- Additional commands to process and close input
    vim.api.nvim_create_user_command("ConvertWethProcessInput", function()
        M.ConvertWethProcessInput()
    end, { nargs = 0, desc = "Process input for WETH conversion" })

    vim.api.nvim_create_user_command("ConvertWethCloseInput", function()
        M.ConvertWethCloseInput()
    end, { nargs = 0, desc = "Close input popup" })
end

return M
