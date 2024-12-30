local mapping_manager = require("config.helpers.mapping")

local M = {}

M.active = false
M.mod_mappings = {}
M.original_key_maps = {}
M.exit_key = "Q" 

M.original_bg = nil

M.fold_mode_bg = "#363944"


local function set_normal_bg(color)
    if color then
        vim.api.nvim_set_hl(0, "Normal", {bg = color})
    else
        vim.api.nvim_set_hl(0, "Normal", {bg = "none"})
    end
end

function M.enable()

    if M.active then
        print("Mod is already enabled.")
        return
    end
    mapping_manager.clear_all_mappings()
    for _, mapping in ipairs(M.mod_mappings) do
        for _, map in ipairs(mapping) do
            vim.keymap.set(map.mode, map.key, map.command, {silent = true, noremap = true})
        end
    end
    vim.keymap.set("n", M.exit_key, M.toggle, {silent = true, noremap = true})
    M.active = true
    print("Mod enabled.")
    set_normal_bg(M.fold_mode_bg)
end

function M.disable()
    if not M.active then
        print("Mod is not enabled.")
        return
    end

    mapping_manager.restore_all_mappings()
    M.active = false
    print("Mod disabled.")
    set_normal_bg(M.original_bg)
end

function M.toggle()
    if M.active then
        M.disable()
    else
        M.enable()
    end
end

function M.create_command(config)
    vim.api.nvim_create_user_command(config.command_name, M.toggle, {desc = "Toggle " .. M.command_name .. " mode"})
end

function M.setup_plugin(config)
    M.create_command(config)
end

function M.setup(config)
    M.mod_mappings = config.mappings
    M.command_name = config.command_name
    M.setup_plugin(config)
end

return M
