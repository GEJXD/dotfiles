# 输入法与键盘

## 1. fcitx5（中文拼音输入）

**作用**：Wayland 输入法框架，中文拼音输入。

**配置文件**（`.config/fcitx5/`）：

| 文件                 | 作用                                                               |
|----------------------|--------------------------------------------------------------------|
| `profile`            | 启用的输入法组：默认 `keyboard-us` + `pinyin`，默认输入法 `pinyin` |
| `conf/pinyin.conf`   | 拼音引擎选项                                                       |
| `conf/chttrans.conf` | 简繁转换                                                           |
| `conf/*.conf`        | 其他引擎/模块选项                                                  |

**启动**：在 autostart 中启动 `fcitx5 -d --verbose '*=0'`（kwm 与 river-classic 均如此；sway 用 `exec_always`）。

**切换**：`Ctrl+Space`（`fcitx5-remote -t`）。

**环境变量**（`.config/shell/profile.sh`，登录 shell 里 source，river/kwm/sway 及其子进程全部继承）：

| 变量 | 值 | 作用 |
|------|----|------|
| `XMODIFIERS` | `@im=fcitx` | X11 / XWayland 客户端走 XIM（`libxim.so`） |
| `QT_IM_MODULE` | `fcitx` | Qt5 与强制 `xcb` 的 Qt 程序：kwin 之外没有 text-input-v2 |
| `QT_IM_MODULES` | `wayland;fcitx` | Qt >= 6.7 的 im 模块回退顺序，优先原生 Wayland |
| `GTK_IM_MODULE` | **不设** | 让 Gtk3/4 原生客户端使用合成器的 text-input-v3 |

> Gtk 客户端的 im 模块选择顺序：X11 下是 `GTK_IM_MODULE` → XSettings → 配置文件；Wayland 下只有 `GTK_IM_MODULE` → `wayland`。所以 XWayland 里的 Gtk 程序改由配置文件接管：`.config/gtk-3.0/settings.ini`、`.config/gtk-4.0/settings.ini` 的 `gtk-im-module=fcitx`，以及 `.config/gtk-2.0/gtkrc`（`GTK2_RC_FILES` 指向它）。
>
> 若在全局环境里导出 `GTK_IM_MODULE=fcitx`，fcitx5 会在每次启动时发一条 `Wayland Diagnose` 桌面通知（源码 `src/modules/wayland/waylandmodule.cpp::selfDiagnose`），提示改用 Wayland im 前端；这不是错误，只是重复提醒。纯 X11 会话（`.xinitrc`）里仍需 `GTK_IM_MODULE=fcitx`，那边不会告警。
>
> river 0.5 提供 `zwp_input_method_manager_v2` + `zwp_text_input_manager_v3`（可用 `WAYLAND_DEBUG=1 wl-copy </dev/null 2>&1 | grep global` 查看合成器 global），故候选框由合成器定位，无需 `GTK_IM_MODULE`。Chromium/Electron 走 `--enable-wayland-ime --wayland-text-input-version=3`（`.config/electron-flags.conf`）。

**配置方式**：
- 图形界面：`fcitx5-configtool`（该窗口在规则中设为浮动）。
- 直接编辑上述 `.conf` 与 `profile`。
- 用户词典等运行时数据在 `~/.local/share/fcitx5/pinyin/`（不纳入仓库）。

> 注意：wlrctl 模式会先 `killall fcitx5` 再进入，退出时重新 `fcitx5 -d`，避免与 `wtype` 冲突。

## 2. 键盘重复率（repeat rate / delay）

键盘重复由各栈的输入管理器配置，四处配置保持一致：**rate 30 / delay 200ms**。

| 栈             | 配置位置                     | 语法                                                               |
|----------------|------------------------------|--------------------------------------------------------------------|
| kwm 应用内键盘 | `.config/kwim/config.zon`    | `input_device_rules[].repeat_info = .{ .rate = 30, .delay = 200 }` |
| kwm 快捷键重复 | `.config/kwm/config.zon`     | `bindings.repeat_info = .{ .rate = 30, .delay = 200 }`             |
| river-classic  | `.config/river-classic/init` | `riverctl set-repeat 30 100`                                       |
| sway           | `.config/sway/config`        | `input "type:keyboard" { repeat_delay 100; repeat_rate 30 }`       |

