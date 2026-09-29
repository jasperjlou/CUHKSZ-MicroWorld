# V1.0 Phase D — Ground Evidence Bridge

日期：2026-09-28；版本 `1.0.0-phase-d`。

本轮完成地面分段调查、旧模型三角面审计和调查工具接入。**尚未证明湖口至第一岔路的连续行人连接，也未完成真实地面桥接。** 现有几何保持冻结，新增可行走段为零。仍应停留在 Phase D 补证，不进入 Phase E 分支判断。

## 冻结范围

调查前保存 [v10d_frozen_baseline.json](../references/regions/fairy_lake/v10d_frozen_baseline.json)：

- 既有 `FRONTIER_CONNECTOR_B`，游戏坐标 `(1,3.05,111)`，可导航别名 `UNKNOWN_CONNECTOR`；地理配准 unknown。
- 湖口参考为 `VR_42078153` / pano `25448248`，以题字石、树池和灰石前庭识别。湖口“外沿”仅指向外可见铺地的尽头，不声称是实测车道接点。
- 第一岔路候选为 `VR_116384446` / pano `69985552`。它是候选环岛，不预设必然是从湖口出发遇到的第一个路口。
- 三组 Phase C 参考地标原样保存，均无游戏配准坐标。
- 五个入口/林缘布局及建造文件的 SHA-256 冻结；本轮验证仍完全一致。未移动路点、宽度、封口或背景资产。

## Ground Evidence Matrix

这里的段落是以可见固定物为边界的**调查单元**，不是等长实测路段，也不是新增游戏路段。D01/D02来自同一个拍摄点的可见连续范围，不算两个独立来源。

