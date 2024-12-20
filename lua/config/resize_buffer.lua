-- Resize Mode Plugin

local M = {}
local resize_mode = false
local buffer_mappings = {}

local original_mappings = {}

local function save_original_mapping(key)
    local maps = vim.api.nvim_get_keymap("n")
    for _, map in ipairs(maps) do
        if map.lhs == key then
            original_mappings[key] = map.rhs
            return
        end
    end
end
local function restore_original_mapping(key)
    if original_mappings[key] then
        vim.keymap.set("n", key, original_mappings[key], {buffer = true})
    else
        vim.keymap.del("n", key, {buffer = true})
    end
end

local function enable_resize_mode()
    resize_mode = true
    print("Resize Mode: ON")

    buffer_mappings.h =
        vim.keymap.set("n", "h", require("smart-splits").resize_left, {buffer = true, desc = "Resize Left"})
    buffer_mappings.j =
        vim.keymap.set("n", "j", require("smart-splits").resize_down, {buffer = true, desc = "Resize Down"})
    buffer_mappings.k = vim.keymap.set("n", "k", require("smart-splits").resize_up, {buffer = true, desc = "Resize Up"})
    buffer_mappings.l =
        vim.keymap.set("n", "l", require("smart-splits").resize_right, {buffer = true, desc = "Resize Right"})
    buffer_mappings.q = vim.keymap.set("n", "q", M.toggle_resize_mode, {buffer = true, desc = "Exit Resize Mode"})
end

local function disable_resize_mode()
    resize_mode = false
    print("Resize Mode: OFF")

    for key, mapping in pairs(buffer_mappings) do
        vim.keymap.del("n", key, {buffer = true})
    end
    buffer_mappings = {}
end

function M.toggle_resize_mode()
    if resize_mode then
        restore_original_mapping("h")
        restore_original_mapping("j")
        restore_original_mapping("k")
        restore_original_mapping("l")
        disable_resize_mode()
    else
        save_original_mapping("h")
        save_original_mapping("j")
        save_original_mapping("k")
        save_original_mapping("l")
        enable_resize_mode()
    end
end

vim.api.nvim_create_user_command("ToggleResizeMode", M.toggle_resize_mode, {desc = "Toggle Resize Mode"})

return M
