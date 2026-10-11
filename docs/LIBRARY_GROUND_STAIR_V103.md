# 图书馆下层坐席、普通梯与斜翼 V103

2026-10-11，版本 `official-visual-build-103-library-ground-stair-wing`。整个下园 Goal 继续 active；本批不是整层测绘配准完成。

## 新证据与修正

旧GTA可离线恢复，1F几何已交叉用于讨论室、斜排房间和坐席结构。新查看的[官方Ground全景41566367](https://campusvr-en.cuhk.edu.cn/?scene_id=41566367)（pano25181872）明确显示低木质坐席、白板和旁边窄步行梯。V44/V102“有2F–3F大坐席梯，所以G层不应有坐席”的泛化结论撤销；两套结构分别存在，不能混为一套。全景拍摄日未知。

[2024-09-06图书馆更新](https://library.cuhk.edu.cn/zh-hans/event/1064)记录1F设备/三角桌、4F书架重排，因此恢复的旧四楼几何仅作结构参考。[2025-07-18通知](https://library.cuhk.edu.cn/zh-hans/event/1200)记录1F入口施工后重开；其附图是高书墙弧梯照片，不是平面图，照片拍摄日未知。发布/取用日期均不当作拍摄日期。

## 游戏变化

- 105、110、111改独立圆角玻璃室；117/118改圆角前部和宽磨砂带，内部电脑桌保留。
- 112–115移至普通梯侧斜排；119移回相邻斜翼；116转向公共区，打印/饮水设备让出通道。移除原右侧错误G层入口标记，导航转到左側既有入口。
- 新建6级低木质坐席、短侧返台、白板、低吊顶；旁侧2.4m宽窄梯连接0→4.4m，补梯下围护、上口平台与护栏。2F–3F原有高坐席梯保留。
- 二层楼板和下层吊顶改斜向开口。生成器用四条外侧带分片，避免多边形差集返回独立孔环又被三角化填回。
- 补三角桌/脚轮、电脑及彩色椅；新增仅用于本批坐席的43号哑光细木纹，消除原粗大条纹。收尾去掉117/118重复紫色标牌，仅留门号。

具体文件：`LibraryGroundStair.gd`、`LibraryLowerLevel.gd`、`LibraryStudyPods.gd`、`LibraryLowerServices.gd`、`LibraryRegisteredFloors.gd`、`LibraryLobbyDetail.gd`、`LibrarySpaces.gd`、`CampusSurface.gdshader` 和 `campus_visual_build.json`。

## 集中验证

首批31段通过后，右侧直线路径撞三角桌，失败段作废；楼梯物理可用，但画面发现独立孔环导致吊顶仍覆盖，已修复。保留首批25段未受影响的105/110/111及112–115进出记录（索引0–12与19–30），旧楼梯6段不重复计数。最后28段单起点连续上下梯、绕桌、119/117/118进出及返回全部通过；共53条分批有效记录，不是一次53段环游。开口净空、护栏、旧孔填补、坐席高度4项检查通过。

首6图、修复后3图、材质/右侧近景3图均已查看。初坐席图被110玻璃遮挡、初楼梯图被房间墙遮挡，改机位后已补清楚坐席和上口；初上口图已退休。最终坐席图为 `courtyard-refined-library-ground-v103-finish-tiers.png`。最后移除重复标牌属于非碰撞收尾，未重复渲染或路线测试。三个引擎日志均无SCRIPT ERROR/ERROR，初批路线失败如实保留。

- 证据：`references/visual_build_20261008/library_ground_stair_v103.json`
- 图块/年月/来源哈希：`references/visual_build_20261008/originals/library-ground-east-v103/manifest.json`
- 物理：`tests/artifacts/library_ground_stair_v103.json`、`library_ground_stair_v103_final.json`
- 收尾图：`tests/artifacts/library_ground_stair_v103_views.json`
- 回退副本：`.tools/backups/library-ground-stair-before-v103/`；LobbyDetail为按已记录原片段重建的V102副本，其余在对应修改前复制。无提交推送。

## 尚未完成与下一批

尺寸、角度和房间位置仍是公开示意图及现有外壳的拟合。116后侧与外立面/入口亭尚有配准冲突，不能声称整层外壳已精确；117/118成对椭圆共墙、112–115圆角细部、柱网家具及下层梯与二层实际落点需继续核准。4F原单位与1F不同，围边功能和2024改造待对照。V102旧112–119/旧直梯/右G门验收坐标不再适用，未变的共享四室组团证据保留。

下一批以1F全平面和外门全景收紧116/117/118、右翼外壳与入口关系，并核对楼层剖面，再处理四楼；继续保留A区教学A/ICC/东门配准、B–G及图书馆后车道至逸夫、各背面/下层/角落未完项。
