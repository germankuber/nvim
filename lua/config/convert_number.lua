local M = {}

-- Variables to store the buffer and window of the conversion popup
M.popup_buf = nil
M.popup_win = nil
M.current_values = {dec = "", hex = "", bin = ""}
M.module_name = "config.convert_number" -- Replace with your actual module name

-- Variables to store the buffer and window of the menu
M.menu_buf = nil
M.menu_win = nil

-- Helper function to convert a decimal string to a binary string
local function to_binary(decimal)
    if decimal == "0" then return "0" end
    local bin = {}
    local dec = decimal
    while dec ~= "0" do
        -- Get the remainder of dec % 2
        local last_digit = tonumber(dec:sub(-1))
        local remainder = last_digit % 2
        table.insert(bin, 1, tostring(remainder))

        -- dec = floor(dec / 2)
        local new_dec = {}
        local carry = 0
        for i = 1, #dec do
            local digit = tonumber(dec:sub(i, i)) + carry * 10
            local quotient = math.floor(digit / 2)
            carry = digit % 2
            table.insert(new_dec, tostring(quotient))
        end
        -- Remove leading zeros
        local new_dec_str = table.concat(new_dec):gsub("^0+", "")
        dec = new_dec_str ~= "" and new_dec_str or "0"
    end
    return table.concat(bin)
end

-- Helper function to convert a hexadecimal string to a decimal string
local function hex_to_decimal(hex)
    local digits = "0123456789ABCDEF"
    local decimal = "0"
    local base = 16
    hex = hex:upper():gsub("0X", "") -- Remove "0x" if present

    for i = 1, #hex do
        local digit = hex:sub(i, i)
        local value = digits:find(digit, 1, true) - 1
        if value == -1 then error("Invalid hexadecimal digit: " .. digit) end

        -- decimal = decimal * 16 + value
        -- Implement multiplication by 16
        local mult = {}
        local carry = 0
        for j = #decimal, 1, -1 do
            local prod = tonumber(decimal:sub(j, j)) * base + carry
            carry = math.floor(prod / 10)
            mult[j] = tostring(prod % 10)
        end
        if carry > 0 then table.insert(mult, 1, tostring(carry)) end
        decimal = table.concat(mult)

        -- Add the value
        local sum = {}
        carry = value
        for j = #decimal, 1, -1 do
            local s = tonumber(decimal:sub(j, j)) + carry
            carry = math.floor(s / 10)
            sum[j] = tostring(s % 10)
        end
        if carry > 0 then
            table.insert(sum, 1, tostring(carry))
        end
        decimal = table.concat(sum)
    end
    return decimal
end

-- Helper function to convert a decimal string to a hexadecimal string
local function decimal_to_hex(decimal)
    if decimal == "0" then return "0" end
    local hex = {}
    local digits = "0123456789ABCDEF"
    local dec = decimal
    while dec ~= "0" do
        -- Get dec % 16
        local remainder = 0
        local temp = ""
        for i = 1, #dec do
            local digit = tonumber(dec:sub(i, i))
            local num = remainder * 10 + digit
            local q = math.floor(num / 16)
            remainder = num % 16
            if #temp > 0 or q ~= 0 then temp = temp .. tostring(q) end
        end
        table.insert(hex, 1, digits:sub(remainder + 1, remainder + 1))
        dec = temp ~= "" and temp or "0"
    end
    return table.concat(hex)
end

-- Helper function to convert a decimal string to a binary string with prefix
local function decimal_to_binary_string(decimal)
    if decimal == "0" then return "0b0" end
    local bin = to_binary(decimal)
    return "0b" .. bin
end

-- Helper function to convert a decimal string to a hexadecimal string with prefix
local function decimal_to_hex_string_extended(decimal)
    if decimal == "0" then return "0x0" end
    local hex = {}
    local digits = "0123456789ABCDEF"
    local dec = decimal
    while dec ~= "0" do
        -- Get dec % 16
        local remainder = 0
        local temp = ""
        for i = 1, #dec do
            local digit = tonumber(dec:sub(i, i))
            local num = remainder * 10 + digit
            local q = math.floor(num / 16)
            remainder = num % 16
            if #temp > 0 or q ~= 0 then temp = temp .. tostring(q) end
        end
        table.insert(hex, 1, digits:sub(remainder + 1, remainder + 1))
        dec = temp ~= "" and temp or "0"
    end
    return "0x" .. table.concat(hex)
end

