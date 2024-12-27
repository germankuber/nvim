local Popup = require("nui.popup")
local ReadFile = require("config.helpers.read_file")
local Input = require("nui.input")
local Layout = require("nui.layout")
local event = require("nui.utils.autocmd").event
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local conf = require("telescope.config").values
local Menu = require("nui.menu")

local M = {}

local saved_mappings = {}

-- Modes to consider
local modes = {"n", "i", "v", "x", "s", "o", "t", "c"}
local inputs = {}
local request_selected = {}
local layout = {}
local inputs_values = {}
local input_status = "close"
local inputs_names_to_show = {}
-- Function to save the current mappings for a key in all modes
local function save_mapping(key)
    local key_mappings = {} -- Temporary table to store mappings for this key
    for _, mode in ipairs(modes) do
        local mappings = vim.api.nvim_get_keymap(mode)
        for _, map in ipairs(mappings) do
            if map.lhs == key then
                key_mappings[mode] = map
                break
            end
        end
    end
    saved_mappings[key] = key_mappings
    return key_mappings -- Return the saved mappings for this key
end

-- Function to restore the saved mappings for a key in all modes
local function restore_mapping(key)
    local key_mappings = saved_mappings[key]
    if not key_mappings then
        return false -- No saved mappings for this key
    end

    for _, mode in ipairs(modes) do
        local map = key_mappings[mode]
        if map then
            vim.api.nvim_set_keymap(
                mode,
                key,
                map.rhs or "",
                {
                    noremap = not map.noremap,
                    silent = map.silent,
                    expr = map.expr,
                    script = map.script
                }
            )
        else
            -- If no mapping was saved for this mode, delete the keymap
            pcall(vim.api.nvim_del_keymap, mode, key)
        end
    end

    return true -- Mappings restored successfully
end

local function read_file_content(file)
    local f = io.open(file, "r")
    if not f then
        return ""
    end
    local content = f:read("*a")
    f:close()
    return content
end
local function get_request_from_file(path)
    local files = vim.fn.glob(path .. "/*.request", true, true)
    local data = {}

    for _, file in ipairs(files) do
        local content = read_file_content(file)
        local filename = vim.fn.fnamemodify(file, ":t"):gsub("%.request$", "")

        table.insert(
            data,
            {
                value = file,
                ordinal = filename,
                display = filename,
                preview = content
            }
        )
    end
    return data
end
function parse_toml_to_table(toml_string)
    local result = {}
    local currentSection = result
    local lines = {}
    for line in toml_string:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end

    local function trim(s)
        return s:match("^%s*(.-)%s*$")
    end

    local i = 1
    local count = #lines

    while i <= count do
        local line = trim(lines[i])
        if line == "" or line:match("^#") then
            i = i + 1
        elseif line:match("^%[.-%]$") then
            local sectionName = line:match("^%[(.-)%]$")
            result[sectionName] = {}
            currentSection = result[sectionName]
            i = i + 1
        else
            local key, value = line:match("^(.-)%s*=%s*(.*)$")
            if key and value then
                key = trim(key)
                value = trim(value)

                if value:sub(1, 3) == "'''" then
                    local multilineValue = {}
                    local firstLine = value:sub(4)
                    local closed = false
                    if firstLine:sub(-3) == "'''" then
                        table.insert(multilineValue, firstLine:sub(1, -4))
                        closed = true
                    else
                        table.insert(multilineValue, firstLine)
                    end
                    i = i + 1
                    while not closed and i <= count do
                        local nextLine = lines[i]
                        local tripleQuotePos = nextLine:find("'''")
                        if tripleQuotePos then
                            table.insert(multilineValue, nextLine:sub(1, tripleQuotePos - 1))
                            closed = true
                        else
                            table.insert(multilineValue, nextLine)
                        end
                        i = i + 1
                    end
                    currentSection[key] = table.concat(multilineValue, "\n")
                else
                    if value:match("^%d+$") then
                        currentSection[key] = tonumber(value)
                    elseif value:match('^".*"$') or value:match("^'.*'$") then
                        currentSection[key] = value:sub(2, -2)
                    elseif value:lower() == "true" or value:lower() == "false" then
                        currentSection[key] = (value:lower() == "true")
                    else
                        currentSection[key] = value
                    end
                    i = i + 1
                end
            else
                i = i + 1
            end
        end
    end

    return result
