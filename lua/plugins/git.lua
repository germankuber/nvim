return {
    {
        "FabijanZulj/blame.nvim",
        lazy = false,
        config = function()
            require("blame").setup {}
        end,
        opts = {blame_options = {"-w"}}
    },
    {
        "lewis6991/gitsigns.nvim",
        lazy = false,
        config = function()
            require("gitsigns").setup({
                signcolumn = true,
                numhl = false,
                linehl = true,
                word_diff = false
            })

            local function set_gitsigns_highlights()
                -- Signs (gutter)
                vim.api.nvim_set_hl(0, "GitSignsAdd",    { fg = "#9ece6a" })  -- green
                vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#e0af68" })  -- yellow
                vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#f7768e" })  -- red

                -- Full line highlights
                vim.api.nvim_set_hl(0, "GitSignsAddLn",    { bg = "#1f2d1f" }) -- greenish bg
                vim.api.nvim_set_hl(0, "GitSignsChangeLn", { bg = "#2f2a1f" }) -- yellowish bg
                vim.api.nvim_set_hl(0, "GitSignsDeleteLn", { bg = "#2f1f23" }) -- reddish bg

                -- Inline word-diff (if enabled in future)
                vim.api.nvim_set_hl(0, "GitSignsAddInline",    { fg = "#9ece6a", bg = "#1f2d1f" })
                vim.api.nvim_set_hl(0, "GitSignsChangeInline", { fg = "#e0af68", bg = "#2f2a1f" })
                vim.api.nvim_set_hl(0, "GitSignsDeleteInline", { fg = "#f7768e", bg = "#2f1f23" })
            end

            set_gitsigns_highlights()
            vim.api.nvim_create_autocmd("ColorScheme", {
                callback = function()
                    set_gitsigns_highlights()
                end,
            })
        end
    },
    {
        "SuperBo/fugit2.nvim",
        lazy = false,
        opts = {width = 100},
        dependencies = {
            "MunifTanjim/nui.nvim",
            "lewis6991/gitsigns.nvim",
            "nvim-tree/nvim-web-devicons",
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
            {
                "chrisgrieser/nvim-tinygit",
                dependencies = {"stevearc/dressing.nvim"}
            }
        },
        cmd = {"Fugit2", "Fugit2Diff", "Fugit2Graph"}
    },
    {
        "sindrets/diffview.nvim",
        dependencies = {"nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons"},
        lazy = false,
        config = function()
            local actions = require("diffview.actions")

            require("diffview").setup({
                diff_binaries = false,
                enhanced_diff_hl = true,  -- Mejor highlight de diferencias
                git_cmd = { "git" },
                use_icons = true,
                show_help_hints = true,
                watch_index = true,  -- Actualización automática

                icons = {
                    folder_closed = "",
                    folder_open = "",
                },

                signs = {
                    fold_closed = "",
                    fold_open = "",
                    done = "✓",
                },

                view = {
                    default = {
                        layout = "diff2_horizontal",
                        disable_diagnostics = false,
                        winbar_info = false,
                    },
                    merge_tool = {
                        layout = "diff3_horizontal",
                        disable_diagnostics = true,
                        winbar_info = true,
                    },
                    file_history = {
                        layout = "diff2_horizontal",
                        disable_diagnostics = false,
                        winbar_info = false,
                    },
                },

                file_panel = {
                    listing_style = "tree",
                    tree_options = {
                        flatten_dirs = true,
                        folder_statuses = "only_folded",
                    },
                    win_config = {
                        position = "left",
                        width = 35,
                        win_opts = {}
                    },
                },

                file_history_panel = {
                    log_options = {
                        git = {
                            single_file = {
                                diff_merges = "combined",
                            },
                            multi_file = {
                                diff_merges = "first-parent",
                            },
                        },
                    },
                    win_config = {
                        position = "bottom",
                        height = 16,
                        win_opts = {}
                    },
                },

                commit_log_panel = {
                    win_config = {
                        win_opts = {},
                    }
                },

                default_args = {
                    DiffviewOpen = {},
                    DiffviewFileHistory = {},
                },

                hooks = {},

                keymaps = {
                    disable_defaults = false,
                    view = {
                        { "n", "<tab>",      actions.select_next_entry,         { desc = "Siguiente archivo" } },
                        { "n", "<s-tab>",    actions.select_prev_entry,         { desc = "Archivo anterior" } },
                        { "n", "gf",         actions.goto_file,                 { desc = "Abrir archivo" } },
                        { "n", "<C-w><C-f>", actions.goto_file_split,           { desc = "Abrir en split" } },
                        { "n", "<C-w>gf",    actions.goto_file_tab,             { desc = "Abrir en tab" } },
                        { "n", "<leader>e",  actions.focus_files,               { desc = "Enfocar panel de archivos" } },
                        { "n", "<leader>b",  actions.toggle_files,              { desc = "Toggle panel de archivos" } },
                        { "n", "g<C-x>",     actions.cycle_layout,              { desc = "Cambiar layout" } },
                        { "n", "[x",         actions.prev_conflict,             { desc = "Conflicto anterior" } },
                        { "n", "]x",         actions.next_conflict,             { desc = "Siguiente conflicto" } },
                        { "n", "<leader>co", actions.conflict_choose("ours"),   { desc = "Elegir OURS" } },
                        { "n", "<leader>ct", actions.conflict_choose("theirs"), { desc = "Elegir THEIRS" } },
                        { "n", "<leader>cb", actions.conflict_choose("base"),   { desc = "Elegir BASE" } },
                        { "n", "<leader>ca", actions.conflict_choose("all"),    { desc = "Elegir TODOS" } },
                        { "n", "dx",         actions.conflict_choose("none"),   { desc = "Eliminar conflicto" } },
                    },
                    file_panel = {
                        { "n", "j",             actions.next_entry,           { desc = "Siguiente entrada" } },
                        { "n", "<down>",        actions.next_entry,           { desc = "Siguiente entrada" } },
                        { "n", "k",             actions.prev_entry,           { desc = "Entrada anterior" } },
                        { "n", "<up>",          actions.prev_entry,           { desc = "Entrada anterior" } },
                        { "n", "<cr>",          actions.select_entry,         { desc = "Abrir diff" } },
                        { "n", "o",             actions.select_entry,         { desc = "Abrir diff" } },
                        { "n", "<2-LeftMouse>", actions.select_entry,         { desc = "Abrir diff" } },
                        { "n", "-",             actions.toggle_stage_entry,   { desc = "Stage/unstage" } },
                        { "n", "s",             actions.toggle_stage_entry,   { desc = "Stage/unstage" } },
                        { "n", "S",             actions.stage_all,            { desc = "Stage todo" } },
                        { "n", "U",             actions.unstage_all,          { desc = "Unstage todo" } },
                        { "n", "X",             actions.restore_entry,        { desc = "Restaurar archivo" } },
                        { "n", "L",             actions.open_commit_log,      { desc = "Abrir log" } },
                        { "n", "R",             actions.refresh_files,        { desc = "Refrescar" } },
                        { "n", "<tab>",         actions.select_next_entry,    { desc = "Siguiente entrada" } },
                        { "n", "<s-tab>",       actions.select_prev_entry,    { desc = "Entrada anterior" } },
                        { "n", "gf",            actions.goto_file,            { desc = "Abrir archivo" } },
                        { "n", "<C-w><C-f>",    actions.goto_file_split,      { desc = "Abrir en split" } },
                        { "n", "<C-w>gf",       actions.goto_file_tab,        { desc = "Abrir en tab" } },
                        { "n", "i",             actions.listing_style,        { desc = "Toggle tree/list" } },
                        { "n", "f",             actions.toggle_flatten_dirs,  { desc = "Aplanar dirs" } },
                        { "n", "<leader>e",     actions.focus_files,          { desc = "Enfocar archivos" } },
                        { "n", "<leader>b",     actions.toggle_files,         { desc = "Toggle panel" } },
                        { "n", "g<C-x>",        actions.cycle_layout,         { desc = "Cambiar layout" } },
                        { "n", "[x",            actions.prev_conflict,        { desc = "Conflicto anterior" } },
                        { "n", "]x",            actions.next_conflict,        { desc = "Siguiente conflicto" } },
                    },
                    file_history_panel = {
                        { "n", "g!",            actions.options,              { desc = "Opciones" } },
                        { "n", "<C-A-d>",       actions.open_in_diffview,     { desc = "Abrir en diffview" } },
                        { "n", "y",             actions.copy_hash,            { desc = "Copiar hash" } },
                        { "n", "L",             actions.open_commit_log,      { desc = "Abrir log" } },
                        { "n", "zR",            actions.open_all_folds,       { desc = "Abrir folds" } },
                        { "n", "zM",            actions.close_all_folds,      { desc = "Cerrar folds" } },
                        { "n", "j",             actions.next_entry,           { desc = "Siguiente" } },
                        { "n", "<down>",        actions.next_entry,           { desc = "Siguiente" } },
                        { "n", "k",             actions.prev_entry,           { desc = "Anterior" } },
                        { "n", "<up>",          actions.prev_entry,           { desc = "Anterior" } },
                        { "n", "<cr>",          actions.select_entry,         { desc = "Abrir diff" } },
                        { "n", "o",             actions.select_entry,         { desc = "Abrir diff" } },
                        { "n", "<2-LeftMouse>", actions.select_entry,         { desc = "Abrir diff" } },
                        { "n", "<tab>",         actions.select_next_entry,    { desc = "Siguiente" } },
                        { "n", "<s-tab>",       actions.select_prev_entry,    { desc = "Anterior" } },
                        { "n", "gf",            actions.goto_file,            { desc = "Abrir archivo" } },
                        { "n", "<C-w><C-f>",    actions.goto_file_split,      { desc = "Abrir en split" } },
                        { "n", "<C-w>gf",       actions.goto_file_tab,        { desc = "Abrir en tab" } },
                        { "n", "<leader>e",     actions.focus_files,          { desc = "Enfocar archivos" } },
                        { "n", "<leader>b",     actions.toggle_files,         { desc = "Toggle panel" } },
                        { "n", "g<C-x>",        actions.cycle_layout,         { desc = "Cambiar layout" } },
                    },
                    option_panel = {
                        { "n", "<tab>", actions.select_entry,         { desc = "Cambiar opción" } },
                        { "n", "q",     actions.close,                { desc = "Cerrar" } },
                    },
                },
            })

            -- Atajos globales para diffview
            vim.keymap.set("n", "<leader>gdo", ":DiffviewOpen<CR>", { desc = "Git Diff Open", silent = true })
            vim.keymap.set("n", "<leader>gdc", ":DiffviewClose<CR>", { desc = "Git Diff Close", silent = true })
            vim.keymap.set("n", "<leader>gdh", ":DiffviewFileHistory<CR>", { desc = "Git File History", silent = true })
            vim.keymap.set("n", "<leader>gdf", ":DiffviewFileHistory %<CR>", { desc = "Git Current File History", silent = true })
            vim.keymap.set("v", "<leader>gdh", ":'<,'>DiffviewFileHistory<CR>", { desc = "Git Lines History", silent = true })
            vim.keymap.set("n", "<leader>gdt", ":DiffviewToggleFiles<CR>", { desc = "Git Diff Toggle Files", silent = true })
            vim.keymap.set("n", "<leader>gdr", ":DiffviewRefresh<CR>", { desc = "Git Diff Refresh", silent = true })
        end,
    }
}
