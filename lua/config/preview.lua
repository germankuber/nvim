local M = {}

local actions_preview = require("actions-preview")

function M.code_actions_with_custom_rename()
    actions_preview.code_actions({
        on_select = function(action)
            if action.title:lower():match("extract function") then
                vim.ui.input({
                    prompt = "Enter function name: ",
                    default = "my_function"
                }, function(new_name)
                    if not new_name or new_name == "" then
                        print("No function name provided. Cancelling action.")
                        return
                    end

                    -- Check if the action has a command with arguments
                    if action.command and action.command.arguments then
                        -- Modify the command arguments to include the new function name
                        for _, arg in ipairs(action.command.arguments) do
                            if arg and type(arg) == "table" then
                                if arg.newName then
                                    arg.newName = new_name
                                elseif arg.options and arg.options.newName then
                                    arg.options.newName = new_name
                                end
                            end
                        end
                    end

                    -- Apply the action with the modified command
                    actions_preview.apply_action(action, function()
                        -- Trigger rename on the newly created function
                        local current_word = vim.fn.expand("<cword>") -- Get the function name under cursor
                        if current_word == new_name then
                            vim.schedule(function()
                                vim.lsp.buf.rename() -- Prompt for renaming if the function was successfully created
                            end)
                        else
                            print("Failed to identify the newly created function for renaming.")
                        end
                    end)
                end)
            else
                -- Apply other actions as they are
                actions_preview.apply_action(action)
            end
        end
    })
end

-- Expose the functionality as a Neovim command
vim.api.nvim_create_user_command("CodeActionsWithCustomRename", M.code_actions_with_custom_rename, {
    desc = "Perform code actions with custom naming and renaming support"
})

return M
