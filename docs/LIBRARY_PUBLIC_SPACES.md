# 大学图书馆与下层公共空间

这一轮针对“官方全景建造 · 东门起点”完善大学图书馆及相邻架空层。模型锚点与东门坐标系沿用上一版，当前 24 组模型、40 条路线、32 个地点。小地图新增图书馆 G 门厅、下层共享空间、2F 平台，点击只设置步行目标。

## 完成的改造

- **曲面外景**：上部三排窗改为分段墙、窗洞、凹入玻璃与层板；深色外壳采用大板接缝，两端补齐与侧翼间的墙体。
- **水池与入口附属体量**：池边硬铺装、种植盆、过水桥；低层灰砖入口、深色玻璃、暖色门洞与高竖鳍。
- **地面层**：两处可辨识的公共入口，连续硬地、服务台、共享长桌、座椅、种植盆、暖色墙面、格栅顶棚与灯具。原来露在架空层内部的草地被铺地覆盖。
- **2F 主入口**：中央步行楼梯与宽台阶、封闭踏步侧面、完整木色扶手与平台护栏；黑色门框、侧窗、顶棚条片、灯带、后墙及导视。
- **相邻下层空间**：教学 A/B/C、张岭彬楼、行政楼、学生中心、实验楼 A/B 的柱廊地面、边界嵌条和排水格栅。学生中心使用实际 ID `student_centre`，最终单独查看近景确认铺地已生效。

## 实景依据与范围

| 官方参考 | 用于本轮的可见特征 |
|---|---|
| [Central Mall 图书馆段](https://campusvr-en.cuhk.edu.cn/?scene_id=116440792) | 弧形深色上部立面、三排窄窗、下部高竖鳍、水池、低灰砖入口与暖色门洞 |
| [University Library G](https://campusvr-en.cuhk.edu.cn/?scene_id=41566368) | 玻璃门厅、暖色墙面、顶棚格栅与方灯、公共桌椅 |
| [University Library 2F 主入口](https://campusvr-en.cuhk.edu.cn/?scene_id=41830774) | 宽台阶、木色扶手、顶棚条片与灯带、黑色高门框、入口侧窗 |

原图与资产清单保存在 `references/visual_build_20261008/originals/library-spaces/`，由既有忽略规则排除。模型不直接使用全景图片作贴图。没有复制照片中的艺术作品。

可见特征参考实景；**门厅完整平面、家具数量、附属入口尺寸和层高仍为估计**。这些是可探索的风格化公共空间，不是已测绘的完整图书馆室内。G 与 2F 是导览命名；没有根据名称擅自新增地下室或在地形中挖出未知地下层。东门原点、左右关系与未标定真北的状态不变。

## Skill 使用

查看并采用本机 `redesign-existing-projects` 的“Scan → Diagnose → Fix”流程：沿用 Godot 4.5.1，先定位草地穿入、重复砖纹、入口遮挡与缺少收口，再进行局部改造。其网页 CSS、字体和卡片建议不适用于本轮；用户要求完成一批后集中检验，因此没有采用逐次编辑测试。

## 验收证据

- `tests/artifacts/library_spaces_milestone.json`：8 个近景/外景视角；过水桥、G 入口、下层共享空间、主楼梯与 2F 平台等 **14 段实体通行通过**。第 15 段宽台阶被旧玻璃遮挡，原始失败记录保留。
- `tests/artifacts/library_spaces_final.json`：移除该处玻璃后，宽台阶上下与旁路 **3 段通过**；后续附属入口测试路线从侧墙切入，保留失败记录。
- `tests/artifacts/library_annex_milestone.json`：只复测受影响的附属入口，改从正面进入，**4 段进出全部通过**；最终构建 575 ms。
- `tests/artifacts/library-base-engine.log`：学生中心只改装饰铺地与 ID，最终仅渲染一次确认，不重跑无关通行。

共 21 段通过记录分属三组测试，每组只有一次初始测试位置设置，组内连续行走。两项失败均已定位并处理，不将失败报告删除或声称初次全通过。没有反复运行旧 V6/RC1 或此前全下园路线。

最终图像：`library-spaces-pool-front.png`、`library-spaces-annex.png`、`library-spaces-ground-entry.png`、`library-spaces-lower-lobby.png`、`library-spaces-stairs.png`、`library-spaces-upper-lobby.png`、`library-spaces-teaching-base.png`、`library-spaces-student-base.png`，均在 `tests/artifacts/`。

启动：`启动入口/启动官方全景建造.cmd`。旧窗口需重新打开；右键拖动镜头，F2 俯视，F1 查看坐标与估计说明。当前修改仅保存在本机。
