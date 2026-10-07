# Changelog

## 2.0.0-beta1 — Unified Campus V6

Shared Human/Agent campus with physical navigation, 44 exteriors, ten public interiors, structured observation/actions, decision-gated world time, event logs, independent verifier, physical replay and current-product landing menu. Promotes accepted campus development to main while preserving RC1 reproduction. Interior geometry remains inferred.

## Campus world milestones

Masterplan → Architecture V2 → Environment V3 → Exterior V4 → Seamless V5. Each historical branch/report preserves its own measured scope and results; none is rewritten as a surveyed reconstruction.

## 1.0.0-rc1

Frozen historical journey-v1 research baseline, including time/events, transport abstraction, structured agents and evaluation infrastructure. Its scores do not describe the V6 product world.

---

## Preserved historical record

## 1.0.0-phase-d2 — 2026-09-28

- 仅复核中间道路D03和环岛接入D04：四对正反向视角、六种未选定接入假设，两个缺口均保持unknown。
- 旧DAE仅筛查13个既有道路候选的相关性；未找到可定位子集，不扩大三角重审或地面建造。
- 中文F1显示具体缺口与审阅全景数；Agent追加深拷贝gap_review，无新导航对象、路径或规划器。
- 参考viewer、矩阵、续接文档和验证器同步更新；Phase D未完成，Phase E未就绪。

# 更新记录

## V1.0 Phase D — 2026-09-28

- 冻结湖口/前沿/候选岔路及3组地标；4段地面证据，零新增主路径。
- 重新核对湖口与环岛正反向地面，球场视角未补齐跨点缺口。
- 旧DAE实际三角面连通性审计，拒绝把低斜率面当作步行路。
- F1和结构化观察增加分段证据；保持参考与游戏坐标隔离。
- 190/202前沿检查及既有回归通过，下一阶段继续补证。

## V1.0 Phase C — 2026-09-28

- 冻结既有前沿；13项证据矩阵与3组参考地标，无新增主路径。
- 终点真实位置保持 unknown；远景身份不命名，精确摆放标占位。
- F1增加中文调查依据，V双侧观察；相机方向移动与语义导航分离。
- 修正侧向树冠遮挡、中文按键审计登记，完成窗口与既有回归。

## V1.0 Phase B — 2026-09-27

- 沿入口林缘延伸约35.238游戏单位，加入红灰步道、可走草肩、绿化坡和车道/建筑远景。
- 新增可复用路缘和单臂灯；补看环岛与音乐学院北门全景，新增校方中园连接说明。
- 新区域 ZONE_CONNECTOR_UNKNOWN、两段语义步道和 UNKNOWN_CONNECTOR 接入原碰撞导航、ETA和日志。
- C切换林缘/湖边视角，移动保持屏幕方向；真实跨园连接仍未确认。
- 完成两局窗口往返、新段157/166项检查及完整既有回归，修正露水、远景悬空和路面交叠。

## V1.0 Phase A — 2026-09-26

- 基于官方入口全景与题字石照片，向原神仙湖入口外延伸约 38.535 游戏单位，增加灰石铺地、树池、浅阶平台、树带和有界林缘。
- 修正题字石竖向造型与竖排文字；修复转弯铺地缺口和入口陆地边缘露水问题。
- 新增两个可复用环境场景和含 11 类的环境资产目录，保留来源、许可与 verified / inferred / placeholder 区分。
- 新路线接入原物理导航、步行 ETA、中文区域提示和日志；lake-4 观察增加分区、邻近地标与语义路径。
- 完成两局窗口自动路线和原有 V0.7–V0.9 / 晚宴 / Agent / 离线基线回归。真实跨园路线仍未开放，没有导入未授权参考资产。

## V0.9.0 — 2026-09-26

- 在原步道入口增加明确占位的接驳决策点；支持直接走、候车、上车和改变主意。
- 独立 ShuttleSystem 管理班次、上客窗口、离站、运输、到达与可复现延误；不模拟真实校巴线路。
- 复用统一世界时间与原碰撞导航，乘车采用明确标记的 transport abstraction；转场不计入步行距离。
- 中文界面显示正常步行 ETA、预计候车/乘车和抵达时间；开场可选四种情景，候车时保持计时。
- lake-3 观察、board / continue_walking 动作、候车与重规划指标接入原 EventLogger；记录理由来源，不提供决策答案。
- 增加 A–F、迟到/错过乘车及各交通阶段重开的检查。保留地图证据等级、旧玩法和离线基线。

## V0.8.0 — 2026-09-26

- 加入统一 WorldTime；湖区与旧晚宴时钟使用同一运算入口，支持倍率、暂停、显式耗时与重置。
- 湖区新增演示活动与“沿湖赴约”任务，区分提前、准时、迟到、错过；中文时钟、倒计时和结果同步显示。
- 新增通用活动日程生命周期；任务、时间、活动与空间到达分开管理。
- Agent 观察新增时间与活动字段，新增有界 wait；原碰撞导航保留。
- 接入原 EventLogger，记录时间、坐标轨迹、到达结果、距离、无效动作和累计重开；中断不伪造到达。
- 地图与证据等级保持 V0.7 状态，没有新增巴士、建筑、NPC、天气或模型服务。

## V0.7.0 — 2026-09-26

- 主界面新增神仙湖漫步入口，保留原高桌晚宴玩法。
- 新增有限湖岸短段：题字石、灰铺地、缓坡、木栈道、护栏、树带、观景处、白色圆亭、远山及出口导视。
- 中文导览、暂停、重开、规则结尾；演示说明默认隐藏，只通过 F1 打开。
- 同源地形碰撞与导航截面，沿用人物与移动系统；新增结构化近邻语义、合法路点导航与就近查看接口。
- 资料记录补审官方入口与地面湖景全景；外观有据、位置推断、高差及连接占位分别标记。
- 候车点与道路只预留；没有车辆、LLM、新评测矩阵或跨校园连接。

## V0.6.5 — 2026-09-26

- 实拍木牌参考更新；31 条主资料、294 个全景索引、三个分区参考包及四份旧 DAE 空间审计。
- 原件许可与哈希独立记录；未将许可未知图片与网格导入游戏。