-- Function to handle large decimal input
local function handle_large_decimal(number, base)
    if base == 10 then
        return number
    elseif base == 16 then
        return hex_to_decimal(number)
    elseif base == 2 then
        local decimal = "0"
        for i = 1, #number do
            local bit = tonumber(number:sub(i, i))
            if bit ~= 0 and bit ~= 1 then
                error("Invalid binary digit: " .. bit)
            end
            -- decimal = decimal * 2 + bit
            -- Implement multiplication by 2
            local mult = {}
            local carry = 0
            for j = #decimal, 1, -1 do
                local prod = tonumber(decimal:sub(j, j)) * 2 + carry
                carry = math.floor(prod / 10)
                mult[j] = tostring(prod % 10)
            end
            if carry > 0 then table.insert(mult, 1, tostring(carry)) end
            decimal = table.concat(mult)

            -- Add the bit
            if bit == 1 then
                local sum = {}
                carry = 1
                for j = #decimal, 1, -1 do
                    local s = tonumber(decimal:sub(j, j)) + carry
                    carry = math.floor(s / 10)
                    sum[j] = tostring(s % 10)
                end
                if carry > 0 then
                    table.insert(sum, 1, tostring(carry))
                end
                decimal = table.concat(sum)
            end
        end
        return decimal
    else
        error("Unsupported base: " .. base)
    end
end

