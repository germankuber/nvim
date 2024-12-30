local generic_mod_plugin = require("config.helpers.generic_mods")

local M = {}

function M.setup()
    generic_mod_plugin.setup(
        {
            command_name = "MultiCursorModToggle",
            mappings = {
                {
                    {mode = "n", key = "l", command = "<cmd>MultipleCursorsAddJumpNextMatch<CR>"},
                    {mode = "n", key = "j", command = "<cmd>MultipleCursorsAddDown<CR>"},
                    {mode = "n", key = "k", command = "<cmd>MultipleCursorsAddUp<CR>"}
                }
            }
        }
    )
end

M.setup()

return M
