# 软件清单：作用与配置方式

本文按类别列出当前系统使用的软件，说明其作用、配置文件位置和配置方式。所有路径相对于仓库根目录（经 stow 链接到 `~`）。

---

## 合成器 / 窗口管理器

| 软件          | 作用                     | 配置文件                                                        | 说明                                 |
|---------------|--------------------------|-----------------------------------------------------------------|--------------------------------------|
| river 0.5     | Wayland 合成器           | `.config/river/init`                                            | 默认栈，仅启动 kwm 与 FIFO           |
| kwm           | river 上的平铺 WM        | `.config/kwm/config.zon`（同时 `misc/kwm-config.zon` 保持同步） | 绑定、布局、规则、状态栏全部在此     |
| kwim          | 输入管理器（river 协议） | `.config/kwim/config.zon`                                       | kwm 启动时自动调用，配置键盘重复率等 |
| river-classic | 经典 river 合成器        | `.config/river-classic/init` 及其 include                       | 用 riverctl 配置，与 kwm 栈并行存在  |
| sway          | 备用 i3 风格合成器       | `.config/sway/config` 及其 include                              | 仅备用，不常用                       |

配置方式：
- **kwm**：编辑 `.config/kwm/config.zon`，按 `Super+Shift+r` 重载；重载不能生效的项需重启会话。
- **river-classic**：编辑 `.config/river-classic/*`，按 `Super+Shift+r` 重跑 `init`。
- **sway**：编辑 `.config/sway/*`，按 `Super+Shift+r` 重载。

详见 [compositors.md](compositors.md)。

---

## 状态栏

| 软件                   | 作用                               | 配置文件                                       |
|------------------------|------------------------------------|------------------------------------------------|
| damblocks              | 纯 shell 状态行生成器              | `.local/bin/damblocks`（源码式脚本）           |
| dam                    | 将 stdin 文本渲染为 Wayland 状态栏 | `.config/river-classic/` 中通过 `dam-run` 启动 |
| damblocks-mpdd         | MPD 可视化模块                     | `.local/bin/damblocks-mpdd`                    |
| prepare-damblocks-fifo | 启动前创建状态栏 FIFO              | `.local/bin/prepare-damblocks-fifo`            |

- kwm 栈：`damblocks --fifo` 写入 `${XDG_RUNTIME_DIR}/damblocks.fifo`，kwm 内置 bar 直接读取。
- river-classic 栈：`damblocks | dam`。
- 模式协调脚本：`.local/bin/dam-run [river-classic|kwm]`。

详见 [statusbar.md](statusbar.md)。

---

## 终端与编辑器

| 软件            | 作用                                  | 配置文件                                                          |
|-----------------|---------------------------------------|-------------------------------------------------------------------|
| foot            | Wayland 终端                          | `.config/foot/foot.ini`（include `bindings.ini`、`colors-*.ini`） |
| footclient      | foot 客户端（共享服务器，启动快）     | 同上                                                              |
| abduco + dvtm   | 终端复用 / 分屏（`Super+v` 浮动终端） | —                                                                 |
| neovim + NvChad | 编辑器                                | `.config/nvim/`（`init.lua`、`lua/`、`lazy-lock.json`）           |
| lf              | 终端文件管理器                        | `.config/lf/`（`lfrc`、`rifle.conf`、`scope.sh` 等）              |

配置方式：
- **foot**：`foot.ini` 为 ini 格式，可 `include` 其他文件；字体、滚回行数、URL 启动器（默认 `qutebrowser`）都在这里。
- **nvim**：NvChad 结构，插件由 lazy.nvim 管理，`lazy-lock.json` 锁定版本；运行时数据（插件本体）在 `~/.local/share/nvim`，不纳入仓库。

---

## 浏览器

| 软件        | 作用                       | 配置文件                                                             |
|-------------|----------------------------|----------------------------------------------------------------------|
| qutebrowser | 键盘驱动浏览器（vim 风格） | `.config/qutebrowser/`（`config.py`、`bindings.py`、`colors.py` 等） |
| firefox     | 默认浏览器（Wayland）      | 用户配置在 `~/.mozilla`（不纳入仓库）                                |

