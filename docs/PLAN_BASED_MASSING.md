# 教学组团平面与行政楼体量修正

> V42 更新：教学 B 已加深并移动锚点，保持广场前沿；内廊转为侧向，楼梯和后侧路径重接。下文 B 楼旧坐标/旧内廊路线不再证明现状，见 [V42](TEACHING_B_DEPTH_V42.md)。其他楼栋的历史证据不因此升级。

> V41 校正：下文“四排上部办公窗”的历史解释错误，已按三排上窗 + 下方独立四楼门厅/架空空间重建；旧中央后门及其通行坐标已被替换。现状以 [V41 记录](ADMIN_REGISTRATION_V41.md) 为准。

2026-10-10，v14。模型仍使用东门原点，所有建筑 position/yaw 保留。24 组模型、44 条地面路线、47 个导航地点。

## 新证据与形体变化

从 [Rocco Design Architects 一期校园项目](https://www.rocco.hk/?lang=en&view=projects,typology,featured-project&p=comprehensive-master-plan-and-phase-one-construction-of-the-chinese-university-of-hong-kong-shenzhen-campu) 保存了首层、三层、屋顶平面、总体图及轴测图。结合校方 2026 年导览图和 2018 年航拍，识别出 B/C/D 三栋斜向院落，以及独立的 A 组团。此前 B/C 的四面矩形围合、D 的通用围合体量缺少这一关键斜翼。

本批将 B/C/D 改为斜向长楼翼、直侧翼、短连接翼和窄的前侧连廊。保留架空层、B 门厅、C 遮阳门面、D 公共服务门口；B/C 调整成院内单侧首层楼梯。屋顶女儿墙使用平面多边形合并后的外轮廓，消除翼部相交位置多余的矮墙；屋面改为低反射灰色。A 保留既有方正组团和折返楼梯，并按 [教学 A 全景](https://campusvr-en.cuhk.edu.cn/?scene_id=116440778) 增加暖石墙、深色遮阳、玻璃门厅与经管学院标识。

[行政楼四层后门](https://campusvr-en.cuhk.edu.cn/?scene_id=116443793) 和 [背山处](https://campusvr-en.cuhk.edu.cn/?scene_id=116443781) 显示背面成组横窗、四排上部办公窗、玻璃转角与高处平台。校方 [行政楼七楼改造公告](https://jdlab.cuhk.edu.cn/zh-hans/announcement/4545) 明确证实七层存在。模型因此由过矮的上部桥体补成七个模型楼层，背面不再复制正面竖向板墙；正面遮阳、低翼和架空层保留。中央楼梯加宽，补第三段台阶到四层后门，新增平台、栏杆、花池及小门厅，可实际进出。

## 尺度与识别边界

- 建筑师平面支持楼翼组合和院落拓扑，模型未按照图中比例尺整体重标定。斜翼角度、楼宽进深、楼间距仍适配原锚点，不能称为测绘级复原。A/B/C/D 对应关系由建筑师总体图、校方带名称地图和航拍交叉识别。
- B/C/D 当前主体模型为首层架空加四排上层，B 一侧翼更低；各立面层数仍以不同视角可见范围为限。
- 行政楼七层公告仅佐证第七层存在，不等于证明全部实际楼层数量和高度。模型四层平台相对地面 12.4 m、主屋顶顶面 27.52 m、中央梯宽 26 m，均为估计。
- 后门平台及三段楼梯形成可走的游戏连接；真实后山地形与侧向连接尚未测绘配准。没有据一处后门图复原办公室全平面。

## 集中检查

`tests/artifacts/plan_massing_milestone.json`：7 个视角，5 个起始位置、21 段实体移动全部通过。覆盖行政楼全程台阶、四层后门进出，以及 A/B/C/D 受影响的首层路径。首批构建 793 ms，无脚本报错。

最后的屋面/女儿墙/金属板材调整，由 `PlanMassingFinalCapture.gd` 集中复核；另补此前未覆盖的 B/C 共用改位楼梯 4/4 段通过，不重跑已通过的 21 段。最终 7 个视角无报错、构建 765 ms，结果保存在 `plan_massing_final.json`。本批合计 25 段相关通行通过；这不代表整座校园的全面回归测试。

原图与 manifest：`references/visual_build_20261008/originals/massing-plan-20261010/`。代码集中于 `TeachingBlocks.gd`、`TeachingPublicSpaces.gd`、`LandmarkBuildings.gd` 和 `AdministrationBuilding.gd`；配置更新脚本为 `tools/refine_plan_massing.py`。

见 [21 组实景对照](LOWER_CAMPUS_VISUAL_COMPARE.html)。整体建模 Goal 保持 active；这一批完成的是有新平面依据的形体修正，尚未将原锚点间的距离、地形及所有背面统一配准。
