local neotest = require("neotest")
local telescope = require("telescope")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}
local tests = {}

function M.get_all_tests()
    local tests = {}
    local rs_files = {}
    local root_dir = vim.fn.getcwd()

    -- Function to recursively scan directories for .rs files within 'test*' directories
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

    -- Start scanning from the root directory
    scan_dir(root_dir, rs_files, false)

    -- Print the found .rs files
    print("Found .rs files:")
    for _, file in ipairs(rs_files) do
        print(file)
    end

    return rs_files
end

function M.collect_tests_from_file(filepath, callback)
    local tests = {}

    -- Add and load the buffer for the given file path
    local bufnr = vim.fn.bufadd(filepath)
    vim.fn.bufload(bufnr)
    local uri = vim.uri_from_bufnr(bufnr)

    -- Request codeLens from the LSP server
    vim.lsp.buf_request(
        bufnr,
        "textDocument/codeLens",
        { textDocument = { uri = uri } },
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
            -- Print the tests found in the file
            print("Tests in " .. filepath .. ":")
            for _, test in ipairs(tests) do
                print(vim.inspect(test))
            end
            callback(tests)
        end
    )
end

-- Function to display tests in Telescope and run the selected test
function M.show_tests_in_telescope(tests)
    local entries = {}
    for _, test in ipairs(tests) do
        local label = test.arguments[1].label or "Unnamed Test"

        -- Exclude tests that are modules (e.g., names like "test-mod")
        if not label:match("^test%-mod") then
            -- Remove the word "test" from the label if it exists
            label = label:gsub("^test%s+", "")
            table.insert(entries, { display = label, test = test })
        end
    end

    -- Print the entries that will be sent to Telescope
    print("Entries for Telescope:")
    for _, entry in ipairs(entries) do
        print(vim.inspect(entry))
    end
    print("=====")

    pickers.new(
        {
            -- Set Telescope to open in normal mode
            initial_mode = "normal",
        },
        {
            prompt_title = "Rust Tests",
            finder = finders.new_table {
                results = entries,
                entry_maker = function(entry)
                    return {
                        value = entry.test,
                        display = entry.display,
                        ordinal = entry.display
                    }
                end
            },
            sorter = sorters.get_generic_fuzzy_sorter(),
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(
                    function()
                        actions.close(prompt_bufnr)
                        local selection = action_state.get_selected_entry()
                        M.run_test(selection.value)
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

    -- Counter to handle asynchronous calls
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
                        table.insert(test_to_iterate, test)
                    end
                end
                pending = pending - 1
                if pending == 0 then
                    -- Print all collected tests
                    print("All collected tests:")
                    for _, test in ipairs(test_to_iterate) do
                        print(vim.inspect(test))
                    end
                    M.show_tests_in_telescope(test_to_iterate)
                end
            end
        )
    end
end

-- Function to run the selected test
function M.run_test(test)
    -- Implement the logic to run the test here
    print("Running test:", vim.inspect(test))
    -- For example, you could use neotest to run the test
    -- neotest.run.run(vim.inspect(test))
end

-- Setup function to define the command
function M.setup()
    vim.api.nvim_create_user_command("TelescopeTests", M.print_all_test, { desc = "List and run tests using Telescope" })
end

return M
