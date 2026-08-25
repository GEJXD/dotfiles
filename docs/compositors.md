# 合成器栈与启动流程

本机同时维护三套 Wayland 栈：**kwm（river 0.5，默认）**、**river-classic** 和 **sway（备用）**。此外还有 dwl 分支（仅启动脚本支持）。

## 1. 会话启动入口：`startw`

启动脚本：`.local/bin/startw`（默认参数 `kwm`，有 zsh/bash 补全）。

```sh
startw                  # 等价 startw kwm
startw kwm              # river 0.5 + kwm
startw river-classic    # river-classic
startw river            # 纯 river（无 WM）
startw sway             # sway
startw dwl              # dwl（X11 工具链）
```

启动前都会执行：

```sh
${HOME}/.local/bin/prepare-damblocks-fifo
```

确保状态栏 FIFO 在合成器读取 bar 配置之前就已存在（见 [statusbar.md](statusbar.md)）。

各分支通过 `exec ssh-agent <compositor>` 启动，保证会话内继承 SSH agent。

### kwm 分支

```sh
prepare-damblocks-fifo
exec ssh-agent river -c 'kwm'
```

`river` 以 `-c kwm` 启动，kwm 随后读取用户配置。kwm 的配置加载顺序：`~/.config/kwm/config.zon`（经 `fix-local-links.sh` 链接到仓库的 `.config/kwm/config.zon`）。

### river-classic 分支

```sh
prepare-damblocks-fifo
exec ssh-agent river-classic -c ${HOME}/.config/river-classic/init
```

`init` 依次 source：

1. `.local/bin/colors.sh` — 配色
2. `.config/river-classic/autostart` — 自启动程序
3. `.config/river-classic/bindings` — 按键
4. `.config/river-classic/modes` — 模式
5. `.config/river-classic/rules` — 窗口规则

随后设置键盘布局、输入、边框、tag 与布局（riverdeck 或 rivertile）。

## 2. 自启动内容

### river-classic autostart（`.config/river-classic/autostart`）

| 组件                                                  | 说明                                            |
|-------------------------------------------------------|-------------------------------------------------|
| `systemctl --user import-environment ...`             | 把 Wayland 会话变量导入 systemd 用户环境        |
| `systemctl --user restart xdg-desktop-portal.service` | 修复 Electron 文件选择器（portal 需要环境变量） |
| `dam-run river-classic`                               | 状态栏（damblocks \| dam）                      |
| `swaybg -i ~/.local/share/wallpaper`                  | 壁纸                                            |
| `foots`                                               | 重启由脚本决定的终端                            |
| `mbs-cron`                                            | 邮件同步                                        |
| `swayidle -w`                                         | 空闲守护（不存在才启动）                        |
| `kanshi`                                              | 显示器自动配置（不存在才启动）                  |
| `mpd`                                                 | 音乐守护                                        |
| `xwayland-satellite`                                  | X11 应用（QQ 等）的 X 服务                      |
| `wl-paste --watch cliphist store`                     | 剪贴板历史                                      |
| `dunst`                                               | 通知守护                                        |
| `wobd`                                                | 音量 OSD 守护                                   |
| `fcitx5 -d`                                           | 输入法                                          |

### kwm 启动命令（`.config/kwm/config.zon` 的 `startup_cmds`）

| 命令                                                  | 说明                       |
|-------------------------------------------------------|----------------------------|
| `systemctl --user import-environment ...`             | 导入会话环境               |
| `systemctl --user restart xdg-desktop-portal.service` | 修复 portal                |
| `dam-run kwm`                                         | 状态栏（damblocks --fifo） |

每条启动命令都有防重复守卫，`reload -k` 不会重复启动。

## 3. 会话退出

`.local/bin/exiland` 提供带确认的退出：

```sh
exiland -river          # kwm 栈：killall river
exiland -river-classic  # river-classic：riverctl exit
exiland -sway           # sway：swaymsg exit
exiland -dwl            # dwl：killall dwl
```

绑定：`Super+Shift+q`（各栈对应各自的参数）。

## 4. 配置重载

| 栈            | 按键            | 效果                          |
|---------------|-----------------|-------------------------------|
| kwm           | `Super+Shift+r` | 重载 `.config/kwm/config.zon` |
| river-classic | `Super+Shift+r` | 重新执行 `init`（全部重载）   |
| sway          | `Super+Shift+r` | 重载 sway 配置                |

## 5. 机器本地链接（`fix-local-links.sh`）

`install-user.sh` 用 stow 链接仓库，随后调用 `fix-local-links.sh` 修复机器本地链接：

- `~/.config/kwm/config.zon` → 仓库 `.config/kwm/config.zon`（kwm 直接读仓库副本）
- `~/.local/share/wallpaper` → `wallpaper.png`
- `~/.local/share/nvim` 保持真实目录（NvChad 运行时数据）
- `~/.ssh` 保持真实目录（私钥不进仓库）

> stow 用 `--ignore='^\.ssh'` 避免把仓库里的 `.ssh` 链接进家目录。

## 6. 常见排查

- **启动后状态栏丢失**：检查 `${XDG_RUNTIME_DIR}/damblocks.fifo` 是否存在；kwm 重载（`Super+Shift+r`）后 FIFO 被重建，`damblocks --fifo` 因 `trap '' PIPE` 存活会重新接管。
- **kwm 日志报 `execve failed: error.FileNotFound`**：通常是启动命令依赖的程序不在 `PATH`，或 `kwim` 未安装（`install-pkgs.sh --kwm` 现在会装）。
- **portal 失效（Electron 文件选择器报错）**：重启 `xdg-desktop-portal.service` 并确认环境变量已导入。
