return {
{
    "stevearc/conform.nvim",
    dependencies = "williamboman/mason.nvim",
    opts = {
      -- qué usar por filetype
      formatters_by_ft = {
        python      = { "isort", "black" },
        lua         = { "stylua" },
        javascript  = { "prettierd" },
        typescript  = { "prettierd" },
        json        = { "prettierd" },
        sh          = { "shfmt" },
      },

      -- auto‑formato al guardar (opcional)
      -- format_on_save = function(bufnr)
      --   return { lsp_fallback = true, timeout_ms = 3000 }
      -- end,
    },
  },{
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "b0o/schemastore.nvim",
    },
    config = function()
      -- require "configs.lspconfig"
      local lspconfig = require('lspconfig')

      -- Python LSP (Pyright)
      lspconfig.pyright.setup{
        capabilities = capabilities,
        on_attach   = on_attach,
        settings = {
          python = {
            analysis = {
              autoImportCompletions = true,
              useLibraryCodeForTypes = true,
              autoSearchPaths = true,
            },
          },
        },
        on_init = function(client)
          -- tu lógica de virtualenv
          local cwd = vim.fn.getcwd()
          local venv = cwd .. "/.venv/bin/python"
          if vim.fn.filereadable(venv) == 1 then
            client.config.settings.python.pythonPath = venv
          end
        end,
      }

      -- Lua LSP
      lspconfig.lua_ls.setup {
        capabilities = capabilities,
        on_attach   = on_attach,
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
              path = vim.split(package.path, ";"),
            },
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
            },
            telemetry = {
              enable = false,
            },
          },
        },
      }

      -- JSON LSP
      lspconfig.jsonls.setup {
        capabilities = capabilities,
        on_attach   = on_attach,
        settings = {
          json = {
            schemas  = require('schemastore').json.schemas(),
            validate = { enable = true },
          },
        },
      }

      -- Solidity LSP
      lspconfig.solidity_ls.setup({
        capabilities = capabilities,
        on_attach   = on_attach,
        autostart   = true,
        filetypes   = { "solidity" },
        root_dir    = require("lspconfig.util").root_pattern(
                        "hardhat.config.*", "foundry.toml", "remappings.txt", ".git"
                     ),
        cmd = {
          "/Users/GermanKuber/.nvm/versions/node/v20.19.0/bin/vscode-solidity-server",
          "--stdio"
        },
        settings = {
          solidity = {
            includePath = "node_modules",
          },
        },
      })

      -- EFM para formateo, lint y code actions
      lspconfig.efm.setup({
        capabilities = capabilities,
        on_attach   = on_attach,
        filetypes = {
          "solidity", "lua", "python", "json", "jsonc",
          "sh", "javascript", "javascriptreact",
          "typescript", "typescriptreact", "svelte",
          "vue", "markdown", "docker", "html",
          "css", "c", "cpp",
        },
        init_options = {
          documentFormatting      = true,
          documentRangeFormatting = true,
          hover                   = true,
          documentSymbol          = true,
          codeAction              = true,
          completion              = true,
        },
        settings = {
          languages = {
            solidity = { solhint, prettier_d },
          },
        },
      })
    end,
  },
{ "stevanmilic/nvim-lspimport" },
 {"b0o/schemastore.nvim"}, {
    "pmizio/typescript-tools.nvim",
    dependencies = {"nvim-lua/plenary.nvim", "neovim/nvim-lspconfig"},
    opts = {}
}}
