require "config.general"

require "commands"
require "options"

require "config.sound"
require "plugins.run_with_alarm"
require "local_versioning"
require "telescope_versioning"

local builtin = require("telescope.builtin")

local function open_diagnostic_with_popup(prompt_bufnr, map)
  local action_set = require("telescope.actions.set")
  local actions = require("telescope.actions")

  -- Define the custom action
  local function open_and_show_diagnostic(selected_entry)
    actions.close(prompt_bufnr) -- Close Telescope
    -- Jump to the location of the diagnostic
    vim.api.nvim_set_current_win(selected_entry.bufnr)
    vim.api.nvim_win_set_cursor(0, {selected_entry.lnum, selected_entry.col - 1})
    -- Open the diagnostic popup
    vim.diagnostic.open_float(nil, {scope = "line"})
  end

  -- Apply the custom action
  action_set.select:replace(open_and_show_diagnostic)
  return true
end

-- Create custom diagnostics commands
vim.api.nvim_create_user_command(
  "ListWarnings",
  function()
    builtin.diagnostics(
      {
        severity = vim.diagnostic.severity.WARN,
        attach_mappings = open_diagnostic_with_popup
      }
    )
  end,
  {desc = "List global warnings using Telescope"}
)

vim.api.nvim_create_user_command(
  "ListErrors",
  function()
    builtin.diagnostics(
      {
        severity = vim.diagnostic.severity.ERROR,
        attach_mappings = open_diagnostic_with_popup
      }
    )
  end,
  {desc = "List global errors using Telescope"}
)

--