- `BROWSER=firefox` 定义在 `.config/shell/profile.sh`，qutebrowser 相关脚本不变。
- `foot.ini` 的 URL 启动器仍用 `qutebrowser`。

---

## 菜单 / 选择器

| 软件            | 作用                 | 配置                                                        |
|-----------------|----------------------|-------------------------------------------------------------|
| wmenu           | Wayland 动态菜单     | 主题/颜色封装在 `.local/bin/wmenu-color`、`wmenu-run-color` |
| fzf             | 模糊查找             | `.config/fzf/`                                              |
| wmenu-run-color | 程序启动器（带颜色） | `.local/bin/wmenu-run-color`                                |

---

## 输入法

| 软件          | 作用       | 配置文件                                |
|---------------|------------|-----------------------------------------|
| fcitx5        | 输入法框架 | `.config/fcitx5/`（`profile`、`conf/`） |
| fcitx5-pinyin | 拼音输入   | `.config/fcitx5/conf/pinyin.conf`       |

- 切换：`Ctrl+Space`。
- 配置方式：`fcitx5-configtool` 图形配置，`profile` 决定启用的输入法顺序。
- 用户词典等运行时数据在 `~/.local/share/fcitx5`（不纳入仓库）。

详见 [input-method.md](input-method.md)。

---

## 显示 / 锁屏 / 电源

| 软件          | 作用                          | 配置文件                              |
|---------------|-------------------------------|---------------------------------------|
| kanshi        | 按 profile 自动配置输出       | `.config/kanshi/config`               |
| swaybg        | 壁纸                          | autostart 中调用                      |
| swaylock      | 锁屏（`ext-session-lock-v1`） | `.config/swaylock/config`（三栈共用） |
| swayidle      | 空闲动作                      | `.config/swayidle/config`             |
| brightnessctl | 背光控制                      | 由 `.local/bin/bright` 封装           |
| hibe          | 休眠（wmenu 确认）            | `.local/bin/hibe`                     |

详见 [display-power.md](display-power.md)。

---

## 音频

| 软件        | 作用                       | 配置文件                               |
|-------------|----------------------------|----------------------------------------|
| pipewire    | 音频服务                   | `.config/pipewire/`                    |
| wireplumber | 会话策略                   | —                                      |
| wob / wobd  | 音量 OSD（wlr-layer 协议） | `.config/wob/`、`.local/bin/wobd`      |
| audio       | 音量/麦克风控制封装        | `.local/bin/audio`（依赖 wireplumber） |

- 音量键绑定见 [keybinds.md](keybinds.md)。

---

## 音乐

| 软件    | 作用             | 配置文件                               |
|---------|------------------|----------------------------------------|
| mpd     | 音乐播放守护进程 | `.config/mpd/mpd.conf`、`outputs.conf` |
| ncmpcpp | mpd 客户端       | `.config/ncmpcpp/`                     |
| mpc     | 命令行控制       | —                                      |
| lsmus   | 显示当前播放曲目 | `.local/bin/lsmus`                     |

- `Super+Ctrl+Space` 播放/暂停；`n/p` 下一首/上一首；锁屏下 `Super+Space/p/n`。

---

## 通知

| 软件                    | 作用         | 配置文件                                  |
|-------------------------|--------------|-------------------------------------------|
| dunst                   | 通知守护进程 | `.config/dunst/dunstrc`、`dunstrc-offset` |
| dunstctl                | 控制 dunst   | 绑定 `Super+n` 系列                       |
| libnotify (notify-send) | 发送通知     | 被各脚本使用                              |

---

## 截图 / 剪贴板

| 软件                            | 作用             | 配置/脚本                                      |
|---------------------------------|------------------|------------------------------------------------|
| grim                            | Wayland 截图     | `.local/bin/shoot` 封装                        |
| slurp                           | 区域选择         | 同上                                           |
| wl-clipboard (wl-copy/wl-paste) | Wayland 剪贴板   | `clip`、`shoot` 使用                           |
| cliphist                        | 剪贴板历史       | autostart 中 `wl-paste --watch cliphist store` |
| clip                            | 剪贴板历史管理器 | `.local/bin/clip`                              |

