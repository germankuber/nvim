local dap, dapui = require("dap"), require("dapui")

dapui.setup(
  {
    icons = {expanded = "▾", collapsed = "▸"},
    mappings = {},
    layouts = {
      {
        elements = {
          {id = "scopes", size = 0.50},
          {id = "breakpoints", size = 0.25},
          -- {id = "stacks", size = 0.25},
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
  }
)

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
  local current_win = vim.api.nvim_get_current_win()
  local wins = vim.api.nvim_tabpage_list_wins(0) -- Obtiene todas las ventanas del tab actual

  for _, win in ipairs(wins) do
    print(win)
    local config = vim.api.nvim_win_get_config(win)
    print(config)
    if config.relative ~= "" then -- Esto detecta si la ventana es flotante
      vim.api.nvim_set_current_win(win) -- Cambia el foco a la ventana flotante
      print("Focused on floating window!")
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
