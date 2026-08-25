# 按键绑定（keybinds）

三套 Wayland 栈共用 `Super`（Mod4）作为主修饰键，绝大多数绑定保持一致。本文档按合成器分别列出。

- **kwm**：`river 0.5 + kwm`（默认栈），配置在 [`.config/kwm/config.zon`](../.config/kwm/config.zon)
- **river-classic**：配置在 [`.config/river-classic/`](../.config/river-classic/)（`init` + `bindings` + `modes` + `rules`）
- **sway**：配置在 [`.config/sway/`](../.config/sway/)

> 说明：下面用 `Super` 表示 Mod4；`±1%` 等数值表示 `audio`/`bright` 脚本的档位，实际由脚本决定步长。

---

## 1. kwm（river 0.5，默认）

### 1.1 会话与系统

| 按键 | 动作 |
|---|---|
| `Super+Shift+r` | 重载 kwm 配置（`reload_config`） |
| `Super+Shift+q` | 退出会话（`exiland -river`，带 wmenu 确认） |
| `Super+Shift+w` | 锁屏（`swaylock -f`） |
| `Super+Shift+e` | 休眠（`hibe`，带 wmenu 确认后 `systemctl hibernate`） |
| `Super+Shift+i` | 放大镜开关（`mag`） |
| `Super+Shift+c` | 关闭当前窗口 |
| `Super+q` | 关闭当前窗口（`close`） |
| `Super+p` | 程序启动器（`wmenu-run-color`） |
| `Super+Return` | 打开终端（`footclient`） |
| `Super+v` | 浮动终端（`footclient -T Floating_Term ... abduco -A dvtm dvtm-status`） |
| `Super+r` | 终端内打开文件管理器（`lf`） |
| `Super+b` | 显示 / 隐藏状态栏（`toggle_bar`） |
| `Ctrl+Space` | 切换 fcitx5 输入法（`fcitx5-remote -t`） |

### 1.2 窗口管理

| 按键 | 动作 |
|---|---|
| `Super+Space` | 切换浮动 / 平铺（`toggle_floating`） |
| `Super+e` | 切换全屏（`toggle_fullscreen`） |
| `Super+Shift+f` | 切换最大化（`toggle_maximize`，覆盖同键的全屏变体） |
| `Super+Shift+Tab` | 切换回上一个布局 |
| `Super+z` | 缩放（`zoom`，与主窗口交换） |
| `Super+s` | 切换 sticky（跨 tag 显示） |
| `Super+Shift+s` | 切换 sticky（同上，见配置） |
| `Super+Shift+o` | 切换 swallow（终端吞入） |
| `Super+Ctrl+o` | 切换自动 swallow（`toggle_auto_swallow`） |
| `Super+j` / `Super+k` | 聚焦下一个 / 上一个窗口（`focus_iter`） |
| `Super+Shift+j` / `Super+Shift+k` | 与下一个 / 上一个窗口交换（`swap`） |
| `Super+Ctrl+h` / `Super+Ctrl+l` | 返回主窗口（`focus_master_return`） |

**鼠标（pointer）**

| 按键 | 动作 |
|---|---|
| `Super+左键` | 拖动窗口（`pointer_move`） |
| `Super+右键` | 调整窗口大小（`pointer_resize`） |

### 1.3 布局（layout）

| 按键 | 动作 |
|---|---|
| `Super+f` | 浮动布局（`float`） |
| `Super+t` | 平铺布局 + 主区域在左 |
| `Super+Shift+t` | 平铺布局 + 主区域在右 |
| `Super+u` | 平铺布局 + 主区域在底 |
| `Super+Shift+u` | 平铺布局 + 主区域在顶 |
| `Super+o` | deck 布局 |
| `Super+m` | 单窗格布局（`monocle`） |
| `Super+s` | scroller 布局 |
| `Super+Shift+m` | centered-master 布局 |
| `Super+h` / `Super+l` | 主区域比例 `mfact` ±0.05 |
| `Super+Alt+h/j/k/l` | 主区域位置：左 / 底 / 顶 / 右（`modify_master_location`） |
| `Super+i` / `Super+d` | 主区域窗口数 `nmaster` +1 / -1 |
| `Super+Ctrl+[` / `Super+Ctrl+]` | 间隙 `gap` ±2 |
| `Super+Ctrl+m` | 切换 centered-master 方向 |

### 1.4 标签（tag）

