return {
    {
        "neovim/nvim-lspconfig",
        config = function()
            require("lspconfig").lua_ls.setup {
                settings = {
                    Lua = {
                        runtime = {
                            version = "LuaJIT",
                            path = vim.split(package.path, ";")
                        },
                        diagnostics = {
                            globals = {"vim"}
                        },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file("", true)
                        },
                        telemetry = {
                            enable = false
                        }
                    }
                }
            }
        end
    }
}
