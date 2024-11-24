-- ~/.config/nvim/lua/config/jump_config.lua
local M = {}

M.line_jump = 1 -- Valor inicial

-- Función para solicitar el tamaño de salto usando vim.ui.input
function M.set_jump_input()
    vim.ui.input({prompt = 'Set Jump Size: '}, function(input)
        if input then
            -- Remover espacios en blanco al inicio y al final
            local trimmed_input = vim.trim(input)
            local new_jump = tonumber(trimmed_input)
            if new_jump and new_jump > 0 then
                M.line_jump = new_jump
                vim.notify("Jump size set to: " .. M.line_jump,
                           vim.log.levels.INFO)
            else
                vim.notify("Invalid jump size!", vim.log.levels.ERROR)
            end
        end
    end)
end
function M.jump(direction)
    if direction == "j" or direction == "k" then
        local jump_command = tostring(M.line_jump) .. direction
        vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes(jump_command, true, false, true),
            "n", false)
    else
        vim.notify("Invalid direction for jump: " .. direction,
                   vim.log.levels.ERROR)
    end
end

return M
