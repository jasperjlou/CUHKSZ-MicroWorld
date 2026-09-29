# V0.8 世界时间与校园活动

本文保留 V0.8 设计记录。当前 lake-3 交通扩展、wait 在乘车时的行为及最新验证见 [V0.9](V09_SHUTTLE_ROUTE_CHOICE.md)。

2026-09-26。复用 V0.7 的神仙湖短段、角色碰撞、路线与参考资料。没有扩地图、增加 NPC 或车辆。入口仍为主菜单“漫步神仙湖”，进入后任务为“沿湖赴约”。

## 玩家流程与配置

默认 **18:07** 出发，演示交流活动 **18:20** 开始、**18:30** 结束。沿原木栈道前往下园方向出口，靠近后按 E 签到。走到附近但不签到不算到达任务完成。暂停、开场和结尾期间时间停止，站着看风景则继续计时。

所有活动时间与倍率集中在 `tasks/lake_event.json`。默认 1 秒活动时间推进 20 个游戏秒，因此出发到活动开始有 39 秒活动时间，到结束有 69 秒。已有短段正常步行约需 18–20 秒自动路线时间，留出了停留余地；这个测量不是首次人类玩家用时。

HUD 显示世界时间（含秒）、距开始剩余时间或“活动已开始／已结束”、目标与原有交互提示。F1 的演示说明增加倍率、无效动作和重开次数。结果界面按实际时间生成中文描述与结构化指标。

## 系统结构

```text
WorldTime（唯一时间运算与倍率入口）
  ├─ GameState：兼容存储 current_game_time / elapsed
  ├─ CampusEvents：活动日程与状态
  ├─ FairyLakeUI：中文时间与结果
  ├─ FairyLakeEnvironment：结构化观察、行动
  └─ EventBus → EventLogger：原有事件轨迹与结果文件
```

`autoload/WorldTime.gd` 为全局服务，提供 configure / tick / advance / set_paused / reset / snapshot 与 advanced 信号。时间统一以游戏秒表示；elapsed 是未暂停的模拟活动秒。没有第二个湖区计时累加器，`world.elapsed` 只是读取 WorldTime。

服务自身不再注册一个自动计时循环，以避免重复推进：当前场景只由一个驱动器调用 tick。湖区使用物理帧，旧晚宴 `GameClock` 使用原过程帧，后者保留其截止时刻、拍照耗时和信号语义，但所有时钟算术委托给 WorldTime。每次进入／重开场景先 configure 并 reset，旧晚宴恢复原有起始时间和 1.5 倍速。

tick 接受活动秒，按倍率推进世界时间；advance 接受明确的游戏秒成本，可供未来离散交通成本使用，不增加活动秒。暂停时两者均不推进。V0.8 的 wait 使用真实物理帧持续等待，不直接跳动时钟；因此不会绕开事件状态、日志采样或暂停。

## 通用事件结构与状态

`systems/CampusEvents.gd` 管理一个按 id 索引的事件集合；当前配置只有一项：

```json
{
  "id": "lower_activity_01",
  "title": "下园方向交流活动（演示）",
  "location": "LowerCampus_Direction",
  "start_time": 66000,
  "end_time": 66600,
  "confidence": "placeholder",
  "fictional_event": true
}
```

运行时补充 status、arrival_time；观察时补充 destination、time_remaining 与 seconds_until_end。

| 状态 | 定义 |
|---|---|
| upcoming | 当前时间早于开始 |
| active | 开始时刻 ≤ 当前时间 < 结束时刻 |
| completed | 已到结束时刻，且记录了结束前到达 |
| missed | 已到结束时刻，没有结束前到达记录 |

活动状态与任务结果分开：迟到但尚未结束时到达，活动可以最终 completed，但限时任务仍失败。提前签到时任务成功，活动仍为 upcoming。当前结束一局后时钟冻结，所以未来的 completed 转换由独立生命周期测试验证，而不会假装活动立刻结束。

## 到达判定

签到必须由原交互入口验证角色实际在目标 3.3 游戏单位内。远程 inspect 会被拒绝。满足空间条件后，取该时刻的 WorldTime：

| 到达结果 | 时间条件 | 任务成功 |
|---|---|---|
| early／提前 | 到达 < 开始 − 60 秒 | 是 |
| on_time／准时 | 开始 − 60 秒 ≤ 到达 ≤ 开始 | 是 |
| late／迟到 | 开始 < 到达 < 结束 | 否 |
| missed／错过 | 到达 ≥ 结束 | 否 |

