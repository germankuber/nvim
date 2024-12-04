-- file: lua/config/terminal.lua
local M = {}

-- Require necessary modules
local Popup = require("nui.popup")
local Input = require("nui.input")
local event = require("nui.utils.autocmd").event
local telescope = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

-- Table to store terminals
local terminals = {}
-- Variable to keep track of the current terminal
local current_terminal = nil

-- Function to hide the current terminal
local function hide_current_terminal()
    -- Check if there is a current terminal
    if current_terminal and terminals[current_terminal] then
        -- Hide the current terminal's popup
        terminals[current_terminal]:hide()
    end
end

-- Function to create the terminal popup
local function create_terminal_popup(name)
    -- Create a new popup window for the terminal
    local popup = Popup({
        enter = true,
        focusable = true,
        border = { style = "rounded", text = { top = name, top_align = "center" } },
        position = "50%",
        size = { width = 140, height = 30 },
        win_options = {
            winblend = 10,
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
        },
    })

    -- Mount the popup to display it
    popup:mount()
    -- Enter insert mode to start typing
    vim.cmd("startinsert!")

    -- Get the buffer number of the popup
    local term_bufnr = popup.bufnr
    if term_bufnr and term_bufnr > 0 then
        -- Open a terminal in the popup window using the user's shell
        vim.fn.termopen(os.getenv("SHELL") or "/bin/sh")
        -- Map the <Esc> key in terminal mode to exit to normal mode
        vim.api.nvim_buf_set_keymap(term_bufnr, "t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })
    else
        -- Notify the user if there's an error creating the terminal buffer
        vim.notify("Error creating terminal buffer.", vim.log.levels.ERROR)
        -- Unmount the popup to clean up
        popup:unmount()
        return nil
    end

    -- Hide the popup when the buffer is left
    popup:on(event.BufLeave, function()
        popup:hide()
    end)

    -- Return the created popup
    return popup
end

-- Function to create a new terminal
local function create_terminal(name)
    -- Check if a terminal with the given name already exists
    if terminals[name] then
        vim.notify("Terminal '" .. name .. "' already exists.", vim.log.levels.WARN)
        return
    end

    -- Hide the current terminal if any
    hide_current_terminal()

    -- Create the terminal popup
    local popup = create_terminal_popup(name)
    if not popup then
        return
    end

    -- Store the terminal popup in the terminals table
    terminals[name] = popup
    -- Set the current terminal to the newly created one
    current_terminal = name
end

-- Function to show an existing terminal
local function show_terminal(name)
    -- Check if the terminal exists
    if not terminals[name] then
        vim.notify("Terminal '" .. name .. "' does not exist.", vim.log.levels.ERROR)
        return
    end

    -- Hide the current terminal if any
    hide_current_terminal()

    -- Show the selected terminal's popup
    terminals[name]:show()
    -- Update the current terminal
    current_terminal = name
end

-- Function to remove a terminal
local function remove_terminal(name)
    -- Get the terminal popup from the terminals table
    local terminal_popup = terminals[name]
    if not terminal_popup then
        vim.notify("Terminal '" .. name .. "' does not exist.", vim.log.levels.ERROR)
        return
    end

    -- Unmount the popup to remove it
    terminal_popup:unmount()

    -- Get the buffer number associated with the terminal
    local term_bufnr = terminal_popup.bufnr
    -- Delete the buffer if it's valid
    if term_bufnr and vim.api.nvim_buf_is_valid(term_bufnr) then
        vim.api.nvim_buf_delete(term_bufnr, { force = true })
    end

    -- Remove the terminal from the terminals table
    terminals[name] = nil

    -- If it was the current terminal, reset the current_terminal variable
    if current_terminal == name then
        current_terminal = nil
    end
end

-- Function to close a terminal
local function close_terminal(name)
    -- Check if the terminal exists
    if not terminals[name] then
        vim.notify("Terminal '" .. name .. "' does not exist.", vim.log.levels.ERROR)
        return
    end

    -- Remove the terminal
    remove_terminal(name)

    -- If there are other terminals, show one of them
    for t_name, _ in pairs(terminals) do
        show_terminal(t_name)
        break
    end
end

-- Function to list the names of all terminals
local function list_terminals()
    local names = {}
    -- Iterate over the terminals table and collect names
    for name, _ in pairs(terminals) do
        table.insert(names, name)
    end
    return names
end

-- Generic function for terminal pickers using Telescope
local function terminal_picker(title, action)
    -- Check if there are any terminals available
    if vim.tbl_isempty(terminals) then
        vim.notify("No terminals available.", vim.log.levels.WARN)
        return
    end

    -- Create a new Telescope picker
    telescope.new({}, {
        prompt_title = title,
        finder = finders.new_table { results = list_terminals() },
        sorter = sorters.get_generic_fuzzy_sorter(),
        attach_mappings = function(prompt_bufnr, map)
            -- Replace the default selection action
            actions.select_default:replace(function()
                -- Close the Telescope prompt
                actions.close(prompt_bufnr)
                -- Get the selected terminal name
                local selection = action_state.get_selected_entry()
                if selection then
                    -- Perform the action with the selected terminal
                    action(selection[1])
                end
            end)
            return true
        end,
    }):find()
    -- Exit insert mode after using Telescope
    vim.cmd("stopinsert")
end

-- Function to pick and show a terminal
local function pick_terminal()
    -- Use the generic terminal_picker with the show_terminal action
    terminal_picker("Select Terminal", show_terminal)
end

-- Function to pick and close a terminal
local function close_terminal_picker()
    -- Use the generic terminal_picker with the close_terminal action
    terminal_picker("Close Terminal", close_terminal)
end

-- Function to create a terminal using an input prompt
local function create_terminal_picker()
    -- Create an input popup for the terminal name
    local input_popup = Input({
        position = "50%",
        size = { width = 40, height = 1 },
        border = {
            style = "rounded",
            text = { top = " New Terminal Name ", top_align = "center" },
        },
    }, {
        prompt = "Name: ",
        default_value = "",
        on_submit = function(value)
            -- Check if the input value is not empty
            if value ~= "" then
                -- Create a new terminal with the given name
                create_terminal(value)
            else
                -- Notify the user if the terminal name is empty
                vim.notify("Terminal name cannot be empty.", vim.log.levels.ERROR)
            end
        end,
    })

    -- Display the input popup
    input_popup:mount()
end

-- Function to hide the current terminal
local function hide_terminal()
    -- Check if there is a current terminal
    if not current_terminal or not terminals[current_terminal] then
        vim.notify("No terminal is currently open.", vim.log.levels.WARN)
        return
    end

    -- Hide the current terminal's popup
    terminals[current_terminal]:hide()
    -- Reset the current_terminal variable
    current_terminal = nil
end

-- Function to close and remove the current terminal
local function close_and_remove_terminal()
    -- Check if there is a current terminal
    if not current_terminal or not terminals[current_terminal] then
        vim.notify("No terminal is currently open.", vim.log.levels.WARN)
        return
    end

    -- Get the name of the current terminal
    local terminal_name = current_terminal
    -- Remove the terminal
    remove_terminal(terminal_name)

    -- Notify the user that the terminal has been closed and removed
    vim.notify("Terminal '" .. terminal_name .. "' has been closed and removed.", vim.log.levels.INFO)
end

-- Function to close and remove all terminals
local function close_and_remove_all_terminals()
    -- Check if there are any terminals to close
    if vim.tbl_isempty(terminals) then
        vim.notify("No terminals to close.", vim.log.levels.WARN)
        return
    end

    -- Get a list of all terminal names
    local terminal_names = list_terminals()
    -- Iterate over the list and remove each terminal
    for _, name in ipairs(terminal_names) do
        remove_terminal(name)
    end

    -- Notify the user that all terminals have been closed and removed
    vim.notify("All terminals have been closed and removed.", vim.log.levels.INFO)
end

-- Create user commands for the terminal functions
vim.api.nvim_create_user_command('TerminalCreate', create_terminal_picker, { desc = "Create a new terminal" })
vim.api.nvim_create_user_command('TerminalList', pick_terminal, { desc = "List and select a terminal" })
vim.api.nvim_create_user_command('TerminalClose', close_and_remove_terminal, { desc = "Close the current terminal" })
vim.api.nvim_create_user_command('TerminalCloseAll', close_and_remove_all_terminals, { desc = "Close all terminals" })
vim.api.nvim_create_user_command('TerminalHide', hide_terminal, { desc = "Hide the current terminal" })

return M
