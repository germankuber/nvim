-- ~/.config/nvim/lua/config/jump_config.lua
local M = {}

M.line_jump = 1 -- Valor inicial

-- Definir la ruta al archivo de configuración
local config_dir = vim.fn.stdpath("data") .. "/jump_config"
local config_file = config_dir .. "/jump_size.txt"

-- Asegurarse de que el directorio de configuración exista
if vim.fn.isdirectory(config_dir) == 0 then
    vim.fn.mkdir(config_dir, "p")
end

-- Función para cargar el tamaño de salto desde el archivo
local function load_jump_size()
    if vim.fn.filereadable(config_file) == 1 then
        local content = vim.fn.readfile(config_file)
        local value = tonumber(content[1])
        if value and value > 0 then
            M.line_jump = value
            return
        end
    end
    -- Valor por defecto si el archivo no existe o el contenido es inválido
    M.line_jump = 1
end

-- Función para guardar el tamaño de salto en el archivo
local function save_jump_size()
    vim.fn.writefile({ tostring(M.line_jump) }, config_file)
end

-- Cargar el tamaño de salto al iniciar el módulo
load_jump_size()

-- Función para solicitar y establecer el tamaño de salto usando vim.ui.input
function M.set_jump_input()
    vim.ui.input({ prompt = 'Set Jump Size: ' }, function(input)
        if input then
            -- Remover espacios en blanco al inicio y al final
            local trimmed_input = vim.trim(input)
            local new_jump = tonumber(trimmed_input)
            if new_jump and new_jump > 0 then
                M.line_jump = new_jump
                save_jump_size()  -- Guardar el nuevo valor
                vim.notify("Jump size set to: " .. M.line_jump, vim.log.levels.INFO)
            else
                vim.notify("Invalid jump size!", vim.log.levels.ERROR)
            end
        end
    end)
end

-- Función para realizar el salto hacia arriba o hacia abajo
function M.jump(direction)
    if direction == "j" or direction == "k" then
        local jump_command = tostring(M.line_jump) .. direction
        vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes(jump_command, true, false, true),
            "n", false
        )
    else
        vim.notify("Invalid direction for jump: " .. direction, vim.log.levels.ERROR)
    end
end

return M
