require "config.general"
require "mappings"
require "options"

require('config.sound')
require('plugins.run_with_alarm') 


-- vim.api.nvim_create_autocmd("User", {
--     pattern = "*",
--     callback = function(args)
--         print("User Event Triggered:", args.event, args.match)
--     end,
-- })