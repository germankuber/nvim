-- remove_parameter.lua
local RemoveParameter = {}

local api = vim.api
local lsp = vim.lsp
local utils_functions = require("config.refactor.utils.functions")
local ts_utils = require("nvim-treesitter.ts_utils")
function get_name(node)
    local bufnr = vim.api.nvim_get_current_buf()
    return vim.treesitter.get_node_text(node, bufnr)
end

local function find_function_references(function_symbol)
    local bufnr = vim.api.nvim_get_current_buf() -- Get the current buffer number
    local parser = vim.treesitter.get_parser(bufnr) -- Get the parser for the current buffer
    if not parser then
        print("No parser available for the current file.")
        return {}
    end

    local tree = parser:parse()[1] -- Get the first syntax tree
    local root = tree:root() -- Get the root node of the syntax tree

    if not root then
        print("No root node found in the syntax tree.")
        return {}
    end

    local references = {} -- Table to store all references found

    -- Helper function to recursively search for references
    local function search_node(node)
        if not node then
            return
        end

        if node:type() == "identifier" and node:parent():type() == "call_expression" then
            local start_line, start_col, end_line, end_col = node:range()
            local func_start_line, func_start_col, func_end_line, func_end_col = function_symbol.param:range()
            if
                not (start_line == func_start_line and start_col == func_start_col and end_line == func_end_line and
                    end_col == func_end_col)
             then
                if not utils_functions.is_local_function_call(node, function_symbol.function_symbol) then
                    local symbol_name = vim.treesitter.get_node_text(node, bufnr)
                    if symbol_name == utils_functions.get_function_name(function_symbol.function_symbol) then
                        table.insert(
                            references,
                            {
                                node = node,
                                parent = node:parent(),
                                name = symbol_name,
                                range = {node:range()}
                            }
                        )
                    end
                end
            end
        end
        for child in node:iter_children() do
            search_node(child)
        end
    end
    search_node(root)

    return references
end
function RemoveParameter.remove_argument()
    utils_functions.remove_parameter(ts_utils.get_node_at_cursor(), vim.api.nvim_get_current_buf())
end

function RemoveParameter.setup()
    api.nvim_create_user_command(
        "RemoveParameter",
        function()
            RemoveParameter.remove_argument()
        end,
        {
            nargs = 0
        }
    )
end

-- Declare a command to get references from the cursor position excluding the current one
vim.api.nvim_create_user_command(
    "GetReferences2",
    function()
        local references = utils_functions.get_references_lsp(ts_utils.get_node_at_cursor())
        if vim.tbl_isempty(references) then
            print("No references found.")
            return
        end

        for _, ref in ipairs(references) do
            print(ref:type())
            local start_row, start_col, _, _ = ref:range()
            print(string.format("Reference at line %d, column %d", start_row + 1, start_col + 1))
        end
    end,
    {}
)

return RemoveParameter
