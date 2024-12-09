return {
    {
        "RRethy/vim-illuminate",
        config = function()
            require("illuminate").configure(
                {
                    providers = {"lsp", "regex"},
                    delay = 150
                }
            )

            local function apply_custom_styles()
                vim.api.nvim_set_hl(0, "IlluminatedWordText", {bg = "#3b4261", fg = "NONE", underline = true})
                vim.api.nvim_set_hl(0, "IlluminatedWordRead", {bg = "#3b4261", fg = "NONE", underline = true})
                vim.api.nvim_set_hl(0, "IlluminatedWordWrite", {bg = "#3b4261", fg = "NONE", underline = true})
                print("Custom styles applied!")
            end

            local function reset_to_default_styles()
                vim.api.nvim_set_hl(0, "IlluminatedWordText", {})
                vim.api.nvim_set_hl(0, "IlluminatedWordRead", {})
                vim.api.nvim_set_hl(0, "IlluminatedWordWrite", {})
                print("Styles reset to default!")
            end

            vim.api.nvim_create_user_command("IlluminateApplyStyles", apply_custom_styles, {})
            vim.api.nvim_create_user_command("IlluminateResetStyles", reset_to_default_styles, {})

            apply_custom_styles()
        end
    }
}
