vim.api.nvim_create_user_command("UfoFoldPreview", function()
    -- Get the window ID of the preview window
    local winid = require('ufo').peekFoldedLinesUnderCursor()
    if winid then
        -- Move the cursor to the preview window
        vim.api.nvim_set_current_win(winid)

        -- Set a buffer-local mapping for 'Esc' to close the window
        vim.api.nvim_buf_set_keymap(0, 'n', '<Esc>', ':close<CR>',
                                    {noremap = true, silent = true})

        -- Set an autocmd to remove the mapping when the window is closed
        vim.api.nvim_create_autocmd('WinClosed', {
            buffer = vim.api.nvim_get_current_buf(), -- Apply to the current buffer
            once = true, -- Remove autocmd after execution
            callback = function()
                -- Clean up the 'Esc' mapping for this buffer
                vim.api.nvim_buf_del_keymap(0, 'n', '<Esc>')
            end
        })
    end
end, {})
