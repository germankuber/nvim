local M = {}

M.navigate_mode_active = false

-- Key mappings for reference navigation
M.navigate_mappings = {
    { key = "l", command = '<cmd>lua require("illuminate").goto_next_reference(true)<CR>' },
    { key = "h", command = '<cmd>lua require("illuminate").goto_prev_reference(true)<CR>' },
}

M.original_keymaps = {}
M.original_bg = nil
M.navigate_mode_bg = "#363944"

-- Helpers to get/set the Normal highlight background color
local function get_current_normal_bg()
    local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
    return normal_hl.bg
end

local function set_normal_bg(color)
    if color then
        vim.api.nvim_set_hl(0, "Normal", { bg = color })
    else
        vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    end
end

function M.enable_reference_mode()
    if M.navigate_mode_active then
        print("Reference Mode is already enabled.")
        return
    end

    -- Save the original background
    if not M.original_bg then
        M.original_bg = get_current_normal_bg()
    end

    -- Change the background to indicate the mode is active
    set_normal_bg(M.navigate_mode_bg)

    -- Save existing mappings and set our own
    for _, mapping in ipairs(M.navigate_mappings) do
        local existing_maps = vim.api.nvim_get_keymap("n")
        for _, map in ipairs(existing_maps) do
            if map.lhs == mapping.key then
                M.original_keymaps[mapping.key] = map.rhs
                break
            end
        end

        vim.keymap.set("n", mapping.key, mapping.command, { silent = true, noremap = true })
    end

    M.navigate_mode_active = true
    print("Reference Mode: ON")
end

function M.disable_reference_mode()
    if not M.navigate_mode_active then
        print("Reference Mode is already disabled.")
        return
    end

    -- Restore original mappings or remove them if none existed
    for _, mapping in ipairs(M.navigate_mappings) do
        if M.original_keymaps[mapping.key] then
            vim.keymap.set("n", mapping.key, M.original_keymaps[mapping.key], { silent = true, noremap = true })
            M.original_keymaps[mapping.key] = nil
        else
            vim.keymap.del("n", mapping.key)
        end
    end

    -- Restore the original background
    set_normal_bg(M.original_bg)
    M.original_bg = nil

    M.navigate_mode_active = false
    print("Reference Mode: OFF")
end

function M.toggle_reference_mode()
    if M.navigate_mode_active then
        M.disable_reference_mode()
    else
        M.enable_reference_mode()
    end
end

-- Create a user command to toggle Reference Mode
function M.create_commands()
    vim.api.nvim_create_user_command("ReferenceModeToggle", M.toggle_reference_mode, {
        desc = "Toggle Reference Mode On/Off",
    })
end

function M.setup()
    M.create_commands()
end

M.setup()

return M
