local M = {}

-- Generic function to navigate to the next diagnostic globally
local function goto_next_global_diagnostic(severity)
  local diagnostics = vim.diagnostic.get(nil, {severity = severity})
  if #diagnostics == 0 then
    print("No diagnostics found")
    return
  end

  local current_buf = vim.api.nvim_get_current_buf()
  local current_pos = vim.api.nvim_win_get_cursor(0)
  local current_line = current_pos[1] - 1
  local current_col = current_pos[2]

  table.sort(
    diagnostics,
    function(a, b)
      if a.bufnr ~= b.bufnr then
        return a.bufnr < b.bufnr
      elseif a.lnum ~= b.lnum then
        return a.lnum < b.lnum
      else
        return a.col < b.col
      end
    end
  )

  for _, diagnostic in ipairs(diagnostics) do
    if
      diagnostic.bufnr > current_buf or (diagnostic.bufnr == current_buf and diagnostic.lnum > current_line) or
        (diagnostic.bufnr == current_buf and diagnostic.lnum == current_line and diagnostic.col > current_col)
     then
      vim.api.nvim_set_current_buf(diagnostic.bufnr)
      vim.api.nvim_win_set_cursor(0, {diagnostic.lnum + 1, diagnostic.col})
      return diagnostic
    end
  end

  local first = diagnostics[1]
  vim.api.nvim_set_current_buf(first.bufnr)
  vim.api.nvim_win_set_cursor(0, {first.lnum + 1, first.col})
  return first
end

-- Generic function to navigate to the previous diagnostic globally
local function goto_prev_global_diagnostic(severity)
  local diagnostics = vim.diagnostic.get(nil, {severity = severity})
  if #diagnostics == 0 then
    print("No diagnostics found")
    return
  end

  local current_buf = vim.api.nvim_get_current_buf()
  local current_pos = vim.api.nvim_win_get_cursor(0)
  local current_line = current_pos[1] - 1
  local current_col = current_pos[2]

  table.sort(
    diagnostics,
    function(a, b)
      if a.bufnr ~= b.bufnr then
        return a.bufnr < b.bufnr
      elseif a.lnum ~= b.lnum then
        return a.lnum < b.lnum
      else
        return a.col < b.col
      end
    end
  )

  for i = #diagnostics, 1, -1 do
    local diagnostic = diagnostics[i]
    if
      diagnostic.bufnr < current_buf or (diagnostic.bufnr == current_buf and diagnostic.lnum < current_line) or
        (diagnostic.bufnr == current_buf and diagnostic.lnum == current_line and diagnostic.col < current_col)
     then
      vim.api.nvim_set_current_buf(diagnostic.bufnr)
      vim.api.nvim_win_set_cursor(0, {diagnostic.lnum + 1, diagnostic.col})
      return diagnostic
    end
  end

  local last = diagnostics[#diagnostics]
  vim.api.nvim_set_current_buf(last.bufnr)
  vim.api.nvim_win_set_cursor(0, {last.lnum + 1, last.col})
  return last
end

-- Generic wrapper to navigate diagnostics and render popup
local function navigate_and_render(severity, direction)
  local diagnostic
  if direction == "next" then
    diagnostic = goto_next_global_diagnostic(severity)
  elseif direction == "prev" then
    diagnostic = goto_prev_global_diagnostic(severity)
  end
  if diagnostic then
    -- Use defer_fn to ensure the cursor movement is completed before opening the float
    vim.defer_fn(
      function()
        vim.cmd("RustLsp renderDiagnostic current")
      end,
      10
    )
  end
end

-- Specific functions for warnings, errors, and hints
function M.goto_next_warning()
  navigate_and_render(vim.diagnostic.severity.WARN, "next")
end
function M.goto_prev_warning()
  navigate_and_render(vim.diagnostic.severity.WARN, "prev")
end
function M.goto_next_error()
  navigate_and_render(vim.diagnostic.severity.ERROR, "next")
end
function M.goto_prev_error()
  navigate_and_render(vim.diagnostic.severity.ERROR, "prev")
end
function M.goto_next_hint()
  navigate_and_render(vim.diagnostic.severity.HINT, "next")
end
function M.goto_prev_hint()
  navigate_and_render(vim.diagnostic.severity.HINT, "prev")
end

-- Register commands
vim.api.nvim_create_user_command(
  "GotoNextWarning",
  M.goto_next_warning,
  {desc = "Go to next global warning and render Rust diagnostic popup"}
)
vim.api.nvim_create_user_command(
  "GotoPrevWarning",
  M.goto_prev_warning,
  {desc = "Go to previous global warning and render Rust diagnostic popup"}
)
vim.api.nvim_create_user_command(
  "GotoNextError",
  M.goto_next_error,
  {desc = "Go to next global error and render Rust diagnostic popup"}
)
vim.api.nvim_create_user_command(
  "GotoPrevError",
  M.goto_prev_error,
  {desc = "Go to previous global error and render Rust diagnostic popup"}
)
vim.api.nvim_create_user_command(
  "GotoNextHint",
  M.goto_next_hint,
  {desc = "Go to next global hint and render Rust diagnostic popup"}
)
vim.api.nvim_create_user_command(
  "GotoPrevHint",
  M.goto_prev_hint,
  {desc = "Go to previous global hint and render Rust diagnostic popup"}
)

return M
