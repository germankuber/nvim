local M = {}

function M.setup(opts)
    local codeFileType = opts.codeFileType or {}
    local mapping_file_path = opts.mapping_file_path

    local mappings = nil  -- Variable to store cached mappings

    local function resolve_filetypes(filetype)
        -- Check if the filetype is in the form __variable__
        if type(filetype) == "string" and filetype:match("^__(.+)__$") then
            -- Extract the variable name by removing the surrounding __
            local variable_name = filetype:match("^__(.+)__$")
            -- Return the resolved filetypes or fallback to the literal value
            if variable_name == "codeFileType" then
                return codeFileType
            else
                return { filetype }
            end
        elseif type(filetype) == "table" then
            -- If it's already a table, return it directly
            return filetype
        else
            -- If it's a single string, wrap it in a table and return
            return { filetype }
        end
    end

    -- Function to set key mappings
    local function set_keymap(mode, lhs, rhs, opts)
        vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- Function to safely remove key mappings
    local function remove_keymap(mode, lhs, bufnr)
        if vim.api.nvim_buf_is_valid(bufnr) then
            pcall(vim.keymap.del, mode, lhs, {buffer = bufnr})
        end
    end

    local function handle_user_event_mapping(command, base_lhs, mode, lhs, rhs, opts)
        vim.api.nvim_create_autocmd("User", {
            pattern = command.userEvent,
            callback = function()
                vim.schedule(function()
                    local bufnr = vim.api.nvim_get_current_buf()
                    local local_opts = vim.tbl_extend("force", opts, { buffer = bufnr })
                    set_keymap(mode, lhs, rhs, local_opts)

                    vim.api.nvim_create_autocmd({
                        "BufLeave", "BufWinLeave", "WinClosed", "BufWipeout"
                    }, {
                        buffer = bufnr,
                        once = true,
                        callback = function()
                            remove_keymap(mode, lhs, bufnr)
                        end
                    })
                end)
            end
        })
    end

    -- Function to handle filetype mappings
    local function handle_filetype_mapping(command, base_lhs, mode, lhs, rhs, opts)
        -- Resolve filetypes, including markers like __codeFileType__
        local filetypes = resolve_filetypes(command.filetype)
        for _, ft in ipairs(filetypes) do
            -- Create autocommands for each resolved filetype
            vim.api.nvim_create_autocmd("FileType", {
                pattern = ft,
                callback = function(args)
                    local bufnr = args.buf
                    local local_opts = vim.tbl_extend("force", opts, { buffer = bufnr })
                    -- Set the key mapping specific to this buffer
                    set_keymap(mode, lhs, rhs, local_opts)
                end,
            })
        end
    end

    -- Function to process individual commands
    local function process_command(command, base_lhs, parent_filetype,
                                   parent_userEvent)

        local command_filetype = command.filetype or parent_filetype
        local command_userEvent = command.userEvent or parent_userEvent
        local mode = command.mode or "n"
        local lhs = base_lhs .. (command.lhs or "")
        local rhs = command.rhs or ""
        local opts = {
            desc = command.desc,
            noremap = command.noremap ~= false,
            silent = command.silent ~= false
        }

        if command_userEvent then
            handle_user_event_mapping(command, base_lhs, mode, lhs, rhs, opts)
        elseif command_filetype then
            command.filetype = resolve_filetypes(command_filetype)
            handle_filetype_mapping(command, base_lhs, mode, lhs, rhs, opts)
        else
            set_keymap(mode, lhs, rhs, opts)
        end
    end

    -- Function to process a group of mappings
    local function apply_mappings(group, parent_lhs, parent_filetype,
                                  parent_userEvent)
        if not group or not group.commands then return end

        local base_lhs = (parent_lhs or "") .. (group.base_lhs or "")
        local group_filetype = group.filetype or parent_filetype
        local group_userEvent = group.userEvent or parent_userEvent

        if group.title and group.title ~= "" and group.base_lhs and group.base_lhs ~=
            "" then
            if not group_filetype and not group_userEvent then
                local mode = group.mode or "n"
                local lhs = base_lhs
                local rhs = "<Nop>"
                local opts = {desc = group.title, noremap = true, silent = true}
                set_keymap(mode, lhs, rhs, opts)
            else
                -- If group has filetype or userEvent, we need to handle it
                local dummy_command = {
                    mode = group.mode,
                    lhs = "",
                    rhs = "<Nop>",
                    desc = group.title,
                    filetype = group_filetype,
                    userEvent = group_userEvent,
                    noremap = true,
                    silent = true
                }
                process_command(dummy_command, base_lhs)
            end
        end

        for _, command in ipairs(group.commands) do
            if command.commands then
                apply_mappings(command, base_lhs, group_filetype, group_userEvent)
            else
                process_command(command, base_lhs, group_filetype, group_userEvent)
            end
        end
    end

    -- Function to load the JSON file and cache mappings
    local function load_mappings(mapping_file_path)
        if mappings then
            -- Mappings are already loaded
            return
        end

        local mappings_file = mapping_file_path
        local ok, content = pcall(vim.fn.readfile, mappings_file)
        if not ok then
            vim.notify("Error reading mappings file: " .. mappings_file,
                       vim.log.levels.ERROR)
            return
        end

        local json_content = table.concat(content, "\n")
        mappings = vim.fn.json_decode(json_content)
        if not mappings then
            vim.notify("Invalid JSON format in mappings file: " .. mappings_file,
                       vim.log.levels.ERROR)
            return
        end
    end

    -- Function to apply mappings
    local function apply_cached_mappings()
        if not mappings then
            return
        end

        for _, group in ipairs(mappings) do apply_mappings(group) end
    end

    -- Load mappings and apply them
    local function load_and_apply_mappings(mapping_file_path)
        load_mappings(mapping_file_path)
        apply_cached_mappings()
    end

    -- Now call the function with the mapping_file_path
    load_and_apply_mappings(mapping_file_path)
end

return M
