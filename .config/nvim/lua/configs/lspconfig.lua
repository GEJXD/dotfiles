require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "clangd" }

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
  -- Neovim 0.11+ 的 vim.lsp.config 要求 root_dir 函数必须调用 on_dir 回调，
  -- 直接 return 是无效的（会被忽略，导致 LSP 永远不启动）
  root_dir = function(buf, on_dir)
    local fname = vim.api.nvim_buf_get_name(buf)
    on_dir(
      vim.fs.root(fname, "compile_commands.json")
        or vim.fs.root(fname, ".git")
        or vim.fn.fnamemodify(fname, ":p:h")
    )
  end,
})

-- 注意顺序：enable 必须放在 vim.lsp.config 覆盖之后。
-- enable() 会立即对已打开的 buffer 尝试 attach（doautoall），
-- 若放在前面，第一个文件会用 lspconfig 默认配置启动（下面的 cmd/root_dir 全不生效）
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
