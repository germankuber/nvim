local trouble = require("trouble")

local M = {}

-- Función para saltar al diagnóstico seleccionado, ejecutar RustLsp renderDiagnostic, y cerrar Trouble
local function open_and_render()
  -- Saltar al diagnóstico seleccionado
  trouble.jump()

  -- Ejecutar RustLsp renderDiagnostic después de asegurar que el salto se completó
  vim.defer_fn(function()
    -- Verificar si la línea actual tiene diagnósticos
    local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 })
    if #diagnostics > 0 then
      vim.cmd("RustLsp renderDiagnostic current")
    else
      print("No diagnostics found on this line.")
    end
    -- Cerrar la ventana de Trouble
    trouble.close()
  end, 100) -- Aumentar el retraso para asegurar que el salto se complete
end

-- Definir mapeos personalizados para la ventana de Trouble
vim.api.nvim_create_autocmd("FileType", {
  pattern = "Trouble",
  callback = function()
    local opts = { buffer = true, noremap = true, silent = true }

    -- Navegar al siguiente diagnóstico
    vim.keymap.set("n", "j", function()
      trouble.next({ skip_groups = true, jump = false })
    end, opts)

    -- Navegar al diagnóstico anterior
    vim.keymap.set("n", "k", function()
      trouble.prev({ skip_groups = true, jump = false }) -- Corregido de `prev` a `previous`
    end, opts)

    -- Saltar al diagnóstico, ejecutar RustLsp renderDiagnostic, y cerrar Trouble
    vim.keymap.set("n", "l", open_and_render, opts)
    vim.keymap.set("n", "<CR>", open_and_render, opts)
  end,
})

return M
