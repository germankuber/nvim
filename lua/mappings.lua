-- require "nvchad.mappings"

local function apply_mappings(group, parent_lhs, parent_pattern)
  -- Si no hay comandos, no hacemos nada
  if not group or not group.commands then
    return
  end

  -- Hereda el prefijo y el patrón del padre
  local base_lhs = (parent_lhs or "") .. (group.base_lhs or "")
  local group_pattern = group.pattern or parent_pattern -- El grupo usa su patrón o hereda

  -- Si el grupo tiene un título y un base_lhs, registrar el grupo (si no tiene patrón)
  if group.title and group.title ~= "" and group.base_lhs and group.base_lhs ~= "" then
    if not group_pattern then
      -- Crear mapeo global si no hay patrón
      local mode = group.mode or "n" -- Modo normal por defecto
      local lhs = base_lhs
      local rhs = "<Nop>"
      local opts = {
        desc = group.title,
        noremap = true,
        silent = true,
      }
      vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
    end
  end

  -- Procesar comandos y subgrupos
  for _, command in ipairs(group.commands) do
    local command_pattern = command.pattern or group_pattern -- El comando usa su patrón o hereda

    if command.commands then
      -- Si hay comandos anidados, llama recursivamente
      apply_mappings(command, base_lhs, command_pattern)
    else
      -- Crear autocomando si hay un patrón
      if command_pattern then
        vim.api.nvim_create_autocmd("User", {
          pattern = command_pattern,
          callback = function()
            local mode = command.mode or "n"
            local lhs = base_lhs .. (command.lhs or "")
            local rhs = command.rhs or ""
            local opts = {
              desc = command.desc,
              noremap = command.noremap ~= false,
              silent = command.silent ~= false,
            }
            vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
          end,
        })
      else
        -- Crear mapeo normal si no hay patrón
        local mode = command.mode or "n"
        local lhs = base_lhs .. (command.lhs or "")
        local rhs = command.rhs or ""
        local opts = {
          desc = command.desc,
          noremap = command.noremap ~= false,
          silent = command.silent ~= false,
        }
        vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
      end
    end
  end
end

-- Función para cargar el archivo JSON y aplicar los mapeos
local function load_and_apply_mappings(filepath)
  local mappings_file = vim.fn.stdpath "config" .. "/lua/" .. filepath
  local ok, content = pcall(vim.fn.readfile, mappings_file)
  if not ok then
    vim.notify("Error reading mappings file: " .. mappings_file, vim.log.levels.ERROR)
    return
  end

  -- Concatenar las líneas en una sola cadena
  local json_content = table.concat(content, "\n")
  local mappings = vim.fn.json_decode(json_content)
  if not mappings then
    vim.notify("Invalid JSON format in mappings file: " .. mappings_file, vim.log.levels.ERROR)
    return
  end

  -- Procesa cada grupo de mapeos
  for _, group in ipairs(mappings) do
    apply_mappings(group)
  end
end

-- Llama a la función con la ruta correcta
load_and_apply_mappings "mappings/mappings.json"
 