-- ~/.config/nvim/lua/myplugins/autosave.lua

local M = {}
local autosave_enabled = true
local autosave_group = vim.api.nvim_create_augroup("AutoSaveGroup", { clear = true })

local function notify(msg)
  vim.notify(msg, vim.log.levels.INFO)
end

local function enable_autosave()
  autosave_enabled = true
  vim.api.nvim_clear_autocmds({ group = autosave_group })
  vim.api.nvim_create_autocmd("BufLeave", {
    group = autosave_group,
    pattern = "*",
    callback = function(args)
      if autosave_enabled and vim.bo[args.buf].modified then
        vim.cmd("write")
        notify("Buffer saved automatically")
      end
    end,
  })
  notify("AutoSave enabled")
end

local function disable_autosave()
  autosave_enabled = false
  vim.api.nvim_clear_autocmds({ group = autosave_group })
  notify("AutoSave disabled")
end

function M.toggle_autosave()
  if autosave_enabled then
    disable_autosave()
  else
    enable_autosave()
  end
end

function M.setup()
  enable_autosave()
  vim.api.nvim_create_user_command("ToggleAutoSave", function()
    M.toggle_autosave()
  end, {})
end

return M