| 按键 | 动作 |
|---|---|
| `Super+1..9` | 切换到 tag 1..9 |
| `Super+0` | 切换到全部 tag |
| `Ctrl+1..9` | 切换（叠加）输出 tag 1..9 |
| `Super+Shift+1..9` | 把当前窗口放到 tag 1..9 |
| `Super+Shift+0` | 把当前窗口放到全部 tag |
| `Super+Ctrl+1..9` | 切换窗口的 tag（叠加） |
| `Super+Tab` / `Super+\` | 返回上一个 tag |
| `Super+'` / `Super+;` | 聚焦下一个 / 上一个有窗口的 tag |
| `Super+Ctrl+'` / `Super+Ctrl+;` | 聚焦下一个 / 上一个空的 tag |
| `Super+Shift+'` / `Super+Shift+;` | 把窗口移到下一个 / 上一个空 tag |

### 1.5 多显示器

| 按键 | 动作 |
|---|---|
| `Super+.` / `Super+,` | 聚焦下一个 / 上一个输出 |
| `Super+Shift+.` / `Super+Shift+,` | 把窗口移到下一个 / 上一个输出 |
| `Super+Ctrl+j` / `Super+Ctrl+k` | 聚焦下一个 / 上一个输出 |
| `Super+Shift+Right` / `Super+Shift+Left` | 把窗口移到下一个 / 上一个输出 |

> 输出顺序由 kwm 内部维护，`forward/reverse` 语义与 `next/previous` 等价且支持两个以上显示器。

### 1.6 音频

| 按键 | 动作 |
|---|---|
| `Super+-` / `Super+=` | 音量 −1% / +1%（sink，按住可重复） |
| `Super+Shift+-` / `Super+Shift+=` | 音量 −10% / +10% |
| `Super+Backspace` | 静音 / 取消静音（sink） |
| `Super+Ctrl+-` / `Super+Ctrl+=` | 麦克风 −5% / +5%（source） |
| `Super+Ctrl+Shift+-` / `Super+Ctrl+Shift+=` | 麦克风 −1% / +1% |
| `Super+Ctrl+Backspace` | 麦克风静音 |

### 1.7 亮度

| 按键 | 动作 |
|---|---|
| `Super+[` / `Super+]` | 亮度 −1% / +1%（按住可重复） |
| `Super+Shift+[` / `Super+Shift+]` | 亮度 −10% / +10% |
| `Super+Ctrl+[` / `Super+Ctrl+]` | 亮度 −5% / +5% |
| `Super+Ctrl+Shift+[` | 亮度最低（`--min`） |
| `Super+Ctrl+Shift+]` | 亮度最高（`--max`） |

### 1.8 截图 / 剪贴板 / 通讯

| 按键 | 动作 |
|---|---|
| `Super+g` | 截图：当前输出（复制到剪贴板） |
| `Super+Shift+g` | 截图：选择区域 |
| `Super+Ctrl+g` | 截图：全部输出 |
| `Super+c` | 剪贴板历史（`clip`） |
| `Super+Ctrl+c` | 清空剪贴板历史（`clip --wipe`） |
| `Super+a` | 通讯录查询（`address`） |
| `Super+Shift+a` | 通讯录添加（`address --record`） |
| `Super+Ctrl+a` | 通讯录多选（`address --multi`） |

### 1.9 通知（dunst）

| 按键 | 动作 |
|---|---|
| `Super+n` | 弹出历史通知（`dunstctl history-pop`） |
| `Super+Shift+n` | 关闭当前通知（`dunstctl close`） |
| `Super+Ctrl+Shift+n` | 关闭全部通知（`dunstctl close-all`） |

### 1.10 音乐（mpd）

| 按键 | 动作 |
|---|---|
| `Super+Ctrl+Space` | 播放 / 暂停 + 列出曲目（`mpc toggle && lsmus`） |
| `Super+Ctrl+p` | 上一首（`mpc prev`） |
| `Super+Ctrl+n` | 下一首（`mpc next`） |

### 1.11 其他

| 按键 | 动作 |
|---|---|
| `Super+Ctrl+s` | 切换按键显示 `wshowkeys`（`wsk`） |
| `Super+Shift+b` | 切换暖色模式（`gammastep -O 5000` 开关） |

### 1.12 模式（mode）

kwm 使用模式系统；进入模式后按键交给该模式处理，退出方式见各模式。

**浮动模式**（进入 `Super+Ctrl+f`，退出 `f` / `Escape` / `Space`）

| 按键 | 动作 |
|---|---|
| `h/j/k/l` | 移动窗口 50px（按住可重复） |
| `y/u/i/o` | 调整窗口大小（−/− / + / − / +） |
| `Super+Shift+h/j/k/l` | 吸附到左 / 下 / 上 / 右边缘 |

