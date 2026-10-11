# 下园实例建筑 — 2026-10-09

“官方全景建造 · 东门起点”本轮完成 11 栋重点建筑的专用外观。保留全部原有位置和朝向，当前 24 组模型、39 条路线、29 个导航地点。原点仍是 East Gate 门槛中心；从门外面向校园，右 +X、入校 -Z、上 +Y。真北尚未标定，尺寸、未完整展示的层数和背面平面仍为估计。

| 建筑 | 本轮可见外观 | 主要依据 |
|---|---|---|
| 张岭彬楼，原教学 D | 交错教学楼翼、深色玻璃侧翼、柱廊梁底、D 门框与双扇门、竖向服务管线 | [教学 D 全景](https://campusvr-en.cuhk.edu.cn/?scene_id=116697228) |
| 李贤义楼，Research A | 白色窄窗外墙、玻璃底层、入口框与实验楼公共廊道 | [两座实验楼廊道](https://campusvr-en.cuhk.edu.cn/?scene_id=116697227)、[校方命名资料](https://www.cuhk.edu.cn/zh-hans/article/9570) |
| 涂辉龙楼，Research B | 路侧高竖向窗鳍、横向层带、楼名牌、廊侧铜色屏风与外部楼梯 | [逸夫东座道路全景](https://campusvr-en.cuhk.edu.cn/?scene_id=116443797)、同上实验楼廊道 |
| 逸夫东座 | 三栋宿舍楼翼、内院、低层公共门廊、外部楼梯与阳台栏杆 | [东座道路全景](https://campusvr-en.cuhk.edu.cn/?scene_id=116443797)、[校方书院简介](https://polysz.cuhk.edu.cn/college/shaw/index) |
| 逸夫西座 | 三栋错层楼翼、两处院落、凸窗框、空调箱、交错双层露台开口及公共基座 | [西座全景](https://campusvr-en.cuhk.edu.cn/?scene_id=116440787)、同上书院简介 |
| 诚道楼 | 狭长白色课堂楼翼、窄竖窗、通透底层、竖向校训面板 | [校方启动区标名照片](https://10.cuhk.edu.cn/en/start-zone)；照片是历史资料，不复刻施工脚手架 |
| 乐天楼 | 长白色窗格楼翼、底层玻璃、挑出玻璃雨棚和红砖入口地面 | [乐天楼全景](https://campusvr-en.cuhk.edu.cn/?scene_id=116846253) |
| 知仁楼 | 窄竖窗、连续空调百叶箱、开敞底层、柱廊庭院与红砖铺装 | [知仁楼外园全景](https://campusvr-en.cuhk.edu.cn/?scene_id=116846254)、同上启动区照片 |
| 知新楼 | 较低的转折楼翼、横向连续玻璃带、底层玻璃与旗杆前院 | [主广场全景](https://campusvr-en.cuhk.edu.cn/?scene_id=116440774)、[一层入口](https://campusvr-en.cuhk.edu.cn/?scene_id=126106538)、同上启动区照片 |
| 道远楼 | 并列白色楼翼、深门廊、格梁雨棚、入口竖向格栅与校训挂幅 | [道远楼全景](https://campusvr-en.cuhk.edu.cn/?scene_id=116440775) |
| 科研楼 | 背面悬挑基座、圆柱、横向遮阳百叶、底层玻璃与柱间通行 | [科研楼后门全景](https://campusvr-en.cuhk.edu.cn/?scene_id=116443791)；背门近景不确认完整塔楼高度 |

知新楼中的黄宜弘梁凤仪图书馆与东门主轴上的大学图书馆分别建模。当前是风格化外景和公共通行空间；房间、实验设备、门控及完整室内没有据此声明为真实复原。逸夫楼高约 34–41 米仅为模型估计，实景近照和历史楼层活动记录不能确认完整层数。

## 实现与参考保存

- `world/visual_campus/LandmarkBuildings.gd`：教学 D、两座实验楼、逸夫东/西座和实验楼架空连接。
- `world/visual_campus/StartZoneBuildings.gd`：诚道、乐天、知仁、知新、道远五个专用轮廓和开窗。
- `world/visual_campus/LowerCampusBuildings.gd`：接入专用模型，科研楼圆柱与后门细节。
- `tools/refine_landmark_buildings.py`：幂等保存 11 个实例档案、来源、估计状态和新路线，不改变原锚点。
- 原始官方图片及导出清单在 `references/visual_build_20261008/originals/landmark-instances/`，由现有忽略规则排除。没有将图片直接作为模型贴图或声明转载许可。

## 本机集中验收

第一批六个外景视角与 **25 段连续实体通行**通过，涵盖张岭彬院落、实验楼 A/B 廊道、涂辉龙外部楼梯及逸夫东、西座院落。报告 `tests/artifacts/landmark_buildings_milestone.json`，构建 498 ms。

第二批六个外景视角与 **21 段公共入口通行**通过。第 22 段科研楼直线测试撞到门廊柱，原始失败保存在 `tests/artifacts/start_zone_buildings_milestone.json`。按柱间可走空间修改路线后，只复测该入口，**5 段进出与返回路线全部通过**，见 `tests/artifacts/research_access_milestone.json`，构建 556 ms。知仁楼截图机位避开前景树冠，重新保存。

三份报告使用同一角色控制器和真实碰撞；每组只有一次初始测试位置设置，组内无传送。这些是开发自动试玩结果，不是人工试玩、测绘验收或帧率基准。此前主线 27 段结果继续保留，未反复重跑旧 V6/RC1 套件。

运行 `启动入口/启动官方全景建造.cmd` 查看新版本；旧窗口需关闭后重新打开才能载入更新。F2 可切换俯视，左上小地图选择地点，右键拖动转镜头，F1 查看坐标与估计说明。
