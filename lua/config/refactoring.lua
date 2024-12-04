-- refactor.lua

local Refactor = {}

-- Case Conversion Functions
local function to_upper_case(word)
  return string.upper(word)
end

local function to_camel_case(word)
  -- Convert snake_case to camelCase
  word = word:gsub("_(%l)", function(char) return string.upper(char) end)
  -- Ensure the first character is lowercase
  word = word:gsub("^%u", string.lower)
  return word
end

local function to_snake_case(word)
  -- Convert camelCase or PascalCase to snake_case
  word = word:gsub("(%l)(%u)", "%1_%2")
             :lower()
  return word
end

-- Function to Get Selected Text or Word Under Cursor
local function get_selected_text()
  local mode = vim.fn.mode()
  if mode:sub(1,1) == 'v' then
    -- Visual mode
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local lines = vim.fn.getline(start_pos[2], end_pos[2])
    if #lines == 0 then
      return ""
    elseif #lines == 1 then
      return string.sub(lines[1], start_pos[3], end_pos[3])
    else
      -- Multiple lines selected
      lines[1] = string.sub(lines[1], start_pos[3])
      lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
      return table.concat(lines, "\n")
    end
  else
    -- Not in visual mode, get word under cursor
    return vim.fn.expand("<cword>")
  end
end

-- General Function to Refactor Symbol Name
local function refactor_symbol(conversion_func)
  -- Get current name
  local current_name = get_selected_text()
  if not current_name or current_name == "" then
    print("No symbol found to refactor.")
    return
  end

  -- Convert the name
  local new_name = conversion_func(current_name)
  if new_name == current_name then
    print("The name is already in the desired format.")
    return
  end

  -- Optional: Show a confirmation message
  print(string.format("Renaming '%s' to '%s'...", current_name, new_name))

  -- Execute the rename with LSP
  -- Ensure the range is set if in visual mode
  local mode = vim.fn.mode()
  if mode:sub(1,1) == 'v' then
    -- Ensure the visual range is selected
    vim.cmd('normal! `<')
  end

  -- Execute the LSP rename function with the new name
  vim.lsp.buf.rename(new_name)
end

-- Command Handlers
local function refactor_to_upper()
  refactor_symbol(to_upper_case)
end

local function refactor_to_camel()
  refactor_symbol(to_camel_case)
end

local function refactor_to_snake()
  refactor_symbol(to_snake_case)
end

-- Setup Function to Create Commands
function Refactor.setup()
  vim.api.nvim_create_user_command('RefactorToUpper', refactor_to_upper, { nargs = 0, range = true, desc = "Refactor symbol to Upper Case" })
  vim.api.nvim_create_user_command('RefactorToCamel', refactor_to_camel, { nargs = 0, range = true, desc = "Refactor symbol to lower Camel Case" })
  vim.api.nvim_create_user_command('RefactorToSnake', refactor_to_snake, { nargs = 0, range = true, desc = "Refactor symbol to Snake Case" })
end

return Refactor
