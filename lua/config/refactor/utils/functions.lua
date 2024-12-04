local ts_utils = require("nvim-treesitter.ts_utils")
local UtilsFunctions = {}

function UtilsFunctions.get_comma_to_remove(param, parameter_position)
    if parameter_position > 1 then
        comma = param:prev_sibling()
        if comma:type() == "," then
            return comma
        end
    else
        comma = param:next_sibling()
        if comma:type() == "," then
            return comma
        end
    end
    return nil
end
function UtilsFunctions.remove_parameter(current_symbol_node, bufnr)
    symbols_to_remove = UtilsFunctions.get_symbols_to_remove(current_symbol_node, bufnr)

    UtilsFunctions.delete_nodes(symbols_to_remove, bufnr)
end
function UtilsFunctions.get_symbols_to_remove(current_symbol_node, bufnr)
    if current_symbol_node:parent():type() ~= "parameter" then
        print("This command only works with a parameter.")
    end
    local function_symbol = current_symbol_node:parent():parent():parent()
    local parameter_symbol = current_symbol_node:parent()
    local parameter_position = UtilsFunctions.get_param_position(parameter_symbol, function_symbol)

    local params_to_remove = {}
    local declarations = {}
    UtilsFunctions.insertUniqueNode(params_to_remove, parameter_symbol)
    local comma = UtilsFunctions.get_comma_to_remove(parameter_symbol, parameter_position)
    if comma then
        UtilsFunctions.insertUniqueNode(params_to_remove, comma)
    end
    for _, function_symbol_to_remove in ipairs(UtilsFunctions.get_references_lsp(function_symbol, bufnr)) do
        local param = UtilsFunctions.get_param_from_function(function_symbol_to_remove:parent(), parameter_position)

        for _, declaration in ipairs(UtilsFunctions.get_declaration_lsp(param, bufnr)) do
            UtilsFunctions.insertUniqueNode(declarations, declaration:parent())
        end
        local comma = UtilsFunctions.get_comma_to_remove(param, parameter_position)
        if comma then
            UtilsFunctions.insertUniqueNode(params_to_remove, comma, bufnr)
        end

        UtilsFunctions.insertUniqueNode(params_to_remove, param, bufnr)
    end

    for _, node in pairs(UtilsFunctions.clean_unused_symbols(declarations, params_to_remove, bufnr)) do
        local position = UtilsFunctions.get_param_position_from_param(node)
        if position ~= nil then
            local comma = UtilsFunctions.get_comma_to_remove(node:parent(), position)
            if comma then
                UtilsFunctions.insertUniqueNode(params_to_remove, comma)
            end
        end
        if node:type() == "parameter" then
            for _, child_to_remove in pairs(
                UtilsFunctions.get_symbols_to_remove(UtilsFunctions.get_identifier_from_parameter(node), bufnr)
            ) do
                UtilsFunctions.insertUniqueNode(params_to_remove, child_to_remove)
            end
        end

        UtilsFunctions.insertUniqueNode(params_to_remove, node, bufnr)
    end

    return params_to_remove
end
function UtilsFunctions.get_identifier_from_parameter(parameter_node)
    for child in parameter_node:iter_children() do
        if child:type() == "identifier" or child:type() == "name" then
            return child
        end
    end
    return nil
end

function UtilsFunctions.get_param_position_from_param(param_node)
    if param_node:type() ~= "parameter" then
        return UtilsFunctions.get_param_position(param_node, param_node:parent():parent():parent())
    end

    return nil -- Parameter not found
end
function UtilsFunctions.get_param_position(param_node, function_node)
    local param_node_start_line, param_node_start_col, param_node_end_line, param_node_end_col = param_node:range()
    param_position = 1
    for _, ref_node in pairs(UtilsFunctions.get_function_params(function_node)) do
        if UtilsFunctions.are_same_symbol(ref_node.param, param_node) then
            return param_position
        end
        param_position = param_position + 1
    end

    return nil -- Parameter not found
end

