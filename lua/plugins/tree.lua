return {
    {
        "nvim-tree/nvim-tree.lua",
        lazy = false, -- Load immediately
        dependencies = {"nvim-tree/nvim-web-devicons"}, -- Optional icons
        config = function()
            require("nvim-tree").setup({
                on_attach = function(bufnr)
                    local api = require("nvim-tree.api")
                    local function opts(desc)
                        return {
                            desc = "nvim-tree: " .. desc,
                            buffer = bufnr,
                            noremap = true,
                            silent = true,
                            nowait = true
                        }
                    end

                    -- Map `h` to close the folder if open, or navigate to the parent folder
                    vim.keymap.set("n", "h", function()
                        local node = api.tree.get_node_under_cursor()
                        if node.type == "directory" and node.open then
                            api.node.navigate.parent_close()
                        else
                            api.node.navigate.parent()
                        end
                    end, opts("Close folder or go to parent folder"))

                    -- Common function for opening a folder or file
                    local function open_node(node, bufnr)
                        if node.type == "directory" then
                            if not node.open then
                                api.node.open.edit()
                            end
                        else
                            local file_path = vim.fn.fnameescape(
                                                  node.absolute_path)

                            -- Find a non-tree window to open the file
                            local windows = vim.api.nvim_tabpage_list_wins(0)
                            local tree_win = vim.fn.bufwinid(bufnr)

                            for _, win in ipairs(windows) do
                                if win ~= tree_win then
                                    vim.api.nvim_set_current_win(win)
                                    vim.cmd("edit " .. file_path)
                                    vim.cmd("NvimTreeClose")
                                    return
                                end
                            end

                            -- If no non-tree window exists, split the current window
                            vim.cmd("vsplit " .. file_path)

                        end
                    end

                    -- Keymap for opening a directory or previewing a file
                    vim.keymap.set("n", "l", function()
                        if vim.bo.filetype == "NvimTree" then
                            local node = api.tree.get_node_under_cursor()
                            if node then
                                if node.type == "directory" then
                                    -- Open or close the directory as usual
                                    if node.open then
                                        api.node.navigate.parent_close()
                                    else
                                        api.node.open.edit()
                                    end
                                else
                                    -- Preview the file using NvimTree's built-in preview functionality
                                    api.node.open.preview()
                                end
                            end
                        else
                            vim.api.nvim_feedkeys("l", "n", true)
                        end
                    end, {desc = "Open directory or preview file"})
                    -- Keymap for showing file and directory info popup
                    -- Keymap for showing file and directory info popup
                    local preview_win = nil
                    local preview_buf = nil

                    -- Keymap for showing file and directory info popup
                    vim.keymap.set("n", "i", function()
                        if vim.bo.filetype == "NvimTree" then
                            local node = api.tree.get_node_under_cursor()
                            if node then
                                -- Collect Git information for the file or directory
                                local git_info =
                                    "Not a Git repository or no info available"
                                if node.type == "file" then
                                    local handle = io.popen(
                                                       "git log -1 --pretty=format:'%h %an %ar' -- " ..
                                                           vim.fn
                                                               .shellescape(
                                                               node.absolute_path))
                                    if handle then
                                        git_info = handle:read("*a")
                                        handle:close()
                                    end
                                end

                                -- Get the current working directory in Nvim (root of where you are working)
                                local cwd = vim.fn.getcwd()

                                -- Get the relative path from the Nvim root directory (cwd)
                                local relative_path = vim.fn.fnamemodify(
                                                          node.absolute_path,
                                                          ":." .. cwd)

                                -- Collect file or directory information
                                local info = {
                                    "Name: " .. node.name,
                                    "Path: " .. relative_path,
                                    "Type: " .. (node.type or "unknown"),
                                    "Size: " ..
                                        (node.type == "file" and
                                            vim.fn.getfsize(node.absolute_path) ..
                                            " bytes" or "N/A"),
                                    "Git Info: " .. git_info
                                }

                                -- Configure popup dimensions and position
                                local width = 50
                                local height = #info
                                local row = 1 -- Position relative to the cursor
                                local col = 0

                                -- Create a floating buffer
                                local buf = vim.api.nvim_create_buf(false, true)
                                vim.api.nvim_buf_set_lines(buf, 0, -1, false,
                                                           info)

                                -- Create a floating window to display the information
                                local win =
                                    vim.api.nvim_open_win(buf, false, {
                                        relative = "cursor",
                                        width = width,
                                        height = height,
                                        row = row,
                                        col = col,
                                        style = "minimal",
                                        border = "rounded"
                                    })

                                -- Automatically close the popup when moving the cursor
                                local group =
                                    vim.api.nvim_create_augroup("FileInfoPopup",
                                                                {clear = true})
                                vim.api.nvim_create_autocmd("CursorMoved", {
                                    group = group,
                                    callback = function()
                                        if vim.api.nvim_win_is_valid(win) then
                                            vim.api.nvim_win_close(win, true)
                                        end
                                        if vim.api.nvim_buf_is_valid(buf) then
                                            vim.api.nvim_buf_delete(buf, {
                                                force = true
                                            })
                                        end
                                        -- Clear the autocmd group
                                        vim.api.nvim_del_augroup_by_id(group)
                                    end
                                })

                                -- Close the popup when pressing ESC
                                vim.api.nvim_create_autocmd("BufWinLeave", {
                                    group = group,
                                    callback = function()
                                        -- Close the window and buffer when leaving the popup
                                        if vim.api.nvim_win_is_valid(win) then
                                            vim.api.nvim_win_close(win, true)
                                        end
                                        if vim.api.nvim_buf_is_valid(buf) then
                                            vim.api.nvim_buf_delete(buf, {
                                                force = true
                                            })
                                        end
                                        -- Clear the autocmd group
                                        vim.api.nvim_del_augroup_by_id(group)
                                    end
                                })
                            end
                        else
                            vim.api.nvim_feedkeys("i", "n", true)
                        end
                    end, {desc = "Show file or directory info in a popup"})

                    -- Map `Enter` to behave like `l`
                    vim.keymap.set("n", "<CR>", function()
                        local node = api.tree.get_node_under_cursor()
                        open_node(node, bufnr)
                    end, opts("Open folder or file"))

                    -- Enable live preview in the main window
                    -- local preview_window = nil
                    -- vim.api.nvim_create_autocmd("CursorMoved", {
                    --     buffer = bufnr,
                    --     callback = function()
                    --         local node = api.tree.get_node_under_cursor()
                    --         if node and node.type == "file" then
                    --             -- Find a non-tree window for preview
                    --             local windows = vim.api
                    --                                 .nvim_tabpage_list_wins(0)
                    --             local tree_win = vim.fn.bufwinid(bufnr)

                    --             for _, win in ipairs(windows) do
                    --                 if win ~= tree_win then
                    --                     preview_window = win
                    --                     break
                    --                 end
                    --             end

                    --             -- Ensure preview is shown in the selected window
                    --             if preview_window then

                    --                 local buf = vim.fn
                    --                                 .bufadd(node.absolute_path)
                    --                 vim.fn.bufload(buf) -- Load the buffer into memory
                    --                 vim.api
                    --                     .nvim_win_set_buf(preview_window, buf)

                    --                 -- Ensure syntax highlighting and filetype detection
                    --                 vim.api.nvim_buf_call(buf, function()
                    --                     vim.cmd("doautocmd BufReadPre")
                    --                     vim.cmd("doautocmd BufReadPost")
                    --                     vim.cmd("filetype detect")
                    --                 end)

                    --                 -- Focus back to NvimTree window
                    --                 vim.api.nvim_set_current_win(tree_win)
                    --             end
                    --         end
                    --     end
                    -- })
                end,
                update_focused_file = {
                    enable = true,
                    update_root = false, -- Evita cambiar el directorio raíz del treeview
                    ignore_list = {} -- No ignores ningún archivo
                },
                hijack_cursor = false, -- Evita que el cursor se mueva al TreeView
                git = {enable = true, ignore = false, timeout = 500},
                filters = {
                    dotfiles = false,
                    custom = {
                        "^.cargo$", "^.git$", "^.github$", "^.idea$",
                        "^target$", "^.DS_Store$"
                    }
                },
                view = {
                    width = 40,
                    side = "left",
                    number = true,
                    relativenumber = true,
                    adaptive_size = false
                },

                renderer = {
                    group_empty = true -- Group empty folders
                },
                actions = {
                    open_file = {
                        resize_window = false, -- Adjust tree window size if needed
                        quit_on_open = false -- Keep NvimTree open after opening a file
                    }
                }
                --     })
                --     vim.api.nvim_create_autocmd("VimEnter", {
                --         callback = function()
                --             vim.defer_fn(function()
                --                 for _, win in ipairs(vim.api.nvim_list_wins()) do
                --                     if vim.api.nvim_win_is_valid(win) then
                --                         local buf = vim.api.nvim_win_get_buf(win)
                --                         local ft =
                --                             vim.api.nvim_buf_get_option(buf, "filetype")
                --                         if win and ft ~= "NvimTree" then
                --                             vim.api.nvim_set_current_win(win)
                --                             break
                --                         end
                --                     end
                --                 end
                --             end, 100)
                --         end
                --     })
                --     -- Autocommand to ensure focus switches from NvimTree to another buffer
                --     -- and force the tree width to stay consistent
                --     vim.api.nvim_create_autocmd("BufWinEnter", {
                --         callback = function()
                --             local tree_win = nil
                --             local normal_win = nil

                --             -- Iterate through all open windows
                --             for _, win in ipairs(vim.api.nvim_list_wins()) do
                --                 local buf = vim.api.nvim_win_get_buf(win)
                --                 local ft = vim.api.nvim_buf_get_option(buf, "filetype")

                --                 if ft == "NvimTree" then
                --                     -- Identify the NvimTree window
                --                     tree_win = win
                --                     break
                --                 else
                --                     -- Identify a normal (non-tree) window
                --                     normal_win = win
                --                 end
                --             end

                --             if tree_win then
                --                 vim.api.nvim_set_current_win(tree_win) -- 
                --                 vim.api.nvim_win_set_width(tree_win, 40) -- Set the width to your desired value
                --             else
                --                 vim.api.nvim_set_current_win(normal_win) -- 
                --             end
                --         end
            })

            -- vim.cmd([[autocmd VimEnter * NvimTreeOpen]])
        end
    }
}
