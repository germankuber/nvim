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
                                    return
                                end
                            end

                            -- If no non-tree window exists, split the current window
                            vim.cmd("vsplit " .. file_path)
                        end
                    end

                    -- Map `l` to open the folder or file
                    vim.keymap.set("n", "l", function()
                        local node = api.tree.get_node_under_cursor()
                        open_node(node, bufnr)
                    end, opts("Open folder or file"))

                    -- Map `Enter` to behave like `l`
                    vim.keymap.set("n", "<CR>", function()
                        local node = api.tree.get_node_under_cursor()
                        open_node(node, bufnr)
                    end, opts("Open folder or file"))

                    -- Enable live preview in the main window
                    local preview_window = nil
                    vim.api.nvim_create_autocmd("CursorMoved", {
                        buffer = bufnr,
                        callback = function()
                            local node = api.tree.get_node_under_cursor()
                            if node and node.type == "file" then
                                -- Find a non-tree window for preview
                                local windows = vim.api
                                                    .nvim_tabpage_list_wins(0)
                                local tree_win = vim.fn.bufwinid(bufnr)

                                for _, win in ipairs(windows) do
                                    if win ~= tree_win then
                                        preview_window = win
                                        break
                                    end
                                end

                                -- Ensure preview is shown in the selected window
                                if preview_window then

                                    local buf = vim.fn
                                                    .bufadd(node.absolute_path)
                                    vim.fn.bufload(buf) -- Load the buffer into memory
                                    vim.api
                                        .nvim_win_set_buf(preview_window, buf)

                                    -- Ensure syntax highlighting and filetype detection
                                    vim.api.nvim_buf_call(buf, function()
                                        vim.cmd("doautocmd BufReadPre")
                                        vim.cmd("doautocmd BufReadPost")
                                        vim.cmd("filetype detect")
                                    end)

                                    -- Focus back to NvimTree window
                                    vim.api.nvim_set_current_win(tree_win)
                                end
                            end
                        end
                    })
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
                        "^.cargo$", "^.git$", -- Filter out .git directory
                        "^.github$", -- Filter out .github directory
                        "^.idea$", -- Filter out .idea directory
                        "^target$", -- Filter out target directory
                        "^.DS_Store$" -- Filter out .DS_Store file
                    }
                },
                view = {
                    width = 40,
                    side = "left",
                    number = true,
                    relativenumber = true
                },
                renderer = {
                    group_empty = true -- Group empty folders
                },
                actions = {
                    open_file = {
                        resize_window = true, -- Adjust tree window size if needed
                        quit_on_open = false -- Keep NvimTree open after opening a file
                    }
                }
            })
            vim.api.nvim_create_autocmd("VimEnter", {
                callback = function()
                    -- Retrasar la ejecución hasta que NvimTree haya terminado de inicializar
                    vim.defer_fn(function()
                        for _, win in ipairs(vim.api.nvim_list_wins()) do
                            local buf = vim.api.nvim_win_get_buf(win)
                            local ft = vim.api.nvim_buf_get_option(buf, "filetype")
                            if ft ~= "NvimTree" then
                                vim.api.nvim_set_current_win(win) -- Mover el foco al buffer
                                break
                            end
                        end
                    end, 100) -- Retraso suficiente para garantizar que NvimTree cargó
                end,
            })
            -- Autocomando para mover el foco al buffer abierto
            vim.api.nvim_create_autocmd("BufWinEnter", {
                callback = function()
                    local tree_win = nil
                    local normal_win = nil
            
                    -- Encuentra el buffer del TreeView y otro buffer abierto
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        local buf = vim.api.nvim_win_get_buf(win)
                        local ft = vim.api.nvim_buf_get_option(buf, "filetype")
                        if ft == "NvimTree" then
                            tree_win = win
                        else
                            normal_win = win
                        end
                    end
            
                    -- Si existe un buffer abierto y el TreeView está activo, mueve el foco
                    if tree_win and normal_win then
                        vim.api.nvim_set_current_win(normal_win) -- Cambia el foco al buffer no-tree
                    end
                end,
            })
        end
    }
}
