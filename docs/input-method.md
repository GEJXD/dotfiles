# 输入法与键盘

## 1. fcitx5（中文拼音输入）

**作用**：Wayland 输入法框架，中文拼音输入。

**配置文件**（`.config/fcitx5/`）：

| 文件 | 作用 |
|---|---|
| `profile` | 启用的输入法组：默认 `keyboard-us` + `pinyin`，默认输入法 `pinyin` |
| `conf/pinyin.conf` | 拼音引擎选项 |
| `conf/chttrans.conf` | 简繁转换 |
| `conf/*.conf` | 其他引擎/模块选项 |

**启动**：在 autostart 中启动 `fcitx5 -d --verbose '*=0'`（kwm 与 river-classic 均如此；sway 用 `exec_always`）。

**切换**：`Ctrl+Space`（`fcitx5-remote -t`）。

**配置方式**：
- 图形界面：`fcitx5-configtool`（该窗口在规则中设为浮动）。
- 直接编辑上述 `.conf` 与 `profile`。
- 用户词典等运行时数据在 `~/.local/share/fcitx5/pinyin/`（不纳入仓库）。

> 注意：wlrctl 模式会先 `killall fcitx5` 再进入，退出时重新 `fcitx5 -d`，避免与 `wtype` 冲突。

## 2. 键盘重复率（repeat rate / delay）

键盘重复由各栈的输入管理器配置，四处配置保持一致：**rate 30 / delay 200ms**。

| 栈 | 配置位置 | 语法 |
|---|---|---|
| kwm 应用内键盘 | `.config/kwim/config.zon` | `input_device_rules[].repeat_info = .{ .rate = 30, .delay = 200 }` |
| kwm 快捷键重复 | `.config/kwm/config.zon` | `bindings.repeat_info = .{ .rate = 30, .delay = 200 }` |
| river-classic | `.config/river-classic/init` | `riverctl set-repeat 30 200` |
| sway | `.config/sway/config` | `input "type:keyboard" { repeat_delay 200; repeat_rate 30 }` |

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

| 栈 | 配置 |
|---|---|
| river-classic | `riverctl keyboard-layout us`（`init` 中；`.config/layout.xkb` 为备用完整映射，已注释） |
| kwm | 由 kwim 的 `xkb_keyboard_rules` 控制（当前未设置，用默认 us） |
| sway | `.config/sway/config` 中无显式布局（默认 us） |

## 4. 相关脚本

| 脚本 | 作用 |
|---|---|
| `.local/bin/capslock` | CapsLock 状态通知 |
| `.local/bin/wsk` | wshowkeys 按键可视化开关（`Super+Ctrl+s`） |
| `.local/bin/draw-keyboard` | 键盘布局绘图辅助 |

## 5. 常见问题

- **输入法不弹出候选框**：确认 `fcitx5` 进程存在、`GTK_IM_MODULE`/`QT_IM_MODULE`/`XMODIFIERS` 环境正确（Wayland 下主要依赖 `fcitx5` 与合成器的 input-method 协议）。
- **NumLock 灯状态**：当前 LED 由硬件/内核维护；如需在登录时设置，可通过 kwim 的 `xkb_keyboard_rules.numlock`（`.config/kwim/config.zon`）配置。
