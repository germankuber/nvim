local Popup = require("nui.popup")
local Input = require("nui.input")
local event = require("nui.utils.autocmd").event
local Menu = require("nui.menu")
local M = {}

function M.setup(opts)
    local path = opts.path or vim.fn.expand("~/.requests")
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local previewers = require("telescope.previewers")
    local conf = require("telescope.config").values

    vim.api.nvim_set_hl(0, "TomlSection", {fg = "#FFD700", bold = true})
    vim.api.nvim_set_hl(0, "TomlKey", {fg = "#00FF00", bold = true})
    vim.api.nvim_set_hl(0, "JsonBody", {fg = "#87AFD7"})

    local function read_file_content(file)
        local f = io.open(file, "r")
        if not f then
            return ""
        end
        local content = f:read("*a")
        f:close()
        return content
    end

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
            handlers =
                handlers or
                {
                    on_close = function()
                    end,
                    on_submit = function(_)
                    end,
                    on_change = function(_)
                    end
                }

            local inputs = {}
            local total_inputs = #input_names
            local current_input_index = 1
            local input_height = 4
            local screen_width = vim.api.nvim_get_option("columns")
            local input_width = 90
            local centered_col = math.floor((screen_width - input_width) / 2)

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
                            style = "single",
                            text = {
                                top = string.format("[ %s ]", name),
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
                        on_close = handlers.on_close,
                        on_submit = handlers.on_submit,
                        on_change = handlers.on_change
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
                    "<Esc>",
                    function()
                        for _, input in ipairs(inputs) do
                            input:unmount()
                        end
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

        create_inputs(
            fields,
            {},
            {
                on_close = function()
                    print("Closed")
                end,
                on_submit = function(value)
                    print("Submitted:", value)
                end,
                on_change = function(value)
                    -- print("Changed:", value)
                end
            }
        )
    end

    local function on_select(entry)
        local placeholders = parse_placeholders(entry.preview or "")
        if #placeholders == 0 then
            return
        end
        show_form(placeholders)
    end
    local function show_requests()
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
                    results = data,
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
                            local selected = action_state.get_selected_entry()
                            require("telescope.actions").close(prompt_bufnr)
                            on_select(selected)
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
