# V1.0 Phase C — Connector Resolution + Landmark Lock-in

交付日期：2026-09-28；全景审阅日期：2026-09-27。版本 `1.0.0-phase-c`。

本轮完成前沿冻结、参考地标调查和运行时调查工具。**新增主路径为零，真实上下园连接仍未解决。** 这是证据调查阶段的交付，不是已完成真实校园配准。

## 冻结基准

`FRONTIER_CONNECTOR_B` = 游戏坐标 `(1, 3.05, 111)`，沿用可导航 ID `UNKNOWN_CONNECTOR` 和 `ZONE_CONNECTOR_UNKNOWN`。游戏坐标可复核，地理锚点与连接方向为 `unknown`；占位几何是 `placeholder`，二者不能混写。

调查前保存 [冻结清单](../references/regions/fairy_lake/frontier_connector_b.json)，包含 Phase B 四个路点、宽度和原布局文件 SHA-256。随后没有移动路线、封口或背景几何。布局脚本只修正语义，因此当前文件哈希可以变化，测试逐点比较位置与宽度。

## 调查方法与新发现

使用现有 294 场景 / 445 热点索引选取邻近地面视角，实际打开并转动三个官方全景。没有把索引总数当作已审阅总数。场景 ID 与 pano ID 分开处理。来源属于同一个官方全景项目，不能计为两个独立来源。

- 书院站环岛 `116384465`：斑马线、浅色路缘、建筑夹道；另一个朝向可见树荫弯道。往中庭方向可见白色窗墙。
- 书院中庭 `116384466`：草坪、裙房、宽阶扶手及上方连桥构成特征组；台阶方向有书院站热点，不能由此直接认定可通行。
- 大学体育馆门前 `116440784`：现场馆名锁定入口身份；深格栅门廊和白色梁架提供外观锚点。反向可见树坡、浅色挡墙及深色塔楼/橙色立面。

三组 `REF_*` 地标只登记在参考层，`game_position=null`、`game_registered=false`。没有凭空将体育馆或书院建到前沿。身份识别与游戏坐标定位是两项不同工作。

四项参考局部特征由未审阅变为直接可见，一项书院站—中庭局部关联为推断；**前沿真实拓扑解决数仍是 0**。此计数只描述参考调查，不能当作五条新建路线或五个已配准地标。

## Frontier Evidence Matrix

