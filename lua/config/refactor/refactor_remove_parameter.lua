-- remove_parameter.lua
local RemoveParameter = {}

local api = vim.api
local utils_functions = require("config.refactor.utils.functions")
local ts_utils = require("nvim-treesitter.ts_utils")

function RemoveParameter.remove_argument()
    utils_functions.remove_parameter(ts_utils.get_node_at_cursor(), vim.api.nvim_get_current_buf())
end

function RemoveParameter.setup()
    api.nvim_create_user_command(
        "RemoveParameter",
        function()
            RemoveParameter.remove_argument()
        end,
        {
            nargs = 0
        }
    )
end

return RemoveParameter