-- Function to show the conversion popup
local function show_conversion_popup(number, base)
    -- Get the converted values
    local decimal = handle_large_decimal(number, base)
    local bin = decimal_to_binary_string(decimal)
    local hex = decimal_to_hex_string_extended(decimal)
    local dec = decimal

    M.current_values = {dec = dec, hex = hex, bin = bin}

    -- Create the lines with shortcuts and margins
    local lines = {
        "  Conversion Results:", "",
        "  [1]. Decimal:      " .. dec,
        "  [2]. Hexadecimal:  " .. hex,
        "  [3]. Binary:       " .. bin
    }

    -- Function to update the read-only buffer
    local function update_buffer()
        if M.popup_buf and vim.api.nvim_buf_is_valid(M.popup_buf) then
            -- Allow temporary modifications
            vim.api.nvim_buf_set_option(M.popup_buf, 'modifiable', true)
            vim.api.nvim_buf_set_option(M.popup_buf, 'readonly', false)

            -- Update the buffer lines
            vim.api.nvim_buf_set_lines(M.popup_buf, 0, -1, false, lines)

            -- Reset the buffer to read-only
            vim.api.nvim_buf_set_option(M.popup_buf, 'modifiable', false)
            vim.api.nvim_buf_set_option(M.popup_buf, 'readonly', true)
        end
    end

    -- If the conversion popup is already open, update its content
    if M.popup_win and vim.api.nvim_win_is_valid(M.popup_win) then
        update_buffer()
        -- Add highlights
        vim.api.nvim_buf_clear_namespace(M.popup_buf, 0, 0, -1) -- Clear existing highlights
        vim.api.nvim_buf_add_highlight(M.popup_buf, 0, "Title", 0, 2, -1) -- Title
        vim.api.nvim_buf_add_highlight(M.popup_buf, 0, "Special", 2, 3, 6) -- [1]
        vim.api.nvim_buf_add_highlight(M.popup_buf, 0, "Special", 3, 3, 6) -- [2]
        vim.api.nvim_buf_add_highlight(M.popup_buf, 0, "Special", 4, 3, 6) -- [3]
        return
    end

    -- If the conversion buffer exists but the window is closed, reopen the popup
    if M.popup_buf and vim.api.nvim_buf_is_valid(M.popup_buf) then
        M.popup_win = vim.api.nvim_open_win(M.popup_buf, true, {
            relative = "editor",
            width = 70,
            height = #lines + 2,
            col = math.floor((vim.o.columns - 70) / 2),
            row = math.floor((vim.o.lines - (#lines + 2)) / 2),
            style = "minimal",
            border = "rounded"
        })
        update_buffer()
        -- Add highlights
        vim.api.nvim_buf_clear_namespace(M.popup_buf, 0, 0, -1)
        vim.api.nvim_buf_add_highlight(M.popup_buf, 0, "Title", 0, 2, -1)
        vim.api.nvim_buf_add_highlight(M.popup_buf, 0, "Special", 2, 3, 6)
        vim.api.nvim_buf_add_highlight(M.popup_buf, 0, "Special", 3, 3, 6)
        vim.api.nvim_buf_add_highlight(M.popup_buf, 0, "Special", 4, 3, 6)
        return
    end

    -- If the conversion buffer does not exist, create a new one
    M.popup_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(M.popup_buf, 'bufhidden', 'hide') -- Allow reopening the popup

    -- Configure the buffer as temporarily modifiable to set the lines
    vim.api.nvim_buf_set_option(M.popup_buf, 'modifiable', true)
    vim.api.nvim_buf_set_option(M.popup_buf, 'readonly', false)
    vim.api.nvim_buf_set_lines(M.popup_buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(M.popup_buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(M.popup_buf, 'readonly', true)

    -- Create the conversion window
    M.popup_win = vim.api.nvim_open_win(M.popup_buf, true, {
        relative = "editor",
        width = 70,
        height = #lines + 2,
        col = math.floor((vim.o.columns - 70) / 2),
        row = math.floor((vim.o.lines - (#lines + 2)) / 2),
        style = "minimal",
        border = "rounded"
    })

    -- Add highlights
    vim.api.nvim_buf_add_highlight(M.popup_buf, 0, "Title", 0, 2, -1)
    vim.api.nvim_buf_add_highlight(M.popup_buf, 0, "Special", 2, 3, 6) -- [1]
    vim.api.nvim_buf_add_highlight(M.popup_buf, 0, "Special", 3, 3, 6) -- [2]
    vim.api.nvim_buf_add_highlight(M.popup_buf, 0, "Special", 4, 3, 6) -- [3]

    -- Configure key mappings within the popup
    local function map_keys()
        local opts = {nowait = true, noremap = true, silent = true}
        -- Prevent the user from entering insert mode
        vim.api.nvim_buf_set_keymap(M.popup_buf, 'n', 'i', '<Nop>', opts)
        vim.api.nvim_buf_set_keymap(M.popup_buf, 'n', 'a', '<Nop>', opts)
        vim.api.nvim_buf_set_keymap(M.popup_buf, 'n', 'I', '<Nop>', opts)
        vim.api.nvim_buf_set_keymap(M.popup_buf, 'n', 'A', '<Nop>', opts)

        -- Key mappings to copy values
        vim.api.nvim_buf_set_keymap(M.popup_buf, 'n', '1',
            '<cmd>lua require("' .. M.module_name .. '").copy_dec()<CR>', opts)
        vim.api.nvim_buf_set_keymap(M.popup_buf, 'n', '2',
            '<cmd>lua require("' .. M.module_name .. '").copy_hex()<CR>', opts)
        vim.api.nvim_buf_set_keymap(M.popup_buf, 'n', '3',
            '<cmd>lua require("' .. M.module_name .. '").copy_bin()<CR>', opts)
        vim.api.nvim_buf_set_keymap(M.popup_buf, 'n', '<Esc>',
            '<cmd>lua require("' .. M.module_name .. '").toggle_popup()<CR>', opts)
    end
    vim.api.nvim_command('stopinsert')
    map_keys()
end

-- Function to show the menu popup
local function show_menu_popup()
    -- Create the menu lines
    local lines = {
        "  Number Conversion Menu:",
        "",
        "  [1] Convert Decimal",
        "  [2] Convert Binary",
        "  [3] Convert Hexadecimal",
        "",
        "Press the corresponding number to choose an option."
    }

    -- Function to update the read-only buffer of the menu
    local function update_menu_buffer()
        if M.menu_buf and vim.api.nvim_buf_is_valid(M.menu_buf) then
            -- Allow temporary modifications
            vim.api.nvim_buf_set_option(M.menu_buf, 'modifiable', true)
            vim.api.nvim_buf_set_option(M.menu_buf, 'readonly', false)

            -- Update the buffer lines
            vim.api.nvim_buf_set_lines(M.menu_buf, 0, -1, false, lines)

            -- Reset the buffer to read-only
            vim.api.nvim_buf_set_option(M.menu_buf, 'modifiable', false)
            vim.api.nvim_buf_set_option(M.menu_buf, 'readonly', true)
        end
    end

    -- If the menu popup is already open, update its content
    if M.menu_win and vim.api.nvim_win_is_valid(M.menu_win) then
        update_menu_buffer()
        -- Add highlights
        vim.api.nvim_buf_clear_namespace(M.menu_buf, 0, 0, -1) -- Clear existing highlights
        vim.api.nvim_buf_add_highlight(M.menu_buf, 0, "Title", 0, 2, -1) -- Title
        vim.api.nvim_buf_add_highlight(M.menu_buf, 0, "Special", 2, 3, 6) -- [1]
        vim.api.nvim_buf_add_highlight(M.menu_buf, 0, "Special", 3, 3, 6) -- [2]
        vim.api.nvim_buf_add_highlight(M.menu_buf, 0, "Special", 4, 3, 6) -- [3]
        return
    end

    -- If the menu buffer exists but the window is closed, reopen the menu popup
    if M.menu_buf and vim.api.nvim_buf_is_valid(M.menu_buf) then
        M.menu_win = vim.api.nvim_open_win(M.menu_buf, true, {
            relative = "editor",
            width = 50,
            height = #lines + 2,
            col = math.floor((vim.o.columns - 50) / 2),
            row = math.floor((vim.o.lines - (#lines + 2)) / 2),
            style = "minimal",
            border = "rounded"
        })
        vim.cmd("stopinsert")
        update_menu_buffer()
        -- Add highlights
        vim.api.nvim_buf_clear_namespace(M.menu_buf, 0, 0, -1)
        vim.api.nvim_buf_add_highlight(M.menu_buf, 0, "Title", 0, 2, -1)
        vim.api.nvim_buf_add_highlight(M.menu_buf, 0, "Special", 2, 3, 6)
        vim.api.nvim_buf_add_highlight(M.menu_buf, 0, "Special", 3, 3, 6)
        vim.api.nvim_buf_add_highlight(M.menu_buf, 0, "Special", 4, 3, 6)
        return
    end

    -- If the menu buffer does not exist, create a new one
    M.menu_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(M.menu_buf, 'bufhidden', 'wipe') -- Close and delete the buffer when the window is closed

    -- Configure the buffer as temporarily modifiable to set the lines
    vim.api.nvim_buf_set_option(M.menu_buf, 'modifiable', true)
    vim.api.nvim_buf_set_option(M.menu_buf, 'readonly', false)
    vim.api.nvim_buf_set_lines(M.menu_buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(M.menu_buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(M.menu_buf, 'readonly', true)

    -- Create the menu window
    M.menu_win = vim.api.nvim_open_win(M.menu_buf, true, {
        relative = "editor",
        width = 50,
        height = #lines + 2,
        col = math.floor((vim.o.columns - 50) / 2),
        row = math.floor((vim.o.lines - (#lines + 2)) / 2),
        style = "minimal",
        border = "rounded"
    })
    vim.cmd("stopinsert")
    -- Add highlights
    vim.api.nvim_buf_add_highlight(M.menu_buf, 0, "Title", 0, 2, -1)
    vim.api.nvim_buf_add_highlight(M.menu_buf, 0, "Special", 2, 3, 6) -- [1]
    vim.api.nvim_buf_add_highlight(M.menu_buf, 0, "Special", 3, 3, 6) -- [2]
    vim.api.nvim_buf_add_highlight(M.menu_buf, 0, "Special", 4, 3, 6) -- [3]

    -- Configure key mappings within the menu
    local function map_menu_keys()
        local opts = {nowait = true, noremap = true, silent = true}
        -- Key mappings to choose options
        vim.api.nvim_buf_set_keymap(M.menu_buf, 'n', '1',
            '<cmd>lua require("' .. M.module_name .. '").ConvertNumberFromDecInteractive()<CR>', opts)
        vim.api.nvim_buf_set_keymap(M.menu_buf, 'n', '2',
            '<cmd>lua require("' .. M.module_name .. '").ConvertNumberFromBinInteractive()<CR>', opts)
        vim.api.nvim_buf_set_keymap(M.menu_buf, 'n', '3',
            '<cmd>lua require("' .. M.module_name .. '").ConvertNumberFromHexInteractive()<CR>', opts)
        vim.api.nvim_buf_set_keymap(M.menu_buf, 'n', '<Esc>',
            '<cmd>lua require("' .. M.module_name .. '").toggle_menu_popup()<CR>', opts)
    end

    map_menu_keys()
end

-- Function to close the menu popup
function M.toggle_menu_popup()
    if M.menu_win and vim.api.nvim_win_is_valid(M.menu_win) then
        -- If the menu window is open, close it
        vim.api.nvim_win_close(M.menu_win, true)
        M.menu_win = nil
        M.menu_buf = nil
    else
        -- Open the menu popup
        show_menu_popup()
    end
end

-- Functions to copy values to the clipboard and notify the user
function M.copy_dec()
    if M.current_values.dec ~= "" then
        vim.fn.setreg('+', M.current_values.dec)
        vim.notify("Copied Decimal value: " .. M.current_values.dec, vim.log.levels.INFO)
        M.toggle_popup()
    else
        vim.notify("No decimal value to copy.", vim.log.levels.WARN)
    end
end

function M.copy_hex()
    if M.current_values.hex ~= "" then
        vim.fn.setreg('+', M.current_values.hex)
        vim.notify("Copied Hexadecimal value: " .. M.current_values.hex, vim.log.levels.INFO)
        M.toggle_popup()
    else
        vim.notify("No hexadecimal value to copy.", vim.log.levels.WARN)
    end
end

function M.copy_bin()
    if M.current_values.bin ~= "" then
        vim.fn.setreg('+', M.current_values.bin)
        vim.notify("Copied Binary value: " .. M.current_values.bin, vim.log.levels.INFO)
        M.toggle_popup()
    else
        vim.notify("No binary value to copy.", vim.log.levels.WARN)
    end
end

-- Function to toggle the conversion popup
function M.toggle_popup()
    if M.popup_win and vim.api.nvim_win_is_valid(M.popup_win) then
        -- If the conversion window is open, close it
        vim.api.nvim_win_close(M.popup_win, true)
        M.popup_win = nil
    elseif M.popup_buf and vim.api.nvim_buf_is_valid(M.popup_buf) then
        -- If the conversion buffer exists but the window is closed, reopen the popup
        M.popup_win = vim.api.nvim_open_win(M.popup_buf, true, {
            relative = "editor",
            width = 70,
            height = 6, -- Adjust according to the number of lines
            col = math.floor((vim.o.columns - 70) / 2),
            row = math.floor((vim.o.lines - 6) / 2),
            style = "minimal",
            border = "rounded"
        })
    else
        -- If no conversion has been made yet, show an alert
        vim.notify("No conversion has been made yet.", vim.log.levels.WARN)
    end
end

-- Function to toggle the conversion menu popup
function M.toggle_menu_popup()
    if M.menu_win and vim.api.nvim_win_is_valid(M.menu_win) then
        -- If the menu window is open, close it
        vim.api.nvim_win_close(M.menu_win, true)
        M.menu_win = nil
        M.menu_buf = nil
    else
        -- Open the menu popup
        show_menu_popup()
    end
end

-- Functions for direct conversions
function M.ConvertNumberFromDec(number)
    show_conversion_popup(number, 10)
    M.toggle_menu_popup() -- Close the menu popup after initiating conversion
end

function M.ConvertNumberFromBin(number)
    show_conversion_popup(number, 2)
    M.toggle_menu_popup() -- Close the menu popup after initiating conversion
end

function M.ConvertNumberFromHex(number)
    show_conversion_popup(number, 16)
    M.toggle_menu_popup() -- Close the menu popup after initiating conversion
end

-- Functions for interactive conversion
local function show_input_popup(conversion_func, base, prompt)
    local input_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(input_buf, 'bufhidden', 'wipe')

    local width = 50
    local height = 3
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)

    local win = vim.api.nvim_open_win(input_buf, true, {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal",
        border = "rounded"
    })

    -- Add prompt to the buffer
    vim.api.nvim_buf_set_lines(input_buf, 0, -1, false, {prompt, ""})

    -- Move the cursor to the second line
    vim.api.nvim_win_set_cursor(win, {2, 0})

    -- Enter insert mode automatically
    vim.api.nvim_command('startinsert')

    -- Configure key mappings in the buffer
    local function map_keys()
        local opts = {nowait = true, noremap = true, silent = true}
        -- Esc to close the input popup
        vim.api.nvim_buf_set_keymap(input_buf, 'n', '<Esc>',
            '<cmd>lua require("' .. M.module_name .. '").close_input_popup()<CR>', opts)
        -- Enter to process the input
        vim.api.nvim_buf_set_keymap(input_buf, 'i', '<CR>',
            '<cmd>lua require("' .. M.module_name .. '").process_input("' .. conversion_func ..
                '", ' .. base .. ')<CR>', opts)
        vim.api.nvim_buf_set_keymap(input_buf, 'v', '<CR>',
            '<cmd>lua require("' .. M.module_name .. '").process_input("' .. conversion_func ..
                '", ' .. base .. ')<CR>', opts)
    end

    map_keys()

    -- Store the input window and buffer
    M.input_win = win
    M.input_buf = input_buf
end

-- Function to close the input popup
function M.close_input_popup()
    if M.input_win and vim.api.nvim_win_is_valid(M.input_win) then
        vim.api.nvim_win_close(M.input_win, true)
        M.input_win = nil
        M.input_buf = nil
    end
end

-- Function to process the user input
function M.process_input(conversion_func, base)
    -- Get the input from the buffer
    local input = vim.api.nvim_buf_get_lines(M.input_buf, 1, 2, false)[1]
    -- Close the input popup
    M.close_input_popup()

    -- Validate the input
    local valid = false
    if base == 10 then
        valid = input:match("^%d+$") ~= nil
    elseif base == 16 then
        valid = input:match("^[0-9A-Fa-f]+$") ~= nil
    elseif base == 2 then
        valid = input:match("^[01]+$") ~= nil
    end

    if not valid then
        vim.notify("Invalid number for base " .. base, vim.log.levels.ERROR)
        return
    end

    -- Call the corresponding conversion function
    if conversion_func == "ConvertNumberFromDec" then
        M.ConvertNumberFromDec(input)
    elseif conversion_func == "ConvertNumberFromHex" then
        M.ConvertNumberFromHex(input)
    elseif conversion_func == "ConvertNumberFromBin" then
        M.ConvertNumberFromBin(input)
    end
end

-- Functions for interactive conversion
function M.ConvertNumberFromDecInteractive()
    show_input_popup("ConvertNumberFromDec", 10, "Enter a Decimal number:")
end

function M.ConvertNumberFromHexInteractive()
    show_input_popup("ConvertNumberFromHex", 16, "Enter a Hexadecimal number:")
end

function M.ConvertNumberFromBinInteractive()
    show_input_popup("ConvertNumberFromBin", 2, "Enter a Binary number:")
end

-- Setup function to register commands
function M.setup()
    -- Direct conversion commands
    vim.api.nvim_create_user_command("ConvertNumberFromDec", function(args)
        M.ConvertNumberFromDec(args.args)
    end, {nargs = 1, desc = "Convert from Decimal to Binary and Hexadecimal"})

    vim.api.nvim_create_user_command("ConvertNumberFromBin", function(args)
        M.ConvertNumberFromBin(args.args)
    end, {nargs = 1, desc = "Convert from Binary to Decimal and Hexadecimal"})

    vim.api.nvim_create_user_command("ConvertNumberFromHex", function(args)
        M.ConvertNumberFromHex(args.args)
    end, {nargs = 1, desc = "Convert from Hexadecimal to Decimal and Binary"})

    -- Interactive conversion commands
    vim.api.nvim_create_user_command("ConvertNumberFromDecInteractive",
        function()
            M.ConvertNumberFromDecInteractive()
        end, {nargs = 0, desc = "Interactive conversion from Decimal"})

    vim.api.nvim_create_user_command("ConvertNumberFromBinInteractive",
        function()
            M.ConvertNumberFromBinInteractive()
        end, {nargs = 0, desc = "Interactive conversion from Binary"})

    vim.api.nvim_create_user_command("ConvertNumberFromHexInteractive",
        function()
            M.ConvertNumberFromHexInteractive()
        end, {nargs = 0, desc = "Interactive conversion from Hexadecimal"})

    -- Copy commands
    vim.api.nvim_create_user_command("ConvertNumberCopyDec",
        function() M.copy_dec() end, {
            nargs = 0,
            desc = "Copy Decimal value to clipboard"
        })

    vim.api.nvim_create_user_command("ConvertNumberCopyHex",
        function() M.copy_hex() end, {
            nargs = 0,
            desc = "Copy Hexadecimal value to clipboard"
        })

    vim.api.nvim_create_user_command("ConvertNumberCopyBin",
        function() M.copy_bin() end, {
            nargs = 0,
            desc = "Copy Binary value to clipboard"
        })

    -- Toggle conversion popup command
    vim.api.nvim_create_user_command("ConvertNumberToggle",
        function() M.toggle_popup() end, {
            nargs = 0,
            desc = "Toggle the conversion popup"
        })

    -- New command to show the conversion menu
    vim.api.nvim_create_user_command("ConvertNumberMenu",
        function()
            M.toggle_menu_popup()
        end, {
            nargs = 0,
            desc = "Show the Number Conversion Menu"
        })
end

return M
