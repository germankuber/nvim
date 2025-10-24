return {
    {
        "jackMort/ChatGPT.nvim",
        event = "VeryLazy",
        config = function() require("chatgpt").setup() end,
        dependencies = {
            "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim",
            "folke/trouble.nvim", -- optional
            "nvim-telescope/telescope.nvim"
        }
    },
    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        version = false, -- Never set this value to "*"! Never!
        opts = {
            provider = "openai", -- o "claude" si prefieres
            -- Nueva estructura de providers según migración oficial
            providers = {
                openai = {
                    endpoint = "https://api.openai.com/v1",
                    model = "gpt-4o",
                    timeout = 30000,
                    extra_request_body = {
                        temperature = 0,
                        max_completion_tokens = 8192,
                    },
                },
            },
            -- Configuración de keymaps actualizada según la migración
            mappings = {
                ask = "<leader>aa",     -- AvanteAsk
                edit = "<leader>ae",    -- AvanteEdit  
                refresh = "<leader>ar", -- AvanteRefresh
            },
        },
        -- Keymaps usando la nueva API
        keys = function(_, keys)
            local opts = require("lazy.core.plugin").values(
                require("lazy.core.config").spec.plugins["avante.nvim"], 
                "opts", 
                false
            )

            local mappings = {
                {
                    opts.mappings.ask,
                    function() require("avante.api").ask() end,
                    desc = "avante: ask",
                    mode = { "n", "v" },
                },
                {
                    opts.mappings.refresh,
                    function() require("avante.api").refresh() end,
                    desc = "avante: refresh",
                    mode = "v",
                },
                {
                    opts.mappings.edit,
                    function() require("avante.api").edit() end,
                    desc = "avante: edit",
                    mode = { "n", "v" },
                },
            }
            mappings = vim.tbl_filter(function(m) return m[1] and #m[1] > 0 end, mappings)
            return vim.list_extend(mappings, keys)
        end,
        build = "make",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "echasnovski/mini.pick",
            "nvim-telescope/telescope.nvim",
            "hrsh7th/nvim-cmp",
            "ibhagwan/fzf-lua",
            "nvim-tree/nvim-web-devicons",
            "zbirenbaum/copilot.lua",
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
            {
                'MeanderingProgrammer/render-markdown.nvim',
                opts = {
                    file_types = { "markdown", "Avante" },
                },
                ft = { "markdown", "Avante" },
            },
        },
    }
}