function UtilsFunctions.clean_unused_symbols(declarations, to_check, bufnr)
    local to_return = {}
    for _, declaration in ipairs(declarations) do
        references =
            UtilsFunctions.get_nodes_in_first_list_are_not_in_second(
            UtilsFunctions.get_references_lsp(declaration),
            to_check
        )

        if #references <= 1 then
            UtilsFunctions.insertUniqueNode(to_return, declaration, bufnr)
        end
    end

    return to_return
end

function UtilsFunctions.print_node_info(node_symbol)
    local start_line1, start_col1, end_line1, end_col1 = node_symbol:range()

    name = UtilsFunctions.get_symbol_name(node_symbol)
    print(
        "Name: ",
        name,
        "(",
        node_symbol:type(),
        ")",
        "Start Line: ",
        start_line1,
        "Start Col: ",
        start_col1,
        "End Line: ",
        end_line1,
        "End Col: ",
        end_col1
    )
end

function UtilsFunctions.are_same_symbol(symbol_node1, symbol_node2)
    local start_line1, start_col1, end_line1, end_col1 = symbol_node1:range()
    local start_line2, start_col2, end_line2, end_col2 = symbol_node2:range()

    return start_line1 == start_line2 and start_col1 == start_col2
end

function UtilsFunctions.get_references_lsp(node_symbol, bufnr)
    local function get_node_at_range(bufnr_inner, range)
        local parser = vim.treesitter.get_parser(bufnr_inner)
        if not parser then
            return nil
        end
        local tree = parser:parse()[1]
        if not tree then
            return nil
        end
        local root = tree:root()

        local start_row = range.start.line
        local start_col = range.start.character

        return root:named_descendant_for_range(start_row, start_col, start_row, start_col)
    end

    if not node_symbol then
        print("No symbol found at cursor.")
        return {}
    end

    -- Get the position of the identifier within the node_symbol
    local function get_identifier_range(node)
        if node:type() == "function_item" or node:type() == "function_declaration" then
            for child in node:iter_children() do
                if child:type() == "name" or child:type() == "identifier" then
                    return child:range()
                end
            end
        else
            for child in node:iter_children() do
                if child:type() == "identifier" then
                    return child:range()
                end
            end
        end
        return node:range()
    end

    local start_row, start_col, _, _ = get_identifier_range(node_symbol)

    local params = {
        textDocument = vim.lsp.util.make_text_document_params(),
        position = {line = start_row, character = start_col},
        context = {includeDeclaration = true}
    }

    local timeout_ms = 1000
    local response = vim.lsp.buf_request_sync(bufnr, "textDocument/references", params, timeout_ms)

    local references = {}

    if response and response[1] and response[1].result then
        for _, ref in ipairs(response[1].result) do
            local uri = ref.uri or ref.targetUri
            local range = ref.range or ref.targetSelectionRange
            local ref_bufnr = vim.uri_to_bufnr(uri)
            local node = get_node_at_range(ref_bufnr, range)
            if node then
                -- Exclude the current node by comparing buffer number and range
                if not (ref_bufnr == bufnr and range.start.line == start_row and range.start.character == start_col) then
                    table.insert(references, node)
                end
            end
        end
    end

    return references
end

function UtilsFunctions.get_nodes_in_first_list_are_not_in_second(list1, list2)
    to_return = {}
    for _, node_1 in pairs(list1) do
        exist_in_list = false
        for _, node_2 in pairs(list2) do
            if UtilsFunctions.are_same_symbol(node_1, node_2) then
                exist_in_list = true
            end
        end
        if not exist_in_list then
            UtilsFunctions.insertUniqueNode(to_return, node_1)
        end
    end

    return to_return
end

