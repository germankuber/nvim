return {{
    "neovim/nvim-lspconfig",
    config = function()
        local lspconfig = require('lspconfig')

        -- Python LSP
        lspconfig.pyright.setup{
            on_init = function(client)
              local cwd = vim.fn.getcwd()
              local venv_python = cwd .. "/.venv/bin/python"
              if vim.fn.filereadable(venv_python) == 1 then
                client.config.settings = {
                  python = {
                    pythonPath = venv_python
                  }
                }
              end
            end,
          } 

        -- Lua LSP
        lspconfig.lua_ls.setup {
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

        -- JSON LSP
        lspconfig.jsonls.setup {
            settings = {
                json = {
                    schemas = require('schemastore').json.schemas(),
                    validate = {
                        enable = true
                    }
                }
            }
        }

        require('lspconfig').solidity_ls.setup({
            capabilities = capabilities,
            on_attach = on_attach,
            autostart = true,
            filetypes = { "solidity" },
            root_dir = require("lspconfig.util").root_pattern("hardhat.config.*", "foundry.toml", "remappings.txt", ".git"),
            cmd = { "/Users/GermanKuber/.nvm/versions/node/v20.19.0/bin/vscode-solidity-server", "--stdio" },
            settings = {
                solidity = {
                    includePath = "node_modules",
                    -- remappings = {
                    --     ["@openzeppelin/"] = "lib/openzeppelin-contracts/",
                    --     ["account-abstraction/"] = "lib/account-abstraction/"
                    -- }
                }
            }
        })

        -- configure efm server
        lspconfig.efm.setup({
            filetypes = {"solidity", "lua", "python", "json", "jsonc", "sh", "javascript", "javascriptreact",
                         "typescript", "typescriptreact", "svelte", "vue", "markdown", "docker", "html", "css", "c",
                         "cpp"},
            init_options = {
                documentFormatting = true,
                documentRangeFormatting = true,
                hover = true,
                documentSymbol = true,
                codeAction = true,
                completion = true
            },
            settings = {
                languages = {
                    solidity = {solhint, prettier_d}

                }
            }
        })

    end
}, {"b0o/schemastore.nvim"}, {
    "pmizio/typescript-tools.nvim",
    dependencies = {"nvim-lua/plenary.nvim", "neovim/nvim-lspconfig"},
    opts = {}
}}
