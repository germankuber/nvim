-- Load Telescope and its modules
local telescope = require("telescope")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local builtin = require("telescope.builtin")

-- Function to determine the project root
local function get_project_root()
    local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
    if git_root and git_root ~= "" then
        return git_root
    else
        return vim.fn.getcwd()
    end
end

-- Function to compare the current file with another selected file
local function CompareCurrentFileWith()
    builtin.find_files(
        {
            prompt_title = "Select a file to compare with the current file",
            cwd = get_project_root(),
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(
                    function()
                        local selection = action_state.get_selected_entry()
                        actions.close(prompt_bufnr)
                        if selection then
                            local file_to_compare = selection.path

                            -- Open the selected file in a vertical split
                            vim.cmd("vsplit " .. file_to_compare)

                            -- Activate diff mode in both windows
                            vim.cmd("windo diffthis")

                            -- Synchronize window sizes
                            vim.cmd("wincmd =")
                        end
                    end
                )
                return true
            end
        }
    )
end

-- Function to compare two selected files
local function CompareFileAWithFileB()
    -- First file selection
    builtin.find_files(
        {
            prompt_title = "Select the FIRST file to compare",
            cwd = get_project_root(),
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(
                    function()
                        local selection1 = action_state.get_selected_entry()
                        actions.close(prompt_bufnr)
                        if selection1 then
                            local file1 = selection1.path

                            -- Second file selection
                            builtin.find_files(
                                {
                                    prompt_title = "Select the SECOND file to compare",
                                    cwd = get_project_root(),
                                    attach_mappings = function(prompt_bufnr2, map2)
                                        actions.select_default:replace(
                                            function()
                                                local selection2 = action_state.get_selected_entry()
                                                actions.close(prompt_bufnr2)
                                                if selection2 then
                                                    local file2 = selection2.path

                                                    -- Close all other windows to ensure only two splits
                                                    vim.cmd("only")

                                                    -- Open the first file in a vertical split
                                                    vim.cmd("vsplit " .. vim.fn.fnameescape(file1))

                                                    -- Open the second file in another vertical split
                                                    vim.cmd("vsplit " .. vim.fn.fnameescape(file2))

                                                    -- Activate diff mode in both windows
                                                    vim.cmd("windo diffthis")

                                                    -- Synchronize window sizes
                                                    vim.cmd("wincmd =")
                                                end
                                            end
                                        )
                                        return true
                                    end
                                }
                            )
                        end
                    end
                )
                return true
            end
        }
    )
end
local function CloseDiff()
    vim.cmd("windo diffoff")
end

-- Create user commands
vim.api.nvim_create_user_command(
    "CompareCurrentFileWith",
    CompareCurrentFileWith,
    {desc = "Compare the current file with another selected file"}
)

vim.api.nvim_create_user_command("CompareFileAWithFileB", CompareFileAWithFileB, {desc = "Compare two selected files"})

vim.api.nvim_create_user_command("CompareFileClose", CloseDiff, {desc = "Close diff mode"})