60 秒是“准时附近”的显示分类窗口，位于开始之前，**不是迟到宽限**。精确开始时刻仍成功；开始后一毫秒已迟到；精确结束时刻已错过。事件结束不会把角色锁在半路，仍可走到出口查看失败结果。主动重开、返回主场景或关闭进行中的游戏记录 aborted，arrival_time 与 lateness 为 null，不伪造到达。

## Agent 观察与行动

湖区 observation 升为 `lake-2`，保留原空间字段并新增：

| 字段 | 单位／含义 |
|---|---|
| current_time | 当前游戏秒 |
| current_time_text | 同一值的时分秒格式 |
| event_start_time | 活动开始的游戏秒 |
| time_remaining | 距开始的非负游戏秒，开始后为 0 |
| event_status | 日程状态 |
| destination | 原稳定目标 id：LowerCampus_Direction |
| destination_confidence | placeholder |
| current_location | 当前最近的合法路点 id |
| event | 完整公开活动信息，含 end_time |
| time_scale | 游戏秒／活动秒 |
| task_result | 结束后的结果；进行中为空 |

观察不依赖 OCR。原 navigate / inspect 保留，增加 `{"type":"wait","duration":60}`，duration 单位为游戏秒，只接受有限数值且范围为 (0, 1800]。等待时不驱动移动，但世界时间、事件与轨迹继续更新；暂停会冻结等待进度。等待和导航都有帧预算，并在场景被重开后取消旧行动。

无效目标、非法动作、远程查看、非法等待时长均记录 AGENT_INVALID_ACTION 并计数；无效动作本身不增加时间成本。完成后追加的输入不修改已结算的计数与末尾结果。模型与新 benchmark 均未接入。

## 结果与轨迹

继续使用 EventBus + EventLogger 的 `user://logs/run_*.json` 和 `run_*_summary.json`。测试使用独立的 qa_logs。没有第二套文件日志。

- success：空间签到成立且到达不晚于活动开始。
- arrival_time / event_start_time / event_end_time：游戏秒；未到达的中断结果 arrival_time 为 null。
- lateness / earliness：相对开始时刻的非负游戏秒。
- travel_time：本局未暂停活动秒，包含停留与等待。
- game_travel_time：世界时钟相对出发的差值。
- path_length：实际角色水平位移累计，单位 game_units；不当作校园实测米制距离。
- invalid_actions：本局被拒绝的 Agent 动作数。
- reset_count：当前湖区访问会话中的累计重开次数；回到主场景后再进入，开始新会话。
- destination_confidence、time_scale、arrival_status、event_status 等上下文同时记录。

每约一秒活动时间写一条 TRAJECTORY_SAMPLE，含真实坐标、世界时间和活动状态；交互、状态切换、Agent 动作和最终 TASK_FINISHED 沿用同一递增事件序列。记录用于分析，不是逐帧确定性 replay。

## 证据边界与已知限制

沿用 V0.7 全部地形与语义证据；实际路宽、高差、坡度、上下园真实接点仍无可靠测量。没有把方向出口改名为确定的下园入口。活动是演示设定，时间不来自校方通知。

本版按场景重置世界，未提供跨场景持续日历、天气、光照日夜变化或 NPC 排班。日志保持原 JSON 事件写入方式，适合当前短任务；未来长时程使用前再评估写入量。渲染和自动等待可以用固定帧率加速验收，不能据此声称真人实时测试或真实模型能力。

## 验收与复现

`--event-qa` 执行时钟单元检查、精确边界、完整早到路线、准时附近、故意停留迟到、开始后出发、错过、多次 reset、进行中 reset、观察与落盘指标对照。`--event-render` 执行同一路线并保存中文 HUD 和各结尾截图，检查 1280×800 与 960×640。

报告：`tests/artifacts/v08_event_qa.json`、`v08_event_render.json`；截图：`v08-*.png`。最终检查数量见 `QA.md`。

## V0.9 建议

下一版把站点可达性、等待、上车与车程作为动作适配器接到同一时钟、活动和结果结构。先确认路线与站点证据，再比较步行与等车选择。不要把当前预留站点当作已运营站点，也不需要为交通重新实现计时器。