function UtilsFunctions.get_declaration_lsp(node_symbol, bufnr)
    local function get_node_at_range(bufnr_inner, range)
        local parser = vim.treesitter.get_parser(bufnr_inner)
        if not parser then
            return nil
        end
        local tree = parser:parse()[1]
        if not tree then
            return nil
        end
        local root = tree:root()

        local start_row = range.start.line
        local start_col = range.start.character

        return root:named_descendant_for_range(start_row, start_col, start_row, start_col)
    end

    if not node_symbol then
        print("No symbol provided.")
        return {}
    end

    -- Get the position of the identifier within the node_symbol
    local function get_identifier_range(node)
        if node:type() == "function_item" or node:type() == "function_declaration" then
            for child in node:iter_children() do
                if child:type() == "name" or child:type() == "identifier" then
                    return child:range()
                end
            end
        else
            for child in node:iter_children() do
                if child:type() == "identifier" then
                    return child:range()
                end
            end
        end
        return node:range()
    end

    local start_row, start_col, _, _ = get_identifier_range(node_symbol)

    local params = {
        textDocument = vim.lsp.util.make_text_document_params(),
        position = {line = start_row, character = start_col}
    }

    local timeout_ms = 1000
    local response = vim.lsp.buf_request_sync(bufnr, "textDocument/declaration", params, timeout_ms)

    local declarations = {}

    if response and response[1] then
        local result = response[1].result
        if result then
            if not vim.tbl_islist(result) then
                result = {result}
            end
            for _, decl in ipairs(result) do
                local uri = decl.uri or decl.targetUri
                local range = decl.range or decl.targetSelectionRange
                local decl_bufnr = vim.uri_to_bufnr(uri)
                local node = get_node_at_range(decl_bufnr, range)
                if node then
                    table.insert(declarations, node)
                end
            end
        end
    end

    return declarations
end
function UtilsFunctions.get_key(node)
    local start_row, start_col, end_row, end_col = node:range()
    string.format("%d:%d-%d:%d", start_row, start_col, end_row, end_col)
end

function UtilsFunctions.insertUniqueNode(symbols_table, node, bufnr)
    found = false
    for _, node_to_check in pairs(symbols_table) do
        if UtilsFunctions.are_same_symbol(node_to_check, node) then
            found = true
        end
    end
    if not found then
        table.insert(symbols_table, node)
    end
end

function UtilsFunctions.get_symbol_name(symbol)
    local symbol_name = vim.treesitter.get_node_text(symbol, vim.api.nvim_get_current_buf())
    return symbol_name
end

function UtilsFunctions.get_function_params(function_symbol)
    local parents = {}

    if function_symbol:type() == "function_item" then
        for item in function_symbol:iter_children() do
            if item:type() == "parameters" then
                for param in item:iter_children() do
                    if param:type() == "parameter" then
                        table.insert(
                            parents,
                            {
                                param = param,
                                param_text = vim.treesitter.get_node_text(param, vim.api.nvim_get_current_buf()),
                                function_symbol = function_symbol
                            }
                        )
                    end
                end
            end
        end
    end
    return parents
end

function UtilsFunctions.get_function_name(node)
    for child in node:iter_children() do
        if child:type() == "identifier" then
            local bufnr = vim.api.nvim_get_current_buf()
            return vim.treesitter.get_node_text(child, bufnr)
        end
    end
    return nil
end
function UtilsFunctions.get_param_from_function(function_node, position)
    for child in function_node:iter_children() do
        if child:type() == "arguments" then
            -- Access the named child at the given position (zero-based indexing)
            local arg_node = child:named_child(position - 1)
            return arg_node
        end
    end
    return nil
end

function UtilsFunctions.delete_nodes(nodes, bufnr)
    if not nodes or next(nodes) == nil then
        print("No nodes to delete.")
        return
    end

    bufnr = bufnr or vim.api.nvim_get_current_buf()

    -- Collect nodes into an array for sorting
    local node_list = {}
    for _, node in pairs(nodes) do
        if node then
            table.insert(node_list, node)
        end
    end

    -- Sort nodes in reverse order to prevent shifting positions
    table.sort(
        node_list,
        function(a, b)
            local a_start_row, a_start_col = a:range()
            local b_start_row, b_start_col = b:range()
            if a_start_row == b_start_row then
                return a_start_col > b_start_col
            else
                return a_start_row > b_start_row
            end
        end
    )

    -- Delete each node
    for _, node in ipairs(node_list) do
        if node then
            local start_row, start_col, end_row, end_col = node:range()
            vim.api.nvim_buf_set_text(bufnr, start_row, start_col, end_row, end_col, {})
        end
    end
end

return UtilsFunctions
