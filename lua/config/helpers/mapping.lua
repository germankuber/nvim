-- mapping_manager.lua
local M = {}

local original_mappings = {}
local modes = {"n", "i", "v", "x", "s", "c", "o", "t", "l", "!"}

function M.save_original_mapping(key, mode)
    local maps = vim.api.nvim_get_keymap(mode)
    for _, map in ipairs(maps) do
        if map.lhs == key then
            original_mappings[mode] = original_mappings[mode] or {}
            original_mappings[mode][key] = map.rhs
            break
        end
    end
end

function M.restore_original_mapping(key, mode)
    if original_mappings[mode] and original_mappings[mode][key] then
        vim.keymap.set(mode, key, original_mappings[mode][key], { silent = true, noremap = true })
    else
        vim.keymap.del(mode, key)
    end
end

function M.clear_all_mappings()
    for _, mode in ipairs(modes) do
        local maps = vim.api.nvim_get_keymap(mode)
        for _, map in ipairs(maps) do
            -- Save the original mapping for restoration
            original_mappings[mode] = original_mappings[mode] or {}
            original_mappings[mode][map.lhs] = map.rhs

            -- Try to delete the mapping globally
            local success, err =
                pcall(function()
                    vim.keymap.del(mode, map.lhs) -- Global deletion
                end)

            if not success then
                print("Failed to delete global mapping: " .. map.lhs .. " - " .. err)
            end

            -- Try to delete the mapping for the current buffer
            local success_buffer, err_buffer =
                pcall(function()
                    vim.keymap.del(mode, map.lhs, { buffer = true }) -- Buffer-specific deletion
                end)

            if not success_buffer then
                -- Uncomment the line below to see buffer-specific deletion errors
                -- print("Failed to delete buffer mapping: " .. map.lhs .. " - " .. err_buffer)
            end
        end
    end
end

function M.restore_all_mappings()
    for mode, mappings in pairs(original_mappings) do
        for key, rhs in pairs(mappings) do
            vim.keymap.set(mode, key, rhs, { silent = true, noremap = true })
        end
    end
    M.clean()
end

function M.clean()
    original_mappings = {}
end

return M
