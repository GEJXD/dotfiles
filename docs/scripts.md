# `~/.local/bin` 脚本速查

本文档收录键盘绑定和自启动里引用到的脚本，说明作用与常用参数。完整清单以 `ls ~/.local/bin` 为准。

## 会话 / 电源 / 锁屏

| 脚本      | 作用                                                                 |
|-----------|----------------------------------------------------------------------|
| `startw`  | 启动 Wayland 会话（`startw [dwl\|river-classic\|river\|kwm\|sway]`） |
| `exiland` | 退出合成器（`-river` / `-river-classic` / `-sway` / `-dwl`）         |
| `hibe`    | 休眠（wmenu 确认后 `systemctl hibernate`）                           |
| `mag`     | 放大镜开关                                                           |
| `wsk`     | wshowkeys 按键可视化开关                                             |

## 音频 / 亮度 / OSD

| 脚本            | 作用                                                             |
|-----------------|------------------------------------------------------------------|
| `audio`         | 音量/麦克风控制（wireplumber）。参数：`sink`/`source` + `--minus | --plus | --minus10 | --plus10 | --mute`   |
| `bright`        | 背光控制（brightnessctl）。参数：`--minus                        | --plus | --minus5  | --plus5  | --minus10 | --plus10 | --min | --max` |
| `speaker`       | 交互式切换音频输出                                               |
| `wobd` / `xobd` | OSD 守护进程（wob / xob）                                        |

## 截图 / 剪贴板

| 脚本      | 作用                                                                                                          |
|-----------|---------------------------------------------------------------------------------------------------------------|
| `shoot`   | 截图（grim+slurp）。参数：默认当前输出、`--geo` 区域、`--all` 全部；保存到 `~/tmp/screenshots` 并复制到剪贴板 |
| `clip`    | 剪贴板历史（`cliphist`）。`--wipe` 清空                                                                       |
| `capture` | 录屏                                                                                                          |
| `picker`  | 颜色拾取                                                                                                      |
| `cropper` | 图片裁剪辅助                                                                                                  |

## 通讯 / 文档 / 知识

| 脚本      | 作用                                      |
|-----------|-------------------------------------------|
| `address` | 通讯录（`--record` 添加、`--multi` 多选） |
| `wiki`    | 搜索 arch-wiki-docs 并在浏览器打开        |
| `heart`   | 在仓库里搜索并编辑 dotfiles 文件          |
| `jdoc`    | 搜索 openjdk 文档                         |
| `books`   | 用 zathura 打开书籍                       |
| `emoji`   | emoji 选择器                              |

## 音乐 / 媒体

| 脚本                                               | 作用                    |
|----------------------------------------------------|-------------------------|
| `lsmus`                                            | 列出当前播放曲目（mpc） |
| `id3title` / `id3trck`                             | MP3 标签工具            |
| `yta` / `ytv`                                      | yt-dlp 下载音频 / 视频  |
| `rename-dlp` / `rename-lowercase` / `rename-space` | 文件重命名              |
| `img2vid` / `mediatrim` / `gif`                    | 媒体处理                |
| `selwall` / `randwall` / `setwall`                 | 壁纸选择 / 随机 / 设置  |

## 系统信息 / 更新

| 脚本                   | 作用                                 |
|------------------------|--------------------------------------|
| `checkupdates-cron`    | 检查可更新软件包（配合 pacman 钩子） |
| `lsupdates`            | 通过通知列出可更新包                 |
| `lsoutputs`            | 列出显示器输出                       |
| `os`                   | 系统信息                             |
| `rmcache` / `rmorphan` | 清理缓存 / 孤立包                    |
| `fanmode`              | 风扇模式（MSI isw）                  |
| `phone`                | 手机相关                             |

## 日历 / 天气 / 邮件 / 新闻

| 脚本                       | 作用              |
|----------------------------|-------------------|
| `dcal`                     | 日历通知          |
| `wttr`                     | 天气通知          |
| `calen`                    | 日历              |
| `mbs` / `mbs-cron`         | isync 邮件同步    |
| `mutt` / `muttauth`        | 邮件客户端 / 认证 |
| `news` / `newsboat-*-cron` | RSS 阅读          |
| `pomodoro`                 | 番茄钟            |

## 其他工具

| 脚本                                                               | 作用                |
|--------------------------------------------------------------------|---------------------|
| `reload`                                                           | 通用重载脚本        |
| `sync-config` / `sync-pkg` / `sync-data` / `sync-to` / `sync-usb*` | 数据同步            |
| `backup-gpg` / `backup-mail`                                       | 备份                |
| `gpg-*`                                                            | GPG 加密辅助        |
| `getprox` / `prox`                                                 | 代理切换            |
| `sa` / `saddle` / `prefix`                                         | 文本处理            |
| `ttyper-gen-*`                                                     | 打字练习生成        |
| `wmenu-color` / `wmenu-run-color`                                  | 带配色的 wmenu 封装 |
