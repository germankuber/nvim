-- CreateFolderWithMod.lua

local api = require('nvim-tree.api')
local Path = require('plenary.path')

local M = {}

-- Function to create folder with mod.rs and update existing Rust files
function M.create_folder_with_mod()
  -- Prompt user for folder name
  vim.ui.input({ prompt = 'Folder Name: ' }, function(input)
    if not input or input == '' then
      return
    end

    local folder_name = input

    -- Get the current node under cursor
    local node = api.tree.get_node_under_cursor()
    if not node then
      print("No node under cursor.")
      return
    end

    local parent_path = node.absolute_path

    -- If the node is not a directory, get its parent directory
    if node.type ~= 'directory' then
      parent_path = Path:new(parent_path):parent():absolute()
    end

    -- Validate parent_path
    local parent_dir = Path:new(parent_path)
    if not parent_dir:exists() then
      print("Invalid parent path:", parent_path)
      return
    end

    -- Create the new folder path
    local new_folder_path = Path:new(parent_path, folder_name)
    if not new_folder_path:exists() then
      local ok, err = pcall(function()
        new_folder_path:mkdir({ parents = true })
      end)
      if not ok then
        print("Error creating folder:", err)
        return
      end
      print("Folder created:", new_folder_path:absolute())
    else
      print("Folder already exists:", new_folder_path:absolute())
    end

    -- Create mod.rs inside the new folder
    local mod_rs_path = new_folder_path:joinpath('mod.rs')
    if not mod_rs_path:exists() then
      mod_rs_path:touch()
      print("mod.rs created at:", mod_rs_path:absolute())
    else
      print("mod.rs already exists at:", mod_rs_path:absolute())
    end

    -- List of possible Rust files to update
    local rust_files = { 'main.rs', 'mod.rs', 'lib.rs' }

    for _, file in ipairs(rust_files) do
      local file_path = Path:new(parent_path, file)
      if file_path:exists() then
        -- Get buffer number if loaded
        local bufnr = vim.fn.bufnr(file_path:absolute())
        if bufnr ~= -1 then
          -- Check if the buffer's filetype is 'rust'
          local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
          if filetype ~= 'rust' then
            print("Skipping non-rust buffer:", file_path:absolute())
            goto continue
          end

          -- Load buffer if not already loaded
          vim.fn.bufload(bufnr)
          -- Read existing content from buffer
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
          local content = table.concat(lines, "\n")

          -- Prepare the line to add
          local new_line = string.format("pub mod %s;", folder_name)

          -- Check if the line already exists
          if not content:find(new_line, 1, true) then
            -- Prepend the new line
            table.insert(lines, 1, new_line)
            -- Set buffer lines
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
            -- Format the buffer using LSP asynchronously, then write after formatting
            vim.lsp.buf.format({
              bufnr = bufnr,
              async = true,
              on_complete = function()
                vim.api.nvim_buf_call(bufnr, function()
                  vim.cmd('write')
                end)
                print(string.format("Added '%s' to %s and formatted the file.", new_line, file))
              end
            })
          else
            print(string.format("'%s' already exists in %s", new_line, file))
          end
        else
          -- If buffer not loaded, write to file directly
          -- Read the existing content
          local content = file_path:read()

          -- Prepare the line to add
          local new_line = string.format("pub mod %s;\n", folder_name)

          -- Check if the line already exists
          if not content:find(new_line, 1, true) then
            -- Prepend the new line
            local updated_content = new_line .. content
            local ok, err = pcall(function()
              -- Write the updated content with write flag 'w'
              file_path:write(updated_content, 'w')
            end)
            if not ok then
              print("Error writing to file:", err)
            else
              print(string.format("Added '%s' to %s", new_line:sub(1, -2), file))
            end
          else
            print(string.format("'%s' already exists in %s", new_line:sub(1, -2), file))
          end
        end
      end
      ::continue::
    end

    -- Refresh nvim-tree to show new folder
    if api.tree.reload then
      api.tree.reload()
    else
      vim.cmd('NvimTreeRefresh')
    end
  end)
end

-- Setup command
vim.api.nvim_create_user_command('CreateFolderWithMod', M.create_folder_with_mod, {})

return M
