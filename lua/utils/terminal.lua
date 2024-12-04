local Terminal = {}

Terminal.state = {
  buf = nil,
  win = nil,
}

function Terminal.toggle()
  if Terminal.state.win and vim.api.nvim_win_is_valid(Terminal.state.win) then
    -- Si la terminal ya está abierta, ciérrala
    vim.api.nvim_win_close(Terminal.state.win, true)
    Terminal.state.win = nil
    -- No establezcas Terminal.state.buf a nil aquí
  else
    -- Abre un split horizontal en la parte inferior para la terminal ocupando 1/3 de la pantalla
    vim.cmd("belowright split")
    vim.cmd("resize " .. math.floor(vim.o.lines * 0.33)) -- Ajusta al 33% de la altura
    Terminal.state.win = vim.api.nvim_get_current_win()

    -- Crear o reutilizar el buffer
    if not Terminal.state.buf or not vim.api.nvim_buf_is_valid(Terminal.state.buf) then
      -- Crea una nueva terminal
      vim.cmd("term")
      Terminal.state.buf = vim.api.nvim_get_current_buf()
    else
      -- Usa el buffer existente
      vim.api.nvim_win_set_buf(Terminal.state.win, Terminal.state.buf)
    end

    vim.cmd "startinsert" -- Entra en modo inserción
  end
end

return Terminal
