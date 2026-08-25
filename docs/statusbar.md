# 状态栏：damblocks / dam / FIFO

状态栏由 **damblocks**（纯 POSIX shell 的状态行生成器）提供，按合成器栈以两种方式消费：

| 栈            | 消费方式                 | 启动入口                                      |
|---------------|--------------------------|-----------------------------------------------|
| kwm           | kwm 内置 bar 直接读 FIFO | `.local/bin/damblocks --fifo`                 |
| river-classic | dam 渲染 stdin           | `damblocks \| dam`                            |
| sway（备用）  | swaybar 读 stdin         | `damblocks`（`sway/bar` 的 `status_command`） |

## 1. 角色分工

- **damblocks**：`.local/bin/damblocks`
  - 每个模块独立刷新间隔 / 信号，只在需要时更新。
  - 支持 stdin、fifo、xsetroot 三种输出；Wayland / Xorg / tty 通用。
  - 依赖 `ttf-nerd-fonts-symbols wireplumber brightnessctl coreutils sed grep awk curl cronie udev`。
  - 信号来源：个人脚本、cron（`.config/crontab.example`）、udev 规则（`etc/udev/rules.d/`）。

- **dam**：`.local/bin/dam-run` 中与 damblocks 通过管道组合，把文本渲染成 Wayland layer-shell 状态栏。

- **damblocks-mpdd**：`.local/bin/damblocks-mpdd`，MPD 可视化模块（独立进程）。

## 2. FIFO 机制（kwm 栈）

kwm 的 bar 配置在 `.config/kwm/config.zon` 中，`status` 部分读取 FIFO：

```text
${XDG_RUNTIME_DIR}/damblocks.fifo
```

关键点：

1. **启动前创建**：`startw` 与 `river/init` 都先调用 `.local/bin/prepare-damblocks-fifo`（存在即跳过，否则 `mkfifo`），避免合成器先于 FIFO 启动造成 bar 空白。
2. **写入者存活**：`damblocks --fifo` 启动时 `trap '' PIPE`，kwm 重建 bar / 短暂关闭 FIFO 时写入者不会因 SIGPIPE 退出，等 kwm 重新打开 FIFO 后继续写。
3. **防重复启动**：`.local/bin/dam-run` 用 `pgrep -f` 精确匹配进程命令行，且用 `flock`（`${XDG_RUNTIME_DIR}/dam-run.lock`）串行化切换，避免两个栈的状态栏进程同时存在。

## 3. `dam-run` 模式协调

```sh
dam-run river-classic   # damblocks | dam  + damblocks-mpdd
dam-run kwm             # prepare-fifo + damblocks --fifo + damblocks-mpdd
```

- `start_classic`：若 `dam` 或默认模式 damblocks 不在运行、或 FIFO 模式残留，则先清场再启动 `damblocks | dam`。
- `start_kwm`：先创建 FIFO；若 FIFO 模式未运行、或 `dam`/默认模式残留，则清场后启动 `damblocks --fifo`。
- 两者都确保 `damblocks-mpdd` 恰好一个实例。

## 4. 手动操作

```sh
# 查看当前状态栏进程
pgrep -a -f damblocks

# 杀掉并重启 kwm 栈状态栏
pkill -f 'damblocks --fifo'
dam-run kwm

# 刷新 damblocks（river-classic 绑定 Super+b）
pkill -x -SIGUSR1 dam

# 重建 FIFO（kwm 重启场景）
~/.local/bin/prepare-damblocks-fifo
```

## 5. 恢复流程验证

完整的恢复路径（kwm 栈）：

1. 删除 FIFO → 用 `prepare-damblocks-fifo` 重建。
2. 启动 kwm → 验证 kwm 已打开 FIFO 作为其 bar 读端。
3. 停止 kwm → 验证 `damblocks --fifo` 仍存活（未被 SIGPIPE 杀死）。
4. 重启 kwm → 验证状态内容恢复。

## 6. 相关配置

| 文件                                | 作用                                       |
|-------------------------------------|--------------------------------------------|
| `.local/bin/damblocks`              | 状态行生成器                               |
| `.local/bin/damblocks-mpdd`         | MPD 可视化模块                             |
| `.local/bin/dam-run`                | 栈模式协调入口                             |
| `.local/bin/prepare-damblocks-fifo` | FIFO 创建                                  |
| `.config/kwm/config.zon`            | kwm bar 配置（含 FIFO 路径）               |
| `.config/sway/bar`                  | swaybar 配置（`status_command damblocks`） |
| `etc/udev/rules.d/*`                | 模块信号触发                               |
| `.config/crontab.example`           | 定时刷新                                   |
