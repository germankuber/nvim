local dap, dapui = require("dap"), require("dapui")

dapui.setup({
  icons = {expanded = "▾", collapsed = "▸"},
  mappings = {},
  layouts = {
    {
      elements = {
        {id = "scopes", size = 0.50},
        {id = "breakpoints", size = 0.25},
        {id = "watches", size = 0.25}
      },
      size = 40,
      position = "left"
    },
    {
      elements = {
        {id = "console", size = 1}
      },
      size = 10,
      position = "bottom"
    }
  },
  floating = {
    position = nil,
    enter = true
  },
  windows = {indent = 3}
})

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
  local current_win = vim.api.nvim_get_current_win()
  local wins = vim.api.nvim_tabpage_list_wins(0)

  for _, win in ipairs(wins) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= "" then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
end

dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end

dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

dap.adapters.lldb = {
  type = 'executable',
  command = 'lldb-vscode',
  name = 'lldb'
}

dap.configurations.rust = {
  {
    name = "Debug Rust Tests",
    type = "lldb",
    request = "launch",
    program = function()
      return vim.fn.input('Ruta al ejecutable de prueba: ', vim.fn.getcwd() .. '/target/debug/deps/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},
    initCommands = function()
      return {
        -- Establece breakpoints en múltiples variantes de funciones de pánico
        "breakpoint set --name core::panicking::panic_fmt",
        "breakpoint set --name __rust_begin_panic",
        "breakpoint set --name std::panicking::begin_panic",
      }
    end,
    runInTerminal = false,
  }
}
