return {
    -- {
    --     "brenton-leighton/multiple-cursors.nvim",
    --     version = "*", -- Use the latest tagged version
    --     opts = {
    --         pre_hook = function()
    --             vim.g.minipairs_disable = true
    --           end,
    --           post_hook = function()
    --             vim.g.minipairs_disable = false
    --           end,
    --     } -- This causes the plugin setup function to be called
    -- }
    {
      "smoka7/multicursors.nvim",
      event = "VeryLazy",
      dependencies = {
          'nvimtools/hydra.nvim',
      },
      opts = {
        updatetime = 5
      },
      cmd = { 'MCstart', 'MCvisual', 'MCclear', 'MCpattern', 'MCvisualPattern', 'MCunderCursor' },
      config = function()
        require("multicursors").setup({
          updatetime = 5
        })
      end
      
  }
}