**wmenu 模式**（进入 `Super+w`，退出 `w` / `Escape` / `Space`）

| 按键 | 动作 |
|---|---|
| `w` | wiki 搜索（arch-wiki-docs） |
| `h` | heart（编辑 dotfiles 里的文件） |
| `b` | books（zathura 打开书籍） |
| `u` | blue（蓝牙设备） |
| `s` | speaker（切换音频输出） |
| `e` | emoji 选择 |
| `j` | jdoc（openjdk 文档） |

**dunst 模式**（进入 `Super+x`，退出 `x` / `Escape` / `Space`）

| 按键 | 动作 |
|---|---|
| `l` | lsupdates（列出可更新软件包） |
| `w` | wttr（天气） |
| `c` | dcal（日历） |
| `m` | lsmus（当前播放） |
| `i` | 清空剪贴板历史 |

**wlrctl 模式**（进入 `Super+/`，退出 `/` / `Escape` / `Space`；进入前会先杀掉 fcitx5，退出时重启）

| 按键 | 动作 |
|---|---|
| `h/j/k/l` | 鼠标指针移动 90px（按住可重复） |
| `Shift+h/j/k/l` | 鼠标指针移动 15px |
| `Ctrl+h/j/k/l` | 方向键（`wtype -k Left/Down/Up/Right`） |
| `,` / `.` | 左键 / 右键点击 |
| `Shift+,` / `Shift+.` | 左键 / 右键点击 |
| `n` / `p` | 滚轮上 / 下 |
| `/` | 指针移到角落并退出 |

**passthrough 模式**（进入 / 退出 `Super+Shift+Escape`）：把按键原样传给应用。

**lock 模式**（锁屏后生效）

| 按键 | 动作 |
|---|---|
| `Super+Ctrl+Space` | 播放 / 暂停 |
| `Super+Ctrl+p` | 上一首 |
| `Super+Ctrl+n` | 下一首 |
| `Super+-` / `Super+=` | 音量 −1% / +1% |
| `Super+[` / `Super+]` | 亮度 −1% / +1% |

---

## 2. river-classic

配置文件：[`.config/river-classic/init`](../.config/river-classic/init)、[`bindings`](../.config/river-classic/bindings)、[`modes`](../.config/river-classic/modes)、[`rules`](../.config/river-classic/rules)。`init` 会依次 source 这四份。

### 2.1 会话与系统

| 按键 | 动作 |
|---|---|
| `Super+Shift+r` | 重新执行 `init`（重新加载全部配置） |
| `Caps_Lock` | 发送 CapsLock 状态通知 |
| `Super+Shift+q` | 退出会话（`exiland -river-classic`） |
| `Super+Shift+w` | 锁屏（`swaylock -f`） |
| `Super+Shift+e` | 休眠（`hibe`） |
| `Super+Shift+i` | 放大镜（`mag`） |
| `Super+q` | 关闭窗口 |
| `Super+Shift+c` | 关闭窗口 |
| `Super+p` | 启动器（`wmenu-run-color`） |
| `Super+Return` | 终端（`footclient`） |
| `Super+v` | 浮动终端（dvtm） |
| `Super+r` | 终端内 `lf` |
| `Super+b` | 刷新 dam 状态栏（`pkill -x -SIGUSR1 dam`） |
| `Ctrl+Space` | 切换 fcitx5 |

### 2.2 窗口与布局

