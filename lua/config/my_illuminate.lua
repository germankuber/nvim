local M = {}

M.denylist = {"await", "var", "let", "const", "if", "else", "for", "while", "return", "unwrap", "expect"}

-- Variables to store references and current index
local ref_list = {}
local ref_index = 1

function M.apply_highlights()
    vim.api.nvim_set_hl(0, "LspReferenceText", { bg = "#2A2E36", underline = true })
    vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = "#2A2E36", underline = true })
    vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = "#2A2E36", underline = true })
end

function M.reset_highlights()
    vim.api.nvim_set_hl(0, "LspReferenceText", {})
    vim.api.nvim_set_hl(0, "LspReferenceRead", {})
    vim.api.nvim_set_hl(0, "LspReferenceWrite", {})
end

function M.on_cursor_hold()
    local symbol = vim.fn.expand("<cword>")
    local clients = vim.lsp.get_active_clients({buf = 0})
    if not vim.tbl_contains(M.denylist, symbol) and #clients > 0 then
        vim.lsp.buf.document_highlight()
    end
end

function M.on_cursor_moved()
    vim.lsp.buf.clear_references()
end

-- Retrieve references and store them
function M.get_references()
    local params = vim.lsp.util.make_position_params()
    vim.lsp.buf_request(0, 'textDocument/references', params, function(err, result, ctx, config)
        if err or not result or vim.tbl_isempty(result) then
            print("No references found")
            return
        end
        ref_list = result
        ref_index = 1
        M.jump_to_reference(ref_index)
    end)
end

function M.jump_to_reference(index)
    if not ref_list[index] then
        print("No reference at index: " .. index)
        return
    end
    vim.lsp.util.jump_to_location(ref_list[index])
end

function M.next_reference()
    if #ref_list == 0 then
        print("No references stored. Run :GetReferences first.")
        return
    end
    ref_index = (ref_index % #ref_list) + 1
    M.jump_to_reference(ref_index)
end

function M.prev_reference()
    if #ref_list == 0 then
        print("No references stored. Run :GetReferences first.")
        return
    end
    ref_index = (ref_index - 2) % #ref_list + 1
    M.jump_to_reference(ref_index)
end

function M.setup()
    M.apply_highlights()
    vim.api.nvim_create_autocmd("CursorHold", {callback = M.on_cursor_hold})
    vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {callback = M.on_cursor_moved})

    -- User commands to navigate references
    vim.api.nvim_create_user_command("GetReferences", function() M.get_references() end, {})
    vim.api.nvim_create_user_command("NextReference", function() M.next_reference() end, {})
    vim.api.nvim_create_user_command("PrevReference", function() M.prev_reference() end, {})
end

return M
