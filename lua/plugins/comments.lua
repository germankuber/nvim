return {
    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup({
                -- Desactiva los mapeos predeterminados
                toggler = nil,
                opleader = nil,
                mappings = false, -- Esta opción asegura que no se configuren mapeos predeterminados

                -- Otras configuraciones (puedes personalizarlas o dejarlas por defecto)
                padding = true, -- Añade un espacio entre el comentario y el texto
                sticky = true, -- Mantiene el cursor en su posición tras comentar
                pre_hook = nil, -- Puedes agregar un hook si usas treesitter u otras herramientas
                post_hook = nil -- Función que se ejecuta después de comentar
            })
        end,
        lazy = false -- Carga el plugin inmediatamente
    }, {
        "folke/todo-comments.nvim",
        lazy = false,
        dependencies = {
            "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim"
        },
        config = function() require("todo-comments").setup {} end
    }
}