| 按键 | 动作 |
|---|---|
| `Super+j` / `Super+k` | 聚焦下一个 / 上一个视图 |
| `Super+Ctrl+h/j/k/l` | 聚焦左 / 下 / 上 / 右 |
| `Super+Shift+j/k` | 交换下一个 / 上一个 |
| `Super+Shift+h/l` | 向左 / 向右交换（`swap left/right`） |
| `Super+Shift+Ctrl+h/j/k/l` | 方向交换 |
| `Super+i` / `Super+d` | 主窗口数 +1 / -1（`main-count`） |
| `Super+h` / `Super+l` | 主区域比例 ±0.05（`main-ratio`，按住可重复） |
| `Super+Ctrl+[` / `Super+Ctrl+]` | 间隙 ±2 |
| `Super+z` | zoom |
| `Super+Tab` / `Super+\` | 上一个 tag |
| `Super+Space` | 切换浮动 |
| `Super+e` | 切换全屏 |
| `Super+t` / `Super+Shift+t` | 主区域左 / 右 |
| `Super+u` / `Super+Shift+u` | 主区域底 / 顶 |
| `Super+m` | monocle |
| `Super+o` | deck |
| `Super+g` | grid |

**鼠标**

| 按键 | 动作 |
|---|---|
| `Super+左键` | 移动窗口 |
| `Super+右键` | 调整大小 |
| `Super+中键` | 切换浮动 |

### 2.3 标签（含 sticky 与 scratchpad）

`init` 中定义了 sticky tag（`1<<31`）和 scratchpad tag（`1<<20`），并把它们与数字 tag 叠加。

| 按键 | 动作 |
|---|---|
| `Super+1..9` | 聚焦 tag（自动叠加 sticky tag） |
| `Ctrl+1..9` | 切换输出 tag |
| `Super+Shift+1..9` | 设置视图 tag |
| `Super+Ctrl+1..9` | 切换视图 tag |
| `Super+0` / `Super+Shift+0` | 全部 tag |
| `Super+Shift+s` | 切换 sticky tag |
| `Super+Ctrl+o` | 切换 scratchpad |
| `Super+Shift+o` | 发送窗口到 scratchpad |

### 2.4 多显示器

| 按键 | 动作 |
|---|---|
| `Super+.` / `Super+,` | 聚焦下一个 / 上一个输出 |
| `Super+Shift+.` / `Super+Shift+,` | 移动窗口到下一个 / 上一个输出 |
| `Super+Ctrl+j` / `Super+Ctrl+k` | 聚焦下一个 / 上一个输出 |
| `Super+Shift+Right` / `Super+Shift+Left` | 移动窗口到下一个 / 上一个输出 |

### 2.5 音频 / 亮度

与 kwm 完全一致（见 1.6、1.7），音量/亮度/麦克风绑定相同。

### 2.6 截图 / 剪贴板 / 通讯 / 通知 / 音乐

与 kwm 一致（见 1.8–1.10），另外：

| 按键 | 动作 |
|---|---|
| `Super+Ctrl+s` | `wsk`（wshowkeys 开关） |
| `Super+Shift+b` | 暖色模式开关 |
| `Super+'` / `Super+;` | river-shifttags：聚焦下一个 / 上一个占用 tag |
| `Super+Shift+'` / `Super+Shift+;` | river-shifttags：移动窗口到下一个 / 上一个占用 tag |
| `Super+Ctrl+'` / `Super+Ctrl+;` | river-shifttags：下一个 / 上一个空闲 tag |

### 2.7 模式

river-classic 的 `modes` 与 kwm 的模式基本相同：

- **浮动模式**：`Super+Ctrl+f` 进入，`Super+Ctrl+f` / `Escape` / `Space` 退出；`hjkl` 移动、`yuio` 缩放、`Super+Shift+hjkl` 吸附。
- **wmenu 模式**：`Super+w` 进入；`w/h/b/u/s/e/j` 对应 wiki/heart/books/blue/speaker/emoji/jdoc。
- **dunst 模式**：`Super+x` 进入；`l/w/c/m/i` 对应 lsupdates/wttr/dcal/lsmus/clip --wipe。
- **wlrctl 模式**：`Super+/` 进入（先杀 fcitx5）；`hjkl` 移动指针、`Shift+hjkl` 微调、`Ctrl+hjkl` 方向键、`,`/`.` 点击、`n/p` 滚轮、`/` 指针移角落并退出。

---

## 3. sway

配置文件：[`.config/sway/config`](../.config/sway/config)（include colors/bar/autostart/bindings/modes/rules）。

> 与 kwm/river-classic 的主要差异：**`Super+q` 是打开 qutebrowser**（不是关窗口）；截图键是 `Super+y`（不是 `Super+g`）；音频/亮度的 `Super` 与 `Super+Shift` 档位相反。

### 3.1 会话与系统

| 按键 | 动作 |
|---|---|
| `Super+Shift+r` | 重载 sway 配置 |
| `Super+Shift+q` | 退出会话（`exiland -sway`） |
| `Super+Shift+w` | 锁屏（`swaylock -f`） |
| `Super+Shift+e` | 休眠（`hibe`） |
| `Super+Shift+i` | 放大镜（`mag`） |
| `Super+q` | 打开 qutebrowser |
| `Super+Shift+c` | 关闭窗口（kill） |
| `Super+p` | 启动器 |
| `Super+Return` | 终端 |
| `Super+v` | 浮动终端 |
| `Super+r` | 终端内 `lf` |
| `Super+b` | 切换状态栏显示（`swaymsg bar mode toggle`） |
| `Ctrl+Space` | 切换 fcitx5 |

### 3.2 窗口与布局（sway 风格）

