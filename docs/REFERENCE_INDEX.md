## 最新：Phase D2两缺口复核

- [逐对正反向比较、六种人行接入假设](../references/regions/fairy_lake/v10d2_gap_closure.json)
- [旧DAE相关性筛选](../references/legacy_models/gap_relevance.json)：复用旧三角审计，0可定位子集。
- [本轮结论](V10_PHASE_D2_GAP_CLOSURE.md)：两缺口未关闭；不是新增路线。
- 官方全景42078153、116384446、130095287、116384465本轮重审；4处属于同一来源项目，未另存浏览器原图。

> Phase D：湖口/环岛地面反向核查、补看网球场；4段Ground Evidence Matrix、3条候选热点链均未证明跨点步行贯通。旧DAE三角面报告见 [ground_topology.json](../references/legacy_models/ground_topology.json)，完整结论见 [Phase D](V10_PHASE_D_GROUND_EVIDENCE_BRIDGE.md)。

> Phase C：32条主参考、294全景、445热点保持原规模；新增审阅3个地面全景并锁定3组参考地标。参见 [参考查看器](../references/viewer.html#frontier-review) 和 [前沿证据矩阵](../references/regions/fairy_lake/v10c_frontier_evidence.json)。无游戏资产导入，19份原件哈希不变。

# 校园参考资料索引

V1.0 Phase B / 核对日期：2026-09-27。

当前有 **32条主资料记录**，另有 **294个官方全景场景条目、445条全景跳转**。主库保存了用户原照、16幅官方图片及2份完整PDF；旧模型保留在原研究目录。V0.6.5看过所有16幅图片及选定PDF页，VR抽看神仙湖空中场景；V0.7补审入口42078153和湖畔42078154的默认地面视角。数量不等于完整覆盖。

V1.0 Phase A 补看入口全景 42078153 同一拍摄点朝湖与背湖的多个画面，核对灰石铺地、树池、浅台阶和树带，并以 LAKE_09 修正题字石。只使用视觉依据，没有新增照片纹理或模型导入。反向视角槽位为 PARTIAL；连续高程与上下园连接依然缺证据。见 [本轮入口证据清单](../references/regions/fairy_lake/v10_entrance_evidence.json)、[环境资产目录](../assets/campus/environment_catalog.json) 和 [实施说明](V10_CAMPUS_JOURNEY.md)。

- [可筛选图文目录](../references/viewer.html)：按区域、审核状态检索，查看本地原始资料与来源。
- [主库 index.json](../references/index.json)：每项有来源、权利人、时间、许可、可信度及审核状态。
- [官方VR场景目录](../references/vr/scene_catalog.json)：场景ID和链接可定位；未审阅项明确标 METADATA_ONLY。
- [空间依据](CAMPUS_SPATIAL_NOTES.md) / [覆盖与准入状态](RECONSTRUCTION_STATUS.md)。
- [上园](../references/regions/upper_campus/pack.json) / [神仙湖](../references/regions/fairy_lake/pack.json) / [下园](../references/regions/lower_campus/pack.json)。
- [缺口与定向补拍](../references/unresolved/gaps.json) / [本轮搜索记录](../references/unresolved/search_log.json)。
- [旧模型分析](../references/legacy_models/spatial_skeleton.json) / [投影图](../references/legacy_models/projected_envelopes.svg) / [交通站序](../references/transport/routes.json)。

Phase B 补审 VR_116384446 环岛、VR_130095287 北门及湖口多方向；增加 OFFICIAL_MIDDLE_CONNECTION 校方文字来源。全景数量不变，真实路线仍未验证。见 [Phase B 证据矩阵](../references/regions/fairy_lake/v10b_connector_evidence.json)。

## 使用约定

`REFERENCE_ALLOWED` 表示可按用户要求观察研究，不是版权许可。`ASSET_REUSE_UNKNOWN` 的照片、图纸、模型都不可直接放进游戏；原件在 `originals/`，已被Git和Godot排除，禁止批量复制为纹理。AI重新绘制的木牌另记来源，不冒充原始证据。

可信度分为 GROUND_TRUTH_REFERENCE、STRONG_REFERENCE、SUPPORTING_REFERENCE、VISUAL_INSPIRATION_ONLY、UNKNOWN。可信度与是否亲眼看过独立：官方全景是强来源，未查看场景仍只能当线索。未知拍摄日和朝向保留 UNKNOWN/null。

本地原件不随Git分发。恢复时按条目 source_url 合法获取后核对 sha256；远端内容更新导致哈希不同，应建新版本，不能静默覆盖。用户照片需从保留的原始附件恢复。

## 主资料清单

| ID | 对象 | 区域 | 审核状态 | 来源 |
|---|---|---|---|---|
| USER_PLAQUE_001 | 走路不看手机木牌及连廊 | unresolved | VISUALLY_REVIEWED | 用户附件 |
| OFFICIAL_MAP_PAGE | 校园导览图与交通入口 | campus | SOURCE_TEXT_REVIEWED | [来源](https://www.cuhk.edu.cn/zh-hans/page/4908) |
| OFFICIAL_PHASE1 | 一期校园历史图库 | campus | SOURCE_TEXT_REVIEWED | [来源](https://10.cuhk.edu.cn/phase-i-campus) |
| OFFICIAL_PHASE2 | 二期校园历史图库 | campus | DISCOVERED_UNVIEWED | [来源](https://10.cuhk.edu.cn/phase-ii-campus) |
| OFFICIAL_LAKE_PAGE | 黄昏的神仙湖配图 | fairy_lake | SOURCE_TEXT_REVIEWED | [来源](https://mbm.cuhk.edu.cn/zh-hans/node/4087) |
| OFFICIAL_ZONES | 校园建设分区说明 | campus | SOURCE_TEXT_REVIEWED | [来源](https://www.cuhk.edu.cn/en/page/383) |
| SHUTTLE_PAGE | 校内巴士时刻表入口 | transport | SOURCE_TEXT_REVIEWED | [来源](https://www.cuhk.edu.cn/zh-hans/page/492) |
| MINERVA_GUIDE | 厚含书院生活指南 | upper_campus | SOURCE_TEXT_REVIEWED | [来源](https://minerva.cuhk.edu.cn/page/81) |
| OAL_VIDEO | 官方校园导览视频目录 | campus | SOURCE_TEXT_REVIEWED | [来源](https://oal.cuhk.edu.cn/en/incoming_students_videos) |
| UPPER_OVERALL | 上园书院群航拍 | upper_campus | VISUALLY_REVIEWED | [来源](https://10.cuhk.edu.cn/sites/default/files/2023-11/wechat_image_20230410111057.jpg) |
| UPPER_COURT | 学勤书院入口 | upper_campus | VISUALLY_REVIEWED | [来源](https://10.cuhk.edu.cn/sites/default/files/2023-11/xueqinshuyuan.jpg) |
| LOWER_OVERALL | 下园中央空间 | lower_campus | VISUALLY_REVIEWED | [来源](https://10.cuhk.edu.cn/sites/default/files/2023-11/xiaoyuanhangpaisheyingchenming_2.jpg) |
| LOWER_TEACHING | 教学建筑沿街立面 | lower_campus | VISUALLY_REVIEWED | [来源](https://10.cuhk.edu.cn/sites/default/files/2023-11/jiaoxuelou_2.jpg) |
| LOWER_SPORTS | 大学体育馆 | lower_campus | VISUALLY_REVIEWED | [来源](https://10.cuhk.edu.cn/sites/default/files/2023-11/1_sports_hall_waijingtu.jpg) |
| LAKE_01 | 神仙湖景观 01 | fairy_lake | VISUALLY_REVIEWED | [来源](https://mbm.cuhk.edu.cn/sites/default/files/inline-images/1659604496828597.jpg) |
| LAKE_02 | 神仙湖景观 02 | fairy_lake | VISUALLY_REVIEWED | [来源](https://mbm.cuhk.edu.cn/sites/default/files/inline-images/1659604510114662.jpg) |
| LAKE_03 | 神仙湖景观 03 | fairy_lake | VISUALLY_REVIEWED | [来源](https://mbm.cuhk.edu.cn/sites/default/files/inline-images/1659604525187354.jpg) |
| LAKE_04 | 神仙湖景观 04 | fairy_lake | VISUALLY_REVIEWED | [来源](https://mbm.cuhk.edu.cn/sites/default/files/inline-images/1659604542733512.jpg) |
| LAKE_05 | 神仙湖景观 05 | fairy_lake | VISUALLY_REVIEWED | [来源](https://mbm.cuhk.edu.cn/sites/default/files/inline-images/1659604566142985.jpg) |
| LAKE_06 | 神仙湖景观 06 | fairy_lake | VISUALLY_REVIEWED | [来源](https://mbm.cuhk.edu.cn/sites/default/files/inline-images/1659604580739500.jpg) |
| LAKE_07 | 神仙湖景观 07 | fairy_lake | VISUALLY_REVIEWED | [来源](https://mbm.cuhk.edu.cn/sites/default/files/inline-images/1659604598482104.jpg) |
| LAKE_08 | 神仙湖景观 08 | fairy_lake | VISUALLY_REVIEWED | [来源](https://mbm.cuhk.edu.cn/sites/default/files/inline-images/1659604609923639.jpg) |
| LAKE_09 | 神仙湖景观 09 | fairy_lake | VISUALLY_REVIEWED | [来源](https://mbm.cuhk.edu.cn/sites/default/files/inline-images/1659604623131607.jpg) |
| CAMPUS_MAP | 2026年5月校园导览图 | campus | VISUALLY_REVIEWED | [来源](https://www.cuhk.edu.cn/sites/webmaster.prod1.dpsite04.cuhk.edu.cn/files/styles/crop_freeform/public/2026-06/map260512.jpg_.jpg?itok=T8aeU5ZX) |
| SHUTTLE_SCHEDULE | 2026年9月校内巴士时刻表 | transport | VISUALLY_REVIEWED | [来源](https://www.cuhk.edu.cn/sites/webmaster.prod1.dpsite04.cuhk.edu.cn/files/inline-images/%E6%A0%A1%E5%86%85_1.jpg) |
| ARCH_COURTYARD | Courtyard as Agent 建筑研究册 | lower_campus | SELECTED_PAGES_VISUALLY_REVIEWED | [来源](https://foa-media.arch.hku.hk/media/upload/2020/01/Research_Design_Portfolios_029_WangWeijen_CUHKShenzhenCampus.pdf) |
| SHUTTLE_HISTORIC | 2023新生手册巴士照片 | transport | SELECTED_PAGES_VISUALLY_REVIEWED | [来源](https://osa.cuhk.edu.cn/sites/osa/files/attachments/2023-09/2023%E6%96%B0%E7%94%9F%E6%89%8B%E5%86%8C%E4%B8%AD%E6%96%87%E7%89%8828M%281%29%281%29-Jimmy.pdf) |
| ARCH_PHASE2 | 二期校园建筑师项目说明 | lower_campus | SOURCE_TEXT_REVIEWED | [来源](https://wwjarch.com/The-Chinese-University-of-Hong-Kong-Shenzhen-Phase-ll) |
| LEGACY_DAE | 恢复的校园模型四份DAE | lower_campus | GEOMETRY_AUDITED | [来源](https://github.com/newbie-at-cuhksz/virtual-campus-v2/tree/87e2d897fb2264a6b659407522a525f28f7cf211) |
| PUBLIC_AERIAL_VIDEO | 校园航拍视频线索 | campus | UNAVAILABLE_UNVIEWED | [来源](https://www.bilibili.com/video/BV1vf421B7FA/) |
| OFFICIAL_VR | 官方校园全景及场景目录 | campus | PARTIALLY_VISUALLY_REVIEWED | [来源](https://campusvr-en.cuhk.edu.cn/) |

## 重建工作流

真实参考 → 提取特征 → 记录比例及未知项 → 风格化重建 → 游戏网格 → 碰撞 → 导航 → 语义对象 → Agent World。

本轮木牌完整分析见 [plaque_analysis.json](../references/user/plaque_analysis.json)。原始图低清，只支持可见材料、构图和安装关系，不支持逐笔复原或精确地点。

维护时运行 `python tools/validate_reference_library.py`；旧几何可用 `python tools/audit_legacy_spatial.py` 重审。库的功能是阻止无依据扩建，不是用条目数量证明校园已复刻。
