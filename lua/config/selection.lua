-- File: lua/select_entity/init.lua

local M = {}

function M.select_entity()
    local status_ok, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
    if not status_ok then
        print("nvim-treesitter is not installed or failed to load.")
        return
    end

    local node = ts_utils.get_node_at_cursor()
    if not node then
        print("No node found under cursor.")
        return
    end

    local function collect_attributes(current_node)
        local attributes = {}
        local parent = current_node:parent()

        if not parent then
            return attributes
        end

        for sibling in parent:iter_children() do
            if sibling == current_node then
                break
            end
            if sibling:type() == "attribute" then
                table.insert(attributes, sibling)
            end
        end

        return attributes
    end

    while node do
        local node_type = node:type()

        local is_function = node_type == "function_definition" or
                            node_type == "method_declaration" or
                            node_type == "function" or
                            node_type == "method" or
                            node_type == "function_item"

        local is_struct = node_type == "struct_item"

        local is_impl = node_type == "impl_item"

        if is_function or is_struct or is_impl then
            local attributes = collect_attributes(node)
            local start_row, start_col, end_row, end_col

            if #attributes > 0 then
                local first_attr = attributes[1]
                start_row, start_col, _, _ = first_attr:range()
            else
                start_row, start_col, _, _ = node:range()
            end

            _, _, end_row, end_col = node:range()

            start_row = start_row + 1
            end_row = end_row + 1

            -- Enter visual line mode and set cursor to start
            vim.api.nvim_command("normal! V")
            vim.api.nvim_win_set_cursor(0, {start_row, start_col})
            -- Move cursor to end
            vim.api.nvim_win_set_cursor(0, {end_row, end_col})
            return
        end
        node = node:parent()
    end

    print("No function, struct, or impl found under cursor.")
end

function M.setup()
    vim.api.nvim_create_user_command(
        "SelectEntity",
        M.select_entity,
        {
            desc = "Select the entire function, struct, or impl under cursor, including attributes, using Treesitter"
        }
    )
end

return M
