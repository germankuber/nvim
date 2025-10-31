return {{
    "Weissle/persistent-breakpoints.nvim",

    config = function()
        require('persistent-breakpoints').setup {
            load_breakpoints_event = {"BufReadPost"}
        }
    end

}, {"niuiic/dap-utils.nvim"}, {
    "theHamsta/nvim-dap-virtual-text",
    config = function()
        require("nvim-dap-virtual-text").setup()
    end
}, {
    "rcarriga/nvim-dap-ui",
    dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"},
    lazy = false, -- Cargar al inicio junto con nvim-dap
    keymaps = false,
    config = function()
        require("dapui").setup()
    end
}, {
    "mfussenegger/nvim-dap",
    lazy = false, -- Cargar al inicio para que las configuraciones estén disponibles
    keymaps = false,
    keys = {
        -- Keybindings para debugging
        { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
        { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Conditional Breakpoint" },
        { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
        { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
        { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
        { "<leader>do", function() require("dap").step_over() end, desc = "Step Over" },
        { "<leader>dO", function() require("dap").step_out() end, desc = "Step Out" },
        { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
        { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
        { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
        { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
        { "<leader>dh", function() require("dap.ui.widgets").hover() end, desc = "Hover" },
        { "<leader>dp", function() require("dap.ui.widgets").preview() end, desc = "Preview" },
        -- Breakpoint persistente
        { "<leader>dbs", function() require('persistent-breakpoints.api').toggle_breakpoint() end, desc = "Toggle Persistent Breakpoint" },
        { "<leader>dbc", function() require('persistent-breakpoints.api').clear_all_breakpoints() end, desc = "Clear All Breakpoints" },
    },
    config = function()
        local dap, dapui = require "dap", require "dapui"
        local dotnet_helper = require "config.helpers.dotnet"

        -- Configurar listeners para abrir/cerrar dapui automáticamente
        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui_config = function()
            dapui.close()
        end

        -- Configurar adaptador de netcoredbg (instalado por Mason)
        local mason_path = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg/netcoredbg"

        local netcoredbg_adapter = {
            type = "executable",
            command = mason_path,
            args = { "--interpreter=vscode" },
        }

        dap.adapters.netcoredbg = netcoredbg_adapter
        dap.adapters.coreclr = netcoredbg_adapter

        -- Configuración para proyectos C#/.NET
        dap.configurations.cs = {
            {
                type = "coreclr",
                name = "launch - netcoredbg",
                request = "launch",
                program = function()
                    return dotnet_helper.get_dll_path()
                end,
                cwd = function()
                    -- El cwd será el directorio donde está el .csproj
                    local dll_path = dotnet_helper.get_dll_path()
                    local project_dir = vim.fn.fnamemodify(dll_path, ':h:h:h:h')
                    return project_dir
                end,
            },
            {
                type = "coreclr",
                name = "attach - netcoredbg",
                request = "attach",
                processId = function()
                    return require('dap.utils').pick_process()
                end,
            },
        }

        -- Configurar iconos para breakpoints
        vim.fn.sign_define('DapBreakpoint', { text='🔴', texthl='', linehl='', numhl='' })
        vim.fn.sign_define('DapBreakpointCondition', { text='🟡', texthl='', linehl='', numhl='' })
        vim.fn.sign_define('DapBreakpointRejected', { text='⚫', texthl='', linehl='', numhl='' })
        vim.fn.sign_define('DapLogPoint', { text='📝', texthl='', linehl='', numhl='' })
        vim.fn.sign_define('DapStopped', { text='▶️', texthl='', linehl='debugPC', numhl='' })

        -- Registrar keybindings con which-key
        local wk_ok, wk = pcall(require, "which-key")
        if wk_ok then
            wk.add({
                { "<leader>d", group = "Debug" },
                { "<leader>db", group = "Breakpoint" },
            })
        end
    end
}}
