-- Resize Mode Plugin

local M = {}
local resize_mode = false
local buffer_mappings = {}


local mapping_helper = require("config.helpers.mapping")

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
        mapping_helper.restore_original_mapping("h")
        mapping_helper.restore_original_mapping("j")
        mapping_helper.restore_original_mapping("k")
        mapping_helper.restore_original_mapping("l")
        disable_resize_mode()
    else
        mapping_helper.save_original_mapping("h")
        mapping_helper.save_original_mapping("j")
        mapping_helper.save_original_mapping("k")
        mapping_helper.save_original_mapping("l")
        enable_resize_mode()
    end
end

vim.api.nvim_create_user_command("ToggleResizeMode", M.toggle_resize_mode, {desc = "Toggle Resize Mode"})

return M
