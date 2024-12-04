require("config.lazy")
require("config.bookmarks")
-- require("config.telescope:_buffers")
require("config.terminal")
require("config.diagnostic")
require("config.sessions")
require("config.preview")
require("config.refactoring").setup()
require("config.refactor.refactor_remove_parameter").setup()
require("config.jump_config")
require("config.sound")
require("config.trouble")
require("config.funny_clipboard")
require("config.convert_number").setup()
require("config.convert_weth").setup()
require("config.mappings").setup(
    {
        codeFileType = {"rust", "python", "xml", "json", "toml"},
        mapping_file_path = "/Users/GermanKuber/.config/nvim/lua/mappings/mappings.json"
    }
)

require("config.telescope_preview_match").setup(
    {
        fg = "#00FF00", -- Green foreground
        bg = "NONE",
        bold = true,
        underline = true
    }
)
require("config.gas_lualine").setup {
    api_key = "AHBNGRDFTA7NTEHFG745HN917DGKG71VMD",
    upper_threshold = 25,
    lower_threshold = 15
}
vim.o.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

vim.opt.virtualedit = "onemore" -- Allow cursor one more position past EOL, but we handle this with mappings

-- vim.fn.sign_define("LightBulbSign",
--                    {text = "💡", texthl = "DiagnosticSignInfo"})
-- vim.fn.sign_define("CodeActionSign",
--                    {text = "💡", texthl = "DiagnosticSignInfo"})
-- vim.fn.sign_define("DiagnosticSignHint",
--                    {text = "💡", texthl = "DiagnosticSignHint"})

vim.api.nvim_set_keymap(
    "n",
    "<C-s>",
    ":w<CR>",
    {
        noremap = true,
        silent = true
    }
) -- Normal mode
vim.api.nvim_set_keymap(
    "i",
    "<C-s>",
    "<Esc>:w<CR>a",
    {
        noremap = true,
        silent = true
    }
) -- Insert mode

vim.api.nvim_set_hl(
    0,
    "NotifySUCCESS",
    {
        fg = "#00ff00",
        bg = "#000000"
    }
) -- Green for success

vim.cmd [[
  highlight DiagnosticVirtualTextError guifg=#FF5555 gui=bold
  highlight DiagnosticVirtualTextWarn  guifg=#FFC777 gui=bold
  highlight DiagnosticVirtualTextInfo  guifg=#9CDCFE gui=italic
  highlight DiagnosticVirtualTextHint  guifg=#4EC9B0 gui=italic

  highlight DiagnosticSignError guifg=#FF5555 gui=bold
  highlight DiagnosticSignWarn guifg=#FFC777 gui=bold
  highlight DiagnosticSignInfo guifg=#9CDCFE gui=bold
  highlight DiagnosticSignHint guifg=#4EC9B0 gui=bold

  highlight DiagnosticUnderlineError gui=undercurl guisp=#FF5555
  highlight DiagnosticUnderlineWarn gui=undercurl guisp=#FFC777
  highlight DiagnosticUnderlineInfo gui=undercurl guisp=#9CDCFE
  highlight DiagnosticUnderlineHint gui=undercurl guisp=#4EC9B0
]]

vim.fn.sign_define(
    "DiagnosticSignError",
    {
        text = "\u{ea87}",
        texthl = "DiagnosticSignError"
    }
)
vim.fn.sign_define(
    "DiagnosticSignWarn",
    {
        text = "\u{EA6C}",
        texthl = "DiagnosticSignWarn"
    }
)
vim.fn.sign_define(
    "DiagnosticSignInfo",
    {
        text = "\u{f449}",
        texthl = "DiagnosticSignInfo"
    }
)
vim.fn.sign_define(
    "DiagnosticSignHint",
    {
        text = "\u{f0626}",
        texthl = "DiagnosticSignHint"
    }
)

vim.diagnostic.config(
    {
        virtual_text = {
            prefix = "●",
            spacing = 2,
            severity = {
                min = vim.diagnostic.severity.WARN,
                max = vim.diagnostic.severity.ERROR
            }
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        virtual_lines = true
    }
)

vim.keymap.set(
    "n",
    "<leader>ra",
    vim.lsp.buf.code_action,
    {
        noremap = true,
        silent = true,
        desc = "Code action"
    }
)

vim.g.rustaceanvim = {
    server = {
        default_settings = {
            ["rust-analyzer"] = {
                assist = {
                    importGranularity = "module",
                    importPrefix = "by_self"
                },
                cargo = {
                    loadOutDirsFromCheck = true
                },
                procMacro = {
                    enable = true
                },
                lens = {
                    enable = true -- Habilita CodeLens
                },
                diagnostics = {
                    enable = true,
                    disabled = {},
                    enableExperimental = true
                },
                -- Asegúrate de que las acciones de código están habilitadas
                codeLens = {
                    enable = true
                }
            }
        }
    }
}
-- Function to close the current buffer and show the dashboard if no buffers remain
function CloseBufferOrShowDashboard()
    local buffers =
        vim.fn.getbufinfo(
        {
            buflisted = 1
        }
    )
    if #buffers == 1 then
        -- If only one buffer is left, load the dashboard
        vim.cmd("BufferClose") -- Close the last buffer
        vim.cmd("Dashboard") -- Replace this with the command to load your dashboard
    else
        -- Otherwise, just close the buffer
        vim.cmd("BufferClose")
    end
end

-- Create a custom command
vim.api.nvim_create_user_command(
    "BufferCloseOrDashboard",
    CloseBufferOrShowDashboard,
    {
        desc = "Close buffer or show dashboard if no buffers remain"
    }
)

    