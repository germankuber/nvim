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

                  -- Map `l` to expand the folder if closed, or open the file
                  vim.keymap.set("n", "l", function()
                      local node = api.tree.get_node_under_cursor()
                      if node.type == "directory" then
                          if not node.open then
                              api.node.open.edit()
                          end
                      else
                          -- Open the file in the current window
                          vim.cmd("edit " .. node.absolute_path)
                          -- Trigger necessary autocommands
                          vim.cmd("doautocmd BufReadPost")
                          vim.cmd("doautocmd FileType")
                      end
                  end, opts("Open folder or file"))

                  -- Map `Enter` to behave like `l`
                  vim.keymap.set("n", "<CR>", function()
                      local node = api.tree.get_node_under_cursor()
                      if node.type == "directory" then
                          if not node.open then
                              api.node.open.edit()
                          end
                      else
                          -- Open the file in the current window
                          vim.cmd("edit " .. node.absolute_path)
                          -- Trigger necessary autocommands
                          vim.cmd("doautocmd BufReadPost")
                          vim.cmd("doautocmd FileType")
                      end
                  end, opts("Open folder or file"))

                  -- Enable live preview in the main window
                  local preview_window = nil
                  vim.api.nvim_create_autocmd("CursorMoved", {
                      buffer = bufnr,
                      callback = function()
                          local node = api.tree.get_node_under_cursor()
                          if node and node.type == "file" then
                              -- Find a non-tree window for preview
                              local windows = vim.api.nvim_tabpage_list_wins(0)
                              local tree_win = vim.fn.bufwinid(bufnr)

                              for _, win in ipairs(windows) do
                                  if win ~= tree_win then
                                      preview_window = win
                                      break
                                  end
                              end

                              -- Ensure preview is shown in the selected window
                              if preview_window then
                                  local buf = vim.fn.bufadd(node.absolute_path)
                                  vim.fn.bufload(buf) -- Load the buffer into memory
                                  vim.api.nvim_win_set_buf(preview_window, buf)

                                  -- Trigger autocommands and ensure syntax highlighting
                                  vim.api.nvim_buf_set_option(buf, "syntax", "on")
                                  vim.cmd("filetype detect")
                                  vim.cmd("doautocmd BufReadPost")
                                  vim.cmd("doautocmd FileType")

                                  -- Focus back to NvimTree window
                                  vim.api.nvim_set_current_win(tree_win)
                              end
                          end
                      end,
                  })
              end,
              update_focused_file = {enable = true, update_cwd = true},
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
      end
  }
}
