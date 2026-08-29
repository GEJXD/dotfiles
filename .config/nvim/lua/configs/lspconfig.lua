require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "clangd" }
vim.lsp.enable(servers)

-- clangd：与 VS Code 的 clangd.arguments 保持一致（针对 LLVM 这类巨型 C++ 仓库优化，
-- 16 核 / 31G 内存）。参数逐条对应 settings.json，详见那里的注释
vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",             -- 后台索引全仓库（跳转定义/查找引用/重命名的基础）
    "-j=8",                           -- 工作线程数降到 8，留 CPU/内存余量
    -- "--compile-commands-dir=/home/hsin/repo/LLVM/build", -- 按需取消注释改成实际路径
    "--pch-storage=disk",
    "--query-driver=/usr/bin/clang++",
    "--all-scopes-completion",
    "--completion-style=detailed",
    "--header-insertion=iwyu",
    "--limit-results=50",
  },
  -- 对应 VS Code 的 "clangd.runLinter": "none"（关掉每次编辑触发的 lint）
  diagnostics = { enable = false },
  root_dir = function(buf)
    local fname = vim.api.nvim_buf_get_name(buf)
    return vim.fs.root(fname, "compile_commands.json")
      or vim.fs.root(fname, ".git")
      or vim.fn.fnamemodify(fname, ":p:h")
  end,
})

-- read :h vim.lsp.config for changing options of lsp servers
