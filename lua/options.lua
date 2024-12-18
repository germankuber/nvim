
local opt = vim.opt

opt.relativenumber = true
vim.o.cursorline = true
opt.number = true

opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
vim.o.smartindent = true
opt.wrap = false

opt.ignorecase = true
opt.smartcase = true

vim.o.lazyredraw = false

vim.opt.cursorlineopt = "line"
vim.o.cursorcolumn = true

opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

opt.backspace = "indent,eol,start"

opt.clipboard:append("unnamedplus")

opt.splitright = true
opt.splitbelow = true

opt.swapfile = false

vim.opt.guifont = "FiraCode Nerd Font:h12"
vim.opt.updatetime = 150

vim.o.scrolloff = 12

-- vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.timeout = true
vim.o.timeoutlen = 50

vim.opt.foldcolumn = "0"
