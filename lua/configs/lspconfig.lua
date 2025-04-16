local lspconfig = require "lspconfig"
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Configuración para JSON
lspconfig.jsonls.setup {
    settings = {
        json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true }
        }
    },
    capabilities = capabilities,
    on_attach = on_attach
}

-- Configuración para Lua
lspconfig.lua_ls.setup {
    settings = {
        Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = {"vim"} },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false
            },
            telemetry = { enable = false }
        }
    },
    capabilities = capabilities,
    on_attach = on_attach
}

-- LSP para TOML
lspconfig.taplo.setup {
    capabilities = capabilities
}

-- Configuración genérica para múltiples servidores
local servers = {"html", "cssls", "ts_ls", "pyright", "rust_analyzer"}
for _, server in ipairs(servers) do
    lspconfig[server].setup {
        capabilities = capabilities,
        on_attach = on_attach
    }
end

-- Configuración para Hardhat-vscode (servidor para Solidity)
lspconfig.solidity.setup {
    cmd = { "hardhat-vscode-server", "--stdio" },
    filetypes = { "solidity" },
    root_dir = lspconfig.util.root_pattern("hardhat.config.js", "hardhat.config.ts"),
    settings = {
        solidity = {
            includePath = "",
            remapping = { ["@OpenZeppelin/"] = "OpenZeppelin/openzeppelin-contracts@4.6.0/" },
            allowPaths = {}
        }
    },
    capabilities = capabilities,
    on_attach = on_attach
}
