# V1.0 Phase A — 神仙湖入口过渡区

本轮在 V0.9 原工程上完成有限入口延伸。旧入口后方现在可连续走入灰石步道、树池台阶广场和林缘尽头，再原路返回湖边。**真实上园—神仙湖—下园全程仍未接通。** 不增加任务、NPC、模型服务或 Agent 控制器。

## 选段依据

先核对既有参考库、空间说明、V0.7–V0.9 文档与下园 DAE 提取。入口端的官方全景提供了直接可见的树池、铺地、台阶和平直通行带；另一端缺少足以确定连续走向的地面参考。因此采用用户允许的 Phase A，不强行连接上下园。

| 来源 | 本轮核看内容 | 使用与限制 |
|---|---|---|
| [官方入口全景 42078153](https://campusvr-en.cuhk.edu.cn/?scene_id=42078153) | 同一拍摄点朝湖和背湖的多个视角；方形树池、浅台阶、灰石铺地、乔木与题字石 | 局部外观关系；没有校准方位角，也不声称完整全周或沿路连续采样。热点名称不是步行连接证明 |
| [LAKE_09 官方照片](https://mbm.cuhk.edu.cn/sites/default/files/inline-images/1659604623131607.jpg) | 高起竖向题字石、竖排“神仙湖”、湖与石基周围植被 | 修正旧横向石块；尺寸和游戏坐标仍为推断 |
| [LAKE_06 官方照片](https://mbm.cuhk.edu.cn/sites/default/files/inline-images/1659604580739500.jpg) | 木栈道、临水栏杆与深色扶手、植被、白色圆顶亭 | 保留原湖段的材质与空间识别元素 |
| [历史模型仓库固定版本](https://github.com/newbie-at-cuhksz/virtual-campus-v2/tree/87e2d897fb2264a6b659407522a525f28f7cf211) | 重提取 4 个 DAE、123 个实例 | 没有命名湖区锚点且单位未校准；只保留为下园骨架线索，不用于确定本次入口位置 |

原图继续保存在 references 的原件目录；19 份原件哈希未变。全景本轮为交互式浏览，没有新增保存的全景截图。照片、全景和历史模型许可未确认，均只作为参考，没有作为纹理或网格导入游戏。

机器可读决策：[v10_entrance_evidence.json](../references/regions/fairy_lake/v10_entrance_evidence.json)。既有 31 条主参考、294 个全景和 445 条热点关系保留。

## 空间与证据等级

- **verified**：照片/全景中有灰石铺地、树池、浅台阶、乔木、竖向题字石，以及原湖段的栏杆、栈道和圆亭。这是外观类别与局部画面关系的验证。
- **inferred**：本游戏的转弯、树池数量、坐标、宽度、植被密度、区域边界与局部路线拼接。
- **placeholder**：连续高程、真实上下园接点、原型接驳站与班次、林缘封闭边界。

新增中心路线长度约 **38.535 个游戏单位**，不是实测米数。原六个湖区路点和交通起终点不变，向入口外增加三点。玩家沿同一碰撞地面移动，没有通过路线传送衔接；原 V0.9 乘车仍为显式交通抽象。

广场转弯使用共享截面生成铺地和碰撞，修复首轮窗口检查发现的三角空隙。两侧补陆地草坡，避免水面从广场边缘露出形成桥状错觉。树池与浅阶采用淡灰石材、低多边形树冠，保持既有风格；原题字石改为竖向造型及竖排文字。

## 资产组织

[环境资产目录](../assets/campus/environment_catalog.json) 列出 Architecture、Road、Path、Terrain、Vegetation、StreetFurniture、Signage、Lake、Shuttle、Landmark、Background，记录路径、版本、来源、许可、证据等级和可复用状态。原历史模型调查目录通过 environment_catalog 指向它，没有覆盖历史来源记录。

新增两个可独立实例化的场景：`SquareTreePlanter.tscn` 与 `GraniteTerrace.tscn`。后者包含三级浅阶与平台，生产环境用连续斜面碰撞近似台阶，不引入复杂爬阶系统。其它既有程序化资产如实登记为 procedural，并未假称已经全部改造成 prefab。

## 分区与语义

| 分区 | 当前状态 |
|---|---|
| ZONE_UPPER_CAMPUS | 上园，未接入；placeholder |
| ZONE_UPPER_CONNECTOR | 当前游戏入口过渡区，开放；inferred，真实上园连接未验证 |
| ZONE_FAIRY_LAKE | 原湖边步道，开放；inferred |
| ZONE_SHUTTLE_STOP | 原型候车点，开放；placeholder |
| ZONE_LOWER_CONNECTOR | 原下园方向占位出口，开放；placeholder |
| ZONE_LOWER_CAMPUS | 下园，未接入；placeholder |

新目的地 `Entrance_Path_01`、`Entrance_Forecourt`、`Entrance_TreeWalk_End` 接入原 navigate / inspect。与原湖区使用同一个角色、碰撞和动作协议。route_points 按林缘→广场→旧入口→旧湖段顺序组成连续路径；步行 ETA 使用完整路径。树池有实体阻挡，不能被当作导航目的地。

观察版本为 `lake-4`，保留既有时间/交通字段，增加 `location`（zone、nearest_landmark、semantic_path、confidence、global_connection_verified）及 `zones`。对象保留 walkable / obstacle / landmark / destination / semantic_tags / evidence，并补 zone / connector；场景 metadata 与 API 记录一致。`ZONE_ENTERED` 复用原日志。乘车时 zone 为 IN_TRANSPORT。

```json
{"type":"navigate","target":"Entrance_Forecourt"}
{"type":"inspect","target":"Entrance_Forecourt"}
{"type":"navigate","target":"LowerCampus_Direction"}
```

玩家界面只增加小字号中文当前区域与入口导览；地图证据说明通过就近查看显示。原任务与时钟继续推进，逛广场并不会暂停赴约倒计时。

## 验收

| 检查 | 结果 |
|---|---|
| V1.0 无窗口物理路线 | 379 项，0 失败；2,892 次脚下/镜头采样，0 异常 |
| V1.0 原生渲染窗口两局完整路线 | 386 项，0 失败；2,909 次采样，0 异常；7 张关键截图 |
| V0.7 湖段 / V0.8 时间活动 / V0.9 接驳 | 428 / 795 / 893 项，全部通过 |
| 原晚宴 / 五条体验路线 / Agent 接口 | 279 / 343 / 94 项，全部通过 |
| 原规则与随机基线 | 1,555 项通过；规则 20/20、随机 1/20 成功，非法动作 0 |
| 参考与资产校验 | 1,745 项通过；19 份原件、123 个 DAE 实例通过 |

新路线覆盖旧→新、反向返回、多次跨区、完整铺地横向采样、林缘实体边界、暂停后的原系统行为、探索后赴约与第二局准时赴约、重开清空，以及场景/API 语义一致性。既有完整回归验证原老师、拍照、时间、交通和 verifier。

证据是脚本持键输入、同一碰撞体语义导航及原生渲染窗口检查，**不是独立真人试玩、真实校园测量或真实模型测试**。通行测试不使用碰撞豁免或路线瞬移。部分旧回归在最后铺地接缝修正前执行；最终新区域物理与渲染路线在修正后再次执行，未改动旧任务行为。

复现：

```powershell
& .\.tools\godot\Godot_v4.5.1-stable_win64_console.exe --headless --path . --fixed-fps 60 --quit-after 90000 -- --journey-qa
& .\.tools\godot\Godot_v4.5.1-stable_win64.exe --path . --fixed-fps 60 --disable-vsync --max-fps 240 -- --journey-render
python tools/validate_reference_library.py
```

结果见 `tests/artifacts/v10_qa.json`、`v10_render.json` 与 `v10-*.png`。打开游戏选择“漫步神仙湖”；开始后向身后行走进入新增区域。原活动出口在沿湖方向，仍需按 E 签到。

![入口树池广场](../tests/artifacts/v10-02-forecourt.png)

## 下一段的证据门槛

优先补入口林缘之后的连续地面参考，再决定能否朝实际上园方向扩建。需要相邻拍摄点与可确认的路口、坡向、围栏、道路/步道关系；再校准长度与高程。官方全景中的音乐学院/第八书院北门、环岛热点可作为调查线索，不能直接变成可走连接。另一端仍需下园接点、当前站位与连续坡段资料。资料不足时继续保留边界，不用历史 DAE 的数字节点或鸟瞰图推断真实可通行道路。
