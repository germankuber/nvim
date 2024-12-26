local M = {}

function M.load_toml_file(file_path)
    local toml = require("toml-lua.toml") -- Adjust this require statement if needed

    local file = io.open(file_path, "r")
    if not file then
        return nil, "Could not open file: " .. file_path
    end

    local content = file:read("*all")
    file:close()

    local data, err = toml.parse(content)
    if err then
        return nil, "Error parsing TOML: " .. err
    end

    return data, nil
end

return M