| Element | Source | Interpretation | Confidence | Conflict | Missing Evidence |
|---|---|---|---|---|---|
| 冻结前沿 | 冻结游戏基线 | 游戏坐标(1,3.05,111)固定；真实校园拍摄点尚未配准。 | unknown | 游戏坐标已知不等于地理坐标已知。 | 湖口题字石到第一个道路分岔的连续地面视图。 |
| 步道继续与左右岔路 | [VR_42078153](https://campusvr-en.cuhk.edu.cn/?scene_id=42078153) / [VR_116384446](https://campusvr-en.cuhk.edu.cn/?scene_id=116384446) | 实景存在路口；无法把游戏末端唯一绑定到其中一条支路。 | unknown | 热点跳转跨过未见路段。 | 同一岔路来向、去向及左右侧连续画面。 |
| 坡度及台阶 | [VR_116384466](https://campusvr-en.cuhk.edu.cn/?scene_id=116384466) / [LEGACY_DAE](https://github.com/newbie-at-cuhksz/virtual-campus-v2/tree/87e2d897fb2264a6b659407522a525f28f7cf211) | 书院中庭台阶可见；前沿是否接入该台阶未知。 | unknown | 旧模型无已命名湖区锚点，不能与相片做高程配准。 | 前沿锚点、高差参照和坡顶坡底照片。 |
| 书院站斑马线与建筑夹道 | [VR_116384465](https://campusvr-en.cuhk.edu.cn/?scene_id=116384465) | 同点多个朝向直接看到斑马线、路缘和建筑夹道，是可复查的局部路口锚点。 | verified | 不能把当前开阔林缘场景认作这个路口。 | 通向湖口的中间路段；拍摄年代。 |
| 书院中庭台阶与连桥 | [VR_116384466](https://campusvr-en.cuhk.edu.cn/?scene_id=116384466) | 下沉草坪、宽阶、扶手、跨空连桥组合可识别。 | verified | 单独台阶或白墙不具唯一性，应匹配整组特征。 | 与道路路口的连续步行连接及无障碍绕行。 |
| 书院站与中庭局部关联 | [VR_116384465](https://campusvr-en.cuhk.edu.cn/?scene_id=116384465) / [VR_116384466](https://campusvr-en.cuhk.edu.cn/?scene_id=116384466) | 白色窗墙及台阶口视线支持相邻候选，双向热点仅作辅助；局部关联推断。 | inferred | 两个全景属于同一制作来源，不算两个独立来源；没有标定距离。 | 匹配台阶顶端与路口的人行铺地连续细节。 |
| 体育馆有名入口 | [VR_116440784](https://campusvr-en.cuhk.edu.cn/?scene_id=116440784) | 现场馆名、深格栅门廊与白色梁架共同锁定大学体育馆入口外观。 | verified | 馆名证明身份，不证明从湖口到这里的路线。 | 由音乐学院北门至该入口的连续步行路侧。 |
| 体育馆侧挡墙与坡面 | [VR_116440784](https://campusvr-en.cuhk.edu.cn/?scene_id=116440784) | 转向可见浅色挡墙和树坡；存在性可靠。 | verified | 不能将它移植成前沿必经挡墙。 | 墙脚与连续人行面的对应。 |
| 游戏双塔的真实身份 | [VR_116384446](https://campusvr-en.cuhk.edu.cn/?scene_id=116384446) / [VR_116384465](https://campusvr-en.cuhk.edu.cn/?scene_id=116384465) / [VR_116440784](https://campusvr-en.cuhk.edu.cn/?scene_id=116440784) | 继续保留匿名浅色建筑远景；多画面中塔楼形态不同，尚无同一物体匹配。 | unknown | 体育馆侧深色塔楼/橙色立面与游戏浅色双塔明显不同，拒绝同名绑定。 | 至少两个已知拍摄点对同一立面的共同可见特征。 |
| 前沿车行道与行人接点 | [VR_116384446](https://campusvr-en.cuhk.edu.cn/?scene_id=116384446) / [VR_130095287](https://campusvr-en.cuhk.edu.cn/?scene_id=130095287) / [VR_116384465](https://campusvr-en.cuhk.edu.cn/?scene_id=116384465) | 路缘、车道和部分路侧铺地有依据；游戏侧路的连接关系仍未知。 | unknown | 将多个有车道的拍摄点拼接不能证明一条连续人行路线。 | 路口过街点、连续铺地、围栏缺口。 |
| 林缘结束与回看湖面 | [VR_42078153](https://campusvr-en.cuhk.edu.cn/?scene_id=42078153) / [VR_116384446](https://campusvr-en.cuhk.edu.cn/?scene_id=116384446) | 湖口可见湖面；无法标定游戏终点回看湖面的遮挡范围。 | unknown | 当前树密度和宽阔地形是布局近似。 | 由路口回望题字石/湖面的地面照片。 |
| 路牌及接驳站 | [VR_116384465](https://campusvr-en.cuhk.edu.cn/?scene_id=116384465) / [SHUTTLE_SCHEDULE](https://www.cuhk.edu.cn/sites/webmaster.prod1.dpsite04.cuhk.edu.cn/files/inline-images/%E6%A0%A1%E5%86%85_1.jpg) | 书院站是官方全景名及班次表中的定位线索；不据此生成精确站牌。 | unknown | 路线站序不是当前站台位置。 | 带站名、道路朝向和邻接建筑的现场照片。 |
| 真实上下园方向 | [OFFICIAL_MIDDLE_CONNECTION](https://admissions.cuhk.edu.cn/node/909) / [LEGACY_DAE](https://github.com/newbie-at-cuhksz/virtual-campus-v2/tree/87e2d897fb2264a6b659407522a525f28f7cf211) | 中园有连接上下园的道路/绿道；冻结前沿应走哪一支仍无可靠配准。 | unknown | DAE数字节点不提供可验证湖口对应点。 | 至少一段直接连接冻结前沿锚点的可靠地面序列。 |

机器可读表：[v10c_frontier_evidence.json](../references/regions/fairy_lake/v10c_frontier_evidence.json)。每一行明确作用范围；`reference_local_feature` 的 verified 不传播到 `frontier_geography`。

## 多视角对齐结论

| 对照 | 结论 | 处理 |
|---|---|---|
| Phase B 前向 / 道路侧向 / 建筑远景 | 游戏几何在多方向可观察；没有真实同一锚点 | 保留布局，位置标占位、地理锚点未知 |
| Phase B 回看 Phase A 与湖边 | 可看见连续铺地与湖区方向；真实遮挡范围未标定 | 仅作为游戏连续性证据 |
| 书院站前后视角 + 中庭侧向 | 建筑夹道、白色窗墙和台阶可形成参考匹配候选 | 登记参考关系 inferred，等待连续地面序列 |
| 体育馆入口 + 反向塔楼 | 馆名可靠；其深色/橙色建筑与游戏浅色双塔不能强匹配 | 不命名游戏双塔，不把地点硬接入 |
| 旧 DAE 4 文件 / 123 实例 | 现有骨架无已命名湖口锚点、导出单位未标定 | 不用于高程、距离或前沿放置 |

本轮未发现足以改线的“DAE 向左而实景向右”证据：因为 DAE 尚不能绑定同一拍摄点，不能伪造冲突或一致结论。明确冲突是**候选外观不匹配 / 注册缺失**，不是已知校园路线错误。

## 建造门槛决策

两个独立来源支持同一已配准拓扑：未满足。高可信官方全景直接确认当前前沿下一段：未满足。可靠实拍与标定 DAE 一致：未满足。因此 `NO_EXTENSION`，没有新增假转角、路牌、车站或远景命名。

此前 Phase B 的“外观有据、组合推断”仍保留为历史说明。Phase C 将远景的精确位置依据降为 placeholder，补充 geographic_anchor=unknown；终点总体 confidence 从 placeholder 明确为 unknown，几何单独保留 placeholder。没有改变实际路线。

## 运行时工具与兼容

- F1 中文调查面板：当前区域、最近地标、外观/位置依据、冻结前沿、距离、真实连接状态、来源编号。默认隐藏。
- C 保留前后看；V 切换道路侧 / 林坡侧，镜头从 19 缩至 12 游戏单位，避免近处树冠遮画面。
- 人类移动使用相机平面方向；Agent 保持世界方向向量，仍使用同一角色碰撞，不瞬移。
- `lake-4` 增加向后兼容的 `frontier` 字段；location 增加 frontier_id 和 geographic_anchor。行动集合不变，参考层地标不会进入可走目的地。
- 重开清理调查面板和观察方向，原时间、签到、接驳及日志保持原流程。
- 没有新增美术网格/第三方素材；原16个资产、11类目录保留，补齐 unknown 等级。

## 验证

最终结果见 QA.md。新前沿无窗口 176 项通过；最终渲染两局往返 188 项通过，包含正反/左右侧向和 960×640 面板截图。两次完整活动结算均由现有 verifier 执行；无新增 Phase C 路径，故测试终点是冻结的 B 前沿，不虚称走过额外 C 路段。

原生窗口在正常物理导航抵达前沿后，实际按 C、V、V、F1 检查了回看、前向、道路侧、林坡侧及中文面板。截图来自真实 Godot 渲染；连续路线由自动持键与同一碰撞导航驱动，**不是独立真人首次体验测试**。测试窗口的加速时钟不作真人用时估计。

初次旧湖区/接驳回归发现中文检查器漏登记按键 C/V；仅将 `[C]`、`[V]` 加入允许的按键提示，未放宽英文文案检查，重跑通过。

## Phase D 进入条件

继续 reference resolution，先选湖口题字石为真实锚点，取得广场边缘到第一道路岔路的连续地面正反向视图，包含路缘、过街处、挡墙/围栏缺口；再匹配书院站或音乐学院北门方向。补齐坡顶坡底、可靠尺寸参照和拍摄日期。确认同一实际接点后，才决定改正 B 的组合或向上园/下园延伸。

旧 DAE 暂不承担补齐缺失路段的任务，不能把未知自动改成推断。
