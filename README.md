# 飞牛 NAS 视频自动转码工具（双路版）

面向飞牛 fnOS 的本地视频转码应用，在上游
[yang1245789/fpk-converter](https://github.com/yang1245789/fpk-converter) 的 v1.0.56 基础上，
增加了 **GPU + CPU 双路并行转码** 等能力。

- 当前版本：`v1.1.0`
- 安装包：[Releases](https://github.com/chinndesu/fpk-converter/releases)

## 本 fork 相对上游的改动

**新增**

- 双 worker 并行：GPU（QSV）与 CPU（x265）各跑一个任务，共享队列、互不重复
- 双进度面板：GPU / CPU 独立显示当前文件、进度、剩余时间，空闲时灰显
- 可调最小文件大小，小于阈值的文件直接跳过
- QSV 硬解（`-hwaccel qsv`），显著降低 CPU 占用
- 跳过原因区分（小文件「跳过」/ 已达标「达标」）
- 记录转码设备（gpu/cpu），日志行按设备着色
- 统计三卡：待处理 / 已处理 / 节省(GB)
- 扫描深度默认 5 → 20

**修复**

- 文件名含 `..`（如 `xxx..mp4`）被误判为路径穿越、静默不入队
- 卷未挂载时启动清理会清空全部记录（新增卷就绪判断、30% 熔断、每日备份）
- GPU 失败自动降级 CPU 重试
- 单路模式下进度不显示、旧进度残留

## 安装

1. 从 [Releases](https://github.com/chinndesu/fpk-converter/releases) 下载 `fpkconverter-*.fpk`
2. 飞牛应用中心 → 手动安装
3. 应用设置 → 授权目录，给视频目录授予读写权限

> 升级前建议备份 `/vol1/@appdata/fpkconverter`（配置与转码记录）。
> 版本号必须为纯数字（如 `1.1.0`），飞牛不接受 `1.0.56-dual.1` 这类后缀写法。

## 说明

- 本应用以 Root 权限运行，以便 ffmpeg 访问 `/dev/dri/renderD*`，请确认信任安装包来源
