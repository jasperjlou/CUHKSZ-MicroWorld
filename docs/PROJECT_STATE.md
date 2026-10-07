# Campus Environment V3 — 2026-10-07

当前地图分支 `world/campus-environment-v3` 已完成16个地面环境分区。保留44处V2建筑的位置/外壳、道路骨架、湖岸和宏观地形；加入44条入口接入、12段开放短廊、三处湖区地标接入、两处接驳站占位接入、分区铺地、庭院、公共广场、绿化、座椅、路灯、告示板和统一导视。所有新空间记录包含置信、依据与可替换标记。

`启动校园主规划.cmd` 当前打开V3；F1显示中文名称和环境置信。主路线正反向及独立支线使用原角色控制器和真实碰撞检查，截图/性能与V2同机比较。证据属于脚本驱动的开发验收，不是首次玩家测试。原RC1、Agent、科研基线、物理后端和默认项目入口保持不变；不合并main、不修改标签。

[环境设计、验收与局限](CAMPUS_ENVIRONMENT_V3.md)。以下为历史状态。

---

# Campus Architecture V2 — 2026-10-07

当前地图分支 `world/campus-architecture-v2` 已完成44处建筑的首轮风格化建筑外壳：16 A / 27 B / 1 C。V1的位置、道路、湖岸、高程和规划图保持不变。开放基座、柱廊、庭院、立面窗格和屋顶细节已接入；RC1默认场景与Agent科研基线保持独立。建筑外观置信与空间置信分开记录。

[建筑覆盖、性能和验收](CAMPUS_ARCHITECTURE_V2.md) · [逐栋分级](BUILDING_ARCHITECTURE_TIERS.md) · [具体参考缺口](ARCHITECTURE_REFERENCE_GAPS.md)。本节记录V2历史状态，当前开发入口见上方V3。

---

# Campus Masterplan V1 — 2026-10-07

当前地图开发入口为独立 `world/campus_master/CampusMaster.tscn`，分支 `world/campus-masterplan-fast`。上园、中园/神仙湖、下园已统一坐标；61个主要对象含44处建筑体块，6条车行路线、9条步行路线、28个规划节点。湖区轮廓、上下园宏观高差与校园边界已建立。上园 → 神仙湖 → 下园通过原角色控制器的物理巡游。

全校园位置、朝向、尺寸均为 inferred / placeholder；REAL_DISTANCE = UNKNOWN。旧 RC1 仍冻结为科研复现基线，新场景不替换其默认入口或 Agent 导航。本轮明确的地图建设授权取代下方历史“停止地图扩展”建议，仅针对新场景；旧基线继续不改。

交付、启动、截图、置信及回归：[CAMPUS_MASTERPLAN_V1.md](CAMPUS_MASTERPLAN_V1.md)。后续可逐栋升级建筑，不需要先无限补证；不得将推理坐标当作真实测绘。

---

# V1.0 Final RC1 — 2026-09-30

Phase F baseline `71fe452` is immutable. The existing world is frozen; no new map geometry. Added journey-v1 (16 declarative tasks), Reactive/History/PlanHistory, independent state verifier, bounded real-provider opt-in, offline mock/replay, results and report tooling. The existing OpenAI-compatible adapter and physical Agent environment are reused.

No real-model experiment was run: no supported credentials/configuration were present. Mock and loopback receipts are pipeline evidence only. Task scenarios override spawn/time/fictional transport only in benchmark mode; human Phase F remains unchanged. Source freeze, trust boundaries, exact receipts and reproduction: [RC1](V1_FINAL_RC1.md), [protocol](BENCHMARK_PROTOCOL.md), [QA](../QA.md).

Stop map expansion. Next step: controlled real-model pilot and failure analysis. Historical sections below retain their original status.

---

# 当前状态 — V1.0 Phase F

当前权威版本为 `1.0.0-phase-f`，不可变比较基线为 `560a898da54cdb2852c463fabae6b41f92bcb062`（Phase E）。

- 新任务入口“跨园赴约”：上园出发广场 → 神仙湖观景处 → 返回岔路 → 下园活动广场。
- 复用 Phase E 连续路径；端点升级为带导视、座椅、花坛和楼体背景的小广场。道扬书院仅门楼与外部地标。
- Phase F 配置：`systems/data/cross_campus_journey.json`；Phase E `junction_world.json` 保持历史原件。
- 时间、活动、接驳、物理与 Agent 导航沿用既有系统；新增任务进度和跨园评测指标。
- 全部新增几何标明 inferred / placeholder、推理依据和可替换性。无新原图、旧模型导入或现实测绘声明。
- 详情见 [PHASE_F_FULL_JOURNEY.md](PHASE_F_FULL_JOURNEY.md)；最终验证见 [QA.md](../QA.md)。
- 到此停止地图扩展；下一步建议 Final Polish / Benchmark / RC，尚未实施。

