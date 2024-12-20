local M = {}

M.fold_mode_active = false

M.fold_mappings = {
    {key = "h", command = "zc"},
    {key = "l", command = "zo"},
    {key = "j", command = "zj"},
    {key = "k", command = "zk"},
    {key = "H", command = "zM"},
    {key = "L", command = "zR"}
}

M.original_keymaps = {}

M.original_bg = nil

M.fold_mode_bg = "#363944"

local function get_current_normal_bg()
    local normal_hl = vim.api.nvim_get_hl(0, {name = "Normal"})
    return normal_hl.bg
end

local function set_normal_bg(color)
    if color then
        vim.api.nvim_set_hl(0, "Normal", {bg = color})
    else
        vim.api.nvim_set_hl(0, "Normal", {bg = "none"})
    end
end

function M.enable_fold_mode()
    if M.fold_mode_active then
        print("Fold Mode ya está habilitado.")
        return
    end

    if not M.original_bg then
        M.original_bg = get_current_normal_bg()
    end

    set_normal_bg(M.fold_mode_bg)

    for _, mapping in ipairs(M.fold_mappings) do
        local existing_maps = vim.api.nvim_get_keymap("n")
        for _, map in ipairs(existing_maps) do
            if map.lhs == mapping.key then
                M.original_keymaps[mapping.key] = map.rhs
                break
            end
        end

        vim.keymap.set("n", mapping.key, mapping.command, {silent = true, noremap = true})
    end

    M.fold_mode_active = true
    print("Fold Mode: ON")
end

function M.disable_fold_mode()
    if not M.fold_mode_active then
        print("Fold Mode ya está deshabilitado.")
        return
    end

    for _, mapping in ipairs(M.fold_mappings) do
        if M.original_keymaps[mapping.key] then
            vim.keymap.set("n", mapping.key, M.original_keymaps[mapping.key], {silent = true, noremap = true})
            M.original_keymaps[mapping.key] = nil
        else
            vim.keymap.del("n", mapping.key)
        end
    end

    set_normal_bg(M.original_bg)
    M.original_bg = nil

    M.fold_mode_active = false
    print("Fold Mode: OFF")
end

function M.toggle_fold_mode()
    if M.fold_mode_active then
        M.disable_fold_mode()
    else
        M.enable_fold_mode()
    end
end

function M.create_commands()
    vim.api.nvim_create_user_command(
        "FoldModeToggle",
        M.toggle_fold_mode,
        {
            desc = "Toggle Fold Mode On/Off"
        }
    )
end

function M.setup()
    M.create_commands()
end

M.setup()

return M
