local telescope = require("telescope")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local conf = require("telescope.config").values
local utils = require("telescope.utils")
local sorters = require("telescope.sorters")
local M = {}

M.show_jumps = function()
    local jumps, _ = vim.fn.getjumplist()
    local results = {}

    for _, j in ipairs(jumps) do
        if type(j) == "table" then
            for _, jump in ipairs(j) do
                -- Check if the buffer number is valid
                if vim.api.nvim_buf_is_valid(jump.bufnr) then
                    table.insert(
                        results,
                        {
                            filepath = vim.api.nvim_buf_get_name(jump.bufnr),
                            lnum = jump.lnum,
                            col = jump.col or 1
                        }
                    )
                else
                    -- Optionally handle invalid buffer IDs, e.g., skip or log
                    vim.api.nvim_notify(
                        string.format("Invalid buffer ID: %d. Skipping jump.", jump.bufnr),
                        vim.log.levels.WARN,
                        {}
                    )
                end
            end
        end
    end

    if vim.tbl_isempty(results) then
        vim.api.nvim_notify("There are no jumps available in the jump list.", vim.log.levels.WARN, {})
        return
    end

    results = vim.fn.reverse(results)
    local function save_keymaps()
        local saved_maps = {}
        for _, key in ipairs({"<C-o>", "<C-i>"}) do
            local map = vim.fn.maparg(key, "n", false, true)
            if map and map.lhs then
                saved_maps[key] = map
            end
            vim.api.nvim_set_keymap("n", key, "<Nop>", {noremap = true, silent = true})
        end
        return saved_maps
    end

    -- Restore saved keymaps
    local function restore_keymaps(saved_maps)
        for key, map in pairs(saved_maps) do
            vim.api.nvim_set_keymap("n", key, map.rhs or map.callback, {noremap = map.noremap, silent = map.silent})
        end
    end

    local saved_maps = save_keymaps()

    pickers.new(
        {},
        {
            prompt_title = "Jump List",
            finder = finders.new_table {
                results = results,
                entry_maker = function(entry)
                    return {
                        value = entry,
                        display = string.format("%s:%d:%d", entry.filepath, entry.lnum, entry.col),
                        ordinal = entry.filepath,
                        filepath = entry.filepath,
                        lnum = entry.lnum,
                        col = entry.col
                    }
                end
            },
            sorter = sorters.get_generic_fuzzy_sorter(),
            previewer = previewers.new_buffer_previewer {
                define_preview = function(self, entry, status)
                    local filepath = entry.filepath
                    if not filepath then
                        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, {"No file path available"})
                        return
                    end
                    local ok, content = pcall(vim.fn.readfile, filepath)
                    if ok and #content > 0 then
                        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, content)
                        local filetype = vim.filetype.match({filename = entry.filepath})
                        if not filetype then
                            filetype = vim.filetype.match({buf = self.state.bufnr})
                        end
                        vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", filetype)
                    end
                    vim.schedule(
                        function()
                            local line = entry.lnum
                            local start_column = entry.col

                            local buf_content = vim.api.nvim_buf_get_lines(self.state.bufnr, line - 1, line, false)
                            local end_column = #buf_content[1]
                            vim.api.nvim_win_call(
                                status.preview_win,
                                function()
                                    vim.api.nvim_win_set_cursor(status.preview_win, {line, start_column})
                                    vim.cmd("normal! zz")
                                    vim.cmd("stopinsert")
                                end
                            )
                            vim.api.nvim_buf_add_highlight(
                                self.state.bufnr,
                                -1,
                                "Search",
                                line - 1,
                                start_column - 1,
                                end_column
                            )
                        end
                    )
                end
            }
        }
    ):find()

    -- Restore keymaps after Telescope closes
    vim.schedule(
        function()
            restore_keymaps(saved_maps)
        end
    )
end



function M.setup()
    -- vim.api.nvim_create_autocmd("BufUnload", {
    --     pattern = "*",  -- Match all buffers
    --     callback = function()
    --         if vim.bo.filetype == "dashboard" then
    --             vim.cmd("clearjumps")
    --         end
    --     end,
    -- })
    vim.keymap.set("n", "H", "<C-o>", {noremap = true, silent = true})
    vim.keymap.set("n", "L", "<C-i>", {noremap = true, silent = true})
    vim.api.nvim_create_user_command("JumplistTelescope", M.show_jumps, {})
end

return M
