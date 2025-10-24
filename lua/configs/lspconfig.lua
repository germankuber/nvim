-- Guardar funciones originales
local original_notify = vim.notify
local original_notify_once = vim.notify_once
local original_deprecate = vim.deprecate

-- Suprimir todos los warnings de lspconfig
local function should_suppress(msg)
    if type(msg) == "string" then
        return msg:match("lspconfig") or
               msg:match("Feature will be removed") or
               msg:match("deprecated")
    end
    return false
end

-- Wrapper para notify
vim.notify = function(msg, level, opts)
    if should_suppress(msg) then
        return
    end
    original_notify(msg, level, opts)
end

-- Wrapper para notify_once
vim.notify_once = function(msg, level, opts)
    if should_suppress(msg) then
        return
    end
    original_notify_once(msg, level, opts)
end

-- Wrapper para deprecate
vim.deprecate = function(...)
    -- Suprimir completamente vim.deprecate durante la carga de lspconfig
    return
end

local lspconfig = require('lspconfig')

local capabilities = require('cmp_nvim_lsp').default_capabilities()
local on_attach = function(_, _)
end
-- Python LSP (Pyright)
lspconfig.pyright.setup {
    capabilities = capabilities,
    on_attach = on_attach,
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
        -- tu lógica de virtualenv
        local cwd = vim.fn.getcwd()
        local venv = cwd .. "/.venv/bin/python"
        if vim.fn.filereadable(venv) == 1 then
            client.config.settings.python.pythonPath = venv
        end
    end
}

-- Lua LSP
lspconfig.lua_ls.setup {
    capabilities = capabilities,
    on_attach = on_attach,
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
    capabilities = capabilities,
    on_attach = on_attach,
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
lspconfig.solidity_ls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    autostart = true,
    filetypes = {"solidity"},
    root_dir = lspconfig.util.root_pattern("hardhat.config.*", "foundry.toml", "remappings.txt", ".git"),
    cmd = {"/Users/GermanKuber/.nvm/versions/node/v22.21.0/bin/vscode-solidity-server", "--stdio"},
    settings = {
        solidity = {
            includePath = "node_modules"
        }
    }
})

-- EFM para formateo, lint y code actions
lspconfig.efm.setup({
    capabilities = capabilities,
    on_attach = on_attach,
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
        languages = {
            solidity = {solhint, prettier_d}
        }
    }
})
local function organize_imports()
    local params = {
        command = "_typescript.organizeImports",
        arguments = {vim.api.nvim_buf_get_name(0)}
    }
    vim.lsp.buf.execute_command(params)
end

lspconfig.ts_ls.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    init_options = {
        preferences = {
            disableSuggestions = true
        }
    },
    commands = {
        OrganizeImports = {
            organize_imports,
            description = "Organize Imports"
        }
    }
}
-- C# LSP (OmniSharp)
lspconfig.omnisharp.setup {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    -- Llamar tu función on_attach original
    on_attach(client, bufnr)
    -- Desactivar diagnósticos específicamente para OmniSharp
    vim.diagnostic.config({
      virtual_text = false,
      signs = false,
      underline = false,
    }, bufnr)
  end,
  cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
  root_dir = lspconfig.util.root_pattern("*.csproj", "*.sln", ".git"),
}

-- Restaurar todas las funciones originales después de configurar todos los LSP servers
vim.notify = original_notify
vim.notify_once = original_notify_once
vim.deprecate = original_deprecate
