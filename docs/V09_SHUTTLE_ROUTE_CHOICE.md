# V0.9 接驳原型与出行选择

在 V0.8 神仙湖短段上增加步行、候车、上车和改变计划。同一活动仍在 18:20 开始、18:30 结束，世界从 18:07 出发，以 20 倍推进；没有扩展真实校园地理或接入模型服务。

## 怎么玩

从主界面进入“漫步神仙湖”，或运行 `tools/Launch.ps1 -FairyLake`。开场可选较早、较晚、延误或长延误班次。按“开始漫步”后，入口按 E 查看候车信息，也可以直接走。

候车面板不是暂停菜单：世界时钟持续运行。“在这里等车”记录候车选择；车辆上客时按钮“上车”可用。点击“继续步行”或直接走出候车范围，都会取消候车。Esc 才会暂停，也可以在暂停菜单重新出发。到达占位出口后按 E 签到，得到原有提前、准时、迟到或错过结果。

站点、车辆、班次、延误和车程均为演示设定。这里的目的地不是已经核实的真实下园入口。

## 系统分层

| 层 | 职责 |
|---|---|
| WorldTime | 唯一计时运算入口；暂停、倍率与重置仍由 V0.8 提供 |
| CampusEvents | 活动生命周期与纯到达判定，未绑定交通方式 |
| ShuttleSystem | 独立班次、延误、容量和状态机；不依赖场景或活动任务 |
| LakeTransport | 候车距离、出行选择、实体表现、乘车转场、指标及日志适配 |
| FairyLakeEnvironment | lake-3 观察与动作入口，复用原物理步行导航 |
| FairyLakeUI | 中文选择面板、上车按钮、乘车提示和出行结果 |

地图本体 `FairyLakeLayout` / `FairyLakeBuilder` 未重建。运行时在现有路径第一个路点加入 `Prototype_Shuttle_Stop`，并将同一语义记录注册到场景与 Agent；旧 `UpperCampus_BusStop` 预留点保持 inactive。

## 班次与状态

配置入口为 `tasks/lake_transport.json`，与活动 JSON 分离。共享字段含 id、route、boarding_duration、dispatch_duration、ride_duration、capacity、information_mode、scenario_seed、delay_jitter；情景只覆盖到站等待、车程与固定延误。

状态：scheduled → approaching → boarding → departed → in_transit → arrived。departed 是记录离站的瞬时转换，in_transit 是持续状态。精确到站时刻开放上车；精确离站时刻拒绝上车。错过后没有自动生成下一班。

当前是容量为 1 的原型：最多保留 240 游戏秒（12 活动秒）上客；乘客上车后最多停留 20 游戏秒（1 活动秒）就发车。无人上车则到窗口结束时发车。较长窗口用于首次玩家阅读，提前上车仍有更短的行程成本。系统不模拟其他乘客或候车队列。

| 情景 | 计划到站 | 固定延误 | 乘车时长 | 用途 |
|---|---|---:|---:|---|
| walk_faster | 18:13 | 0 | 5 分钟 | 当前正常步行比候车加乘车快 |
| shuttle_faster（默认） | 18:08 | 0 | 2 分钟 | 及时上车比正常步行快 |
| delayed | 18:09 | 8 分钟 | 5 分钟 | 等到计划时刻后改走仍可准时；坚持乘车会迟到 |
| missed | 18:09 | 26 分 40 秒 | 5 分钟 | 一直等待可以错过活动，系统不会自动救场 |

表中分钟均为游戏时间。正常步行估计从实际角色位置投影到现有路线折线，累计剩余长度，再除以 WALK_SPEED 并乘时间倍率。入口约 5 分 45 秒，受实际位置、碰撞、加减速与小跑影响；没有为了迎合示例伪造 11 分钟步行距离。小跑可改变优劣，界面标明估计采用正常步速。

已知延误时接驳 ETA 包括剩余候车、上车后停留与车程，假设到站后及时上车；不是忽略上客成本的“传送耗时”。如果玩家迟上车，预计抵达时间随之变化。

## 乘车抽象

上车需要正确 shuttle_id、上客状态、空位，以及角色距原型候车点不超过 3.3 游戏单位。远程上车、未到站、已离站、未知车辆或忙碌状态都会拒绝并记录原因。

乘车期间隐藏角色并关闭其物理过程；WorldTime 和 Event 持续推进，Esc 暂停仍有效。屏幕显示简化乘车转场与抵达倒计时。到站后将角色移到已有出口路点，重置速度、恢复物理与模型，并重置跟随镜头。该移动在日志明确标记 `transport_abstraction=true`，不是物理驾驶或步行导航。

转场位移不计入 path_length。乘车中的 position 保留上车锚点，但 `position_mode=transport_anchor`、`current_location=transport:<id>`、`in_transport=true` 明确表示正在运输；不会假装乘客仍站在候车点。到达后恢复 world 坐标语义。

## Agent 接口

保留 navigate、inspect、wait，增加 board 和 continue_walking：

