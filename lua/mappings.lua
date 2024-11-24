-- File: lua/custom/mappings.lua

local mapping_config = {
  codeFileType = {"rust", "python", "xml", "json", "toml"}
}

local function resolve_filetypes(filetype)
  if type(filetype) == "string" and filetype:match("^__(.+)__$") then
      local variable_name = filetype:match("^__(.+)__$")
      return mapping_config[variable_name] or { filetype }
  elseif type(filetype) == "table" then
      return filetype
  else
      return { filetype }
  end
end

-- Function to set key mappings
local function set_keymap(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Function to safely remove key mappings
local function remove_keymap(mode, lhs, bufnr)
  if vim.api.nvim_buf_is_valid(bufnr) then
      pcall(vim.keymap.del, mode, lhs, {buffer = bufnr})
  end
end

-- Function to handle user event mappings
local function handle_user_event_mapping(command, mode, lhs, rhs, opts, filetypes)
  vim.api.nvim_create_autocmd("User", {
      pattern = command.userEvent,
      callback = function()
          vim.schedule(function()
              for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                  local bufnr = vim.api.nvim_win_get_buf(win)
                  local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')
                  for _, target_ft in ipairs(filetypes) do
                      if ft == target_ft then
                          opts.buffer = bufnr
                          set_keymap(mode, lhs, rhs, opts)
                          vim.api.nvim_create_autocmd({
                              "BufLeave", "BufWinLeave", "WinClosed", "BufWipeout"
                          }, {
                              buffer = bufnr,
                              once = true,
                              callback = function()
                                  remove_keymap(mode, lhs, bufnr)
                              end
                          })
                          break
                      end
                  end
              end
          end)
      end
  })
end

-- Function to handle filetype mappings
local function handle_filetype_mapping(command, mode, lhs, rhs, opts, filetypes)
  for _, ft in ipairs(filetypes) do
      vim.api.nvim_create_autocmd("FileType", {
          pattern = ft,
          callback = function(args)
              local bufnr = args.buf
              opts.buffer = bufnr
              set_keymap(mode, lhs, rhs, opts)
          end,
      })
  end
end

-- Function to process individual commands
local function process_command(command, base_lhs, parent_filetype, parent_userEvent)
  local command_filetype = command.filetype or parent_filetype
  local command_userEvent = command.userEvent or parent_userEvent
  local mode = command.mode or "n"
  local lhs = base_lhs .. (command.lhs or "")
  local rhs = command.rhs or ""
  local opts = {
      desc = command.desc,
      noremap = command.noremap ~= false,
      silent = command.silent ~= false
  }

  if command_userEvent then
      local resolved_filetypes = resolve_filetypes(command_filetype or {})
      handle_user_event_mapping(command, mode, lhs, rhs, opts, resolved_filetypes)
  elseif command_filetype then
      local resolved_filetypes = resolve_filetypes(command_filetype)
      handle_filetype_mapping(command, mode, lhs, rhs, opts, resolved_filetypes)
  else
      set_keymap(mode, lhs, rhs, opts)
  end
end

-- Function to process a group of mappings
local function apply_mappings(group, parent_lhs, parent_filetype, parent_userEvent)
  if not group or not group.commands then return end

  local base_lhs = (parent_lhs or "") .. (group.base_lhs or "")
  local group_filetype = group.filetype or parent_filetype
  local group_userEvent = group.userEvent or parent_userEvent

  -- Set up the group mapping with description
  if group.title and group.title ~= "" and group.base_lhs and group.base_lhs ~= "" then
      local mode = group.mode or "n"
      local lhs = base_lhs
      local rhs = "<Nop>"
      local opts = {desc = group.title, noremap = true, silent = true}

      if group_userEvent then
          local resolved_filetypes = resolve_filetypes(group_filetype or {})
          handle_user_event_mapping(group, mode, lhs, rhs, opts, resolved_filetypes)
      elseif group_filetype then
          local resolved_filetypes = resolve_filetypes(group_filetype)
          handle_filetype_mapping(group, mode, lhs, rhs, opts, resolved_filetypes)
      else
          set_keymap(mode, lhs, rhs, opts)
      end
  end

  for _, command in ipairs(group.commands) do
      if command.commands then
          apply_mappings(command, base_lhs, group_filetype, group_userEvent)
      else
          process_command(command, base_lhs, group_filetype, group_userEvent)
      end
  end
end

-- Function to load the JSON file and apply mappings
local function load_and_apply_mappings(filepath)
  local mappings_file = vim.fn.stdpath("config") .. "/lua/" .. filepath
  local ok, content = pcall(vim.fn.readfile, mappings_file)
  if not ok then
      vim.notify("Error reading mappings file: " .. mappings_file, vim.log.levels.ERROR)
      return
  end

  local json_content = table.concat(content, "\n")
  local mappings = vim.fn.json_decode(json_content)
  if not mappings then
      vim.notify("Invalid JSON format in mappings file: " .. mappings_file, vim.log.levels.ERROR)
      return
  end

  for _, group in ipairs(mappings) do
      apply_mappings(group)
  end
end

-- Call the function with the correct path
load_and_apply_mappings("mappings/mappings.json")
