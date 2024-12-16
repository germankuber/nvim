require("config.lazy")
require("config.bookmarks")
require("config.terminal")
require("config.diagnostic")
require("config.sessions")
require("config.preview")
require("config.refactoring").setup()
require("config.refactor.refactor")
require("config.jump_config")
require("config.compare_files")
require("config.sound")
require("config.trouble")
require("config.jump_navigation").setup() 
require("config.funny_clipboard")
require("config.neotest_telescope").setup()

require("config.convert_number").setup()
require("config.transaction_detail").setup(
    {
        transaction_detail_url = "https://etherscan.io/tx/",
        contract_detail_url = "https://etherscan.io/address/"
    }
)
require("config.convert_weth").setup()
require("config.debug")

require("config.mappings").setup(
    {
        codeFileType = {"rust", "python", "xml", "json", "toml"},
        mapping_file_path = "/Users/GermanKuber/.config/nvim/lua/mappings/mappings.json"
    }
)

require("config.telescope_preview_match").setup(
    {
        fg = "#00FF00",
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

vim.opt.virtualedit = "onemore"

vim.api.nvim_set_keymap(
    "n",
    "<C-s>",
    ":w<CR>",
    {
        noremap = true,
        silent = true
    }
)
vim.api.nvim_set_keymap(
    "i",
    "<C-s>",
    "<Esc>:w<CR>a",
    {
        noremap = true,
        silent = true
    }
)

vim.api.nvim_set_hl(
    0,
    "NotifySUCCESS",
    {
        fg = "#00ff00",
        bg = "#000000"
    }
)

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

vim.lsp.inlay_hint.enable(true)

function CloseBufferOrShowDashboard()
    local buffers =
        vim.fn.getbufinfo(
        {
            buflisted = 1
        }
    )
    if #buffers == 1 then
        vim.cmd("BufferClose")
        vim.cmd("Dashboard")
    else
        vim.cmd("BufferClose")
    end
end

vim.api.nvim_create_user_command(
    "BufferCloseOrDashboard",
    CloseBufferOrShowDashboard,
    {
        desc = "Close buffer or show dashboard if no buffers remain"
    }
)
vim.api.nvim_set_hl(0, "CursorLine", {bg = "#3b4261", underline = false, default = false})
vim.api.nvim_set_hl(0, "CursorColumn", {bg = "#3b4261", underline = false, default = false})

local function close_non_file_buffers()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
            local buf_type = vim.api.nvim_buf_get_option(buf, "buftype")
            local filetype = vim.api.nvim_buf_get_option(buf, "filetype")

            local non_file_buftypes = {
                "nofile",
                "prompt",
                "help",
                "quickfix",
                "terminal",
                "acwrite"
            }

            local non_file_filetypes = {
                "NvimTree",
                "TelescopePrompt",
                "packer"
            }

            local is_non_file_buftype = vim.tbl_contains(non_file_buftypes, buf_type)
            local is_non_file_filetype = vim.tbl_contains(non_file_filetypes, filetype)

            if is_non_file_buftype or is_non_file_filetype then
                vim.api.nvim_buf_delete(buf, {force = true})
            end
        end
    end
end

vim.api.nvim_create_autocmd(
    "VimLeavePre",
    {
        callback = close_non_file_buffers
    }
)

vim.api.nvim_create_user_command(
    "DiffFiles",
    function()
        vim.cmd("vsplit")
        vim.cmd("windo diffthis")
    end,
    {desc = "Compare two files"}
)


