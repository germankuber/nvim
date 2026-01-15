return {
    {
        "seblj/roslyn.nvim",
        ft = "cs",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "williamboman/mason.nvim",
        },
        config = function()
            -- Disable Roslyn formatting via LspAttach autocmd (most reliable method)
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("DisableRoslynFormatting", { clear = true }),
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client and client.name == "roslyn" then
                        client.server_capabilities.documentFormattingProvider = false
                        client.server_capabilities.documentRangeFormattingProvider = false

                        -- Keybindings for C#
                        local opts = { buffer = args.buf, silent = true }
                        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
                        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
                        vim.keymap.set("n", "gh", vim.lsp.buf.hover, opts)  -- Changed from K to gh
                        vim.keymap.set("n", "<leader>ca", require("actions-preview").code_actions, opts)
                        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
                    end
                end,
            })

            require("roslyn").setup({
                exe = vim.fn.expand("~/.local/share/nvim/mason/packages/roslyn/roslyn"),
                config = {
                    settings = {
                        ["csharp|inlay_hints"] = {
                            csharp_enable_inlay_hints_for_implicit_object_creation = true,
                            csharp_enable_inlay_hints_for_implicit_variable_types = true,
                            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
                            csharp_enable_inlay_hints_for_types = true,
                            dotnet_enable_inlay_hints_for_indexer_parameters = true,
                            dotnet_enable_inlay_hints_for_literal_parameters = true,
                            dotnet_enable_inlay_hints_for_object_creation_parameters = true,
                            dotnet_enable_inlay_hints_for_other_parameters = true,
                            dotnet_enable_inlay_hints_for_parameters = true,
                            dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
                            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
                            dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
                        },
                        ["csharp|code_lens"] = {
                            dotnet_enable_references_code_lens = true,
                            dotnet_enable_tests_code_lens = true,
                        },
                        ["csharp|completion"] = {
                            dotnet_provide_regex_completions = true,
                            dotnet_show_completion_items_from_unimported_namespaces = true,
                            dotnet_show_name_completion_suggestions = true,
                        },
                        ["csharp|background_analysis"] = {
                            dotnet_analyzer_diagnostics_scope = "fullSolution",
                            dotnet_compiler_diagnostics_scope = "fullSolution",
                        },
                    },
                },
            })
        end,
    },
}
