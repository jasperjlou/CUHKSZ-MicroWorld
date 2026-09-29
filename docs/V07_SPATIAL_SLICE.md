# V0.7 神仙湖空间短段

> 历史阶段说明：V0.8 已在同一空间上加入统一世界时间和限时活动，最新逻辑见 [V08_WORLD_TIME_EVENT.md](V08_WORLD_TIME_EVENT.md)。本文件的地形与证据边界仍适用。

核对日期：2026-09-26。这是有实景依据的有限灰盒，不是已标定的数字孪生，也尚未连接整个上园与下园。

## 已实现路线

主界面选择 **漫步神仙湖**，或运行 `tools/Launch.ps1 -FairyLake`。

题字石旁入口 → 灰色铺地 → 左侧临水木栈道、右侧树带 → 湖畔观景处 → 白色圆亭旁 → 下园方向出口。

路线使用 6 个连续截面，中心线约 88 个游戏单位，步道宽 5.6 个游戏单位。人物沿用原工程约 2.85 单位的碰撞高度；没有为测试缩小角色或取消碰撞。缓坡共用渲染与碰撞网格，水侧栏杆、陆侧绿篱与两端边界限定活动范围。外围视觉延伸不代表开放道路。

当前没有计时任务、天气、巴士动作或新增 NPC。活动时长只是本局行走统计，暂停时不增长。高桌晚宴场景与其任务、验证器保持独立。

## 证据与未知

| 内容 | 等级 | 依据及边界 |
|---|---|---|
| 入口有题字石、灰铺地、树荫与延伸道路 | verified | 官方全景 [42078153](https://campusvr-en.cuhk.edu.cn/?scene_id=42078153) 当前可见角度，辅以 LAKE_09 |
| 湖在画面左侧，木栈道沿岸，金属栏杆配深色扶手 | verified | 官方全景 [42078154](https://campusvr-en.cuhk.edu.cn/?scene_id=42078154) 与 LAKE_06；“左侧”是相机视角，不是指南针方位 |
| 树带在画面右侧，后方有平行灰色道路；前方白色圆顶亭；对岸树山 | verified | 同一地面全景的局部构图 |
| 入口与木栈道串成此短段、弯折、圆亭摆放、游戏宽度 | inferred | 参考可辨识构图进行空间简化；未做摄影测量，不宣称精确相邻或复原坐标 |
| 两端“上园方向／下园方向”的接点、缓坡剖面 | placeholder | 真实连接路线、出口朝向、连续高程：**暂无可靠证据** |
| 长椅、灯具、候车点、远处无名建筑轮廓 | placeholder | 当前选定锚点的准确存在及位置：**暂无可靠证据**；仅作可替换环境与语义预留 |
| 实际路宽、坡度、里程、拍摄日期与现状一致性 | unknown | **暂无可靠证据**；引擎单位不能当作实测米制尺寸 |

“verified 外观”不意味着“verified 坐标”。`FairyLakeLayout.gd` 每项分别保存 presence / position / dimensions / elevation / sources。有依据物体的重建位置为 inferred，缓坡均为 placeholder；缺乏位置依据的占位物及方向接点位置为 placeholder。对象名称带位置证据后缀，节点 metadata 保存完整记录。题字石、圆亭和木栈道的模型都是原创简化几何，官方图片只用于观察，没有复制照片纹理或导入许可不明网格。

这次没有把 LAKE_04 的红色多层亭与该白色圆亭混为同一地标，也没有把其它照片中的不同亭拼入这一个短段。

## 语义与导航接口

`world/FairyLakeLayout.gd` 是路线截面和语义对象的共同来源。语义包含 id、中文名称、type、position、interactable、walkable、obstacle、landmark、destination、semantic_tags、active 与 evidence。集合型对象的 position 是其根节点原点，不是每棵树或整片山的测量中心。语义节点承载物体子节点；连续地形、路面、道路和栏杆通过 `semantic_id` 关联到同一记录。

对象包括 FairyLake（水域）、6 个 Walkable_Path 路点、观景处、方向入口／出口、题字石、圆亭、长椅、岸坡、树带、临水栏杆、远山、灯具、道路、未开放候车点等。

`agents/FairyLakeEnvironment.gd` 提供独立的结构化适配器，不扩展原有 benchmark：

```gdscript
var observation = world.environment_api.observe()
await world.environment_api.step({"type":"navigate", "target":"FairyLake_Viewpoint_01"})
await world.environment_api.step({"type":"inspect", "target":"FairyLake_Viewpoint_01"})
await world.environment_api.step({"type":"navigate", "target":"LowerCampus_Direction"})
await world.environment_api.step({"type":"inspect", "target":"LowerCampus_Direction"})
```

观察是公开近邻语义与已知导览知识，**不是截图视觉识别，也不声称遮挡感知**。水域作为已知区域地标提供；其它近邻对象取 24 游戏单位内。导航目标是地图公开的合法路点，控制器沿共同截面逐点驱动原 CharacterBody3D 的 `move_and_slide`，每段设帧数上限。不使用瞬移、修改物理状态或穿墙捷径。inspect 仍检查实际距离。

Water、Road、inactive BusStop 均不是合法导航目标；没有 wait / board / ride 动作。全校空间骨架的关闭连接仍关闭，新短段的可运行状态不改变参考库的地理连接真实性。

## 验证与证据口径

- `--lake-qa`：完整键盘输入路线、观景交互、结尾、重开清空、程序往返、非法目标、栏杆与暂停；持续采样脚下表面和镜头数值。
- `--lake-render`：相同物理路线在真实渲染窗口执行，输出入口、栈道、观景、圆亭、结尾与演示面板截图。
- 沿用 `--qa`、`--agent-qa` 与参考库校验作为回归。
- 结果在 `tests/artifacts/lake_qa*.json`，运行时语义快照在 `lake_semantics.json`。这些是自动路线与人工看图检查，不是外部玩家首次试玩或真实模型 benchmark。

要达到“熟悉港中深的人快速认出对应路段”的最终验收，仍需熟悉校园的人对照实景确认；目前没有替其作出认定。

## 后续范围

1. V0.7：有限神仙湖空间短段；继续核实真实接点和尺度。
2. V0.8：World Time + Event，加入世界时钟与到场任务。
3. V0.9：Shuttle Choice，步行与等车／乘车的时间选择。
4. V1.0：完整上园 → 神仙湖 → 下园行程，再开展跨策略 benchmark。
