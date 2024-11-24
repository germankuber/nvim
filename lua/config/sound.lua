-- ~/.config/nvim/lua/plugins/run_with_alarm.lua
local M = {}
local Popup = require("nui.popup")

-- Define play_sound
local function play_sound()
    local sound_command = nil
    if vim.fn.has('macunix') == 1 then
        sound_command = "afplay /System/Library/Sounds/Ping.aiff"
    elseif vim.fn.has('unix') == 1 then
        sound_command = "paplay /usr/share/sounds/freedesktop/stereo/complete.oga"
    elseif vim.fn.has('win32') == 1 then
        sound_command = 'powershell -c "(New-Object Media.SoundPlayer \'C:\\Windows\\Media\\notify.wav\').PlaySync()"'
    end

    if sound_command then
        vim.fn.jobstart(sound_command, { detach = true })
    else
        vim.notify("Sound playback not supported on this system", vim.log.levels.WARN)
    end
end

-- Function to run command with alarm
function M.run_command_with_alarm(cmd)
    -- Create a new terminal popup
    local popup_terminal = Popup({
        enter = true,
        focusable = true,
        border = {
            style = "rounded",
            text = {
                top = " Command Terminal ",
                top_align = "center",
            },
        },
        position = "50%",
        size = {
            width = 140,
            height = 30,
        },
        win_options = {
            winblend = 10,
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
        },
    })

    -- Mount the popup
    popup_terminal:mount()
    vim.cmd("startinsert!")

    -- Open terminal inside the popup and execute the command
    local term_bufnr = popup_terminal.bufnr
    if term_bufnr and term_bufnr > 0 then
        vim.fn.termopen(cmd, {
            on_exit = function(_, exit_code)
                vim.schedule(function()
                    if exit_code == 0 then
                        play_sound()
                    else
                        vim.notify("Command exited with non-zero status: " .. exit_code, vim.log.levels.WARN)
                    end
                end)
            end,
        })

        -- Additional terminal configuration
        vim.api.nvim_buf_set_keymap(term_bufnr, "t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })
        popup_terminal:on("BufLeave", function()
            popup_terminal:unmount()
        end)
    else
        vim.notify("Failed to create terminal buffer", vim.log.levels.ERROR)
        popup_terminal:unmount()
    end
end

-- Create user command
vim.api.nvim_create_user_command('RunPopupWithAlarm', function(opts)
    M.run_command_with_alarm(opts.args)
end, { nargs = '+' })

return M
