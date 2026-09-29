# 神仙湖参考包

本目录是 CUHKSZ MicroWorld 当前最主要的空间重建资料包之一，负责记录**神仙湖、湖口连接段、第一岔路以及相关地标**的证据与推断过程。

## 当前状态

项目已经从早期“证据不足则停止建设”的策略，转为 **evidence-aware inference**：

- 有直接资料支持的内容标为 `verified`；
- 有多条线索支持但不是测绘结论的内容标为 `inferred`；
- 为保证世界连续性建立、以后允许替换的内容标为 `placeholder`。

截至 `1.0.0-phase-e`，神仙湖一侧已经通过推断连接到第一岔路，并建立上园、下园、道扬书院及其他区域的方向支路。这里记录的是“为什么这样建”，而不是宣称这些坐标、长度和朝向已经被真实测量确认。

## 主要文件

- [pack.json](pack.json)：本区域参考槽位、缺口与资料组织入口。
- [field_20260929.html](field_20260929.html)：2026-09-29 实景附件的人工观察页面。
- [field_20260929.json](field_20260929.json)：14 张实景附件的结构化观察记录。
- [phase_e_construction.json](phase_e_construction.json)：当前 D2 → Phase E 推断建设清单，是现有分支世界的重要记录。
- [v10d_ground_evidence.json](v10d_ground_evidence.json)：Phase D 地面连续性调查。
- [v10d2_gap_closure.json](v10d2_gap_closure.json)：D2 缺口核查的历史状态。
- [v10c_frontier_evidence.json](v10c_frontier_evidence.json)：Phase C 前沿证据矩阵。
- [local_player_build_inventory.json](local_player_build_inventory.json)：约 14.2 GB 旧项目的只读盘点结果。

更高层的来源信息通过 [总资料索引](../../index.json) 的 `reference_id` 查询。

## 实景照片说明

2026-09-29 的 14 张实景附件已经完成逐张观察，包括神仙湖题字石、湖边道路、草坡、路灯、水库设施提示、道扬书院门楼等信息。相关外观校正见 [FIELD_REFERENCE_POLISH_20260929](../../../docs/FIELD_REFERENCE_POLISH_20260929.md)。

归档时原桌面文件路径已经失效，因此当前状态是：

- 观察记录：14/14；
- 原图稳定归档：0/14。

这意味着可以引用已经记录下来的观察事实，但不能把它写成“仓库里保存了 14 张可复查原图”。

## 如何使用这个参考包

判断局部空间时应优先确认：

1. 是否来自同一路段或同一地标；
2. 是否有正反向、左右侧或跨视角的重叠信息；
3. 能否证明**地面连续性**，而不仅是远处看到了某个建筑；
4. 资料只证明“对象存在”，还是还能证明相对位置、方向和可步行连接。

不能把“目录里存在一个链接”当成“这个视角已经被实际审阅”。也不能把旧 DAE 中的数字节点直接注册为真实校园坐标。

## 旧资产边界

旧 Virtual Campus / GTA 资料目前只作为 reference 使用。现阶段没有旧模型被正式导入当前 Godot 世界，也没有因为旧项目里存在道路或建筑对象，就把它们自动视为当前校园的已验证几何。

本目录的目标是让每一次空间推断都可追溯、可替换，而不是让资料不足永久阻塞世界建设。
