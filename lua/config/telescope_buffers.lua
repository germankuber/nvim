-- ~/.config/nvim/lua/custom/functions.lua

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local finders = require("telescope.finders") -- Asegúrate de requerir este módulo

local M = {}

-- Función para abrir un buffer seleccionado con <Enter>
M.open_buffer = function()
    require("telescope.builtin").buffers({
        attach_mappings = function(_, map)
            -- Abrir buffer con Enter en modo inserción
            map("i", "<CR>", function(prompt_bufnr)
                local selection = action_state.get_selected_entry(prompt_bufnr)
                actions.close(prompt_bufnr) -- Cierra la ventana de Telescope
                if selection and selection.bufnr then
                    vim.api.nvim_set_current_buf(selection.bufnr) -- Enfoca el buffer seleccionado
                end
            end)
            -- Abrir buffer con Enter en modo normal
            map("n", "<CR>", function(prompt_bufnr)
                local selection = action_state.get_selected_entry(prompt_bufnr)
                actions.close(prompt_bufnr) -- Cierra la ventana de Telescope
                if selection and selection.bufnr then
                    vim.api.nvim_set_current_buf(selection.bufnr) -- Enfoca el buffer seleccionado
                end
            end)
            return true
        end,
    })
end

-- Función para cerrar un buffer seleccionado con <Enter> y mantener Telescope abierto
M.close_buffer = function()
    require("telescope.builtin").buffers({
        attach_mappings = function(prompt_bufnr, map)
            -- Función para cerrar el buffer y refrescar la lista
            local delete_buffer = function()
                local selection = action_state.get_selected_entry(prompt_bufnr)
                if selection and selection.bufnr then
                    vim.api.nvim_buf_delete(selection.bufnr, { force = true }) -- Cierra el buffer seleccionado
                end

                vim.schedule(function()
                    local picker = action_state.get_current_picker(prompt_bufnr)
                    if picker then
                        picker:refresh(finders.new_table({
                            results = vim.fn.getbufinfo({ buflisted = 1 }),
                            entry_maker = function(buf)
                                return {
                                    value = buf.bufnr,
                                    display = buf.name,
                                    ordinal = buf.name,
                                }
                            end,
                        }), { reset_prompt = true })
                    end
                end)
            end

            -- Cerrar buffer con Enter en modo inserción
            map("i", "<CR>", delete_buffer)
            -- Cerrar buffer con Enter en modo normal
            map("n", "<CR>", delete_buffer)

            return true
        end,
    })
end

return M
