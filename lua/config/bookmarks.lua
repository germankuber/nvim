-- ~/.config/nvim/lua/config/custom_bookmarks.lua
local M = {}

function M.next_global_bookmark()
  local bookmark_file = vim.fn.expand "$HOME/.bookmarks"
  -- print("Buscando en el archivo de marcadores:", bookmark_file) -- Depuración

  local f = io.open(bookmark_file, "r")
  if not f then
    vim.notify("No se encontró el archivo global de marcadores: " .. bookmark_file, vim.log.levels.ERROR)
    return
  end

  local content = f:read "*all"
  f:close()

  -- print("Contenido del archivo de marcadores:", content) -- Depuración

  local success, decoded = pcall(vim.fn.json_decode, content)
  if not success or type(decoded) ~= "table" then
    vim.notify("Error al decodificar el archivo de marcadores.", vim.log.levels.ERROR)
    return
  end

  -- print("Marcadores decodificados:", vim.inspect(decoded)) -- Depuración

  if not decoded.data or type(decoded.data) ~= "table" then
    vim.notify("Formato de marcadores inválido: falta la clave 'data'.", vim.log.levels.ERROR)
    return
  end

  local data = decoded.data
  local sorted = {}

  for filename, lines in pairs(data) do
    for line_str, _ in pairs(lines) do
      local line = tonumber(line_str)
      if line then
        table.insert(sorted, { filename = filename, line = line })
      end
    end
  end

  -- print("Marcadores recopilados:", vim.inspect(sorted)) -- Depuración

  if vim.tbl_isempty(sorted) then
    vim.notify("No se encontraron marcadores globales.", vim.log.levels.INFO)
    return
  end

  -- Ordenar los marcadores por archivo y línea (ascendente)
  table.sort(sorted, function(a, b)
    if a.filename == b.filename then
      return a.line < b.line
    end
    return a.filename < b.filename
  end)

  -- print("Marcadores ordenados:", vim.inspect(sorted)) -- Depuración

  -- Obtener la posición actual
  local current_file = vim.fn.expand "%:p"
  local current_line = vim.fn.line "."
  -- print("Archivo actual:", current_file, "Línea actual:", current_line) -- Depuración

  -- Encontrar el siguiente marcador
  local next_bookmark = nil
  for _, bookmark in ipairs(sorted) do
    if bookmark.filename > current_file or (bookmark.filename == current_file and bookmark.line > current_line) then
      next_bookmark = bookmark
      break
    end
  end

  if next_bookmark then
    -- Saltar al siguiente marcador encontrado
    -- print("Saltando al marcador:", next_bookmark.filename, "Línea:", next_bookmark.line) -- Depuración

    -- Obtener número de buffer si ya está abierto
    local buf_num = vim.fn.bufnr(next_bookmark.filename)
    if buf_num ~= -1 then
      -- Cambiar al buffer existente
      vim.api.nvim_set_current_buf(buf_num)
    else
      -- Abrir el archivo si no está abierto
      vim.cmd("edit " .. next_bookmark.filename)
    end

    -- Establecer el cursor en la línea especificada
    vim.api.nvim_win_set_cursor(0, { next_bookmark.line, 0 })
    vim.notify("Saltando a marcador: " .. next_bookmark.filename .. ":" .. next_bookmark.line, vim.log.levels.INFO)
  else
    -- Si no hay siguiente marcador, saltar al primer marcador (circular)
    local first_bookmark = sorted[1]
    -- print("Saltando al primer marcador (circular):", first_bookmark.filename, "Línea:", first_bookmark.line) -- Depuración

    local buf_num = vim.fn.bufnr(first_bookmark.filename)
    if buf_num ~= -1 then
      vim.api.nvim_set_current_buf(buf_num)
    else
      vim.cmd("edit " .. first_bookmark.filename)
    end

    vim.api.nvim_win_set_cursor(0, { first_bookmark.line, 0 })
    vim.notify(
      "Saltando al primer marcador: " .. first_bookmark.filename .. ":" .. first_bookmark.line,
      vim.log.levels.INFO
    )
  end
