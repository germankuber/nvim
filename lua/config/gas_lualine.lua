-- ~/.config/nvim/lua/config/gas_lualine.lua
local M = {}
local api_key = ""
local upper_threshold = 25
local lower_threshold = 15
local update_interval = 15 -- in seconds
local safe_gas = "-"
local propose_gas = "-"
local fast_gas = "-"
local timer = nil

local colors = {
    error = '#FF0000', -- red
    warning = '#FFA500', -- orange
    info = '#00FFFF', -- cyan
    normal = '#FFFFFF' -- white
}

local function fetch_gas_prices()
    local url = string.format(
                    "https://api.etherscan.io/api?module=gastracker&action=gasoracle&apikey=%s",
                    api_key)
    vim.fn.jobstart({"curl", "-s", url}, {
        stdout_buffered = true, -- Ensure output is buffered
        on_stdout = function(_, data)
            if data and #data > 0 then
                local result = table.concat(data, "\n")
                local json = vim.fn.json_decode(result)
                if json and json.status == "1" and json.result then
                    safe_gas = json.result.SafeGasPrice or "-"
                    propose_gas = json.result.ProposeGasPrice or "-"
                    fast_gas = json.result.FastGasPrice or "-"
                else
                    safe_gas = "-"
                    propose_gas = "-"
                    fast_gas = "-"
                end
            end
        end,
        on_stderr = function(_, data)
            -- Silencing any error output to avoid notifications
            if data and #data > 0 then
                -- Log silently or ignore
            end
        end,
        on_exit = function()
            vim.schedule(function() vim.cmd('redrawstatus') end)
        end
    })
end

local function start_timer()
    if not timer then
        timer = vim.loop.new_timer()
        timer:start(0, update_interval * 1000,
                    vim.schedule_wrap(fetch_gas_prices))
    end
end

M.gas_value = function()
    local num = tonumber(safe_gas)
    if num then
        return string.format("%.1f", num)
    else
        return "N/A"
    end
end

M.gas_color = function()
    local text = "🧪 " .. (safe_gas ~= "-" and safe_gas or "N/A")
    local color = colors.normal
    local gas = tonumber(safe_gas)
    if gas then
        if gas >= upper_threshold then
            color = colors.error
        elseif gas <= lower_threshold then
            color = colors.warning
        else
            color = colors.info
        end
    end
    return {fg = color, bg = '#1E1E2E'}
    -- return {fg = color}

end

M.show_gas_popup = function()
  -- Construct the notification message
  local message = string.format(
    "ETH Gas Prices:\nSafe Gas Price: %s\nPropose Gas Price: %s\nFast Gas Price: %s",
    M.gas_value(),
    (propose_gas ~= "-" and string.format("%.1f", propose_gas) or "N/A"),
    (fast_gas ~= "-" and string.format("%.1f", fast_gas) or "N/A")
  )

  -- Show the notification
  vim.notify(message, vim.log.levels.INFO, {
    title = "Gas Tracker",
    timeout = 3000, -- Notification timeout in milliseconds
  })
end

function M.setup(opts)
    opts = opts or {}
    api_key = opts.api_key or ""
    upper_threshold = opts.upper_threshold or 25
    lower_threshold = opts.lower_threshold or 15
    update_interval = opts.update_interval or 15

    fetch_gas_prices()
    start_timer()

    vim.api.nvim_create_user_command("ShowGasPrices", M.show_gas_popup, {})
end

return M
