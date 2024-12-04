local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
    s(
        "if",
        fmt(
            [[
            if {} {{
                {}
            }}
            ]],
            {
                i(1, "Condition"),
                i(2, "// body")
            }
        )
    ),
    s(
        "ifel",
        fmt(
            [[
        if {} {{
            {}
        }} else {{
            {}
        }}
        ]],
            {
                i(1, "condition"), -- First editable field for the condition
                i(2, "// if body"), -- Second editable field for the if body
                i(3, "// else body") -- Third editable field for the else body
            }
        )
    ),
    s(
        "struct",
        fmt(
            [[
        #[derive(Debug, Clone, Copy, PartialEq)]
        struct {} {{
            {}
        }}
        ]],
            {
                i(1, "StructName"), -- First editable field for the struct name
                i(2, "field: Type,") -- Second editable field for the struct fields (editable as a list)
            }
        )
    )
}
