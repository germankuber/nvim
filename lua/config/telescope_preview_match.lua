local M = {}
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local previewers = require("telescope.previewers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
-- Default highlight configuration
local default_highlight = {
    fg = "#FF4500", -- Orange-red foreground
    bg = "NONE", -- No background
    bold = true,
    underline = true
}

-- Setup function
function M.setup(config)
    config = config or {}
    local highlight = vim.tbl_extend("force", default_highlight, config)

    -- Set up the highlight group
    vim.api.nvim_set_hl(0, "TelescopePreviewMatch", highlight)

    -- Register commands
    M.register_commands()
end

-- Helper to get Treesitter parser
local function get_parser(bufnr)
    local parser = vim.treesitter.get_parser(bufnr or vim.api.nvim_get_current_buf())
    if not parser then
        print("No Treesitter parser found for this buffer")
        return nil
    end
    return parser
end

-- Get the enclosing function or method node
local function get_enclosing_function_node(bufnr)
    local parser = get_parser(bufnr)
    if not parser then
        return nil
    end

    local cursor = vim.api.nvim_win_get_cursor(0)
    local row, col = cursor[1] - 1, cursor[2]

    local tree = parser:parse()[1]
    if not tree then
        print("No Treesitter tree found for this buffer")
        return nil
    end

    local node = tree:root():named_descendant_for_range(row, col, row, col)
    while node do
        if node:type():match("function") or node:type():match("method") then
            return node
        end
        node = node:parent()
    end

    print("No enclosing function or method found")
    return nil
end

-- Collect nodes based on a predicate
local function collect_nodes(root, bufnr, predicate)
    local results = {}

    local function traverse(node)
        if predicate(node) then
            local start_row, start_col, _, end_col = node:range()
            table.insert(
                results,
                {
                    node = node,
                    row = start_row + 1,
                    col = start_col + 1,
                    end_col = end_col + 1
                }
            )
        end
        for child in node:iter_children() do
            traverse(child)
        end
    end

    traverse(root)
    return results
end

-- Collect all local variables in a given function node
local function collect_local_variables(node, bufnr)
    return collect_nodes(
        node,
        bufnr,
        function(n)
            return n:type():match("let_declaration") or n:type():match("let_stmt")
        end
    )
end

-- Collect all references to `self`
local function collect_self_references(root, bufnr)
    local parser = get_parser(bufnr)
    if not parser then
        return {}
    end

    local query_text =
        [[
        [
            (self) @self_ref
            (identifier) @self_ref (#match? @self_ref "^self$")
        ]
    ]]
    local query = vim.treesitter.query.parse(parser:lang(), query_text)
    local results = {}

    for id, node in query:iter_captures(root, bufnr, 0, -1) do
        if query.captures[id] == "self_ref" then
            local start_row, start_col, _, end_col = node:range()
            table.insert(
                results,
                {
                    row = start_row + 1,
                    col = start_col + 1,
                    end_col = end_col + 1
                }
            )
        end
    end
    return results
end

-- Create a Telescope picker
local function create_telescope_picker(bufnr, items, title, display_fn)
    if #items == 0 then
        print("No items found")
        return
    end

    local current_file = vim.api.nvim_buf_get_name(bufnr)
    pickers.new(
        {
            initial_mode = "normal" -- Set the initial mode to 'normal'
        },
        {
            prompt_title = title,
            finder = finders.new_table(
                {
                    results = items,
                    entry_maker = function(entry)
                        -- Find the 'identifier' node within the current node
                        local identifier_node = nil
                        for child in entry.node:iter_children() do
                            if child:type():match("identifier") then
                                identifier_node = child
                                break
                            end
                        end

                        -- Extract the position of the 'identifier' node
                        local row, col, end_row, end_col = 0, 0, 0, 0
                        if identifier_node then
                            row, col, end_row, end_col = identifier_node:range()
                            row = row + 1 -- Convert to 1-indexed for Vim
                            col = col + 1 -- Convert to 1-indexed for Vim
                        -- end_col remains 0-indexed up to but not including this column
                        end

                        return {
                            path = current_file,
                            value = {
                                row = row,
                                col = col,
                                end_col = end_col,
                                node = entry.node
                            },
                            display = display_fn(entry),
                            ordinal = entry.name or string.format("Line %d", row)
                        }
                    end
                }
            ),
            sorter = sorters.get_generic_fuzzy_sorter(),
            previewer = previewers.new_buffer_previewer(
                {
                    define_preview = function(self, entry, status)
                        if not entry.value then
                            return
                        end

                        -- Get all lines from the original buffer
                        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
                        vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "rust") -- Adjust for your language

                        -- Create and clear the namespace for highlighting
                        local ns = vim.api.nvim_create_namespace("TelescopePreviewHighlight")
                        vim.api.nvim_buf_clear_namespace(self.state.bufnr, ns, 0, -1)

                        local var = entry.value

                        -- Highlight all identifiers in the preview
                        for child in var.node:iter_children() do
                            if child:type():match("identifier") then
                                local start_row, start_col, end_row, end_col = child:range()
                                vim.api.nvim_buf_add_highlight(
                                    self.state.bufnr,
                                    ns,
                                    "TelescopePreviewMatch",
                                    start_row,
                                    start_col,
                                    end_col
                                )
                            end
                        end

                        -- Move the cursor to the exact identifier position in the preview
                        if type(self.state.winid) == "number" then
                            vim.schedule(
                                function()
                                    pcall(vim.api.nvim_win_set_cursor, self.state.winid, {var.row, var.col - 1})
                                    pcall(
                                        vim.api.nvim_win_call,
                                        self.state.winid,
                                        function()
                                            vim.cmd("normal! zz")
                                        end
                                    )
                                end
                            )
                        end
                    end
                }
            ),
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(
                    function()
                        actions.close(prompt_bufnr)
                        local selection = action_state.get_selected_entry()
                        if selection and selection.value then
                            -- Move the cursor to the exact identifier position
                            vim.api.nvim_win_set_cursor(0, {selection.value.row, selection.value.col - 1})
                            -- Center the view
                            vim.cmd("normal! zz")
                        end
                    end
                )
                return true
            end
        }
    ):find()
end

-- Register Telescope commands
function M.register_commands()
    -- Command: LocalVars
    vim.api.nvim_create_user_command(
        "LocalVars",
        function()
            local bufnr = vim.api.nvim_get_current_buf()
            local function_node = get_enclosing_function_node(bufnr)
            if not function_node then
                return
            end

            local variables = collect_local_variables(function_node, bufnr)
            create_telescope_picker(
                bufnr,
                variables,
                "Local Variables",
                function(entry)
                    return entry.name or string.format("Variable (Line %d)", entry.row)
                end
            )
        end,
        {desc = "List local variables in the current function with Telescope"}
    )

    -- Command: SelfRefs
    vim.api.nvim_create_user_command(
        "SelfRefs",
        function()
            local bufnr = vim.api.nvim_get_current_buf()
            local function_node = get_enclosing_function_node(bufnr)
            if not function_node then
                return
            end

            local self_refs = collect_self_references(function_node, bufnr)
            create_telescope_picker(
                bufnr,
                self_refs,
                "Self References (Function)",
                function(entry)
                    return string.format("self (Line %d)", entry.row)
                end
            )
        end,
        {
            desc = "List references to 'self' in the current function with Telescope"
        }
    )

    -- Command: FileSelfRefs
    vim.api.nvim_create_user_command(
        "FileSelfRefs",
        function()
            local bufnr = vim.api.nvim_get_current_buf()
            local parser = get_parser(bufnr)
            if not parser then
                return
            end

            local root = parser:parse()[1]:root()
            local self_refs = collect_self_references(root, bufnr)
            create_telescope_picker(
                bufnr,
                self_refs,
                "Self References (File)",
                function(entry)
                    return string.format("self (Line %d)", entry.row)
                end
            )
        end,
        {
            desc = "List all references to 'self' in the current file with Telescope"
        }
    )
end

return M
