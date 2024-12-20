-- ~/.config/nvim/lua/foldmodetoggle.lua

-- FoldModeToggle Plugin for Neovim
-- Toggles a custom folding mode with specific keybindings.

local M = {}

-- State to track if Fold Mode is active
M.fold_mode_active = false

-- Define the key mappings for Fold Mode
M.fold_mappings = {
  { key = "h", command = "zc" }, -- Close current fold
  { key = "l", command = "zo" }, -- Open current fold
  { key = "j", command = "zj" }, -- Jump to next fold
  { key = "k", command = "zk" }, -- Jump to previous fold
  { key = "H", command = "zM" }, -- Close all folds
  { key = "L", command = "zR" }, -- Open all folds
}

-- Table to store original keymaps for restoration
M.original_keymaps = {}

-- Function to enable Fold Mode
function M.enable_fold_mode()
  if M.fold_mode_active then
    print("Fold Mode is already enabled.")
    return
  end

  -- Iterate over fold_mappings to set keybindings
  for _, mapping in ipairs(M.fold_mappings) do
    -- Save existing keymap if it exists
    local existing_maps = vim.api.nvim_get_keymap("n")
    for _, map in ipairs(existing_maps) do
      if map.lhs == mapping.key then
        M.original_keymaps[mapping.key] = map.rhs
        break
      end
    end

    -- Set the new keymap
    vim.keymap.set("n", mapping.key, mapping.command, { silent = true, noremap = true })
  end

  M.fold_mode_active = true
  print("Fold Mode: ON")
end

-- Function to disable Fold Mode
function M.disable_fold_mode()
  if not M.fold_mode_active then
    print("Fold Mode is already disabled.")
    return
  end

  -- Restore original keymaps
  for _, mapping in ipairs(M.fold_mappings) do
    if M.original_keymaps[mapping.key] then
      vim.keymap.set("n", mapping.key, M.original_keymaps[mapping.key], { silent = true, noremap = true })
      M.original_keymaps[mapping.key] = nil
    else
      -- If there was no original mapping, remove the keymap
      vim.keymap.del("n", mapping.key)
    end
  end

  M.fold_mode_active = false
  print("Fold Mode: OFF")
end

-- Function to toggle Fold Mode
function M.toggle_fold_mode()
  if M.fold_mode_active then
    M.disable_fold_mode()
  else
    M.enable_fold_mode()
  end
end

-- Create Neovim user command
function M.create_commands()
  vim.api.nvim_create_user_command('FoldModeToggle', M.toggle_fold_mode, {
    desc = "Toggle Fold Mode On/Off",
  })
end

-- Setup function to initialize the plugin
function M.setup()
  M.create_commands()
end

-- Automatically set up the plugin when required
M.setup()

return M
