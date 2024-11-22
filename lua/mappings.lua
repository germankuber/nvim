require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Nvim DAP
map("n", "<Leader>dl", "<cmd>lua require'dap'.step_into()<CR>", { desc = "Debugger step into" })
map("n", "<Leader>dj", "<cmd>lua require'dap'.step_over()<CR>", { desc = "Debugger step over" })
map("n", "<Leader>dk", "<cmd>lua require'dap'.step_out()<CR>", { desc = "Debugger step out" })
map("n", "<Leader>dc", "<cmd>lua require'dap'.continue()<CR>", { desc = "Debugger continue" })
map("n", "<Leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", { desc = "Debugger toggle breakpoint" })
map(
  "n",
  "<Leader>dd",
  "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
  { desc = "Debugger set conditional breakpoint" }
)
map("n", "<Leader>de", "<cmd>lua require'dap'.terminate()<CR>", { desc = "Debugger reset" })
map("n", "<Leader>dr", "<cmd>lua require'dap'.run_last()<CR>", { desc = "Debugger run last" })

-- rustaceanvim
map("n", "<Leader>dt", "<cmd>lua vim.cmd('RustLsp testables')<CR>", { desc = "Debugger testables" })
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
map(
  "n",
  "<Leader>gd",
  "<cmd>lua vim.lsp.buf.definition()<CR>",
  { desc = "Go to definition", noremap = true, silent = true }
)
map("n", "<Leader>gh", "<cmd>lua vim.lsp.buf.hover()<CR>", { desc = "Hover actions", noremap = true, silent = true })
map(
  "n",
  "<Leader>gi",
  "<cmd>lua vim.lsp.buf.implementation()<CR>",
  { desc = "Go to implementation", noremap = true, silent = true }
)
map(
  "n",
  "<Leader>gs",
  "<cmd>lua vim.lsp.buf.signature_help()<CR>",
  { desc = "Signature", noremap = true, silent = true }
)
map(
  "n",
  "<Leader>gt",
  "<cmd>lua vim.lsp.buf.type_definition()<CR>",
  { desc = "Go to type definition", noremap = true, silent = true }
)
map(
  "n",
  "<Leader>gr",
  "<cmd>lua vim.lsp.buf.references()<CR>",
  { desc = "Find references", noremap = true, silent = true }
)

-- REFACTORING G

map("n", "<leader>rn", "<cmd>vim.lsp.buf.rename()<CR>", { desc = "LSP Rename" })
map("n", "<leader>ra", "<cmd>vim.lsp.buf.code_action()<CR>", { desc = "Code actions" })
map("n", "<leader>rg", "<cmd>vim.lsp.buf.code_action_group()<CR>", { desc = "Code actions group" })

vim.keymap.del("n", "<Leader>th")
vim.keymap.del("n", "<Leader>pt")
vim.keymap.del("n", "<Leader>ma")
-- vim.keymap.set(
--   "n",
--   "<Leader>rn",
--   "<cmd>lua vim.lsp.buf.rename()<CR>",
--   { desc = "LSP Rename", noremap = true, silent = true }
-- )
