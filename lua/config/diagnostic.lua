local M = {}

local function goto_next_global_diagnostic(severity)
  local diagnostics = vim.diagnostic.get(nil, {severity = severity})
  if #diagnostics == 0 then
    print("No se encontraron diagnósticos")
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

  -- Si no hay diagnósticos posteriores, ir al primero
  local first = diagnostics[1]
  vim.api.nvim_set_current_buf(first.bufnr)
  vim.api.nvim_win_set_cursor(0, {first.lnum + 1, first.col})
  return first
end

-- Función genérica para navegar al diagnóstico anterior globalmente
local function goto_prev_global_diagnostic(severity)
  local diagnostics = vim.diagnostic.get(nil, {severity = severity})
  if #diagnostics == 0 then
    print("No se encontraron diagnósticos")
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

  -- Si no hay diagnósticos anteriores, ir al último
  local last = diagnostics[#diagnostics]
  vim.api.nvim_set_current_buf(last.bufnr)
  vim.api.nvim_win_set_cursor(0, {last.lnum + 1, last.col})
  return last
end

-- Función genérica para navegar diagnósticos sin renderizar el popup
local function navigate(severity, direction)
  if direction == "next" then
    return goto_next_global_diagnostic(severity)
  elseif direction == "prev" then
    return goto_prev_global_diagnostic(severity)
  end
end

-- Función para renderizar el popup del diagnóstico actual
local function render_current_diagnostic()
  vim.cmd("RustLsp renderDiagnostic current")
end

-- Funciones específicas para warnings, errores y hints (solo navegación)
function M.goto_next_warning()
  navigate(vim.diagnostic.severity.WARN, "next")
end

function M.goto_prev_warning()
  navigate(vim.diagnostic.severity.WARN, "prev")
end

function M.goto_next_error()
  navigate(vim.diagnostic.severity.ERROR, "next")
end

function M.goto_prev_error()
  navigate(vim.diagnostic.severity.ERROR, "prev")
end

function M.goto_next_hint()
  navigate(vim.diagnostic.severity.HINT, "next")
end

function M.goto_prev_hint()
  navigate(vim.diagnostic.severity.HINT, "prev")
end

-- Función para mostrar el popup del diagnóstico actual
function M.show_current_diagnostic()
  render_current_diagnostic()
end

-- Registrar comandos de navegación
vim.api.nvim_create_user_command("GotoNextWarning", M.goto_next_warning, {desc = "Ir al siguiente warning global"})
vim.api.nvim_create_user_command("GotoPrevWarning", M.goto_prev_warning, {desc = "Ir al warning global anterior"})
vim.api.nvim_create_user_command("GotoNextError", M.goto_next_error, {desc = "Ir al siguiente error global"})
vim.api.nvim_create_user_command("GotoPrevError", M.goto_prev_error, {desc = "Ir al error global anterior"})
vim.api.nvim_create_user_command("GotoNextHint", M.goto_next_hint, {desc = "Ir al siguiente hint global"})
vim.api.nvim_create_user_command("GotoPrevHint", M.goto_prev_hint, {desc = "Ir al hint global anterior"})

-- Registrar comando para mostrar el popup del diagnóstico actual
vim.api.nvim_create_user_command(
  "ShowDiagnosticPopup",
  M.show_current_diagnostic,
  {desc = "Mostrar popup del diagnóstico actual"}
)

return M
