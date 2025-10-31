local M = {}

-- Función para buscar archivos .csproj desde el directorio actual hacia arriba
local function find_csproj()
    local current_file = vim.fn.expand('%:p')
    local current_dir = vim.fn.fnamemodify(current_file, ':h')

    -- Buscar hacia arriba hasta encontrar un .csproj
    while current_dir ~= '/' do
        local csproj_files = vim.fn.glob(current_dir .. '/*.csproj', false, true)
        if #csproj_files > 0 then
            return csproj_files[1]
        end
        current_dir = vim.fn.fnamemodify(current_dir, ':h')
    end

    return nil
end

-- Función para encontrar la versión más alta de .NET en el directorio bin/Debug
local function find_highest_dotnet_version(bin_debug_path)
    if vim.fn.isdirectory(bin_debug_path) == 0 then
        return nil
    end

    local versions = vim.fn.glob(bin_debug_path .. '/*', false, true)
    local highest_version = nil

    for _, version_path in ipairs(versions) do
        if vim.fn.isdirectory(version_path) == 1 then
            local version_name = vim.fn.fnamemodify(version_path, ':t')
            if version_name:match('^net%d') then
                if not highest_version or version_name > highest_version then
                    highest_version = version_name
                end
            end
        end
    end

    return highest_version
end

-- Función principal para detectar automáticamente el DLL
function M.get_dll_path()
    local csproj = find_csproj()

    if not csproj then
        vim.notify("No se encontró archivo .csproj en el árbol del proyecto", vim.log.levels.ERROR)
        return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
    end

    local project_dir = vim.fn.fnamemodify(csproj, ':h')
    local project_name = vim.fn.fnamemodify(csproj, ':t:r')
    local bin_debug_path = project_dir .. '/bin/Debug'

    local highest_version = find_highest_dotnet_version(bin_debug_path)

    if not highest_version then
        vim.notify("No se encontró versión de .NET en " .. bin_debug_path, vim.log.levels.WARN)
        return vim.fn.input('Path to dll: ', bin_debug_path .. '/', 'file')
    end

    local dll_path = bin_debug_path .. '/' .. highest_version .. '/' .. project_name .. '.dll'

    if vim.fn.filereadable(dll_path) == 1 then
        vim.notify("DLL encontrado: " .. dll_path, vim.log.levels.INFO)
        return dll_path
    else
        vim.notify("DLL no encontrado en: " .. dll_path, vim.log.levels.WARN)
        return vim.fn.input('Path to dll: ', dll_path, 'file')
    end
end

return M
