return {
    {
        "b0o/SchemaStore.nvim",
        lazy = true, -- Cargar solo cuando sea necesario
        config = function()
            -- Configuración adicional del plugin
            require("schemastore").setup({
                settings = {
                    json = {
                        schemas = require('schemastore').json.schemas(),
                        validate = {enable = true}
                    }
                }
            })
        end
    }
}