| 段 | 范围 | 可见地面 | 局部行人连续性 | 游戏配准 | 来源 |
|---|---|---|---|---|---|
| GroundSegment_D01 | 题字石附近灰石前庭 → 弧形浅阶之间的通行带 | verified | verified | unknown | [VR_42078153](https://campusvr-en.cuhk.edu.cn/?scene_id=42078153) |
| GroundSegment_D02 | 弧形浅阶之间的通行带 → 外向灰石广场可见边缘 | verified | verified | unknown | [VR_42078153](https://campusvr-en.cuhk.edu.cn/?scene_id=42078153) |
| GroundSegment_D03 | 外向灰石广场可见边缘 → 候选环岛接近段 | unknown | unknown | unknown | [VR_42078153](https://campusvr-en.cuhk.edu.cn/?scene_id=42078153) / [VR_116384446](https://campusvr-en.cuhk.edu.cn/?scene_id=116384446) / [VR_130095287](https://campusvr-en.cuhk.edu.cn/?scene_id=130095287) / [旧模型](../references/legacy_models/ground_topology.json) |
| GroundSegment_D04 | 候选环岛接近段 → 候选第一岔路 | verified | unknown | unknown | [VR_116384446](https://campusvr-en.cuhk.edu.cn/?scene_id=116384446) |

逐段的 geometry source、visual source、fixed object sequence、conflict、missing evidence 见 [机器可读矩阵](../references/regions/fairy_lake/v10d_ground_evidence.json)。

### D01 / D02 的可见连续性

湖口全景同时显示灰石铺地、方形树池、两侧弧形浅阶与中间通行带。朝外转动后，中间灰石带在同一拍摄点可见范围内连续通向广场外沿；阶脚可见排水开口，细黑灯柱与树列可作为后续匹配对象。

固定物序列只在同一全景内成立：题字石附近前庭 → 方形树池/弧形浅阶 → 中间通行带 → 外向铺地可见边缘。没有把三根外形相似的灯柱跨画面认作同一物体，没有给相对距离或方位赋米数/指南针值。

### D03：跨拍摄点仍断开

没有找到灰石外沿到环岛接近段的连续地面照片或可唯一对应的接缝。两个全景虽互设热点，但没有共同固定物序列足以证明中间没有转折、台阶或过街。

### D04：车道存在不等于人行接通

环岛反向全景中可见沥青车道、浅色路缘、红灰侧铺地、路边柱、路灯及过街标志。地面构成 verified；湖口行人如何接入、从哪里过街、路缘是否连续可通行仍 unknown。可见固定物列表不是已确认的步行顺序。

## Panorama Chain

294场景/445热点索引用于筛选候选，未宣称全部看过。

| 候选链 | 检查 | 结论 |
|---|---|---|
| 湖口42078153 → 环岛116384446 | 正向铺地、反向车道与侧铺地；互设热点 | 缺共同地面接缝，连续链未成立 |
| 湖口 → 音乐学院北门130095287 → 环岛 | 索引关联及此前北门路侧审阅 | 无证据说明北门必是中间点，不填成绕行 |
| 环岛 → 网球场42078166 → 42078167 | 补看42078166场内多方向；其余关联为元数据 | 场内网栏、球网和灯柱清楚，不能证明围栏外出口或通往湖口的连续步行 |

本轮实际重新审阅湖口、环岛，并补看网球场42078166；没有把未实际进入的42078167标成视觉审阅。全景拍摄日期未知，资料年代变化也未排除。研究过程有交互画面检查，但未另存浏览器截图，不把文字记录称为原图证据。

额外检索“港中深 神仙湖 入口 环岛 步道 实拍”和“香港中文大学 深圳 神仙湖 上园 步行 视频 路线”。搜索包含其他城市同名湖、仙湖植物园等无关结果，均排除。校方散文和早期校园视频线索未提供已验证连续地面序列；没有从未观看视频推断路线。

## DAE ground topology

运行 `tools/audit_ground_topology.py`，直接解析固定commit的 COLLADA indexed triangles，并组合完整父级变换。未使用凸包包络充当道路面。

| DAE | 实例 | 按名筛出的地面候选 | 含road名称 | 三角面 |
|---|---:|---:|---:|---:|
| 1-start-up-zone.dae | 91 | 22 | 11 | 530732 |
| 2-shaw-SC-univ-lib.dae | 8 | 2 | 0 | 586422 |
| 3&5-around-administration-building&TA.dae | 9 | 3 | 0 | 273386 |
| 4-around-teaching-buildings.dae | 15 | 9 | 2 | 218906 |

共4文件、123实例、1,609,446个三角面；36个命名地面候选，13个含road名称实例。54个数字名仍未识别，不能据此排除完整档案里可能存在湖区。

算法用绝对法线与竖轴夹角筛选≤35°的候选面（549,542面），按原导出坐标舍入到5位小数，统计每实例的共享完整边、连通分量、边界边和非流形边。**这些候选可能是屋顶、底面、平台或合并对象，不能称作可走地面。** 分量只反映网格共享边；T形接缝、跨对象接触和未焊接但视觉相连的面未解决，碎片多也不证明道路不通。

四个小型连通性夹具通过，所有源哈希与历史骨架一致，123实例无遗漏、无不支持的primitive。分析脚本初次因XPath多余空格未遍历到实例，被123实例完整性断言拦截；修正后才生成最终报告。没有用失败输出形成结论。

可用于地理配准的湖口—岔路匹配仍为0。没有为任何匿名road赋校园名称，没有把导出unit元数据当真实米数，没有把网格三角邻接度当作道路分岔。详见 [ground_topology.json](../references/legacy_models/ground_topology.json)。

## Evidence Coverage 与 Unknown Gap

- 资料内局部行人连续性：verified 2，unknown 2。
- 可见地面构成：verified 3，unknown 1。
- 游戏位置配准：unknown 4。
- 新增可行走段：0。
- 缺口长度：未知，不能给米数或缩短百分比。

相比 Phase C，缺口现在被定位到两个具体问题：D03的中间地面序列、D04的行人接入。**这表示问题拆解更明确，不代表实际未知距离已经可测地缩短，更不表示50%路线已建成。** 理想连续桥接标准尚未达到；未知区间尚不能用几何方式闭合。

## Junction status

仅保留 `CANDIDATE_JUNCTION_D01` 参考对象，first_junction_confidence=unknown、branches=[]、game_instantiated=false。不建立可导航的 JUNCTION_D01，不赋branch_A/B/C位置，不加入correct_route或预设上园/下园目的地。

## 游戏与 Agent

没有新增网格或资产。F1追加地面调查信息：当前原型段、候选参考段、真实位置未配准、资料内已核实/未知数量及下一缺口。普通HUD不增加研究文字，C/V操作保持原样。

`observe().ground_context` 将 authored_section 与 reference_candidates 分开，registration=unknown，candidate_mapping_is_localization=false。参考段没有position和可走状态；它们不进入objects/destinations。代码保留明确英文命名，演示UI使用中文。

A区参考候选01/02、B区参考候选03仅说明该原型所参照的调查议题，不表示角色已经处在真实地理段。重开后按当前角色位置重新计算原型段；返回观察的副本修改不能污染证据数据。

## 测试与原生巡检

- 前沿检查190/0；两局完整渲染往返202/0，3990次地面/相机采样0错误，12张截图。
- Phase A433/0、湖区494/0、World Time/Event795/0、Shuttle893/0、旧核心279/0、体验343/0、Agent接口94/0。
- Wait、Board、Replanning、Logging、Reset在原接驳/事件套件及前沿结算中回归；无新交通逻辑。
- 资料2071项检查通过，19份原件哈希不变；冻结几何5文件哈希一致。
- 960×640和标准窗口调查面板无明显裁切。原生窗口真实按F1/C/V检查；连续路线由脚本持键及同一碰撞导航完成，不能当作独立真人试验。
- 没有D新增段，因此路线验证至冻结的B/C前沿，不宣称已走通真实环岛。未进行新外部模型评测。

## 下一步

停留在 Phase D。最有价值的下一份资料应从湖口灰石广场外沿开始，连续拍到第一个实际道路分岔，再从分岔回拍相同灯柱、树池和路缘；重点包含铺地接缝、排水边缘、过街落脚处及路缘开口。画面须重叠，保留原图与拍摄日期；无需先提供精确米数。

只有D03和D04得到可相互解释的地面证据，且能绑定真实锚点后，才决定修改既有布局或建设有界片段。Phase E Junction Branch Resolution 暂不启动。
