# 世界扩展计划（未实施）

V0.5 只保留现有高桌晚宴切片。未来区域预留：upper_campus、fairy_lake、lower_campus、academic_area、college_area、student_center。以下为设计草图，不是经实地测绘的路线图。

## 空间图

上园生活区 → 下坡连接段 → 神仙湖 → 路线分叉 → 下园 → 教学区/学生中心/书院。

[官方招生说明](https://admissions.cuhk.edu.cn/node/909) 证实中园神仙湖及道路连接上下园；具体路口、步行时间、通行限制、坡度仍为 UNVERIFIED。不能把新医学院“神仙湖校园”当作上述湖岸路线的同义词。

每次只开放一个已验证 WorldRegion，区域入口显式连接；先确认实际通路，再加入语义对象和事件。神仙湖承担方向地标、风景路线、休息和未来事件点，不能只做地图边缘的一片蓝色。

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

## 校巴数据架构

只设计数据，不实现车辆或站点：

- BusStop：stop_id、display_name、region_id、boarding_anchor。
- BusRoute：route_id、ordered_stop_ids、service_days、source_url、verified_at。
- Schedule：departure_times 或 interval，明确工作日/周末例外。
- Vehicle：route_id、current_segment、capacity（未来仿真）。
- Board/Exit：合法状态与站点、上下车事件。
- TravelTime：walk_time 与 wait_time + travel_time + 接驳步行时间对比。

真实时刻表未核实，不硬编码班次或把假设等待时间呈现为校方信息。先步行区域连通，再做固定班次确定性交通，最后才考虑更复杂决策任务。