end
local function parse_placeholders(str)
    local unique = {}
    for ph in str:gmatch("{{(.-)}}") do
        unique[ph] = true
    end
    local placeholders = {}
    for ph, _ in pairs(unique) do
        table.insert(placeholders, ph)
    end
    return placeholders
end

local function close_popup(buf, win)
    if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
    end
    if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, {force = true})
    end
end
local function close()
    for _, input in ipairs(inputs) do
        input:unmount()
    end
    layout:unmount()
end
local function make_request(request_table)
    -- Ensure required fields are present
    if not request_table.url or not request_table.method then
        error("Request table must contain 'url' and 'method' fields.")
    end

    -- Initialize the curl command
    local cmd = {"curl", "-s", "-X", request_table.method, request_table.url}

    -- Add headers if present
    if request_table.headers then
        for key, value in pairs(request_table.headers) do
            -- Skip 'body' if it's mistakenly inside headers
            if key ~= "body" then
                table.insert(cmd, "-H")
                table.insert(cmd, string.format('"%s: %s"', key, value))
            end
        end
    end

    for key, value in pairs(inputs_values) do
        request_table.body = request_table.body:gsub("{{" .. key .. "}}", value)
    end

    if request_table.body then
        table.insert(cmd, "-d")
        table.insert(cmd, string.format("'%s'", request_table.body:gsub("\n", "")))
    end

    -- Concatenate the command table into a single string
    local cmd_str = table.concat(cmd, " ")

    -- Execute the curl command

    local handle = io.popen(cmd_str)
    local result = handle:read("*a")
    local success, _, exit_code = handle:close()

    -- Handle execution results
    if success then
        return result
    else
        error(string.format("Request failed with exit code %s", exit_code))
    end
end
local function display_response(json_string)
    -- Decode the JSON string
    local ok, decoded = pcall(vim.fn.json_decode, json_string)
    if not ok then
        error("Invalid JSON string provided.")
    end

    -- Function to serialize Lua table with indentation
    local function serialize(tbl, indent)
        indent = indent or 0
        local s = ""
        local indent_str = string.rep("  ", indent)
        if type(tbl) ~= "table" then
            if type(tbl) == "string" then
                s = '"' .. tbl .. '"'
            else
                s = tostring(tbl)
            end
            return s
        end
        s = s .. "{\n"
        for k, v in pairs(tbl) do
            s = s .. indent_str .. "  " .. '"' .. k .. '": ' .. serialize(v, indent + 1) .. ",\n"
        end
        s = s .. indent_str .. "}"
        return s
    end

    -- Pretty-print the JSON
    local formatted_json = serialize(decoded)

    -- Open a new tab to ensure full-screen buffer
    vim.cmd("tabnew")
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_name(buf, request_selected.display)

    -- Prepare the content
    local lines = {
        "Response",
        "",
        "Body:",
        ""
    }

    -- Split the formatted JSON into lines and add to content
    for line in formatted_json:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end

    -- Set the lines in the buffer
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Set the buffer to be non-modifiable and read-only
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "readonly", true)

    -- Set filetype to JSON for syntax highlighting
    vim.api.nvim_buf_set_option(buf, "filetype", "json")

    -- Optional: Center the view
    vim.cmd("normal! gg")