---

## 输入辅助

| 软件      | 作用          | 配置                 |
|-----------|---------------|----------------------|
| wtype     | 键盘注入      | wlrctl 模式使用      |
| wlrctl    | 指针/输入控制 | wlrctl 模式使用      |
| wshowkeys | 按键可视化    | `.local/bin/wsk`     |
| gammastep | 暖色屏幕滤镜  | `Super+Shift+b` 开关 |
| mag       | 放大镜        | `.local/bin/mag`     |

---

## 桌面工具

| 软件                 | 作用                  | 配置文件                   |
|----------------------|-----------------------|----------------------------|
| picom                | 合成特效（仅 X 备用） | `.config/picom/picom.conf` |
| swayimg              | 图片查看器            | `.config/swayimg/`         |
| mpv                  | 视频播放器            | `.config/mpv/`             |
| zathura              | PDF/文档查看器        | `.config/zathura/`         |
| nsxiv                | 图片浏览器            | `.config/nsxiv/`           |
| taskwarrior          | 任务管理              | `.config/task/taskrc`      |
| calcurse             | 日历                  | `.config/calcurse/`        |
| newsboat             | RSS 阅读器            | `.config/newsboat/`        |
| btop                 | 系统监视器            | `.config/btop/`            |
| mutt / neomutt       | 邮件客户端            | `.config/mutt/`            |
| qutebrowser 相关脚本 | qb/qbn/qbp/qbu/qbz    | `.local/bin/`              |

---

## 系统配置（`etc/`）

| 文件                               | 作用                                           |
|------------------------------------|------------------------------------------------|
| `etc/systemd/sleep.conf`           | 休眠模式（`HibernateMode=shutdown`）           |
| `etc/systemd/logind.conf`          | 登录会话设置                                   |
| `etc/default/grub`                 | 内核参数（含 `resume=UUID=...` 休眠恢复）      |
| `etc/mkinitcpio.conf`              | initramfs hooks（含 `sd-encrypt`、`lvm2`）     |
| `etc/pacman.conf`                  | 包管理器配置                                   |
| `etc/pacman.d/hooks/*`             | pacman 钩子                                    |
| `etc/xdg/reflector/reflector.conf` | reflector 生成 mirrorlist 的规则（每周 timer） |
| `etc/modprobe.d/isw-ec_sys.conf`   | MSI 笔记本风扇模块参数                         |
| `etc/pam.d/swaylock`               | 锁屏独立 PAM 策略（避免 faillock 锁账户）      |
| `etc/pam.d/waylock`                | 旧 waylock 策略（已不再使用）                  |
| `etc/udev/rules.d/*`               | damblocks 相关 udev 规则                       |
| `etc/vconsole.conf`                | 控制台字体/键位                                |
| `etc/tlp.conf`                     | 电源管理                                       |
| `etc/fwupd/fwupd.conf`             | 固件更新                                       |
| `etc/libvirt/network.conf`         | libvirt 网络                                   |

> `etc/` 通过 `install-root.sh` 安装到系统；修改后需重新运行并以 root 权限覆盖目标文件。

---

## 外壳与基础工具

| 软件       | 配置文件                                                          |
|------------|-------------------------------------------------------------------|
| zsh        | `.zshrc`、`.config/zsh/`（aliases/functions/completions）         |
| bash       | `.bashrc`、`.config/bash/`                                        |
| git        | `.config/git/config`（含 `user.inc`、`proxy.inc` 等机器本地文件） |
| fontconfig | `.config/fontconfig/fonts.conf`                                   |
| GTK 主题   | `.config/gtk-2.0`、`gtk-3.0`、`gtk-4.0`                           |
| Qt 主题    | `.config/qt5ct`、`qt6ct`                                          |
| less       | `.config/lesskey`                                                 |
| wget       | `.config/wget/`                                                   |
| yt-dlp     | `.config/yt-dlp/`                                                 |
