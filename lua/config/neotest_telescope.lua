local neotest = require("neotest")
local telescope = require("telescope")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")

local M = {}
local tests = {}

function M.get_all_tests()
    local tests = {}
    local rs_files = {}
    local root_dir = vim.fn.getcwd()

    local function scan_dir(dir, file_list, in_test_dir)
        local handle = vim.loop.fs_scandir(dir)
        if handle then
            while true do
                local name, type = vim.loop.fs_scandir_next(handle)
                if not name then
                    break
                end
                local path = dir .. "/" .. name
                if type == "directory" then
                    if name ~= "target" and name ~= ".git" then
                        local is_test_dir = in_test_dir or name:match("^test")
                        scan_dir(path, file_list, is_test_dir)
                    end
                elseif type == "file" and name:match("%.rs$") and in_test_dir then
                    table.insert(file_list, path)
                end
            end
        end
    end

    scan_dir(root_dir, rs_files, false)
    return rs_files
end

function M.collect_tests_from_file(filepath, callback)
    local tests = {}
    local bufnr = vim.fn.bufadd(filepath)
    vim.fn.bufload(bufnr)
    local uri = vim.uri_from_bufnr(bufnr)

    vim.lsp.buf_request(
        bufnr,
        "textDocument/codeLens",
        {textDocument = {uri = uri}},
        function(err, result)
            if err then
                print("LSP request error for " .. filepath .. ":", err)
            end
            if result then
                for _, lens in ipairs(result) do
                    local command = lens.command
                    if command and command.command == "rust-analyzer.runSingle" then
                        table.insert(tests, command)
                    end
                end
            end
            callback(tests)
        end
    )
end

function M.show_tests_in_telescope(tests)
    local entries = {}
    for _, test_entry in ipairs(tests) do
        local test = test_entry.test
        local filepath = test_entry.filepath
        local label = test.arguments[1].label or "Unnamed Test"
        if not label:match("^test%-mod") then
            label = label:gsub("^test%s+", "")
            table.insert(entries, {display = label, test = test, filepath = filepath})
        end
    end

    pickers.new(
        {
            initial_mode = "normal"
        },
        {
            prompt_title = "Rust Tests",
            finder = finders.new_table {
                results = entries,
                entry_maker = function(entry)
                    return {
                        value = entry.test,
                        display = entry.display,
                        ordinal = entry.display,
                        filepath = entry.filepath
                    }
                end
            },
            sorter = sorters.get_generic_fuzzy_sorter(),
            previewer = previewers.new_buffer_previewer {
                define_preview = function(self, entry, status)
                    local filepath = entry.filepath
                    if not filepath then
                        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, {"No file path available"})
                        return
                    end

                    local ok, content = pcall(vim.fn.readfile, filepath)
                    if ok and #content > 0 then
                        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, content)
                        vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "rust")

                        local line = entry.value.arguments[1].location.targetSelectionRange.start.line
                        local start_column = entry.value.arguments[1].location.targetSelectionRange.start.character
                        local end_column = entry.value.arguments[1].location.targetSelectionRange["end"].character
                        vim.schedule(
                            function()
                                vim.api.nvim_win_call(
                                    status.preview_win,
                                    function()
                                        vim.api.nvim_win_set_cursor(status.preview_win, {line + 1, 0})
                                        vim.cmd("normal! zz")
                                    end
                                )
                                vim.api.nvim_buf_add_highlight(
                                    self.state.bufnr,
                                    -1,
                                    "Search",
                                    line,
                                    start_column,
                                    end_column
                                )
                            end
                        )
                    else
                        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, {"Unable to read file"})
                    end
                end
            },
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(
                    function()
                        actions.close(prompt_bufnr)
                        local selection = action_state.get_selected_entry()

                        local test = selection.value
                        local filepath = selection.filepath

                        local line = test.arguments[1].location.targetSelectionRange.start.line
                        local start_column = test.arguments[1].location.targetSelectionRange.start.character
                        local end_column = test.arguments[1].location.targetSelectionRange["end"].character

                        vim.cmd("edit " .. filepath)
                        vim.defer_fn(
                            function()
                                vim.api.nvim_win_set_cursor(0, {line + 1, start_column})
                            end,
                            50
                        )

                        require("neotest").run.run({strategy = "dap"})
                    end
                )
                return true
            end
        }
    ):find()
end

function M.print_all_test()
    local test_to_iterate = {}
    local rs_files = M.get_all_tests()

    local pending = #rs_files
    if pending == 0 then
        print("No .rs files found.")
        return
    end

    for _, path in ipairs(rs_files) do
        M.collect_tests_from_file(
            path,
            function(tests)
                if tests then
                    for _, test in ipairs(tests) do
                        table.insert(test_to_iterate, {test = test, filepath = path})
                    end
                end
                pending = pending - 1
                if pending == 0 then
                    M.show_tests_in_telescope(test_to_iterate)
                end
            end
        )
    end
end

function M.setup()
    vim.api.nvim_create_user_command("TelescopeTests", M.print_all_test, {desc = "List and run tests using Telescope"})
end

return M