end

-- Función para saltar al marcador global anterior (circular)
function prev_global_bookmark()
  local bookmark_file = vim.fn.expand "$HOME/.bookmarks"
  -- print("Buscando en el archivo de marcadores:", bookmark_file) -- Depuración

  local f = io.open(bookmark_file, "r")
  if not f then
    vim.notify("No se encontró el archivo global de marcadores: " .. bookmark_file, vim.log.levels.ERROR)
    return
  end

  local content = f:read "*all"
  f:close()

  -- print("Contenido del archivo de marcadores:", content) -- Depuración

  local success, decoded = pcall(vim.fn.json_decode, content)
  if not success or type(decoded) ~= "table" then
    vim.notify("Error al decodificar el archivo de marcadores.", vim.log.levels.ERROR)
    return
  end

  -- print("Marcadores decodificados:", vim.inspect(decoded)) -- Depuración

  if not decoded.data or type(decoded.data) ~= "table" then
    vim.notify("Formato de marcadores inválido: falta la clave 'data'.", vim.log.levels.ERROR)
    return
  end

  local data = decoded.data
  local sorted = {}

  for filename, lines in pairs(data) do
    for line_str, _ in pairs(lines) do
      local line = tonumber(line_str)
      if line then
        table.insert(sorted, { filename = filename, line = line })
      end
    end
  end

  -- print("Marcadores recopilados:", vim.inspect(sorted)) -- Depuración

  if vim.tbl_isempty(sorted) then
    vim.notify("No se encontraron marcadores globales.", vim.log.levels.INFO)
    return
  end

  -- Ordenar los marcadores por archivo y línea (ascendente)
  table.sort(sorted, function(a, b)
    if a.filename == b.filename then
      return a.line < b.line
    end
    return a.filename < b.filename
  end)

  -- print("Marcadores ordenados:", vim.inspect(sorted)) -- Depuración

  -- Obtener la posición actual
  local current_file = vim.fn.expand "%:p"
  local current_line = vim.fn.line "."
  -- print("Archivo actual:", current_file, "Línea actual:", current_line) -- Depuración

  -- Encontrar el marcador anterior
  local prev_bookmark = nil
  for _, bookmark in ipairs(sorted) do
    if bookmark.filename < current_file or (bookmark.filename == current_file and bookmark.line < current_line) then
      prev_bookmark = bookmark
    end
  end

  if prev_bookmark then
    -- Saltar al marcador anterior encontrado
    -- print("Saltando al marcador anterior:", prev_bookmark.filename, "Línea:", prev_bookmark.line) -- Depuración

    -- Obtener número de buffer si ya está abierto
    local buf_num = vim.fn.bufnr(prev_bookmark.filename)
    if buf_num ~= -1 then
      -- Cambiar al buffer existente
      vim.api.nvim_set_current_buf(buf_num)
    else
      -- Abrir el archivo si no está abierto
      vim.cmd("edit " .. prev_bookmark.filename)
    end

    -- Establecer el cursor en la línea especificada
    vim.api.nvim_win_set_cursor(0, { prev_bookmark.line, 0 })
    vim.notify(
      "Saltando al marcador anterior: " .. prev_bookmark.filename .. ":" .. prev_bookmark.line,
      vim.log.levels.INFO
    )
  else
    -- Si no hay marcador anterior, saltar al último marcador (circular)
    local last_bookmark = sorted[#sorted]
    -- print("Saltando al último marcador (circular):", last_bookmark.filename, "Línea:", last_bookmark.line) -- Depuración

    local buf_num = vim.fn.bufnr(last_bookmark.filename)
    if buf_num ~= -1 then
      vim.api.nvim_set_current_buf(buf_num)
    else
      vim.cmd("edit " .. last_bookmark.filename)
    end

    vim.api.nvim_win_set_cursor(0, { last_bookmark.line, 0 })
    vim.notify(
      "Saltando al último marcador: " .. last_bookmark.filename .. ":" .. last_bookmark.line,
      vim.log.levels.INFO
    )
  end
end

return M