end
local function execute()
    if input_status == "open" then
        request = make_request(parse_toml_to_table(request_selected.preview))
        display_response(request)
        -- local url = request_selected.url:match('url%s*=%s*"(.-)"') or ""
        -- -- local method = request_selected:match('method%s*=%s*"(.-)"') or "GET"
        -- -- local raw_headers = parse_headers_section(current_request_content)
        -- -- local raw_body = parse_body_section(current_request_content)

        -- print(url)
        -- print(method)
        -- print(raw_headers)
        -- print(raw_body)

        -- url = replace_placeholders(url, inputs_values)
        -- method = replace_placeholders(method, inputs_values)

        -- local headers = {}
        -- for k, v in pairs(raw_headers) do
        --     local header_key = replace_placeholders(k, inputs_values)
        --     local header_val = replace_placeholders(v, inputs_values)
        --     headers[header_key] = header_val
        -- end

        -- local body = replace_placeholders(raw_body, inputs_values)

        -- local cmd = {"curl", "-s", "-X", method}

        -- for key, val in pairs(headers) do
        --     table.insert(cmd, "-H")
        --     table.insert(cmd, key .. ": " .. val)
        -- end

        -- table.insert(cmd, url)

        -- if (method == "POST" or method == "PUT" or method == "PATCH") and body ~= "" then
        --     table.insert(cmd, "-d")
        --     table.insert(cmd, body)
        -- end

        -- local result = vim.fn.system(cmd)
        -- print("Resultado de la request:\n" .. result)

        close()
        input_status = "close"
    end
end

