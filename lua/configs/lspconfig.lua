-- LSP Configuration using Neovim 0.11+ native API
-- See :help lspconfig-nvim-0.11

-- Configurar nivel de log de LSP
vim.lsp.set_log_level("ERROR")

-- Capabilities para autocompletado con nvim-cmp
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Python LSP (Pyright)
vim.lsp.config.pyright = {
    capabilities = capabilities,
    settings = {
        python = {
            analysis = {
                autoImportCompletions = true,
                useLibraryCodeForTypes = true,
                autoSearchPaths = true
            }
        }
    },
    on_init = function(client)
        local cwd = vim.fn.getcwd()
        local venv = cwd .. "/.venv/bin/python"
        if vim.fn.filereadable(venv) == 1 then
            client.config.settings.python.pythonPath = venv
        end
    end
}

-- Lua LSP
vim.lsp.config.lua_ls = {
    capabilities = capabilities,
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
vim.lsp.config.jsonls = {
    capabilities = capabilities,
    settings = {
        json = {
            schemas = require('schemastore').json.schemas(),
            validate = {
                enable = true
            }
        }
    }
}

-- Solidity LSP
vim.lsp.config.solidity_ls = {
    capabilities = capabilities,
    autostart = true,
    filetypes = {"solidity"},
    root_markers = {"hardhat.config.js", "hardhat.config.ts", "foundry.toml", "remappings.txt", ".git"},
    cmd = {"/Users/GermanKuber/.nvm/versions/node/v22.21.0/bin/vscode-solidity-server", "--stdio"},
    settings = {
        solidity = {
            includePath = "node_modules"
        }
    }
}

-- EFM para formateo, lint y code actions
vim.lsp.config.efm = {
    capabilities = capabilities,
    filetypes = {"solidity", "lua", "python", "json", "jsonc", "sh", "javascript", "javascriptreact", "typescript",
                 "typescriptreact", "svelte", "vue", "markdown", "docker", "html", "css", "c", "cpp"},
    init_options = {
        documentFormatting = true,
        documentRangeFormatting = true,
        hover = true,
        documentSymbol = true,
        codeAction = true,
        completion = true
    },
    settings = {
        languages = {}
    }
}

-- TypeScript LSP
vim.lsp.config.ts_ls = {
    capabilities = capabilities,
    init_options = {
        preferences = {
            disableSuggestions = true
        }
    }
}

-- Habilitar todos los LSPs configurados
vim.lsp.enable({
    'pyright',
    'lua_ls',
    'jsonls',
    'solidity_ls',
    'efm',
    'ts_ls',
})

-- Comando para organizar imports en TypeScript
vim.api.nvim_create_user_command('OrganizeImports', function()
    local params = {
        command = "_typescript.organizeImports",
        arguments = {vim.api.nvim_buf_get_name(0)}
    }
    vim.lsp.buf.execute_command(params)
end, { desc = "Organize TypeScript Imports" })

-- C# LSP: Configurado via roslyn.nvim (ver lua/plugins/csharp.lua)
