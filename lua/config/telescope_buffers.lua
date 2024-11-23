-- ~/.config/nvim/lua/custom/functions.lua

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local finders = require("telescope.finders") -- Asegúrate de requerir este módulo

local M = {}

M.open_buffer = function()
    require("telescope.builtin").buffers({
        attach_mappings = function(_, map)
            local open_selected_buffer = function(prompt_bufnr)
                local selection = action_state.get_selected_entry(prompt_bufnr)
                actions.close(prompt_bufnr)

                if selection and selection.bufnr then
                    local buftype = vim.api.nvim_buf_get_option(selection.bufnr, "buftype")
                    if buftype == "" or buftype == "acwrite" then
                        -- Retraso para asegurar que el foco se mueve al buffer
                        vim.defer_fn(function()
                            vim.api.nvim_set_current_buf(selection.bufnr)
                        end, 10)
                    end
                end
            end

            map("i", "<CR>", open_selected_buffer)
            map("n", "<CR>", open_selected_buffer)
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