local function show_form(fields)
    local Input = require("nui.input")

    local function next_focus(inputs, current_input_index)
        next_input = inputs[current_input_index]

        if next_input then
            vim.api.nvim_set_current_win(next_input.winid)
        --   vim.cmd("startinsert!")
        end
        if current_input_index == #inputs then
            current_input_index = 1
        else
            current_input_index = current_input_index + 1
        end
        return current_input_index
    end
    local function create_inputs(input_names, base_opts, handlers)
        base_opts = base_opts or {}

        local total_inputs = #input_names
        inputs_names_to_show = input_names
        local current_input_index = 1
        local input_height = 4
        local screen_width = vim.api.nvim_get_option("columns")
        local input_width = 90
        local centered_col = math.floor((screen_width - input_width) / 2)

        local first_row = 0
        local first_col = 0

        local top_popup = Popup({border = "double"})
        local bottom_left_popup = Popup({border = "single"})
        local bottom_right_popup = Popup({border = "single"})

        layout =
            Popup(
            {
                enter = false,
                focusable = false,
                position = {
                    row = math.floor((vim.api.nvim_get_option("lines") - (input_height * total_inputs)) / 2) +
                        (0 - 1) * (input_height - 1),
                    col = centered_col - 5
                },
                size = {
                    width = input_width + 10,
                    height = (input_height * #input_names) + 2
                }
            }
        )

        layout:mount()
        local text = "Press <TAB>/navigate, <Q>/close, <E>/ execute"
        local win_width = vim.api.nvim_win_get_width(0)
        local padding = 99 - #text

        local aligned_text = string.rep(" ", padding) .. text

        vim.api.nvim_buf_set_lines(layout.bufnr, 0, 1, false, {aligned_text})
        for i, name in ipairs(input_names) do
            local row_offset = (i - 1) * (input_height - 1)

            local opts =
                vim.tbl_deep_extend(
                "force",
                {},
                base_opts,
                {
                    relative = "editor",
                    position = {
                        row = math.floor((vim.api.nvim_get_option("lines") - (input_height * total_inputs)) / 2) +
                            row_offset,
                        col = centered_col
                    },
                    size = {
                        width = input_width,
                        height = input_height
                    },
                    border = {
                        style = "double",
                        text = {
                            top = string.format("[%s]", name),
                            top_align = "left"
                        }
                    },
                    win_options = {winblend = 0}
                }
            )

            local input =
                Input(
                opts,
                {
                    prompt = "> ",
                    default_value = "",
                    on_change = function(value)
                        inputs_values[name] = value
                    end
                }
            )

            input:mount()
            table.insert(inputs, input)
        end

        for i, inp in ipairs(inputs) do
            local next_index = (i == total_inputs) and 1 or (i + 1)
            inp:map(
                "i",
                "<Tab>",
                function()
                    vim.schedule(
                        function()
                            current_input_index = next_focus(inputs, current_input_index)
                        end
                    )
                end,
                {noremap = true, silent = true}
            )
            inp:map(
                "i",
                "Q",
                function()
                    close()
                end,
                {noremap = true, silent = true}
            )

            inp:map(
                "i",
                "E",
                function()
                    for _, input in ipairs(inputs) do
                        execute()
                    end
                end,
                {noremap = true, silent = true}
            )
            inp:map(
                "i",
                "<CR>", -- Map Enter key
                function()
                    vim.schedule(
                        function()
                            for _, input in ipairs(inputs) do
                                execute()
                            end
                        end
                    )
                end,
                {noremap = true, silent = true}
            )
        end

        vim.schedule(
            function()
                local first_input = inputs[1]
                if first_input and first_input.focus then
                    first_input:focus()
                    vim.cmd("startinsert!")
                end
            end
        )

        current_input_index = next_focus(inputs, current_input_index)
        return inputs
    end

    local mapping_saved_Q = save_mapping("Q")
    local mapping_saved_E = save_mapping("E")
    local mapping_saved_CR = save_mapping("<CR>")
    create_inputs(
        fields,
        {},
        {
            on_close = function()
                restore_mapping(mapping_saved_Q)
                restore_mapping(mapping_saved_E)
                restore_mapping(mapping_saved_CR)
            end,
            on_submit = function(value)
            end,
            on_change = function(value)
            end
        }
    )
    input_status = "open"
end

function M.setup(opts)
    vim.api.nvim_set_hl(0, "TomlSection", {fg = "#FFD700", bold = true})
    vim.api.nvim_set_hl(0, "TomlKey", {fg = "#00FF00", bold = true})
    vim.api.nvim_set_hl(0, "JsonBody", {fg = "#87AFD7"})

    requests_from_file = get_request_from_file(opts.path or vim.fn.expand("~/.requests"))

    local function on_select(entry)
        local placeholders = parse_placeholders(entry.preview or "")
        if #placeholders == 0 then
            input_status = "open"
            execute()
        else
            show_form(placeholders)
        end
    end
    local function show_requests()
        inputs = {}
        layout = {}
        inputs_values = {}
        request_selected = {}
        pickers.new(
            {
                prompt_title = "Requests",
                initial_mode = "normal",
                layout_strategy = "horizontal",
                layout_config = {
                    width = 0.9,
                    preview_width = 0.6
                }
            },
            {
                finder = finders.new_table {
                    results = requests_from_file,
                    entry_maker = function(entry)
                        return {
                            value = entry.value,
                            ordinal = entry.ordinal,
                            display = entry.display,
                            preview = entry.preview
                        }
                    end
                },
                previewer = previewers.new_buffer_previewer {
                    define_preview = function(self, entry, _)
                        local ns = vim.api.nvim_create_namespace("my_request_preview")
                        vim.api.nvim_buf_set_option(self.state.bufnr, "modifiable", true)
                        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, {})
                        if entry.preview and entry.preview ~= "" then
                            local lines = vim.split(entry.preview, "\n", true)
                            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
                            local in_body = false
                            for i, line in ipairs(lines) do
                                if line:match("^%[.-%]$") then
                                    vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, "TomlSection", i - 1, 0, -1)
                                elseif
                                    line:match("^%s*url%s*=") or line:match("^%s*method%s*=") or
                                        line:match("^%s*body%s*=")
                                 then
                                    vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, "TomlKey", i - 1, 0, -1)
                                end
                                if line:match("'''") then
                                    in_body = not in_body
                                elseif in_body then
                                    vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, "JsonBody", i - 1, 0, -1)
                                end
                            end
                        end
                        vim.api.nvim_buf_set_option(self.state.bufnr, "modifiable", false)
                    end
                },
                sorter = conf.generic_sorter({}),
                attach_mappings = function(_, map)
                    map(
                        "i",
                        "<CR>",
                        function(prompt_bufnr)
                            local action_state = require("telescope.actions.state")
                            local selected = action_state.get_selected_entry()
                            require("telescope.actions").close(prompt_bufnr)
                            on_select(selected)
                        end
                    )
                    map(
                        "n",
                        "<CR>",
                        function(prompt_bufnr)
                            local action_state = require("telescope.actions.state")
                            request_selected = action_state.get_selected_entry()
                            require("telescope.actions").close(prompt_bufnr)
                            on_select(request_selected)
                        end
                    )
                    return true
                end
            }
        ):find()
    end

    vim.api.nvim_create_user_command("RequestPicker", show_requests, {})
end

return M
