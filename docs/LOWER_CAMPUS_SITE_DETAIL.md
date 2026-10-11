# 下园场地细化 · 2026-10-10

本批实现位于 `world/visual_campus/LowerCampusLandscape.gd`，仍沿用官方全景建造场景和东门原点；24 组原建筑锚点均未移动。当前数据为 v9、44 条地面路线、40 处导航点。南门属于场地入口，未重复计作一栋建筑。

## 依据与实际修改

- [官方南门全景](https://campusvr-en.cuhk.edu.cn/?scene_id=116410029)：低矮校名石墙、石墙前后绿篱、侧置门岗和入口树阵；结合[官方校园地图](https://www.cuhk.edu.cn/zh-hans/page/4908)，把入口放在教学 A/B 间隙，铺设通往中央大道的林荫步道、排水缝及边带。
- [官方荷花池全景](https://campusvr-en.cuhk.edu.cn/?scene_id=116440795)与[建筑师航拍](https://wwjarch.com/Central-Courtyard-of-Chinese-University-of-Hong-Kong-SZ)：池塘位于大学图书馆与学生中心之间，原先场景在学生中心另一侧的矩形水池位置不符，已移除并改为绿化庭院。新池塘位于现有两楼之间，地形真实开口，有池床、挡水岸壁、石材压顶、弧形平台、树阵座椅和白色池端景墙。
- 荷叶由带缺口的径向网格构成，使用 MultiMesh 批量实例；荷花为小型花瓣网格，不再使用方块代替叶片。
- 学生中心池侧补黄色双层凹廊、高位开口和上层红色遮阳段；对应开口处的实体楼板也已留空。既有二层连接楼板仍保留。
- 小地图支持水面色块和不带矩形范围的点状场地记录；池塘导航点移到岸边，取消落在水里的自动路牌。

## 精度边界

入口位于哪两栋楼之间、池塘与两楼的相邻关系有一手图像支持；具体坐标、51 × 26 m 池塘、0.64 m 池床高差、门岗及石墙尺寸仍是适配当前场景的估计。真北未重新标定。当前南门大道是步行连接，照片中的完整车道曲线与校外市政道路尚未重建。教学组团的整体楼翼比例、绿化自然度及图书馆池侧侧墙仍须后续细化。

原始四向全景瓦片和 URL 清单保存在 `references/visual_build_20261008/originals/site-landscape-20261010/`；仅作本地参考，未用作游戏贴图。

## 本批检查

集中 GPU 实机检查覆盖南门入口、大道、池塘两岸及两楼整体关系。首次记录保留为 `tests/artifacts/lower_landscape_initial_failures.json`：防撞柱位于入口测试路线，连续池岸壁封住弧形平台入口。已调整防撞柱间距并在平台连接处断开岸壁；最终 9/9 段连续实体移动通过、6 张视角，构建 694 ms，最终引擎日志无脚本错误。结果在 `lower_landscape_milestone.json`，日志在 `lower-landscape-final.log`。此前已通过的教学楼与中庭完整路线不重复执行。最后将北岸非碰撞铺装向池侧延伸 0.6 m，遮住弧形平台接缝中的草地，该纯装饰收口未额外重跑路线。

![荷花池与学生中心](../tests/artifacts/landscape-refined-pond-student.png)

![南门入口](../tests/artifacts/landscape-refined-south-gate.png)
