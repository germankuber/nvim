-- This module defines a command "OpenTransactionAddressDetail" that:
-- 1. Takes two base URLs from a setup function: transaction_detail_url and contract_detail_url.
-- 2. When the command is executed, it checks the word under the cursor.
--    - If it's a valid transaction hash (64 hex chars or 0x followed by 64 hex chars),
--      it opens transaction_detail_url + hash.
--    - If it's a valid contract address (40 hex chars or 0x followed by 40 hex chars),
--      it opens contract_detail_url + address.
-- 3. Opens that URL in the system's default web browser.

local M = {
    transaction_detail_url = nil,
    contract_detail_url = nil
}

-- Setup function to define the base URLs and register the command
function M.setup(opts)
    if not opts or type(opts.transaction_detail_url) ~= "string" or type(opts.contract_detail_url) ~= "string" then
        error("OpenTransactionAddressDetail setup requires valid 'transaction_detail_url' and 'contract_detail_url' strings.")
    end

    M.transaction_detail_url = opts.transaction_detail_url
    M.contract_detail_url = opts.contract_detail_url

    -- Register the command after the URLs are set
    vim.api.nvim_create_user_command("OpenTransactionAddressDetail", function()
        M.open_address_detail()
    end, {})
end

-- Check if the given string is a hex string of a certain length (with or without '0x')
local function is_hex_of_length(str, len)
    local hex_str = str
    if vim.startswith(str, "0x") or vim.startswith(str, "0X") then
        hex_str = str:sub(3)
    end
    return #hex_str == len and hex_str:match("^%x+$") ~= nil
end

-- Handler function that determines which URL to open
function M.open_address_detail()
    if not M.transaction_detail_url or not M.contract_detail_url then
        print("OpenTransactionAddressDetail: URLs not set. Please call setup first.")
        return
    end

    -- Get the word under the cursor
    local word = vim.fn.expand("<cword>")

    if word == "" then
        print("No word under the cursor.")
        return
    end

    -- Determine if the word is a transaction hash or a contract address
    -- Transaction hash: 64 hex chars (with or without 0x)
    -- Contract address: 40 hex chars (with or without 0x)

    local final_url = nil
    if is_hex_of_length(word, 64) then
        final_url = M.transaction_detail_url .. word
    elseif is_hex_of_length(word, 40) then
        final_url = M.contract_detail_url .. word
    else
        print("The word under the cursor is not a recognized transaction hash or contract address.")
        return
    end

    -- Determine the appropriate open command based on the OS
    local open_cmd = nil
    if vim.fn.has("mac") == 1 then
        open_cmd = {"open", final_url}
    elseif vim.fn.has("unix") == 1 then
        open_cmd = {"xdg-open", final_url}
    elseif vim.fn.has("win32") == 1 then
        open_cmd = {"cmd", "/c", "start", final_url}
    else
        print("Unsupported system: Cannot open URL automatically.")
        return
    end

    -- Start the job to open the URL asynchronously
    vim.fn.jobstart(open_cmd, { detach = true })
end

return M
