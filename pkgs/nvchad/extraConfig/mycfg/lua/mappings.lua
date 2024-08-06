require "nvchad.mappings"

-- add yours here
-- Leader+/  comment

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jj", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

local preview = require('preview_line')

vim.api.nvim_set_keymap('n', '<Leader>gg', ':lua require("preview_line").preview_line()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'T', ':HopLineStartMW<CR>', {noremap = true, silent = true})
-- vim.api.nvim_set_keymap('n', '<Leader>q', ':HopLineStartMW<CR>', { noremap = true, silent = true })

vim.api.nvim_create_user_command('W', 'SudaWrite', {})
vim.api.nvim_create_user_command('R', 'SudaRead', {})

vim.api.nvim_create_user_command('wc', 'WhichKey', {})