| 按键 | 动作 |
|---|---|
| `Super+h/j/k/l` | 聚焦左 / 下 / 上 / 右 |
| `Super+Shift+h/j/k/l` | 移动窗口左 / 下 / 上 / 右 |
| `Super+Ctrl+h/j/k/l` | 调整大小（shrink/grow） |
| `Super+Space` | 切换浮动 |
| `Super+e` | 全屏 |
| `Super+f` | 切换焦点模式 |
| `Super+i` / `Super+d` | focus parent / focus child |
| `Super+t` | 切换 tabbed / split 布局 |
| `Super+s` | 切换 stacking / split |
| `Super+u` | 切换 split 方向 |
| `Super+x` / `Super+z` | 垂直 / 水平分割 |
| `Super+Tab` / `Super+\` | 上一个工作区 |
| `Super+Shift+s` | sticky 切换 |
| `Super+Shift+o` | 移动到 scratchpad |
| `Super+o` | 显示 scratchpad |
| `Super+Ctrl+[` / `Super+Ctrl+]` | 内部间隙 ±2 |

### 3.3 工作区

| 按键 | 动作 |
|---|---|
| `Super+1..9` | 工作区 1..9 |
| `Super+0` | 工作区 `10:0` |
| `Super+Shift+1..9` | 移动容器到工作区 1..9 |
| `Super+Shift+0` | 移动容器到工作区 `10:0` |
| `Super+'` / `Super+;` | 下一个 / 上一个输出上的工作区 |
| `Super+Shift+'` / `Super+Shift+;` | 移动容器到下一个 / 上一个工作区 |

### 3.4 多显示器

| 按键 | 动作 |
|---|---|
| `Super+.` / `Super+,` | 聚焦右 / 左输出 |
| `Super+Shift+.` / `Super+Shift+,` | 移动容器到右 / 左输出 |

> 工作区到输出的固定映射见 [`.config/sway/config`](../.config/sway/config) 中的 `workspace N output ...`。

### 3.5 音频 / 亮度（档位与 kwm 相反）

| 按键 | 动作 |
|---|---|
| `Super+-` / `Super+=` | 音量 −10% / +10% |
| `Super+Shift+-` / `Super+Shift+=` | 音量 −1% / +1% |
| `Super+Backspace` | 静音 |
| `Super+Ctrl+-` / `Super+Ctrl+=` | 麦克风 −10% / +10% |
| `Super+Ctrl+Shift+-` / `Super+Ctrl+Shift+=` | 麦克风 −1% / +1% |
| `Super+Ctrl+Backspace` | 麦克风静音 |
| `Super+[` / `Super+]` | 亮度 −10% / +10% |
| `Super+Shift+[` / `Super+Shift+]` | 亮度 −1% / +1% |
| `Super+Ctrl+Shift+[` / `Super+Ctrl+Shift+]` | 最低 / 最高 |

### 3.6 截图 / 剪贴板 / 通讯 / 通知 / 音乐

| 按键 | 动作 |
|---|---|
| `Super+y` | 截图当前输出 |
| `Super+Shift+y` | 截图区域 |
| `Super+Ctrl+y` | 截图全部 |
| `Super+c` / `Super+Ctrl+c` | 剪贴板 / 清空 |
| `Super+a` / `Super+Shift+a` / `Super+Ctrl+a` | 通讯录 查询 / 添加 / 多选 |
| `Super+n` / `Super+Shift+n` / `Super+Ctrl+Shift+n` | dunst 历史 / 关闭 / 全部关闭 |
| `Super+Ctrl+Space` / `p` / `n` | mpc 播放 / 上一首 / 下一首 |
| `Super+Ctrl+s` | wsk |
| `Super+Shift+b` | 暖色模式 |

### 3.7 模式

- **wmenu 模式**：`Super+w` 进入；`w/h/b/u/s/e/j` 同 kwm。
- **wlrctl 模式**：`Super+/` 进入；绑定与 kwm 相同（用 sway 内置 `seat - cursor` 移动指针）。

---

## 4. 键盘重复率

| 栈 | 位置 | 值 |
|---|---|---|
| kwm 应用内键盘 | `.config/kwim/config.zon`（`repeat_info`） | rate 30 / delay 200ms |
| kwm 快捷键重复 | `.config/kwm/config.zon`（`bindings.repeat_info`） | rate 30 / delay 200ms |
| river-classic | `.config/river-classic/init`（`riverctl set-repeat 30 100`） | rate 30 / delay 100ms |
| sway | `.config/sway/config`（`input "type:keyboard"`） | rate 30 / delay 200ms |

详见 [input-method.md](input-method.md)。