下方记录保留各阶段当时的认识；旧“仍是 D2”或“证据不足停建”不代表当前版本与开发政策。

---

# Repository snapshot - 2026-09-29

Requested baseline: V1.0 Phase D2. The current working tree already includes evidence-aware D2 construction and initial Phase E branches; project.godot declares 1.0.0-phase-e. Repository preparation preserves that code without changing game logic. See [current README](../README.md), [repository contents](REPOSITORY_CONTENTS.md), and [construction manifest](../references/regions/fairy_lake/phase_e_construction.json). The frozen-geometry and stop-on-unknown statements below describe earlier snapshots, not current construction policy.

---

# 当前续接优先入口 — Phase D2 实景外观校正

2026-09-29：见 `docs/FIELD_REFERENCE_POLISH_20260929.md`。已根据新照片校正题字石、碎石绿植与既有路灯；`LakeReferenceDetails.gd` 添加纯外观层，68碰撞/38语义锚点不变，五个冻结文件哈希仍不变。两局最终渲染440/0，湖区494/0，连接199/0，Agent94/0，原参考库2128/0。

14张聊天照片已逐张审阅；首次元数据无EXIF日期，归档时桌面原文件已消失，原件0/14待新路径，详情见field_20260929.json。照片里的中式亭不能替换现有圆顶亭，道扬门楼/水库牌未配准。旧14.2GB团结包完成57文件元数据只读盘点，27场景；对象名称/场景读取有限，不确定许可，无资产导入。

仍是Phase D2，不扩展地图；Gap A/B未关闭。旧参考生成器会覆盖viewer手工追加入口，重跑后需保留本轮链接。以下为历史记录。

# 当前续接优先入口 — V1.0 Phase D2

2026-09-28，1.0.0-phase-d2。权威记录：docs/V10_PHASE_D2_GAP_CLOSURE.md、references/regions/fairy_lake/v10d2_gap_closure.json。

两个缺口均未关闭：D03中间地面接缝、D04湖口侧人行开口及过街落脚点。行人连续性仍2 verified / 0 strong inferred / 2 unknown；不能报告未知距离缩短。四段未配准，五个几何文件冻结，0新增路段，Phase E未就绪。

本轮复看湖口、环岛、北门、书院站四个官方全景和正反向地面；书院站斑马线不能移作湖口过街证据。六种接入假设都保留unknown。DAE仅复核旧13个road候选的相关性，0可定位子集，0新增三角重审；不是与全景一致，也不能伪造冲突。

F1显示缺口甲/乙及已审阅全景数；同一来源不代表独立证据。ground_context.gap_review兼容附加且深拷贝，不加入导航对象或correct_route。只运行最新tools/update_phase_d2_references.py；旧D工具会覆盖新运行时字段。验收见QA.md。

下一步仅补两处重叠地面实拍/全景，条件不足继续Phase D。以下为历史记录。

# 当前续接优先入口 — V1.0 Phase D

2026-09-28。版本1.0.0-phase-d。权威入口 docs/V10_PHASE_D_GROUND_EVIDENCE_BRIDGE.md、references/regions/fairy_lake/v10d_ground_evidence.json、QA.md。

冻结前沿、湖口、候选环岛和三组C地标；v10d_frozen_baseline.json中5几何文件哈希不变。零新增主路径；湖口→环岛还没走通，不进入Phase E。

四个参考调查段：D01/D02同一湖口全景可见连续地面，D03中间地面缺图，D04车道可见但行人接入未知。行人连续性2verified/2unknown，几何外观3verified/1unknown，游戏配准4unknown。不得把计数换成路线百分比或距离缩短。

GroundSurvey.gd加载systems/data/ground_survey.json；lake-4新增ground_context，authored_section和reference_candidates分开，candidate_mapping_is_localization=false；不新增reference目标或correct_route字段。F1显示地面信息，C/V保持。

旧DAE实际三角面审计 tools/audit_ground_topology.py：4文件123实例，36命名地面候选、13road命名实例；无湖口配准。低斜率面含屋顶/底面，完整共享边组件不等于可走道路图。复现用固定commit，四个连通性夹具和源哈希验证。

