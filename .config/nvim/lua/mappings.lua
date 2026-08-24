require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- toggle file tree (nvim-tree)
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "toggle nvimtree" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
