# 港中深微型世界 · CUHKSZ MicroWorld

参照校方全景、较新校园实景和公开建筑资料制作的下园 3D 校园。玩家与 Agent 展示使用同一套模型、地面、楼梯和碰撞。

**当前阶段包 `v2.1.6`，V226–V234 图书馆与学生中心精修 + V235 体验整合。** [Windows 下载与发行说明](https://github.com/jasperjlou/CUHKSZ-MicroWorld/releases/tag/v2.1.6)。玩家与 Agent 共用 `world/product/CampusProduct.tscn`；旧 Unified Campus V6 与 RC1 研究线索保留，新一轮全下园精修持续进行，阶段版与未验收开发改动分开。

## 两个入口

- **玩家游玩**：从东门自由探索。WASD 移动、Shift 跑步、右键旋转镜头、滚轮缩放，V 切换第一/第三人称；左上小地图可设目标；F1 查看坐标依据，F2 切换俯视，R 返回东门，Esc 回主菜单。步行使用原基础速度的 2.5 倍。
- **Agent 自动展示**：按章节展示外立面、铺地、连廊、楼梯、图书馆下层、后车道至逸夫、逸夫公共台地及体育馆室内（现 30 章）。章节内使用真实角色物理步行；跨区采用明确淡出剪辑。空格暂停/继续，左右键换章节，Esc 回菜单。它是编排导览，不代表外部模型自主视觉导航。

## 本地运行

安装 **Godot 4.5.1**，导入 `project.godot` 并运行。Windows 启动器可复用本地 `.tools/godot` 引擎或 PATH 中的 Godot。

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/LaunchProduct.ps1 -Mode Menu
powershell -NoProfile -ExecutionPolicy Bypass -File tools/LaunchProduct.ps1 -Mode Human
powershell -NoProfile -ExecutionPolicy Bypass -File tools/LaunchProduct.ps1 -Mode Agent
```

项目顶层仅保留“玩家游玩”和“Agent自动展示”，固定指向 `builds/releases/v2.1.6/Windows/` 的独立程序。旧入口已归档到 `tools/legacy-launchers/`。上面的命令用于工作区开发运行；稳定包与后续未验收修改分开。`Visual` 参数目前兼容转入新玩家模式；`RC1` 仅供开发者复现历史研究。

本次补图书馆 209–213 公共房间、209 培训室、预约取书柜/咨询台、公共石阶与顶面，以及学生中心前梯、301 西门平台、天窗和院落灰砖。完成 [V235 玩家与展示整合](docs/PRODUCT_REVIEW_V235.md)。Agent 七个受影响章节 102 段、5,962 镜头采样通过；复用 23 章旧证据 221 段，合计 323 有效段，并非最终无中断整轮重放。玩家复用本批各结构阶段的局部证据；23 张源码画面及独立包双模式已复核。发布事实以 `docs/releases/v2.1.6-published.json` 为准；v2.1.5 保留回退，完整 Goal 继续。

## 阶段发布与继续精修

当前推进范围包括东门至学生中心、大学图书馆及主入口楼梯下馆内下层、教学 B/C/D 分层场地、图书馆后路至逸夫、知新及旧图书馆、科研与体育区。东门原点保持；场景坐标轴不是已校准的地理北向，尺度和未见空间按资料拟合。

正式版是一个阶段快照。GitHub 与本地按同一版本发布，发布后继续全下园精修；保留固定 tag/构建、既有资料与未完成项，后续未验收改动不直接覆盖稳定版。

- [v2.0.0 阶段发行与验证](docs/releases/v2.0.0.md)
- [当前目标与逐批进展](docs/LOWER_CAMPUS_ACTIVE_GOAL.md)
- [完整覆盖台账](docs/lower_campus_refinement_coverage.json)
- [阶段发布要求](docs/FORMAL_RELEASE_CONVERGENCE.md)
- [可恢复的下一轮交接](docs/NEXT_ITERATION_HANDOFF.md)
- [V145 主线通行与 Windows 候选包](docs/STAGE_ROUTE_EXPORT_V145.md)
- [V144 逸夫西座公共层窗墙与展示](docs/SHAW_PUBLIC_GLAZING_V144.md)
- [V143 逸夫西座平面、折返梯与屋顶山桥](docs/SHAW_WEST_PLAN_V143.md)
- [V142 逸夫东座院落与首层轮廓](docs/SHAW_PODIUM_PLAN_V142.md)
- [V141 图书馆后路至逸夫与公共裙楼](docs/REAR_SHAW_SHOWCASE_V141.md)
- [V140 东门铺面与 A–B 后路](docs/GATE_AB_REAR_ROAD_V140.md)
- [V139 教学 B 与 B–C 下层道路](docs/TEACHING_B_LOWER_DATUM_V139.md)
- [历史 V6 产品与研究说明](docs/UNIFIED_CAMPUS_V6_README.md)

当前局部验收不能代表整个校园精修完成。A–B 后车道已接通，准确配准、部分下层实际房间及全区细节仍在收束；阶段版的 tag、commit、包校验及发布验收保存在交接文件和 `docs/releases/`。

## 开发与验证

只在结构或产品批次完成后集中验证。产品候选的入口、按键和章节物理检查：

```powershell
python tools/run_lower_milestone.py --script StageCameraV218 --log stage-camera-v218-physical-engine --headless
```

GPU 镜头检查在需要时运行；证据保存在本地 `tests/artifacts/`。历史测试有各自模型版本和退休范围，不可把旧坐标的通过记录直接当作当前全区通过。

## 素材与许可

项目自制几何与代码纳入版本管理。原始照片、官方全景及其他参考素材因版权、许可或体积留在本地；参考元数据不授予原件再分发权限。旧 Virtual Campus / GTA 资产不随发行包分发，复用需另行确认许可。保留第三方声明；项目不代表校方背书。

**License pending / All rights reserved unless otherwise stated.** 不对参考来源或第三方材料授予新的统一许可。

当前接续断点见 [下一轮交接](docs/NEXT_ITERATION_HANDOFF.md)。[V190 暂停交接](docs/PAUSE_HANDOFF_V190.md) 作为历史资料索引保留；暂停已由新 Goal 解除。
