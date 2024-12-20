-- Panel Move Mode Plugin

local M = {}
local move_mode = false
local buffer_mappings = {}
local original_mappings = {}

-- Save the original mapping of a key
local function save_original_mapping(key)
    local maps = vim.api.nvim_get_keymap("n")
    for _, map in ipairs(maps) do
        if map.lhs == key then
            original_mappings[key] = map.rhs
            return
        end
    end
end

-- Restore the original mapping of a key
local function restore_original_mapping(key)
    if original_mappings[key] then
        vim.keymap.set("n", key, original_mappings[key], {buffer = true})
    else
        vim.keymap.del("n", key, {buffer = true})
    end
end

-- Enable move mode
local function enable_move_mode()
    move_mode = true
    print("Panel Move Mode: ON")

    -- Save original mappings
    save_original_mapping("h")
    save_original_mapping("j")
    save_original_mapping("k")
    save_original_mapping("l")
    save_original_mapping("q")

    -- Set new mappings for navigation
    buffer_mappings.h = vim.keymap.set("n", "h", "<C-w>h", {buffer = true, desc = "Move Left"})
    buffer_mappings.j = vim.keymap.set("n", "j", "<C-w>j", {buffer = true, desc = "Move Down"})
    buffer_mappings.k = vim.keymap.set("n", "k", "<C-w>k", {buffer = true, desc = "Move Up"})
    buffer_mappings.l = vim.keymap.set("n", "l", "<C-w>l", {buffer = true, desc = "Move Right"})
    buffer_mappings.q = vim.keymap.set("n", "q", M.toggle_move_mode, {buffer = true, desc = "Exit Move Mode"})
end

-- Disable move mode
local function disable_move_mode()
    move_mode = false
    print("Panel Move Mode: OFF")

    -- Restore original mappings
    restore_original_mapping("h")
    restore_original_mapping("j")
    restore_original_mapping("k")
    restore_original_mapping("l")
    restore_original_mapping("q")

    -- Remove move mode mappings
    for key, _ in pairs(buffer_mappings) do
        vim.keymap.del("n", key, {buffer = true})
    end
    buffer_mappings = {}
end

-- Toggle move mode
function M.toggle_move_mode()
    if move_mode then
        disable_move_mode()
    else
        enable_move_mode()
    end
end

-- Command to toggle move mode
vim.api.nvim_create_user_command("ToggleMoveMode", M.toggle_move_mode, {desc = "Toggle Panel Move Mode"})

return M
