# 显示、锁屏与休眠

## 1. 多显示器布局（kanshi）

**作用**：kanshi 按 profile 自动配置输出（热插拔时生效）。

**配置文件**：`.config/kanshi/config`

当前 profile：

```ini
profile hdmi {
    output eDP-1 position 0,0
    output HDMI-A-1 enable position 2560,0
}
```

另有 `nomad`、`home`（DP-1 / DP-2）等备用 profile。

**配置方式**：
- 编辑 profile 后 `kanshi reload` 或重启 kanshi（`pgrep kanshi || kanshi` 由 autostart 保证）。
- 输出名用 `wlr-randr` 查看。

> sway 栈不使用 kanshi profile，而是在 `.config/sway/config` 里写死 `output 'eDP-1' ...` 与工作区映射。

## 2. 锁屏（swaylock）

**作用**：屏幕锁定。三栈共用同一份配置与同一锁屏程序 `swaylock`（支持 `ext-session-lock-v1`，kwm / river-classic / sway 都支持该协议）。

**配置文件**：`.config/swaylock/config`（经 stow 链接到 `~/.config/swaylock/config`）。

内容要点：黑色背景、可见指示环、验证/错误配色、按键高亮、失败次数显示。

**锁定命令**：`swaylock -f`（`-f` 表示立即启动，不等待光标消失）。

**绑定**：`Super+Shift+w`（三栈一致）；swayidle 的空闲锁屏与 `before-sleep` 也调用同一命令。

**PAM**：`etc/pam.d/swaylock` 使用独立策略：

```
auth required pam_unix.so
auth required pam_permit.so
account required pam_unix.so
```

这样解锁失败只提示重试，不会触发 `pam_faillock` 锁定整个账户。安装方式：`install-root.sh` 把它放到 `/etc/pam.d/`。

> `waylock` 已不再使用（只有纯色无输入框），但其包与 `/etc/pam.d/waylock` 暂时保留未删。

## 3. 空闲与电源（swayidle）

**配置文件**：`.config/swayidle/config`

| 时间 | 动作 |
|---|---|
| 600s | 降低亮度到 4%（`brightnessctl set 4% -s`），恢复时还原 |
| 900s | `swaylock -f`（锁屏） |
| 960s | 屏幕关闭（`brightnessctl set 0%`），恢复时 `kanshi reload` + 还原亮度 |
| before-sleep | `swaylock -f` |

**关键点**：使用 `swayidle -w`，保证锁屏命令完成后再进入休眠，避免解锁与休眠竞态。

## 4. 休眠 / 挂起

**脚本**：`.local/bin/hibe` — wmenu 确认后 `systemctl hibernate`（Wayland 用 `wmenu-color`，X 用 `dmenu`）。

**绑定**：`Super+Shift+e`（三栈一致）。

**系统配置**：

| 文件 | 内容 |
|---|---|
| `/etc/default/grub`（仓库 `etc/default/grub`） | `resume=UUID=91e919ba-bbc6-4d18-aa3a-9fc64057abfa`（swap LVM 卷） |
| `etc/systemd/sleep.conf` | `HibernateMode=shutdown` |
| `etc/mkinitcpio.conf` | hooks 含 `sd-encrypt`、`lvm2`，保证 initramfs 能解析 LVM/加密卷 |

> 历史问题：曾用 `resume=/dev/mapper/vg0-swap`，initramfs 阶段解析失败导致休眠恢复退化为冷启动；改用 UUID 后修复。修改 grub 后需 `sudo grub-mkconfig -o /boot/grub/grub.cfg` 并重新生成 initramfs。

## 5. 壁纸

- 壁纸文件：`~/.local/share/wallpaper`（`fix-local-links.sh` 链接到仓库 `wallpaper.png`）。
- 启动：`swaybg -i ~/.local/share/wallpaper -m fill`。
- 切换：`.local/bin/selwall` / `.local/bin/randwall`。

## 6. 相关脚本

| 脚本 | 作用 |
|---|---|
| `.local/bin/bright` | 背光控制（`brightnessctl` 封装，支持 OSD） |
| `.local/bin/audio` | 音量控制（含 OSD） |
| `.local/bin/wobd` / `xobd` | OSD 守护进程 |
| `.local/bin/mag` | 放大镜 |

## 7. 常见排查

- **休眠后冷启动而非恢复**：检查 `/etc/default/grub` 的 `resume=UUID=...`、`/etc/systemd/sleep.conf`，并确认 initramfs 含 `lvm2`/`sd-encrypt`。
- **解锁后显示器没开**：早期曾残留 `wlr-randr --output DP-1 --off`，已移除；当前输出为 `eDP-1` / `HDMI-A-1`。
- **解锁失败被锁账户**：确认 `/etc/pam.d/swaylock` 是独立策略（不含 `pam_faillock`）。
