local M = {}

local function is_scope_node(node_type)
  local scope_types = {
    "function_declaration",
    "function_definition",
    "method_declaration",
    "if_statement",
    "else_clause",
    "while_statement",
    "for_statement",
    "switch_statement",
    "try_statement",
    "catch_clause",
    "block",
    "loop",
    "do_statement",
    "class_declaration",
    "module_declaration",
    "arrow_function",
  }
  for _, st in ipairs(scope_types) do
    if node_type == st then
      return true
    end
  end
  return false
end

local function go_to_parent_scope()
  local ts_utils = require("nvim-treesitter.ts_utils")
  local node = ts_utils.get_node_at_cursor()

  if not node then
    print("No Treesitter node found under cursor.")
    return
  end

  local parent = node:parent()
  while parent do
    if is_scope_node(parent:type()) then
      local start_row, start_col, _, _ = parent:range()
      vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
      return
    end
    parent = parent:parent()
  end

  print("No parent scope found.")
end

vim.api.nvim_create_user_command(
  "GoToParentScope",
  go_to_parent_scope,
  { desc = "Navigate to the beginning of the parent scope" }
)

return M