```json
{"type":"navigate","target":"Prototype_Shuttle_Stop"}
{"type":"wait","duration":120,"reason":"先等到计划到站时刻再评估"}
{"type":"board","shuttle_id":"prototype_shuttle_01","reason":"接驳预计抵达早于活动开始"}
{"type":"continue_walking","reason":"延误后改走更合适"}
{"type":"navigate","target":"LowerCampus_Direction"}
{"type":"inspect","target":"LowerCampus_Direction"}
```

wait 的 duration 是游戏秒，范围 `(0,1800]`。它通过物理帧推进同一世界时间；暂停冻结、重开取消，不直接修改时间或强行完成事件。候车点附近的 wait 会被湖区适配层记录为候车；通用等待本身并不依赖车辆。乘车时也可以 wait，其他移动/重复上车动作仍被拒绝。board 成功后立即返回乘车观察，可继续用 wait 等到到站；continue_walking 取消候车意图，实际行走仍由 navigate 或玩家输入完成。

lake-3 在 V0.8 字段上增加：walking（estimated_time、available、estimate_basis）、shuttle_stop（id、nearby、confidence）、shuttle（state、scheduled_arrival、estimated_wait、estimated_total_time、estimated_delay、ride_duration、departure_time、capacity、boardable）、waiting_time、waiting、in_transport、position_mode、transport_available、replanning_count。ETA 单位全部是游戏秒。

不提供 best_choice。正常模式为 known delay；partial 模式会隐藏未到站前的 actual_arrival、estimated_delay、estimated_wait、derived total ETA 与 departure_time，避免通过派生字段泄露答案。当前人类情景使用已知固定延误，部分信息模式仅验证接口隔离，未开展模型评测。

可将 delay_jitter 设为正整数启用 `[0,jitter]` 的附加延误；独立 RandomNumberGenerator 使用 scenario_seed，重置可复现，不扰动其他系统随机状态。默认 jitter 为 0。

## 重规划、日志与指标

复用 EventBus / EventLogger。TRANSPORT_CHOICE 包含选择、时刻、当时观察、输入来源及可选 reason；TRANSPORT_REPLAN 记录 wait → walk。直接走出候车范围也记录重规划。同一次取消只计一次。没有 reason 时记录 unspecified，不杜撰 Agent 的内心理由。

SHUTTLE_STATE_CHANGED、TRANSPORT_BOARDED、TRANSPORT_ARRIVED 与原有轨迹采样使用同一时钟；乘车期间继续采样并带 in_transport / transport_state。结果仍以 TASK_FINISHED 结束并写入原 summary JSON。

新增结果：transport_mode、waiting_time、shuttle_used、scheduled_arrival、actual_arrival、delay、boarding_time、ride_time、replanning_count，以及情景、seed、信息模式和占位标记。actual_arrival 指班车实际到候车点的时刻，不是玩家到活动的 arrival_time；单班配置即使玩家未乘坐也会保留。

- waiting_time：选择候车到取消或上车之间的游戏秒；不含上车后停留。
- ride_time：在 in_transit 区间累计的游戏秒；中断保留已乘车部分。
- travel_time：整局未暂停活动秒，包含等车、上客停留和车程。
- path_length：实际步行水平距离，游戏单位，不是实测米数。
- reset_count：保留 V0.8 的当前湖区访问累计次数；其他交通指标每局清空。

waiting、boarding、in_transit、arrived 各阶段可重开，恢复时间、活动、班次、角色、UI 和观察。未签到的重开仍记录 aborted，arrival_time 为 null；到站本身不会伪造已经完成签到。

## 验证

沿用 IntegrationQA、既有真实碰撞导航、GUI 点击和截图工具。`--shuttle-qa` 覆盖 A–F、坚持等延误车、错过活动后乘车、直接移动取消候车、非法上车、容量和精确状态边界、seed、partial 隔离、指标落盘、轨迹以及各阶段重置。`--shuttle-render` 额外保存窗口完整路线、候车与转场画面，以及 960×640 结尾。最新数量和回归结果见 `QA.md`。

```powershell
& .\.tools\godot\Godot_v4.5.1-stable_win64_console.exe --headless --path . --fixed-fps 60 --quit-after 90000 -- --shuttle-qa
& .\.tools\godot\Godot_v4.5.1-stable_win64.exe --path . --fixed-fps 60 --disable-vsync --max-fps 240 -- --shuttle-render
```

报告 `tests/artifacts/v09_qa.json`、`v09_render.json`；截图 `v09-*.png`。这些是自动化物理步行与明确交通抽象的引擎证据，不是首次真人测试、真实车辆路测或模型成绩。原随机/规则基线只用于回归，未扩展 LLM / 本地模型 benchmark。

## 边界与 V1.0 建议

候车点坐标、班次、车程、车辆外观、上下园接点均为 prototype / placeholder。原路线宽度、弯折及高差的 inferred / placeholder 不升级，参考库与原图未改动。车辆只是低多边形到站/离站表现，没有道路 AI、悬挂、轮胎物理或实际跨园驾驶。

下一阶段先核实真实上下园接点和站点，再将 transport adapter 的起终点接到新验证路段。保留统一时钟、活动与动作协议；若增加多乘客、循环班次和未知延误，再扩充容量、调度与信息发布规则，不把当前参数当作校方数据。
