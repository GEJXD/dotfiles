# dotfiles

Arch Linux 的个人运行环境。默认栈是 **river 0.5 + kwm** 平铺合成器，同时保留 river-classic、纯 river、sway、dwl、dwm 五条可启动分支；所有配置用 GNU Stow 以符号链接管理，安装拆成「包 → 用户 → 系统」三层脚本，任何一层都能单独跑通。

![kwm 栈（默认）](misc/kwm.png)

中文 ｜ [English](README.en.md) ｜ 细节文档：[docs/](docs/README.md)

**规模**：440+ 个受版本控制的文件 · `~/.local/bin` 下 155 个自写脚本 · 60 个应用的 `.config` 目录 · 2700+ commits（自 2025-01）。

---

## 目录

1. [这套 dotfiles 长什么样](#1-这套-dotfiles-长什么样)
2. [仓库结构](#2-仓库结构)
3. [合成器栈与会话生命周期](#3-合成器栈与会话生命周期)
4. [环境要求](#4-环境要求)
5. [安装](#5-安装)
6. [改完之后怎么生效](#6-改完之后怎么生效)
7. [包、镜像与缓存](#7-包镜像与缓存)
8. [状态栏与 cron 信号](#8-状态栏与-cron-信号)
9. [脚本层](#9-脚本层)
10. [私有数据与 `.gitignore` 策略](#10-私有数据与-gitignore-策略)
11. [同步与备份](#11-同步与备份)
12. [修改流程与验证](#12-修改流程与验证)
13. [已知问题](#13-已知问题)
14. [截图](#14-截图)
15. [来源与许可](#15-来源与许可)

---

## 1. 这套 dotfiles 长什么样

### 1.1 技术栈

| 角色 | 选择 |
|---|---|
| 合成器 / 窗口管理 | river 0.5 + [kwm](https://github.com/kewuaa/kwm)（默认）· river-classic · 纯 river · sway（备用）· dwl、dwm（脚本仍支持） |
| 状态栏 | [damblocks](.local/bin/damblocks)（纯 POSIX shell 生成状态行）→ kwm 内置 bar 读 FIFO / `dam` 渲染 / swaybar |
| 终端 | foot + footclient（客户端共享服务器，秒开）；abduco + dvtm 做复用 |
| 编辑器 | neovim + [NvChad](https://nvchad.com)（`lazy-lock.json` 锁版本） |
| 文件管理 | lf（+ rifle / scope） |
| 浏览器 | qutebrowser（键盘驱动）· firefox（`BROWSER`） |
| 菜单 / 选择器 | wmenu（`wmenu-run-color` 配色封装）· fzf |
| 输入法 | fcitx5 + 拼音（另装 anthy 日文），`Ctrl+Space` 切换 |
| 音频 | pipewire + wireplumber，OSD 用 wob |
| 音乐 | mpd + ncmpcpp + mpc（`damblocks-mpdd` 做状态栏可视化） |
| 通知 | dunst |
| 锁屏 / 电源 | swaylock（三栈共用配置 + 独立 PAM 策略）· swayidle · tlp · systemd-hibernate |
| 显示 | kanshi 按 profile 切输出 · swaybg 壁纸 · brightnessctl |
| X11 兼容 | xwayland-satellite（QQ 之类只要 X 的客户端）+ xorg-* 工具链 |
| 文字型工作流 | neomutt + isync · newsboat · calcurse + taskwarrior · ttyper |
| 邮件 / 天气 / 日历信号 | 由 cron 写入缓存文件，状态栏只读文件（见 [§8](#8-状态栏与-cron-信号)） |

### 1.2 设计原则

写在 [AGENTS.md](AGENTS.md) 里，实际也照做：

- **仓库是唯一事实来源**。`git ls-files` 列出的东西 = 重装系统后能恢复的全部配置；运行时数据、缓存、私钥一律不入库。
- **符号链接而非拷贝**。家目录里的配置全是 stow 建出来的链接，`readlink -f` 一步追回仓库；`kwm` 这种「运行时直接读仓库副本」的例外由 `fix-local-links.sh` 明确处理。
- **三层安装，逐层可用**。`install-pkgs.sh`（装什么包）→ `install-user.sh`（链接 + 用户环境）→ `install-root.sh`（`/etc`、服务、防火墙）。每层互不阻塞，都支持先看后动。
- **白名单式 `.gitignore`**。默认忽略一切，显式放行受管文件——所以新增系统配置必须同时改 `.gitignore`，否则不会入库。
- **不留向后兼容层**。路径废弃就删，不加 fallback、不做迁移脚本。

---

## 2. 仓库结构

```text
.
├── .config/              60 个应用的配置，stow 链接到 ~/.config
├── .local/
│   ├── bin/              155 个自写脚本（PATH 首位，整个目录本身就是一个软链接）
│   └── share/            wallpaper.png、nvim 运行时骨架、address 通讯录
├── .bashrc .profile .zprofile .zshrc .xinitrc
├── install-pkgs.sh       包层：按角色的 profile，默认 dry-run
├── install-user.sh       用户层：目录骨架、stow、chsh、crontab、模板落地
├── install-root.sh       系统层：/etc + /usr 落盘、服务、ufw（需 root）
├── fix-local-links.sh    stow 之后修复必须留在机器本地的链接
├── etc/                  系统配置：pacman、systemd、udev、PAM、内核参数……
├── usr/                  自定义键盘映射 us-custom.map.gz
├── boot/                 systemd-boot 条目模板（.example）
├── docs/                 中文详细文档（按键、软件、合成器、状态栏、输入法、电源、脚本）
├── misc/                 截图、kwm 配置副本、river-classic 构建补丁
├── mus/                  MPD 元数据（只 `.mpdignore`，音乐本体不入库）
└── AGENTS.md             给编码代理的仓库规则（结构、风格、测试、提交规范）
```

`.config/` 里几个值得单独点名的目录：

| 路径 | 作用 |
|---|---|
| `.config/shell/` | `profile.sh` / `aliases.sh` / `functions.sh`，bash 与 zsh 共用同一份环境（XDG 化、`EDITOR`、`BROWSER`、`PATH`） |
| `.config/{zsh,bash}/` | 各 shell 的 aliases、functions、`completions/_scripts.{z,b}sh`（自写脚本的参数补全） |
| `.config/kwm/config.zon`、`.config/kwim/config.zon` | 默认栈的绑定、布局、规则、bar、`startup_cmds`；键盘重复率 |
| `.config/river-classic/` | `init` + `bindings` + `modes` + `rules` + `autostart`，与 kwm 栈并行维护 |
| `.config/river/init`、`.config/sway/` | river 入口（只拉 kwm 与 FIFO）、备用 sway 配置 |
| `.config/proxy/` | 各应用代理配置模板的集合（git、newsboat、qutebrowser、ssh、yt-dlp） |
| `.config/git/config` | 通过 `include` 引入机器本地的 `user.inc` / `proxy.inc`（不入库） |
| `.config/mpd/`、`.config/ncmpcpp/` | 音乐守护进程与客户端 |
| `.config/kanshi/config` | 多显示器 profile（内置屏 2K + HDMI 1080p） |

`etc/` 的内容见 [§7](#7-包镜像与缓存)，脚本分类见 [§9](#9-脚本层)。

---

## 3. 合成器栈与会话生命周期

会话入口是 `.local/bin/startw`（默认参数 `kwm`，带 zsh/bash 补全）：

```sh
startw                  # = startw kwm
startw kwm              # river 0.5 + kwm（默认）
startw river-classic    # 经典 river
startw river            # 纯 river，无 WM
startw sway             # 备用 sway
startw dwl              # dwl（X11 工具链）
```

每条分支启动前都会先跑 `prepare-damblocks-fifo`，确保状态栏 FIFO 早于合成器读 bar 存在，然后以 `exec ssh-agent <compositor>` 起会话（会话内继承 SSH agent；另有用户级 `ssh-agent.service`）。

| 操作 | 命令 / 按键 |
|---|---|
| 退出会话 | `Super+Shift+q`（→ `exiland -river` / `-river-classic` / `-sway` / `-dwl`，带 wmenu 确认） |
| 重载配置 | `Super+Shift+r`（三栈统一；kwm 重载 `config.zon`，river-classic 重跑 `init`） |
| 锁屏 | `Super+Shift+w`（`swaylock -f`） |
| 休眠 | `Super+Shift+e`（`hibe`，wmenu 确认后 `systemctl hibernate`） |

常用按键摘要（mod = `Super`，完整表见 [docs/keybinds.md](docs/keybinds.md)）：

| 按键 | 动作 | 按键 | 动作 |
|---|---|---|---|
| `Return` | 终端 | `Space` | 浮动 / 平铺切换 |
| `p` | 启动器 | `e` | 全屏 |
| `q` | 关闭当前窗口 | `j` / `k` | 聚焦下 / 上一个窗口 |
| `1..9` | 切 tag | `Shift+j` / `Shift+k` | 与下 / 上一个窗口交换 |
| `b` | 显示 / 隐藏状态栏 | `z` | zoom（与主窗口交换） |
| `v` | 浮动终端（abduco + dvtm） | `s` | sticky（跨 tag） |
| `r` | 终端内打开 lf | `Ctrl+o` | 自动 swallow 开关 |
| `g` / `Shift+g` | 截全屏 / 选区（进剪贴板） | `Ctrl+Space` | fcitx5 切换 |
| `minus` / `equal` | 音量 ±1% | `[` / `]` | 亮度 ±1% |

细节：[docs/compositors.md](docs/compositors.md)（启动流程、autostart 清单、排查）、[docs/statusbar.md](docs/statusbar.md)、[docs/input-method.md](docs/input-method.md)、[docs/display-power.md](docs/display-power.md)。

---

## 4. 环境要求

- Arch Linux（或足以跑 Arch 包的衍生环境），`archlinux-keyring` 保持较新。
- 跑 `install-user.sh` 的前置检查会要：`git` `stow` `systemctl` `gsettings` `gpg` `fzf`。缺任何一个都会直接退出。
- `install-pkgs.sh` 分三条通道：
  - **pacman**：官方仓库包，`sudo pacman -S --needed`；
  - **AUR**：走 `yay`（`--yay` 会先尝试复用 `~/pkg/yay` 里已构建好的包）；
  - **源码**：`make` / `zig build` / `meson`，克隆到 `~/.local/src`。源码包默认来自 `codeberg.org/unixchad/<pkg>`（`kwim` 来自 `github.com/kewuaa/kwim`），需要的构建依赖（`zig`、`scdoc`、`meson` 等）由对应 profile 自己带上。
- 磁盘外的事：`install-root.sh` 会动 `/etc`、建用户、改防火墙，**只应在目标主机上跑，且先读 diff**。

---

## 5. 安装

### 5.1 一条命令

```sh
git clone git@github.com:GEJXD/dotfiles.git ~/doc/heart/dotfiles
cd ~/doc/heart/dotfiles
./install.sh                                          # 只打印三层各会做什么
./install.sh --install                                # 真装，默认 profile：--base --yay --kwm --ime
./install.sh --install --base --river-classic --mutt   # 换 profile
```

`install.sh` 做三件事：确认 `git` / `stow` 就位（缺就 `pacman -S --needed`）→ 依次跑 [5.2](#52-包层install-pkgssh) / [5.3](#53-用户层install-usersh) / [5.4](#54-系统层install-rootsh)，每一层单独确认 → 结尾列出仍需手填的私有文件（装了 `fzf` 就能直接打开）。`--skip-root` 跳过系统层，不碰 `/etc`。装单台机器建议逐层手动跑，方便看清每步。

仓库约定放在 `~/doc/heart/dotfiles`（外层 `~/doc/heart/` 放机器本地内容：`package-list/`、`.cache/`、`.backup-ssh/`，不属本仓库）。

### 5.2 包层：`install-pkgs.sh`

不带 `--install` 时**只打印**将要执行的命令，可以先把 profile 组合看一眼再动手（包括 `--yay`：预览不会真的去构建 AUR 包）。

```sh
./install-pkgs.sh --base --kwm --ime              # dry-run：只打印
./install-pkgs.sh --install --base --kwm --ime    # 真装
```

| 选项 | 内容 | 通道 |
|---|---|---|
| `--base` | 内核 + headers、按 CPU vendor 选 ucode、按 `lspci` 选 GPU 驱动（NVIDIA → `nvidia-open-dkms`）、`base`/`base-devel`、`linux-firmware`、`lvm2`、NetworkManager、man、`zsh`/`dash`、`sbctl`+`efibootmgr`、openssh、arch-install-scripts、`pacman-contrib`/`reflector`/`rebuild-detector`、neovim、nodejs、firejail、ufw、监控套件（btop/nvtop/ncdu/smartmontools/sysstat/iftop/powertop）、常用 CLI（bat/fzf/git/jq/less/lf/libcdio/poppler/rsync/samba/stow/tree/zip/w3m…） | pacman；`abduco`、`dvtm` 源码 |
| `--yay` | 安装 yay 本身（优先复用 `~/pkg/yay` 里现成的包，否则 clone + `makepkg`）；只要 profile 带 AUR 包，就会在它之前自动构建 | 源码 |
| `--kwm` | **默认栈**：wayland 基础集 + zig + `wlroots0.20` + scdoc，再源码构建 `river`、`kwim`、`kwm` | pacman + AUR + zig |
| `--river` | 同上但不装 kwm / kwim | pacman + zig |
| `--river-classic` | wayland 基础集 + `wlroots0.20` + `dam` + `river-shifttags` + `river-classic`（构建时自动应用 `misc/river-classic-wl-shm-v3.patch`） | pacman + 源码 + zig |
| `--dwl` | wayland 基础集 + `wlroots0.19` + dwl | pacman + 源码 |
| `--dwm` | X11 栈（xorg、`st`、`dmenu`、`nsxiv`、`xob`、`xbanish`、picom、redshift、clipmenu…）+ dwm | pacman + 源码 |
| `--damblocks` | 只补状态栏生成器 | 源码 |
| `--swayimg` | swayimg | meson |
| `--ime` / `--fcitx5` | fcitx5 + chinese-addons + gtk/qt 桥 + anthy + 主题 jade | pacman + 源码 |
| `--mutt` | neomutt、isync、`cyrus-sasl-xoauth2-git` | pacman + AUR |
| `--kvm` | libvirt、dnsmasq、virt-install、virt-manager、qemu-base + spice 系列 | pacman |
| `--bluetooth` | bluez-utils、bluetui | pacman |
| `--coding` | jdk-openjdk + src/doc、tree-sitter-cli、`code` | pacman |
| `--coc-java` | nodejs、npm、jdk21 + src/doc | pacman |
| `--all` | 上面大部分 profile 的组合（含 dwm + river-classic + kwm 三套并存） | — |
| `--linux linux\|linux-lts\|linux-zen` | 指定内核与 headers（默认 `linux`） | — |

`--dwm` / `--dwl` / `--river*` / `--kwm` 都会自动带上各自的音频（pipewire + `wireplumber` + `pipewire-audio`，没有 session manager 会没声音）、公共 Wayland 组件（含 `xdg-desktop-portal(-wlr)`，`pick-wl-mirror` 与门户文件选择器依赖它）、字体（Noto 全家桶 + nerd symbols）、主题依赖。

### 5.3 用户层：`install-user.sh`

```sh
./install-user.sh      # 不能用 sudo；内部已含 stow 与 fix-local-links.sh
```

它按顺序做这些事：

1. 依赖检查（见 [§4](#4-环境要求)）。
2. 建家目录骨架并设权限：`~/dls doc mnt mus pic pkg smb tmp vid`、`~/.gnupg`，XDG 目录 `~/.local/{share,state}`；`umask 027`。
3. 建状态文件，让 cron 与状态栏第一次就能读数：`~/doc/heart/.cache/{wttr,mbsync.cron,newsboat.num,checkupdates-cron.log}`、`~/.local/state/{bash,zsh}/history`、`~/.ollama/history`。
4. 交互询问城市名 → 写 `~/.cache/city`（`wttr` 天气模块用）。
5. 复用已有构建缓存：`~/.cache/yay` → `~/pkg/yay`、`~/.cache/zig/p` → `~/pkg/zig/p`；`/data/virt` 存在则链接并给 `libvirt-qemu` 加 ACL。
6. **`stow -R --adopt --ignore='^\.ssh'`** 把仓库链接进家目录；`--adopt` 会把已存在的同名文件收编为链接。`~/.ssh` 由 stow 忽略、由 `fix-local-links.sh` 单独处理。
7. 跑 `fix-local-links.sh`（[§10](#10-私有数据与-gitignore-策略)）。
8. `chsh -s /usr/bin/zsh`；`systemctl --user enable ssh-agent.service`；有 `gsettings` 则设 `Adwaita-dark`。
9. 缺就补的私有模板：`~/.ssh/proxy.conf`、`btop.conf`、`git/proxy.inc`、`mutt/account*.muttrc`、`newsboat/{proxy.conf,urls}`、`qutebrowser/proxy.py`、`yt-dlp/proxy.conf`、`isyncrc`（git 身份 `user.inc` 无模板，自己写）。
10. 有 `~/doc/.gpg/gpg-keys` 时用 fzf 挑公钥/私钥导入。
11. 导入 crontab：优先 `~/.config/crontab.backup`（由 `sync-config` 生成），否则退到 [.config/crontab.example](.config/crontab.example)。
12. 有 `calcurse` 且日历为空时 `calcurse -i calendar.ical`；刷新 fontconfig 缓存；`setwall` 设壁纸。
13. 询问是否执行 `sync-config-root`（把 shell 配置同步一份给 root）。

`~/.bashrc`、`~/.bash_profile` 若已是真实文件会被改名成 `~/.bashrc~` 再让位给链接。

### 5.4 系统层：`install-root.sh`

```sh
sudo ./install-root.sh
```

行为清单（**破坏性较强，务必先看 `git diff` 与脚本本身**）：

| 组 | 动作 |
|---|---|
| 包 | `pacman -Sy` + 更新 `archlinux-keyring`；按**主机清单**安装：`~/doc/heart/package-list/arch-$(hostname).list`（由 `sync-config` 用 `pacman -Qenq` 生成，在本仓库之外；没有该文件只报错、继续执行） |
| 落盘 | `etc/`、`usr/` 统一 `chmod 755/644` 后 `cp -r --preserve=mode … /`（覆盖同名系统文件） |
| 用户 / 权限 | uid 1000 加入 `kvm`、`libvirt`；创建 `termux` 用户并准备 `authorized_keys`；`~` 收为 750；`/root/cryptkey` 存在则 `400` + `chattr +i` |
| 时间 | `timedatectl set-ntp true` + 启用 `systemd-timesyncd` |
| 防火墙 | `ufw`：放行 192.168.0.0/16 的 SSH、CIFS，libvirt 的 `virbr0`，mpd 8000，`sharepkg` 8080，然后 `ufw enable` |
| 服务 | `sshd`、`systemd-boot-update`、`bluetooth`、`tlp`、`smb`、`dictd`、`cronie`（缺包则跳过）；非虚机时启用 `libvirtd` 并定义/自启 default 网络；装了 `nvidia-utils` 则启用四个 NVIDIA 电源服务；装了 `seatd` 则加 `seat` 组并启用 |
| 镜像 / 缓存 | 启用 `reflector.timer` 并立即刷新一次 mirrorlist；关闭 `paccache.timer`（缓存由 `rmcache` / `sync-pkg` 手动管） |
| 其他 | 装 samba 且无用户时 `smbpasswd -a`；`firecfg` 重建 firejail 符号链接 |

### 5.5 装完之后

```sh
exec $SHELL            # 或重登，让 profile.sh 生效
./fix-local-links.sh   # 之后每次手动 stow 都要补一次
startw                 # 进图形会话
```

---

## 6. 改完之后怎么生效

| 改动 | 生效方式 |
|---|---|
| `.config/kwm/config.zon` | `Super+Shift+r`。`~/.config/kwm/config.zon` 是指向仓库的相对链接，改完即生效；少数项仍需重启会话 |
| `.config/river-classic/*`、`.config/sway/*` | `Super+Shift+r`（重跑 `init` / 重载 sway） |
| `.config/foot/*`、`.config/shell/*`、`.zshrc`、`.bashrc` | 新开终端，或 `source ~/.config/shell/profile.sh` |
| `.local/bin/*` | 立即生效（`~/.local/bin` 整个目录就是指向仓库的软链接，脚本每次执行都读最新） |
| cron 驱动的模块（天气、未读数） | 等下一次 cron，或手动跑对应 `*-cron` 脚本 |
| `etc/**` | `sudo ./install-root.sh`（或单独 `sudo cp` + `sudo systemctl restart <unit>`），部分需重启 |
| `.config/nvim/` | 重启 nvim；插件变更走 lazy.nvim，锁文件 `lazy-lock.json` 一并提交 |
| 行为 / 按键变了 | 同步更新 `docs/` 对应文档（仓库要求二者一致） |

---

## 7. 包、镜像与缓存

### 7.1 镜像站由 reflector 托管

规则只写在 [etc/xdg/reflector/reflector.conf](etc/xdg/reflector/reflector.conf) 里，systemd timer 与手动脚本共用同一份，保证两种路径产出一致：

```text
--save /etc/pacman.d/mirrorlist
--protocol https --completion-percent 100 --score 20   # 完整同步的 https 源，按 MirrorStatus 分数取前 20
--fastest 5                                            # 实测下载速度后保留 5 个（对齐 ParallelDownloads=5）
--download-timeout 30                                  # 测速要下 extra.db（~9 MiB），默认 5s 会把慢源直接判 0
--verbose
```

| 触发方式 | 说明 |
|---|---|
| `reflector.timer` | 每周一次（`Persistent=true` 会补跑，附最多 12h 随机延迟），`install-root.sh` 已 `enable --now` |
| `refresh-mirror` | 手动刷新；`-l` 查看当前源，`-t` 只测速打印、不写盘（无需 sudo） |

注意三点：

- 测速是**真下载**：一次刷新约下载 20 × 9 MiB，耗时 1–2 分钟；
- 是**覆盖式写入**，`ala`（Arch Linux Archive）插入的镜像行、手写的本地源都会丢失，刷新后要重新执行 `ala`；
- 若失败（官方 mirrorstatus API 不可达或无源匹配），reflector 直接退出、不动现有 mirrorlist。
- 想改成国内优先：把 `--score 20` 换成 `--country China --score 20`（境内完整 https 源约 6 个）。

`lsml` 别名可以一眼看当前前 5 个源。

### 7.2 其他 pacman 侧配置

| 文件 | 作用 |
|---|---|
| `etc/pacman.conf` | 并行下载 5、`CheckSpace` 等 |
| `etc/pacman.d/hooks/checkupdates-cron.hook` | 每次升级后以普通用户跑 `checkupdates-cron --now`，状态栏的待更新数立刻归位 |
| `etc/pacman.d/hooks/default-shell-symlink.hook` | bash 包升级后把 `/bin/sh` 重新指回 dash |
| `paccache.timer` | 被 `install-root.sh` 关掉；缓存清理走 `rmcache`、离线包池走 `sync-pkg` |
| `~/doc/heart/package-list/arch-<host>.list` | 每台机器「显式装过的包」全量清单，`install-root.sh` 照它恢复；与 `install-pkgs.sh` 的角色 profile 是互补的两条路 |

---

## 8. 状态栏与 cron 信号

状态行由 `.local/bin/damblocks` 生成（每个模块独立刷新间隔与信号，只在需要时更新，Wayland / Xorg / tty 通用），再按栈消费：kwm 内置 bar 读 `${XDG_RUNTIME_DIR}/damblocks.fifo`、river-classic 用 `damblocks | dam`、sway 用 swaybar。

设计上的关键约定：**重量级信号不放进状态栏进程**，而是由 cron 写进缓存文件，damblocks 只读文件。这样状态栏刷新永远很快，也不会因为网络请求卡住。

```cron
*/15 * * * * ~/.local/bin/wttr --cron                # 天气 → 缓存
*/15 * * * * ~/.local/bin/checkupdates-cron          # 待更新数
*/15 * * * * ~/.local/bin/newsboat-update-cron       # RSS 拉取
*/15 * * * * ~/.local/bin/newsboat-num-cron          # 未读数
*/15 * * * * ~/.local/bin/calcurse-num-cron          # 日程数
*/15 * * * * ~/.local/bin/sync-config-cron           # 包清单 / crontab 备份（12h 节流）
```

完整清单见 [.config/crontab.example](.config/crontab.example)；FIFO 的启动顺序、SIGPIPE 存活、`dam-run` 用 `pgrep` + `flock` 协调多栈的机制见 [docs/statusbar.md](docs/statusbar.md)。

---

## 9. 脚本层

`~/.local/bin` 是指向仓库的软链接，155 个 POSIX shell 脚本按职责分：

| 类别 | 代表脚本 |
|---|---|
| 会话 / 电源 | `startw`、`exiland`、`hibe`、`reload`、`mag`、`wsk` |
| 音频 / 亮度 / OSD | `audio`（wireplumber）、`bright`、`speaker`、`wobd`、`xobd` |
| 截图 / 剪贴板 | `shoot`（grim+slurp）、`clip`、`capture`、`picker`、`cropper` |
| 状态栏 | `damblocks`、`dam-run`、`damblocks-mpdd`、`prepare-damblocks-fifo` |
| 系统 / 更新 | `lsupdates`、`checkupdates-cron`、`refresh-mirror`、`rmcache`、`rmorphan`、`sharepkg`、`os`、`fanmode` |
| 邮件 / RSS / 日历 | `mbs`、`mbs-cron`、`mutt`、`muttauth`、`news`、`newsboat-*-cron`、`dcal`、`calen`、`wttr`、`pomodoro` |
| 媒体 | `lsmus`、`yta`、`ytv`、`id3title`、`img2vid`、`mediatrim`、`gif`、`selwall`、`randwall`、`setwall` |
| 知识 / 文档 | `wiki`（arch-wiki-docs）、`jdoc`、`books`、`address`、`emoji`、`heart` |
| 同步 / 备份 | `sync-*`（见 [§11](#11-同步与备份)）、`backup-gpg`、`backup-mail`、`gpg-*` |
| 代理 / 网络 | `prox`、`getprox`、`phone` |
| 菜单配色 | `wmenu-color`、`wmenu-run-color`、`colors.sh` |

约定：shebang 保留、四空格缩进、小写局部变量 + 大写配置常量、路径一律加引号；带参数的脚本在 `.config/{zsh,bash}/completions/_scripts.{zsh,bash}` 里配补全。完整速查表：[docs/scripts.md](docs/scripts.md)。

---

## 10. 私有数据与 `.gitignore` 策略

`.gitignore` 是**白名单式**：第 2 行 `*` 忽略一切，之后逐条 `!` 放行。所以——新增任何受管文件（尤其 `etc/**`），必须同时补一条 `!` 放行，否则 `git add` 收不到。

不入库的东西分两类：

**运行时数据**（本来就该重生）：浏览器历史与 cookie、NvChad 插件本体（`~/.local/share/nvim`）、fcitx5 用户词典、日历 / 新闻 / 天气缓存、包数据库、zig/go 缓存。

**机密**（永不入库，装完自己填）：

| 模板 | 目标位置 | 内容 |
|---|---|---|
| `.config/git/proxy.inc.example`（另见 `.config/proxy/git/`） | `~/.config/git/proxy.inc` | git 代理；同目录的 `user.inc`（git 身份）**无模板，需手写**，`~/.config/git/config` 会 `include` 两者 |
| `.config/qutebrowser/proxy.py.example`、`search.py.example` | 同名去掉 `.example` | 浏览器代理 / 搜索引擎账号 |
| `.config/newsboat/{proxy.conf,urls}.example` | 同目录 | 订阅源与代理 |
| `.config/yt-dlp/proxy.conf.example` | `~/.config/yt-dlp/proxy.conf` | 下载代理 |
| `.config/isyncrc.example` | `~/.config/isyncrc` | 邮箱 IMAP/SMTP 账号 |
| `.config/mutt/account.md`（写法说明） | `~/.config/mutt/account-{private,public}.muttrc` | 凭据不入库；`install-user.sh` 会生成占位文件，按 `account.md` 填内容即可（`account-unixchad.muttrc` 是仓库里带样例的账号） |
| `.ssh/proxy.conf.example` | `~/.ssh/proxy.conf` | SSH 代理 |
| `.config/btop/btop.conf.example` | `~/.config/btop/btop.conf` | 监控偏好 |
| `.config/crontab.example` | `crontab -`（`install-user.sh` 导入） | 定时任务 |
| `.config/Code - OSS/User/settings.json.example`、`.config/VSCodium/…` | 各自 `settings.json` | 编辑器设置 |
| `.local/share/address/address.example` | 同名去掉 `.example` | 通讯录 |
| `boot/loader/{loader.conf,entries/arch.conf}.example` | `/boot/loader/…` | systemd-boot 条目（含 `resume=` UUID） |
| `etc/samba/smb.conf.example` | `/etc/samba/smb.conf` | Samba 共享 |

`fix-local-links.sh` 负责在每次 stow 之后把这些「必须留在机器本地」的东西摆回原位：`~/.config/kwm/config.zon` 改成指向仓库的相对链接、`~/.local/share/wallpaper` → `wallpaper.png`、`~/mus/.mpdignore` 指回仓库、`~/.ssh` 还原成真实目录（可从 `~/doc/heart/.backup-ssh` 恢复）并修权限、`~/.local/share/nvim` 保证是真实目录而不是链接。

---

## 11. 同步与备份

多台机器（含通过 `termux` 用户拉取）之间靠 rsync 家族同步，全部脚本都遵循**先 `--dry-run` 打印、再交互确认**的习惯：

| 脚本 | 方向 | 内容 |
|---|---|---|
| `sync-config` | 本机 → 仓库 | 生成 `package-list/{arch,aur,code}-<hostname>.list`、把当前 crontab 备份到 `~/.config/crontab.backup`、给投屏用的通讯录脱敏 |
| `sync-config-cron` | 节流层 | 12 小时内只跑一次 `sync-config`，由 cron 每 15 分钟敲它 |
| `sync-config-sys` | `/etc` → 仓库 | 把受管的系统配置（`pacman.conf`、`mirrorlist`、hooks、`xdg/reflector/reflector.conf`、`ufw` 规则、`tlp.conf`…）拉回仓库，供提交 |
| `sync-config-root` | 仓库 → `/root/heart` | 给 root 也铺一份 shell / lf / fzf / vim 配置 |
| `sync-pkg` / `-cron` / `-reverse` | 包池 ⇄ `~/pkg/pacman` | pacman 缓存镜像化，7 天一次；配合 `sharepkg` 起局域网 HTTP 源 |
| `sync-data` | `~/{doc,mus,pic,vid,pkg}` → `/data/` | 冷备到本地大盘 |
| `sync-to <ip>` | 同上 → 远端主机 | 局域网整目录同步 |
| `sync-usb` / `-all` | → 卷标 `usb-*` 的分区 | 离线备份（`e2label` 设卷标） |
| `sync-notify` | — | `sync` + 桌面通知（别名 `sync`） |

想手动触发某个信号刷新，直接跑对应的 `*-cron` 脚本即可，它们只是「算一次并写缓存」。

---

## 12. 修改流程与验证

本仓库没有编译产物和自动化测试，验证靠语法检查 + 在真机上试：

```sh
# 1) 语法
bash -n install-user.sh install-root.sh fix-local-links.sh
sh -n install-pkgs.sh .local/bin/<改过的脚本>

# 2) 空白 / 冲突标记
git diff --check

# 3) 链接影响面（只预览，不落盘）
stow -n -v -t "$HOME" .

# 4) stow 之后确认关键链接仍指向仓库
readlink -f ~/.config/kwm/config.zon ~/.local/share/wallpaper ~/mus/.mpdignore
```

行为相关的改动（合成器、按键、状态栏、服务）要在真实会话里过一遍，并更新 `docs/` 对应文档。

提交规范（沿用现有 2700+ 条历史）：Conventional Commit 短句、祈使语气、必要时带 scope —— `feat(input): …`、`fix(bar): …`、`docs: …`、`chore(foot): …`。一次提交只做一件事；涉及 `/etc`、服务、防火墙时，在正文里点明受影响的主机组件。

---

## 13. 已知问题

- reflector 覆盖 mirrorlist 导致 ALA 行丢失（[§7.1](#71-镜像站由-reflector-托管)）。
- `install-root.sh` 会创建 `termux` 用户、开防火墙端口，属于「按我家网络拓扑写死」的脚本，换环境请逐项审。
- 启动类问题的排查清单（状态栏空白、FIFO、portal 让 Electron 文件选择器报错、kwm `execve failed`）在 [docs/compositors.md](docs/compositors.md#6-常见排查)。

---

## 14. 截图

| 栈 | 图 |
|---|---|
| kwm（river 0.5，默认） | ![kwm](misc/kwm.png) |
| river-classic | ![river-classic](misc/river-classic.png) |
| sway（备用） | ![sway](misc/sway.png) |
| dwm（X11） | ![dwm](misc/dwm.png) |
| dwl | ![dwl](misc/dwl.png) |

---

## 15. 来源与许可

- 早期从 [unixchad/dotfiles](https://codeberg.org/unixchad/dotfiles)（GPL-3.0，上游签名密钥见 [unixchad.asc](unixchad.asc)）fork 并大幅改写；本仓库以 MIT 发布，见 [LICENSE](LICENSE)。上游文件保留其原许可。
- 状态栏 damblocks、dam、dwm/dwl/st 等源码包默认来自上游作者的 codeberg 仓库（`install-pkgs.sh` 的 `check_src`）。
- 结构、编码风格与提交约定见 [AGENTS.md](AGENTS.md)，功能文档见 [docs/](docs/README.md)。
