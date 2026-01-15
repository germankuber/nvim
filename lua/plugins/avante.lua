return {
    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        lazy = false,
        version = false,
        opts = {
            -- Provider de IA por defecto (puede cambiar con :AvanteChangeProvider)
            provider = "copilot",  -- Empieza con Copilot, cambia a "claude" si prefieres
            auto_suggestions_provider = "copilot",

            -- Nueva configuración de providers
            providers = {
                claude = {
                    endpoint = "https://api.anthropic.com",
                    model = "claude-sonnet-4-20250514",
                    timeout = 30000,
                    extra_request_body = {
                        temperature = 0,
                        max_tokens = 8000,
                    },
                },
                copilot = {
                    endpoint = "https://api.githubcopilot.com",
                    model = "gpt-4o-2024-05-13",
                    timeout = 30000,
                    extra_request_body = {
                        temperature = 0,
                        max_tokens = 8000,
                    },
                },
            },

            -- Comportamiento general
            behaviour = {
                auto_suggestions = false,
                auto_set_highlight_group = true,
                auto_set_keymaps = true,
                auto_apply_diff_after_generation = false,
                support_paste_from_clipboard = true,
            },

            -- Mappings (puedes personalizar estos)
            mappings = {
                --- @class AvanteConflictMappings
                diff = {
                    ours = "co",
                    theirs = "ct",
                    all_theirs = "ca",
                    both = "cb",
                    cursor = "cc",
                    next = "]x",
                    prev = "[x",
                },
                suggestion = {
                    accept = "<M-l>",
                    next = "<M-]>",
                    prev = "<M-[>",
                    dismiss = "<C-]>",
                },
                jump = {
                    next = "]]",
                    prev = "[[",
                },
                submit = {
                    normal = "<CR>",
                    insert = "<C-s>",
                },
                sidebar = {
                    apply_all = "A",
                    apply_cursor = "a",
                    switch_windows = "<Tab>",
                    reverse_switch_windows = "<S-Tab>",
                },
            },

            -- Ventanas y UI
            windows = {
                ---@type "right" | "left" | "top" | "bottom"
                position = "right",
                wrap = true,
                width = 30,
                sidebar_header = {
                    enabled = true,
                    align = "center",
                    rounded = true,
                },
                input = {
                    prefix = "> ",
                    height = 8,
                },
                edit = {
                    border = "rounded",
                    start_insert = true,
                },
                ask = {
                    floating = false,
                    start_insert = true,
                    border = "rounded",
                    focus_on_apply = "ours",
                },
            },

            -- Highlights personalizados
            highlights = {
                ---@type AvanteConflictHighlights
                diff = {
                    current = "DiffText",
                    incoming = "DiffAdd",
                },
            },

            -- Diff (para comparar cambios)
            diff = {
                autojump = true,
                ---@type string | fun(): any
                list_opener = "copen",
                --- Override the 'timeoutlen' setting while hovering over a diff (see :help timeoutlen).
                --- Helps to avoid entering operator-pending mode with diff mappings starting with `c`.
                --- Disable by setting to -1.
                override_timeoutlen = 500,
            },

            -- Instrucciones específicas del proyecto
            instructions_file = "avante.md",  -- Archivo en la raíz del proyecto
        },

        -- Construir binarios nativos
        build = vim.fn.has("win32") ~= 0
            and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
            or "make",

        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
            "zbirenbaum/copilot.lua",  -- Ya lo tienes
            {
                "MeanderingProgrammer/render-markdown.nvim",
                opts = {
                    file_types = { "markdown", "Avante" },
                },
                ft = { "markdown", "Avante" },
            },
            {
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
                opts = {
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true,
                        },
                        use_absolute_path = true,
                    },
                },
            },
        },

        config = function(_, opts)
            require("avante").setup(opts)

            -- Keymaps globales personalizados
            vim.keymap.set("n", "<leader>aa", "<cmd>AvanteAsk<cr>", { desc = "Avante Ask", noremap = true, silent = true })
            vim.keymap.set("v", "<leader>aa", "<cmd>AvanteAsk<cr>", { desc = "Avante Ask", noremap = true, silent = true })
            vim.keymap.set("n", "<leader>ar", "<cmd>AvanteRefresh<cr>", { desc = "Avante Refresh", noremap = true, silent = true })
            vim.keymap.set("n", "<leader>ae", "<cmd>AvanteEdit<cr>", { desc = "Avante Edit", noremap = true, silent = true })
            vim.keymap.set("n", "<leader>at", "<cmd>AvanteToggle<cr>", { desc = "Avante Toggle", noremap = true, silent = true })
            vim.keymap.set("n", "<leader>ac", "<cmd>AvanteChat<cr>", { desc = "Avante Chat", noremap = true, silent = true })
            vim.keymap.set("n", "<leader>ap", "<cmd>AvanteChangeProvider<cr>", { desc = "Avante Change Provider", noremap = true, silent = true })

            -- Nota para API key de Claude
            if opts.provider == "claude" then
                -- Avante buscará la API key de Claude en la variable de entorno ANTHROPIC_API_KEY
                -- Agregar a tu ~/.zshrc o ~/.bashrc:
                -- export ANTHROPIC_API_KEY="tu-api-key-aquí"
                vim.notify(
                    "Avante usando Claude. Asegúrate de tener ANTHROPIC_API_KEY en tu entorno",
                    vim.log.levels.INFO
                )
            end
        end,
    }
}
