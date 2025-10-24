return {
    {
        "nvim-tree/nvim-tree.lua",
        lazy = false, -- Load immediately
        dependencies = {"nvim-tree/nvim-web-devicons"}, -- Optional icons
        config = function()
            require("nvim-tree").setup(
                {
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
                        vim.keymap.set(
                            "n",
                            "h",
                            function()
                                local node = api.tree.get_node_under_cursor()
                                if node.type == "directory" and node.open then
                                    api.node.navigate.parent_close()
                                else
                                    api.node.navigate.parent()
                                end
                            end,
                            opts("Close folder or go to parent folder")
                        )

                        -- Common function for opening a folder or file
                        local function open_node(node, bufnr)
                            if node.type == "directory" then
                                if not node.open then
                                    api.node.open.edit()
                                end
                            else
                                local file_path = vim.fn.fnameescape(node.absolute_path)

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
                        vim.keymap.set(
                            "n",
                            "l",
                            function()
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
                            end,
                            {desc = "Open directory or preview file"}
                        )
                        -- Keymap for showing file and directory info popup
                        -- Keymap for showing file and directory info popup
                        local preview_win = nil
                        local preview_buf = nil

                        -- Keymap for showing file and directory info popup
                        vim.keymap.set(
                            "n",
                            "i",
                            function()
                                if vim.bo.filetype == "NvimTree" then
                                    local node = api.tree.get_node_under_cursor()
                                    if node then
                                        -- Collect Git information for the file or directory
                                        local git_info = "Not a Git repository or no info available"
                                        if node.type == "file" then
                                            local handle =
                                                io.popen(
                                                "git log -1 --pretty=format:'%h %an %ar' -- " ..
                                                    vim.fn.shellescape(node.absolute_path)
                                            )
                                            if handle then
                                                git_info = handle:read("*a")
                                                handle:close()
                                            end
                                        end

                                        -- Get the current working directory in Nvim (root of where you are working)
                                        local cwd = vim.fn.getcwd()

                                        -- Get the relative path from the Nvim root directory (cwd)
                                        local relative_path = vim.fn.fnamemodify(node.absolute_path, ":." .. cwd)

                                        -- Collect file or directory information
                                        local info = {
                                            "Name: " .. node.name,
                                            "Path: " .. relative_path,
                                            "Type: " .. (node.type or "unknown"),
                                            "Size: " ..
                                                (node.type == "file" and vim.fn.getfsize(node.absolute_path) .. " bytes" or
                                                    "N/A"),
                                            "Git Info: " .. git_info
                                        }

                                        -- Configure popup dimensions and position
                                        local width = 50
                                        local height = #info
                                        local row = 1 -- Position relative to the cursor
                                        local col = 0

                                        -- Create a floating buffer
                                        local buf = vim.api.nvim_create_buf(false, true)
                                        vim.api.nvim_buf_set_lines(buf, 0, -1, false, info)

                                        -- Create a floating window to display the information
                                        local win =
                                            vim.api.nvim_open_win(
                                            buf,
                                            false,
                                            {
                                                relative = "cursor",
                                                width = width,
                                                height = height,
                                                row = row,
                                                col = col,
                                                style = "minimal",
                                                border = "rounded"
                                            }
                                        )

                                        -- Automatically close the popup when moving the cursor
                                        local group = vim.api.nvim_create_augroup("FileInfoPopup", {clear = true})
                                        vim.api.nvim_create_autocmd(
                                            "CursorMoved",
                                            {
                                                group = group,
                                                callback = function()
                                                    if vim.api.nvim_win_is_valid(win) then
                                                        vim.api.nvim_win_close(win, true)
                                                    end
                                                    if vim.api.nvim_buf_is_valid(buf) then
                                                        vim.api.nvim_buf_delete(
                                                            buf,
                                                            {
                                                                force = true
                                                            }
                                                        )
                                                    end
                                                    -- Clear the autocmd group
                                                    vim.api.nvim_del_augroup_by_id(group)
                                                end
                                            }
                                        )

                                        -- Close the popup when pressing ESC
                                        vim.api.nvim_create_autocmd(
                                            "BufWinLeave",
                                            {
                                                group = group,
                                                callback = function()
                                                    -- Close the window and buffer when leaving the popup
                                                    if vim.api.nvim_win_is_valid(win) then
                                                        vim.api.nvim_win_close(win, true)
                                                    end
                                                    if vim.api.nvim_buf_is_valid(buf) then
                                                        vim.api.nvim_buf_delete(
                                                            buf,
                                                            {
                                                                force = true
                                                            }
                                                        )
                                                    end
                                                    -- Clear the autocmd group
                                                    vim.api.nvim_del_augroup_by_id(group)
                                                end
                                            }
                                        )
                                    end
                                else
                                    vim.api.nvim_feedkeys("i", "n", true)
                                end
                            end,
                            {desc = "Show file or directory info in a popup"}
                        )

                        -- Map `Enter` to behave like `l`
                        vim.keymap.set(
                            "n",
                            "<CR>",
                            function()
                                local node = api.tree.get_node_under_cursor()
                                open_node(node, bufnr)
                            end,
                            opts("Open folder or file")
                        )
                    end,
                    update_focused_file = {
                        enable = true,
                        update_root = false,
                        ignore_list = {}
                    },
                    hijack_cursor = false,
                    git = {enable = true, ignore = false, timeout = 500},
                    filters = {
                        dotfiles = false,
                        custom = {
                            "^.cargo$",
                            "^.git$",
                            "^.github$",
                            "^.idea$",
                            "^target$",
                            "^.DS_Store$"
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
                        group_empty = true
                    },
                    actions = {
                        open_file = {
                            resize_window = false,
                            quit_on_open = false
                        }
                    },
                    hijack_directories = {
                        enable = true,
                        auto_open = false,
                    }
                }
            )

            -- Autocomando para limpiar buffers de nvim-tree huérfanos
            vim.api.nvim_create_autocmd("BufEnter", {
                group = vim.api.nvim_create_augroup("NvimTreeCleanup", { clear = true }),
                callback = function()
                    -- Limpiar buffers huérfanos de NvimTree
                    local buffers = vim.api.nvim_list_bufs()
                    for _, buf in ipairs(buffers) do
                        if vim.api.nvim_buf_is_valid(buf) then
                            local name = vim.api.nvim_buf_get_name(buf)
                            if name:match("NvimTree_") and not vim.api.nvim_buf_is_loaded(buf) then
                                vim.api.nvim_buf_delete(buf, { force = true })
                            end
                        end
                    end
                end,
            })

        end
    }
}
