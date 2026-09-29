# 参考资料库

本目录保存的是 **CUHKSZ MicroWorld 的证据、来源与重建记录**，不是原始素材分发仓库。

项目会使用官方页面、校园导览、全景、实拍照片、公开视频和旧模型等资料来辅助判断校园空间与外观，但所有资料都需要区分“看到了什么”和“能证明什么”。原始照片、地图、全景图块、视频、DAE/FBX/Blender/Unity 资产等，并不会因为被项目引用就自动获得再分发许可。

## 核心原则

空间重建统一使用三档置信标记：

| 标记 | 含义 |
|---|---|
| `verified` | 有较直接、可靠的照片或资料支持 |
| `inferred` | 多条线索可以支持合理推断，但不是测绘结论 |
| `placeholder` | 为保持世界连续性而建立、以后应允许替换的临时实现 |

项目采用 **evidence-aware inference**：资料不足时可以继续建设最合理的可玩世界，但必须保留来源、推理依据、置信等级和可替换性，不能把推断坐标、尺寸或路线写成真实测量结果。

## 主要入口

- [总资料索引](index.json)：reference id、来源、状态与许可备注。
- [本地参考浏览器](viewer.html)：面向人工审阅的图文入口；fresh clone 中部分本地图片链接可能不可用。
- [神仙湖参考包](regions/fairy_lake/README.md)：当前空间重建资料最完整的区域。
- [上园参考包](regions/upper_campus/README.md)。
- [下园参考包](regions/lower_campus/README.md)。
- [校园交通参考](transport/README.md)。
- [航拍与俯视资料](aerial/README.md)。
- [公开视频线索](student_media/README.md)。
- [现场照片观察记录](regions/fairy_lake/field_20260929.json)。
- [Phase E 推断建设记录](regions/fairy_lake/phase_e_construction.json)。
- [旧项目只读盘点](regions/fairy_lake/local_player_build_inventory.json)。
- [旧模型地面拓扑分析](legacy_models/ground_topology.json)。
- [资产来源与许可说明](../docs/ASSET_PROVENANCE.md)。

## 什么不会上传到仓库

以下内容默认保持本地，不作为 Git 仓库的一部分：

- 实拍照片原件；
- Campus Guide 原始图片或 PDF；
- 官方全景原图与图块缓存；
- 下载的视频与截图缓存；
- DAE、FBX、Blender、Unity / 团结引擎大型原始资产；
- 编译后的旧 Virtual Campus / GTA player；
- 任何许可尚未明确的大型第三方二进制资源。

这些目录通过 `.gitignore` 与本目录的 `.gdignore` 隔离。**不要通过 force-add 或 Git LFS 绕过这个边界。**

约 14.2 GB 的旧 Virtual Campus / GTA 资料目前只保留 inventory、hash、候选项、限制与复用判断；截至当前 Phase E，没有旧模型被正式导入游戏。

## 当前资料边界

2026 年 9 月 29 日补充的 14 张实景照片已经完成逐张观察记录，但当时归档时原桌面路径已经失效，因此当前记录的是 **0/14 原图归档、14/14 观察完成**。观察记录可以支持已经明确看到的对象或局部关系，但不能替代可复查的原图文件。

2026 Campus Guide 用于大尺度拓扑与地标相对关系参考，不被当作正射地图或测绘坐标系。历史绝对路径只说明当时研究机器上的位置，不是 fresh clone 的运行依赖。

## 如何补充新资料

新增资料时优先完成四件事：

1. 在 `index.json` 或对应 region manifest 中记录来源；
2. 标明资料是否已经实际审阅，而不是仅仅发现链接；
3. 写清它支持的结论和不能支持的结论；
4. 若是二进制原件，先检查许可与再分发边界，再决定是否只保留本地。

正常运行游戏不依赖本目录中的原始参考文件。完整 reference validation 可能会检查本机持有的原件，因此它和 source-only fresh clone smoke test 是两种不同的验证。
