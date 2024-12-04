return {
    {
        "kevinhwang91/nvim-ufo",
        lazy = false,
        keymaps = false,
        dependencies = {"kevinhwang91/promise-async"},
        config = function()
            -- Configuración básica
            vim.o.foldcolumn = "1"
            vim.o.foldlevel = 99
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true

            -- Configura los símbolos de plegado
            require("ufo").setup {
                fold_virt_text_handler = function(virtText, lnum, endLnum,
                                                  width, truncate)
                    local newVirtText = {}
                    local totalLines = vim.api.nvim_buf_line_count(0) -- Get total lines in the file
                    local foldedLines = endLnum - lnum
                    local percentage = (foldedLines / totalLines) * 100 -- Calculate percentage
                    local suffix = (" \u{ec0e} %d lines (%.1f%%) "):format(
                                       foldedLines, percentage) -- Add percentage to the suffix
                    local sufWidth = vim.fn.strdisplaywidth(suffix)
                    local targetWidth = width - sufWidth -- Calculate available width for dots
                    local curWidth = 0

                    for _, chunk in ipairs(virtText) do
                        local chunkText = chunk[1]
                        local chunkWidth = vim.fn.strdisplaywidth(chunkText)

                        if targetWidth > curWidth + chunkWidth then
                            table.insert(newVirtText, chunk) -- Add the chunk if it fits
                        else
                            chunkText = truncate(chunkText,
                                                 targetWidth - curWidth)
                            table.insert(newVirtText, {chunkText, chunk[2]}) -- Truncate and add the chunk
                            curWidth = curWidth +
                                           vim.fn.strdisplaywidth(chunkText)
                            break
                        end

                        curWidth = curWidth + chunkWidth
                    end

                    -- Dynamically fill the remaining space with dots
                    local fillChar = "."
                    local fillWidth = targetWidth - curWidth
                    if fillWidth > 0 then
                        table.insert(newVirtText, {
                            string.rep(fillChar, fillWidth), "Folded"
                        })
                    end

                    -- Add the suffix with the line count and percentage
                    table.insert(newVirtText, {suffix, "MoreMsg"})

                    return newVirtText
                end

            }

            -- Define los símbolos globales de plegado
            vim.fn.sign_define("FoldClosed", {text = "▸", texthl = "Folded"})
            vim.fn.sign_define("FoldOpen", {text = "▾", texthl = "Folded"})
            vim.fn.sign_define("FoldSeparator", {text = " ", texthl = "Folded"})
        end
    }
}
