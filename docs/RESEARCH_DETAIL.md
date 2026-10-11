# 李贤义楼、涂辉龙楼与公共通道 · v28

主要依据[实验楼官方全景 116697227](https://campusvr-en.cuhk.edu.cn/?scene_id=116697227)与[道路全景 116443797](https://campusvr-en.cuhk.edu.cn/?scene_id=116443797)。本地原图在 `references/visual_build_20261008/originals/landmark-instances/labs/` 和 `east-road/`。

## 从原图落实到模型

| 参考 | 已落地 |
|---|---|
| `labs/f5d6456371e1d237.jpg`，Research A 墙与两楼间通道 | A 楼砖格材质改平滑浅墙，保留窄窗；底层分实墙窗间柱与玻璃入口，通道改灰色长条铺地 |
| `labs/3218d7cd1090d494.jpg`，B 楼通道侧 | 去掉原整面铜色竖片，改水平玻璃窗带、浅色层带、深色窗框及局部遮阳板 |
| `labs/2147002f506c512c.jpg`，临景观外廊 | 铜色悬挂竖片改在道路外侧，补上下支架、斜撑、梁与条灯 |
| `east-road/5ddf26ad59a7c61b.jpg`，涂辉龙楼正面 | 重新构造密竖窗鳍，补右部两层退进平台、后退玻璃及细栏杆 |
| `labs/e396dbbf6827f3e1.jpg`，室外楼梯 | 保留原楼梯并补斜底板，落地栏杆由平台中线移到两侧，接入下层退进平台 |

两栋楼增加带真实门洞的贯通公共门厅，补墙、顶棚、灯和座位。B 楼门洞内一根原柱移到门侧。上部跨楼廊的标高调整至既有楼板层带，未扩展为上层可游览实验室。

**尺度与范围**：宽深、整体高度和楼群位置沿用现有模型；窗格数量、退台宽深、公共门厅布局及高架廊位置是拟合。照片中的道路侧栏杆和真实场地高差尚未逐段恢复。内部是用于游戏公共通行的简化空间，不冒充实验室平面或设备布置。两栋实验楼的局部坐标方向没有重新解释为地理真北。

## 本批验证

一次集中运行七个实机机位及 **20/20 段连续实体通行**：两栋公共门厅进出、A 楼穿行、B 楼从楼间通道到道路、外楼梯上下、下层退台两端、整条楼间通道往返。初始位置仅设一次，组内无传送。

画面检查发现 B 楼柱子侵入入口，调整后仅补该门厅的四段往返，**4/4 通过**。同期补遮阳斜撑并更新门厅及外廊两张画面。最终构建 967 ms，无脚本或渲染错误，没有重跑未受影响的其他楼群。

- 初次报告：`tests/artifacts/research_detail_milestone.json`
- 局部收口报告：`tests/artifacts/research_detail_finish.json`
- 实机：`tests/artifacts/research-detail-*.png`
- 模型：`world/visual_campus/ResearchDetail.gd`，通过 `LandmarkBuildings.gd` 接入。

版本 `official-visual-build-28-research-detail`。24 组建筑 / 51 路线 / 65 导航点；新增两个公共门厅和涂辉龙楼临路平台。[实景对照页](LOWER_CAMPUS_VISUAL_COMPARE.html)56 组。整体 Goal 保持 active；下园山侧衔接和整体完成度仍需复核，不能以本批通行通过代表全部建模完成。
