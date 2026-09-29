# 当前路线图 — V0.7 至 V1.0

本节取代下方历史草案：

- **V0.7**：独立、有限的神仙湖空间短段，已实现。证据、通行、语义及限制见 [V07_SPATIAL_SLICE.md](V07_SPATIAL_SLICE.md)。上下园名称表示方向预留，尚未接通实际区域。
- **V0.8**：World Time + Event；已实现共享时钟、活动日程、限时签到、结构化时间观察与原日志集成，见 [V08_WORLD_TIME_EVENT.md](V08_WORLD_TIME_EVENT.md)。
- **V0.9**：Shuttle Choice；已实现步行、等车、乘车与延误重规划；是占位交通抽象，见 [V09_SHUTTLE_ROUTE_CHOICE.md](V09_SHUTTLE_ROUTE_CHOICE.md)。
- **V1.0 Phase A**：已完成有参考支持的神仙湖入口广场延伸、环境资产与语义分区，见 [V10_CAMPUS_JOURNEY.md](V10_CAMPUS_JOURNEY.md)。完整 Upper → Fairy Lake → Lower journey 等待连续地面证据；本轮没有增加 benchmark。

- **V1.0 Phase B**：已完成林缘至路侧有限扩建及未知连接分区，见 [Phase B](V10_PHASE_B_CONNECTOR.md)。Phase C 先核实相邻路口的人行衔接与高差。

## 以下为 V0.6 历史扩展草案（阶段号已被上文替代）

下一阶段只做第一条真实跨区域可玩走廊，不做完整校园。当前 V0.6 的道路、导视和地理分区是原创游戏布局，未声称实际校区比例或精确方位。

## V0.6 已实现

- 当前入口属于 `upper_campus`；合影及晚宴段属于 `high_table_area`。原任务用的细粒度 location ID 保留。
- `WorldRegion.KNOWN_REGIONS` 有 upper_campus、middle_campus、fairy_lake、lower_campus、high_table_area。
- `CONNECTORS` 包含 connector_id/from_region/to_region/approximate_distance/transport_modes/enabled。现有晚宴步行连接开启；未来跨区连接关闭，距离未测量时为 null，不编造里程。
- 东侧 30 游戏单位的下坡道路桩、人行道、树与路灯；养护提示与绿植界定暂未开放路段，道路仍向外延伸。
- 校园接驳站牌、候车地面、WaitingArea/BoardingPoint 锚点、BusStop 语义元数据；`active=false`。没有巴士、时刻表、上下车或车辆 AI。
- Agent 的 `known_regions` 是公开导视知识；`available_actions` 仍只使用已实走的四个 TARGETS。关闭区域与站点请求必须拒绝且不推进时间。

## 首条路线

上园 → 下坡道路 → 中园 → 神仙湖 → 主路 / 湖边步道 → 下园。

先核查参考与许可，再做高差/路面/碰撞，随后建立 region transition 与语义地标。每段量实际游戏步行时间，控制长距离疲劳。阶段验收要求人类与 Agent 走同一物理路线，无隐式传送。

神仙湖同时承担六个角色：视觉地标、导航地标、区域过渡、风景路线、校园生活区、事件地点。湖的岸线与步道关系必须服务路线选择，而不是只铺一块蓝色背景。

- 快路线：主路，更直接、更快。
- 风景路线：湖边步道，稍慢，穿过湖边生活与环境事件。

V0.6 仅记录两条路线，不实现选择策略或完整湖区。真实出口方向、坡度、步行距离需实地或可信图纸核对；全景跳转不能当作可通行道路。

## V0.8 校巴候选

先完成步行跨区连接，再考虑巴士。未来才添加 route_id、ordered_stop_ids、service_days、source_url、verified_at、等待/车行时间与上下车事件。真实时刻表未核实前不发布班次，不把假设呈现为校方信息。

## FairyLakeReferenceSet

| 参考 | 可用内容 | 缺项 |
|---|---|---|
| [官方分区说明](https://admissions.cuhk.edu.cn/node/909) | VERIFIED：湖区处于上下园连接区域 | 坐标、岸线与具体连接点 |
| [校园十周年图集](https://10.cuhk.edu.cn/our-campus) | VERIFIED：官方校园照片入口 | 湖畔照片视角与拍摄点需逐张核验 |
| [官方 VR](https://campusvr.cuhk.edu.cn/) | VERIFIED：导览入口 | 本次连接失败；湖区 scene graph 未提取 |
| GauU-Scene 上下园数据 | VERIFIED：上下园数据存在 | 湖面/步道覆盖、许可、精度待确认 |
| [720yun 场景数据](campus_reference_graph.json) | VERIFIED：神仙湖航拍 pano 92544889、湖入口 25448248、湖边 25448418 | 跳转边不是实走道路；无授权照片导入 |
| 未来实地补拍 | NOT_FOUND：本任务没有用户提供的实地素材 | 湖岸两侧、上下坡接点、分叉、路牌、栏杆高度、步行计时 |

优先补齐四个视点：上园向湖、下园向湖、湖畔分叉、上坡入口。参考照片只放获准的研究库；正式游戏使用原创重建或获授权网格。
