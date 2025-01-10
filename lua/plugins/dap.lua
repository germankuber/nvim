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
    keymaps = false,
    config = function()
        require("dapui").setup()
    end
}, {
    "mfussenegger/nvim-dap",
    keymaps = false,
    config = function()
        local dap, dapui = require "dap", require "dapui"
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
    end
}}
