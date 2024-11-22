return {
  {
    "Isrothy/neominimap.nvim",
    version = "v3.*.*",
    enabled = true,
    keymaps = false,
    lazy = false, -- NOTE: NO NEED to Lazy load
    init = function()
      vim.opt.wrap = false
      vim.opt.sidescrolloff = 36 -- Set a large value
      ---@type Neominimap.UserConfig
      vim.g.neominimap = {
        auto_enable = true,
      }
    end,
  },
}
