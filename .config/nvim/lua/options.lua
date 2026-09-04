require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

-- C/C++ 使用 4 空格缩进（覆盖 NvChad 全局的 2 空格）。
-- .h 默认按 cpp 识别，因此 .cpp/.hpp/.cc/.h 等都在此范围。
-- 若项目里有 .editorconfig，其 indent_size 会在之后应用并覆盖这里（项目配置优先）。
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "cuda" },
  callback = function()
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.softtabstop = 4
    vim.bo.expandtab = true
  end,
})
