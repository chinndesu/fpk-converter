# 本 fork 的改动清单

基于上游 `yang1245789/fpk-converter` 的 `v1.0.56`，版本号 `1.1.0`。

## 核心（fpk_converter.py）

| 改动 | 说明 |
|---|---|
| 双 worker | `dual_worker=True` 时启动 GPU、CPU 两个线程共享同一队列，`_workers_alive` 记录存活 worker |
| 线程局部 use_gpu | `use_gpu` 改为 property，各线程独立决定走 QSV 还是 x265 |
| 临时文件唯一化 | `unique_id` 加入线程 id，避免同秒启动撞名 |
| 日志标签 | 关键日志加 `[GPU] ` / `[CPU] ` 前缀，供前端解析 |
| QSV 质量偏移 | `global_quality = CRF + 4`（QSV 与 x265 的刻度不同） |
| QSV 硬解 | `-hwaccel qsv -hwaccel_output_format qsv`，并跳过 `-pix_fmt`；需要缩放时回退软解 |
| GPU 失败降级 | 同线程内改用 libx265 重试一次 |
| 线程数 | 上限跟 `os.cpu_count()`，填 0 自动取一半；双路时 GPU 路只给 1~2 线程 |
| 跳过标记 | `saved_size=-1` 小文件跳过，`-2` 已达标跳过 |
| 记录设备 | 新增 `worker` 列（gpu/cpu），写入时按线程标签自动标注 |
| 路径校验 | 用 `Path(...).parts` 判断 `..`，避免误伤 `xxx..mp4` |
| 数据库保护 | 每日备份、卷未就绪跳过清理、单次删除超 30% 熔断 |

## 页面（web_server.py）

| 改动 | 说明 |
|---|---|
| 最小文件大小 | 配置项 + 输入框，小于阈值跳过 |
| 双路开关 | 与 GPU 加速联动，关 GPU 时自动禁用 |
| 双进度面板 | GPU/CPU 各一条进度条，闲置灰显，显示剩余时间（累计均速 + 平滑） |
| 设备着色 | 日志行按 worker 着色，仅对真正转过码的记录生效 |
| 状态区分 | 成功 / 达标 / 跳过 / 失败 四态 |
| 统计三卡 | 待处理 / 已处理 / 节省(GB)，后台每 5 分钟扫描一次 |
| 扫描深度 | 5 → 20 |
| GPU 可用性探测 | 无 `/dev/dri/renderD*` 时禁用相关开关 |

## 已知限制

- 缩放模式（1080p/自定义）下不做硬解
- 双 worker 同时写 SQLite 依赖 `timeout=10`，未见异常
- 历史记录（改造前）的 `worker` 为空，显示白底
