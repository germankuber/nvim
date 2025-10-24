return {
    {
        "nvimdev/dashboard-nvim",
        event = "VimEnter",
        lazy = false,
        config = function()
            -- Definir colores personalizados para el dashboard
            vim.api.nvim_set_hl(0, "DashboardHeader", { fg = "#89ddff", bold = true })
            vim.api.nvim_set_hl(0, "DashboardCenter", { fg = "#c3e88d" })
            vim.api.nvim_set_hl(0, "DashboardShortCut", { fg = "#f78c6c", bold = true })
            vim.api.nvim_set_hl(0, "DashboardFooter", { fg = "#82aaff", italic = true })
            vim.api.nvim_set_hl(0, "DashboardDesc", { fg = "#c792ea" })
            vim.api.nvim_set_hl(0, "DashboardKey", { fg = "#ffcb6b", bold = true })
            vim.api.nvim_set_hl(0, "DashboardIcon", { fg = "#f78c6c" })

            -- ============================================
            -- ELIGE TU ASCII ART FAVORITO (descomenta uno)
            -- ============================================

            -- OPCIÓN 1: Logo Neovim Moderno con Diseño
            local header1 = {
                "",
                "",
                "                                                       ",
                "                                                       ",
                "                                                       ",
                " ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
                " ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
                " ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
                " ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
                " ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
                " ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
                "                                                       ",
                "        [ Code with Passion, Deploy with Confidence ] ",
                "                                                       ",
                "",
            }

            -- OPCIÓN 2: Terminal/Código Theme
            local header2 = {
                "",
                "",
                "           ▄ ▄                   ",
                "       ▄   ▄▄▄     ▄ ▄▄▄ ▄ ▄     ",
                "       █ ▄ █▄█ ▄▄▄ █ █▄█ █ █     ",
                "    ▄▄ █▄█▄▄▄█ █▄█▄█▄▄█▄▄█ █     ",
                "  ▄ █▄▄█ ▄ ▄▄ ▄█ ▄▄▄▄▄▄▄▄▄▄▄▄▄▄  ",
                "  █▄▄▄▄ ▄▄▄ █ ▄ ▄▄▄ ▄ ▄▄▄ ▄ ▄ █ ▄",
                "▄ █ █▄█ █▄█ █ █ █▄█ █ █▄█ ▄▄▄ █ █",
                "█▄█ ▄ █▄▄█▄▄█ █ ▄▄█ █ ▄ █ █▄█▄█ █",
                "    █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█ █▄█▄▄▄█    ",
                "",
                "    [ Welcome to Your Code Space ]",
                "",
                "",
            }

            -- OPCIÓN 3: Neovim 3D Style
            local header3 = {
                "",
                "",
                "                                                     ",
                "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
                "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
                "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
                "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
                "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
                "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
                "                                                     ",
                "              ⚡ Blazing Fast Editor ⚡              ",
                "                                                     ",
                "",
            }

            -- OPCIÓN 4: ASCII Art Artístico (Ondas)
            local header4 = {
                "",
                "",
                "                                   ",
                "   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆          ",
                "    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       ",
                "          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄     ",
                "           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄    ",
                "          ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   ",
                "   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄  ",
                "  ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄   ",
                " ⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄  ",
                " ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄ ",
                "      ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆     ",
                "       ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃     ",
                "                                   ",
                "            [ Embrace the Vim ]            ",
                "",
            }

            -- OPCIÓN 5: Minimal Geometric
            local header5 = {
                "",
                "",
                "                                                       ",
                "    ███▄    █ ▓█████  ▒█████   ██▒   █▓ ██▓ ███▄ ▄███▓",
                "    ██ ▀█   █ ▓█   ▀ ▒██▒  ██▒▓██░   █▒▓██▒▓██▒▀█▀ ██▒",
                "   ▓██  ▀█ ██▒▒███   ▒██░  ██▒ ▓██  █▒░▒██▒▓██    ▓██░",
                "   ▓██▒  ▐▌██▒▒▓█  ▄ ▒██   ██░  ▒██ █░░░██░▒██    ▒██ ",
                "   ▒██░   ▓██░░▒████▒░ ████▓▒░   ▒▀█░  ░██░▒██▒   ░██▒",
                "   ░ ▒░   ▒ ▒ ░░ ▒░ ░░ ▒░▒░▒░    ░ ▐░  ░▓  ░ ▒░   ░  ░",
                "   ░ ░░   ░ ▒░ ░ ░  ░  ░ ▒ ▒░    ░ ░░   ▒ ░░  ░      ░",
                "      ░   ░ ░    ░   ░ ░ ░ ▒       ░░   ▒ ░░      ░   ",
                "            ░    ░  ░    ░ ░        ░   ░         ░   ",
                "                                   ░                   ",
                "                 [ The Hyperextensible Editor ]                ",
                "                                                       ",
                "",
            }

            -- OPCIÓN 6: Retro Computer
            local header6 = {
                "",
                "",
                "          ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄          ",
                "        ▄▀░░░░░░░░░░░░░░░░░░░░░░░▀▄        ",
                "      ▄▀░░░░░░░░░░░░░░░░░░░░░░░░░░░▀▄      ",
                "     █░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█     ",
                "    █░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█    ",
                "   █░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█   ",
                "  █░░░░░▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄░░░░░░░░█  ",
                " █░░░░░█                          █░░░░░░█ ",
                " █░░░░░█     N E O V I M          █░░░░░░█ ",
                " █░░░░░█                          █░░░░░░█ ",
                " █░░░░░█   Ready to Code...  >_  █░░░░░░█ ",
                " █░░░░░█                          █░░░░░░█ ",
                "  █░░░░░▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀░░░░░░░█  ",
                "   █░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█   ",
                "    █░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░█    ",
                "     ▀▄░░░░░░░░░░░░░░░░░░░░░░░░░░░░▄▀     ",
                "       ▀▄░░░░░░░░░░░░░░░░░░░░░░░▄▀       ",
                "         ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀         ",
                "",
            }

            -- 🎯 SELECCIONA TU HEADER AQUÍ (cambia el número)
            local selected_header = header4  -- <-- Cambia esto: header1, header2, header3, header4, header5 o header6

            require("dashboard").setup {
                theme = "doom",
                config = {
                    header = selected_header,
                    center = {
                        {
                            icon = "  ",
                            icon_hl = "DashboardIcon",
                            desc = "Find File                   ",
                            desc_hl = "DashboardDesc",
                            key = "f",
                            key_hl = "DashboardKey",
                            key_format = " [%s]",
                            action = "Telescope find_files"
                        },
                        {
                            icon = "  ",
                            icon_hl = "DashboardIcon",
                            desc = "Recent Files                ",
                            desc_hl = "DashboardDesc",
                            key = "r",
                            key_hl = "DashboardKey",
                            key_format = " [%s]",
                            action = "Telescope oldfiles"
                        },
                        {
                            icon = "  ",
                            icon_hl = "DashboardIcon",
                            desc = "Find Text                   ",
                            desc_hl = "DashboardDesc",
                            key = "g",
                            key_hl = "DashboardKey",
                            key_format = " [%s]",
                            action = "Telescope live_grep"
                        },
                        {
                            icon = "  ",
                            icon_hl = "DashboardIcon",
                            desc = "File Explorer               ",
                            desc_hl = "DashboardDesc",
                            key = "e",
                            key_hl = "DashboardKey",
                            key_format = " [%s]",
                            action = "NvimTreeToggle"
                        },
                        {
                            icon = "  ",
                            icon_hl = "DashboardIcon",
                            desc = "Restore Session             ",
                            desc_hl = "DashboardDesc",
                            key = "s",
                            key_hl = "DashboardKey",
                            key_format = " [%s]",
                            action = "lua require('persistence').load()"
                        },
                        {
                            icon = "  ",
                            icon_hl = "DashboardIcon",
                            desc = "Configuration               ",
                            desc_hl = "DashboardDesc",
                            key = "c",
                            key_hl = "DashboardKey",
                            key_format = " [%s]",
                            action = "edit ~/.config/nvim/init.lua"
                        },
                        {
                            icon = "  ",
                            icon_hl = "DashboardIcon",
                            desc = "Update Plugins              ",
                            desc_hl = "DashboardDesc",
                            key = "u",
                            key_hl = "DashboardKey",
                            key_format = " [%s]",
                            action = "Lazy update"
                        },
                        {
                            icon = "  ",
                            icon_hl = "DashboardIcon",
                            desc = "Quit Neovim                 ",
                            desc_hl = "DashboardDesc",
                            key = "q",
                            key_hl = "DashboardKey",
                            key_format = " [%s]",
                            action = "quit"
                        },
                    },
                    footer = function()
                        local stats = require("lazy").stats()
                        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)

                        -- Obtener hora actual
                        local hour = tonumber(vim.fn.strftime("%H"))
                        local greeting = ""

                        if hour < 12 then
                            greeting = "Good Morning"
                        elseif hour < 18 then
                            greeting = "Good Afternoon"
                        else
                            greeting = "Good Evening"
                        end

                        return {
                            "",
                            "",
                            "⚡ " .. stats.loaded .. "/" .. stats.count .. " plugins loaded in " .. ms .. "ms",
                            "",
                            greeting .. ", " .. os.getenv("USER") .. "! " .. vim.fn.strftime("%A, %B %d, %Y"),
                            "",
                            "✨ Make something amazing today ✨",
                        }
                    end,
                },
                hide = {
                    statusline = false,
                    tabline = false,
                    winbar = false,
                },
            }

            -- Autocomandos para mejorar la experiencia visual
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "dashboard",
                callback = function()
                    -- Deshabilitar elementos visuales innecesarios
                    vim.opt_local.number = false
                    vim.opt_local.relativenumber = false
                    vim.opt_local.cursorline = false
                    vim.opt_local.colorcolumn = "0"
                    vim.opt_local.fillchars = "eob: "  -- Ocultar ~ en líneas vacías

                    -- Centrar verticalmente el dashboard
                    vim.opt_local.scrolloff = 999
                end,
            })

            -- Atajo para volver al dashboard
            vim.keymap.set("n", "<leader>D", ":Dashboard<CR>", { desc = "Open Dashboard", silent = true })
        end,
        dependencies = { "nvim-tree/nvim-web-devicons" }
    }
}
