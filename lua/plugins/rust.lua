return {
    {
        "mrcjkb/rustaceanvim",
        version = "*", -- Usa siempre la última versión
        dependencies = {"nvim-lua/plenary.nvim", "mfussenegger/nvim-dap"},
        ["rust-analyzer"] = {cargo = {allFeatures = true}}
        -- config = function() require("rustaceanvim").setup({}) end
    },{
        "kosayoda/nvim-lightbulb",
        config = function()
            require("nvim-lightbulb").setup({
                autocmd = {enabled = true}, -- Automatically updates light bulb
                sign = {enabled = true, priority = 10}, -- Show light bulb as a sign
                virtual_text = {
                    enabled = false,
                    text = "\u{f0626}", -- Unicode for the icon
                    lens_text = "🔎", -- Optional lens text
                    hl = "LightBulbFloatWin", -- Custom highlight group
                    win_opts = {
                        focusable = true,
                    },
                },
                -- virtual_text = {enabled = false}, -- Disable virtual text
                status_text = {enabled = false} -- Disable status text
            })
    
        end
    }
    -- {
    --     "simrat39/rust-tools.nvim",
    --     lazy = false,
    --     dependencies = {"neovim/nvim-lspconfig", "nvim-lua/plenary.nvim"},
    --     config = function()
    --         require("rust-tools").setup({
    --             tools = {
    --                 inlay_hints = {
    --                     auto = true, -- Automatically enable hints
    --                     only_current_line = false, -- Show hints for the entire file
    --                     show_parameter_hints = true, -- Show parameter hints
    --                     right_align = false, -- Do not align hints to the right
    --                     max_len_align = false, -- Do not align hints based on max length
    --                     parameter_hints_prefix = "", -- No prefix for parameter hints
    --                     other_hints_prefix = ": " -- Prefix for other hints (e.g., types)
    --                 }
    --             },
    --             server = {
    --                 on_attach = function(_, bufnr)
    --                     local opts = {
    --                         noremap = true,
    --                         silent = true,
    --                         buffer = bufnr
    --                     }
    --                 end,
    --                 settings = {
    --                     ["rust-analyzer"] = {
    --                         cargo = {allFeatures = true}, -- Enable all Cargo features
    --                         checkOnSave = {command = "clippy"}, -- Run Clippy on save
    --                         procMacro = {enable = true} -- Enable procedural macros
    --                     }
    --                 }
    --             }
    --         })
    --     end
    -- }
    --  {
    --     "rust-lang/rust.vim",
    --     ft = "rust",
    --     lazy = false,
    --     init = function() vim.g.rustfmt_autosave = 1 end
    -- }, {
    --     "saecki/crates.nvim",
    --     ft = {"toml"},
    --     lazy = false,
    --     config = function()
    --         require("crates").setup {completion = {cmp = {enabled = true}}}
    --         require("cmp").setup.buffer {sources = {{name = "crates"}}}
    --     end
    -- }
}
