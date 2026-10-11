# 行政楼立面分层与公共底层 · v20

2026-10-10。依据官方 Central Mall（116440794）正面原图及 Administration Backdoor（116443793）四向原图继续建模。使用已保存的原始照片，没有改绘参考；全部建筑锚点、坐标轴和既有层高保留。

本批解决的实际问题：正面上部被做成从底到顶同一种白色格栅，缺少照片中独立的暖色下层窗带；两翼底层只有柱子和远处一片不透光玻璃，近距离几乎空置；楼前石铺装没有连续连接中央广场。

- 上部白色格栅改从既有 16.1 m 层线开始，下方恢复 12.4–16.1 m 暖色细竖片、窗下实面和水平收边。区间由现有楼层模型拟合，不是照片测量高度。
- 白色低翼面板使用平滑材质和已有竖缝，移除不符实景的砖格；暗柱也改平滑表面，低翼屋顶用哑光屋面。
- 两翼新增退进玻璃入口、打开的门扇、侧面玻璃、深色顶棚、灯具、座椅及公共服务台。中央通道与两侧外廊保持可走。内部深度、隔墙和家具是推断，未声称还原实际办公平面。
- 前场补连续石铺装、深色回纹、四个独立花槽、低种植槽和树木支撑；后平台补横向屏风、种植边界、门前暖色铺装条与细边带。

实现：`world/visual_campus/AdministrationPublic.gd` 为公共空间模块，`AdministrationBuilding.gd` 负责立面分层及调用。元数据迁移 `tools/refine_administration_public.py` 已执行，带前置版本保护。

一次集中验证 `AdministrationPublicCapture.gd`：两翼门厅往返 8 段，前场/中央台阶/后平台 7 段，共 **15/15** 实体移动通过；6 个实机视角无脚本或渲染错误。构建 782 ms。报告为 `tests/artifacts/administration_public_milestone.json`，日志 `administration-public-engine.log`，截图 `admin-public-*.png`。没有额外重跑全校园测试。

当前 `official-visual-build-20-administration-public`，仍为 24 建筑 / 50 路线 / 54 导航点；实景并排对照增至 39 组。后平台与山坡的高差衔接仍粗糙，上部整体宽高比尚未完成测绘配准；整体 Goal 保持 active。