### kwim（kwm 的输入管理器）

- **作用**：实现 river-input-management-v1 等协议，独立于 WM 配置输入设备（键盘重复、滚动因子、libinput 选项、xkb 布局、NumLock 等）。
- **来源**：`https://github.com/kewuaa/kwim`，由 `install-pkgs.sh --kwm` 克隆并 `zig build` 安装到 `/usr/local/bin/kwim`。
- **启动**：kwm 收到 seat capabilities 事件时自动执行 `kwim`；也可手动运行。
- **配置读取**：`~/.config/kwim/config.zon`（仓库中即 `.config/kwim/config.zon`）。

常用命令：

```sh
kwim                    # 应用配置（默认路径）
kwim -c /path/to.zon    # 指定配置
kwim list input-device  # 列出输入设备
kwim apply input-device --repeat-info 30,200   # 对单设备临时应用
```

## 3. 键盘布局

| 栈            | 配置                                                                                    |
|---------------|-----------------------------------------------------------------------------------------|
| river-classic | `riverctl keyboard-layout us`（`init` 中；`.config/layout.xkb` 为备用完整映射，已注释） |
| kwm           | 由 kwim 的 `xkb_keyboard_rules` 控制（当前未设置，用默认 us）                           |
| sway          | `.config/sway/config` 中无显式布局（默认 us）                                           |

## 4. 相关脚本

| 脚本                       | 作用                                       |
|----------------------------|--------------------------------------------|
| `.local/bin/capslock`      | CapsLock 状态通知                          |
| `.local/bin/wsk`           | wshowkeys 按键可视化开关（`Super+Ctrl+s`） |
| `.local/bin/draw-keyboard` | 键盘布局绘图辅助                           |

## 5. 常见问题

- **输入法不弹出候选框**：先确认 `fcitx5` 进程存在，再看客户端走哪条路。原生 Wayland 客户端依赖合成器的 input-method/text-input 协议（`WAYLAND_DEBUG=1 <client> 2>&1 | grep global` 检查）；XWayland 客户端依赖 `XMODIFIERS` 与 Gtk/Qt 配置文件里的 `gtk-im-module`/`QT_IM_MODULE`。
- **开机弹 "Detect GTK_IM_MODULE being set ..." 通知**：说明环境里又导出 `GTK_IM_MODULE` 了，按上表删掉该行（fcitx5 wayland 模块的诊断通知，非报错）。
- **NumLock 灯状态**：当前 LED 由硬件/内核维护；如需在登录时设置，可通过 kwim 的 `xkb_keyboard_rules.numlock`（`.config/kwim/config.zon`）配置。

## 6. 换启动栈时的输入法开关

`GTK_IM_MODULE` 该不该设，只看一件事：**合成器有没有广播 `zwp_input_method_manager_v2` + `zwp_text_input_manager_v3`**（`WAYLAND_DEBUG=1 wl-copy </dev/null 2>&1 | grep -o 'zwp_[a-z_]*_v[0-9]*' | sort -u`）。有 → 不设；没有 → 不设就会让原生 Wayland 客户端彻底没有输入法，必须会话内 `export GTK_IM_MODULE=fcitx`。

| 会话 | 协议支持 | 输入法配置来源 |
|------|----------|------------------|
| `startw kwm` / `river` / `river-classic`（river 0.5） | 有 | `profile.sh`，**不设** `GTK_IM_MODULE` |
| `startw sway`（sway >= 1.10） | 有 | 同上 |
| `startw dwl`（dwl 0.8 + wlroots0.19，dwl/dwl#235 未合入） | 无 | `startw` 的 dwl 分支会话内导出 `GTK_IM_MODULE=fcitx` 并拉起 `fcitx5 -d` |
| `startx dwm` / `bspwm` / `i3`（纯 X11） | 不适用 | `.xinitrc` 的 `config_x()` 导出全部三个变量，`autostart()` 起 `fcitx5` |

> XWayland 里的 X11 程序在任何合成器下都一样：`XMODIFIERS` 走 XIM，Gtk 读 `gtk-im-module` 配置文件，Qt 读 `QT_IM_MODULE`——这几项与合成器无关。Qt >= 6.7 的 `QT_IM_MODULES="wayland;fcitx"` 本身就是回退链，所以在不支持该协议的合成器下 Qt6 仍会自动落到 fcitx。