资料更新只运行最新 tools/update_phase_d_references.py；历史A/B/C工具可能覆盖新版本元数据。原始照片、DAE网格未导入游戏。完成190/202前沿检查和既有回归，资料2071项。自动路线不是独立真人试验。

以下为历史续接信息。

# 当前续接优先入口 — V1.0 Phase C

2026-09-28：以 docs/V10_PHASE_C_CONNECTOR_RESOLUTION.md、references/regions/fairy_lake/v10c_frontier_evidence.json 和 QA.md 为准。前沿冻结(1,3.05,111)，四路点和宽度均未改；零新增路径。三组参考锚点未进入游戏，真实注册仍未知。

F1 中文调查、V 双侧看、C 前后看；人类方向随相机，Agent方向保持世界坐标。FrontierSurvey.gd 提供运行时冻结元数据，reference JSON 记录研究证据。lake-4为兼容字段追加。

重要限制：不能把三个全景当三个独立来源，不能把已识别体育馆推成游戏端点身份。下一步先核实湖口题字石到第一个岔路的连续路线，Phase D 不预设方向。使用 tools/update_phase_c_references.py 保留累计资料，勿重跑历史 A/B 更新脚本覆盖 C。

原生窗口实按 C/V/F1 验证；完整两局由脚本持键和碰撞导航完成。保留全部既有未提交工作，未推送或付费评测。

以下为 Phase B 及更早的历史续接信息。

# 项目续接记录

更新：2026-09-27。当前为 **V1.0 Phase B**，不是完整跨园世界。

- Phase B：ForestConnectorLayout/Builder 连续追加35.238游戏单位，ZONE_CONNECTOR_UNKNOWN / UNKNOWN_CONNECTOR 明确真实接点未知。Prefab PaleCurb、SingleArmLamp；C反向观察时人类移动随屏幕，Agent仍世界坐标。
- 新权威记录 docs/V10_PHASE_B_CONNECTOR.md；新段157/166项、既有完整回归及资料1764项通过。32主参考、294全景；环岛/北门多方向审阅，校方文字只证明中园有道路/绿道连接，不定位路口。
- 以下 Phase A 记录保留历史背景；原封闭林缘已向 Phase B 开放。

- 当前可玩入口：`tools/Launch.ps1 -FairyLake` 或主菜单“漫步神仙湖”。原始晚宴场景保留。
- 当前交付：旧入口后新增约 38.535 游戏单位的树池浅阶广场；同一角色和碰撞连续双向通行。路线见 `EntranceLayout.gd`，外观与共享截面见 `EntranceBuilder.gd`。
- 场景/API 的新区域身份见 `CampusZones.gd`、`FairyLakeWorld.location_observation()`，观察版本 lake-4。实际上下园保持未接入。不要把分区 ID 名字当作真实地理验证。
- 主要依据是官方入口全景 VR_42078153 的同点多个朝向与 LAKE_09；原湖景参考 LAKE_06/VR_42078154。所有具体尺寸、坐标、地形拼接仍需区分 inferred / placeholder。
- 两个可复用场景为 SquareTreePlanter、GraniteTerrace；目录 `assets/campus/environment_catalog.json`，历史资产来源调查仍在 `docs/asset_catalog.json`。
- 权威版本说明与结果：`docs/V10_CAMPUS_JOURNEY.md`、`QA.md`。新路线无窗口 379/0，渲染两局 386/0；既有 V0.7–V0.9、晚宴、Agent、规则/随机基线全部通过。自动物理路线不是独立人类实验。
- 检查游戏时使用原生窗口及其实际渲染图；不要把浏览器界面或另一窗口像素当作游戏证据。原生桌面工具只提供按键短按，连续通行通过引擎测试的持键输入和同一碰撞导航验证，不能称为人工持键实走。
- 本轮发现的边界：宽铺地转弯必须共享截面，否则会出现中心线测试漏掉的三角空隙；除中心线外保留全宽/接缝向下射线采样。quit-after 上限不能代替完成行；原基线需要完成 40 局并出现 AGENT CHECKS。
- 后续先补入口林缘之后或湖区另一端的连续地面参考，再扩建；全景热点、鸟瞰图与旧 DAE 数字节点不能证明真实步行连接。当前 DAE 重提取 4 文件/123 实例，没有可定位湖区锚点。
- 保留本地既有未提交工作。本轮未 commit、push、发布或执行付费模型评测。
