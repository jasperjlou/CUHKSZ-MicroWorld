# Historical README

Preserved during repository preparation. Version statements and future-work gates below are historical; see the current [README](../README.md).

当前调查版本：**V1.0 Phase D2**。两个地面缺口仍未关闭，没有新增道路；[本轮报告](../docs/V10_PHASE_D2_GAP_CLOSURE.md)。

> 当前版本：V1.0 Phase D 地面连续性调查。V0.5 冻结点为 `v0.5-high-table-slice`（3bbb471）；后续改动保持本地工作区状态。
> [图文参考库](../references/viewer.html) · [资料索引](../docs/REFERENCE_INDEX.md) · [空间依据](../docs/CAMPUS_SPATIAL_NOTES.md) · [覆盖与V0.7准入](../docs/RECONSTRUCTION_STATUS.md) · [资产许可](../docs/ASSET_PROVENANCE.md) · [V0.6历史验收](../docs/V06_DELIVERY.md)

# 校园微世界：高桌晚宴

**神仙湖入口**：启动游戏后选择“漫步神仙湖”，或运行 `tools/Launch.ps1 -FairyLake`。18:07 出发，在 18:20 前到达下园方向出口并按 E 签到；每秒推进 20 个游戏秒。在入口按 E 查看原型接驳班次，可等车、上车，也可直接走或中途改主意。开场可选不同班次/延误情景。候车面板不会暂停时间，Esc 才会暂停。见 [V0.9 系统与验收](../docs/V09_SHUTTLE_ROUTE_CHOICE.md)。原高桌晚宴玩法仍可进入。

Phase D 拆分四个地面调查段，F1显示证据缺口；主路径仍冻结，真实湖口至岔路尚未贯通。[查看Phase D结果](../docs/V10_PHASE_D_GROUND_EVIDENCE_BRIDGE.md)。

Phase C 冻结既有前沿，新增路径为零；F1 查看中文证据状态，V 侧看，C 前后看。真实位置配准仍未知。见 [Phase C 调查结论](../docs/V10_PHASE_C_CONNECTOR_RESOLUTION.md)。

Phase B 已沿林缘再延伸约 35.238 游戏单位，加入红灰步道、路缘、路灯及车道/建筑远景；按 C 切换观察方向。真实上下园接点仍未知。见 [Phase B 交付与证据](../docs/V10_PHASE_B_CONNECTOR.md)。

入口身后已增加灰石步道、方形树池、浅阶广场与林缘短段，可连续走入并返回湖边。新增约 38.535 个游戏单位，不是实测米数。详见 [V1.0 Phase A 空间与验收](../docs/V10_CAMPUS_JOURNEY.md)。地图**尚未连通真实上园与下园**；站点、班次、车辆及车程仍为演示设定，完整跨区行程等待连续地面证据。下方旧 benchmark 阶段规划仅作历史。

一个可直接运行的 Godot 4 / GDScript 桌面 3D 校园原型。校园由基础几何体搭建，场景为虚构、压缩的校园布局，不是港中深实景复刻。玩家沿连廊赴宴，选择回复朋友、帮助拍照，并可能因边走边看手机被老师提醒。行为改变世界状态、角色反馈和任务结果。

所有玩家界面、对话、事件查看器和演示面板均为简体中文。实体校园海报与导视按 V0.6 要求使用中文优先、中英双语；技术标识保持英文。人类试玩和规则/随机基线无需联网或模型服务；可选模型评测通过兼容 API 运行。默认使用模拟服务，没有 RAG。

## 启动

本机已经准备 Godot **4.5.1 stable**（项目内 `.tools/godot/`）：

- 双击 **启动游戏.cmd**，选择任务后点击“开始赴宴”。
- 双击 **打开编辑器.cmd**，打开后按 F6 运行当前主场景，或 F5 运行项目。
- 也可在 Godot 4.5.1 的项目管理器中导入本文件夹的 `project.godot`。

迁移时复制工程即可；`.godot/` 是可重建缓存，`.tools/` 是本机测试工具，不是工程依赖。另一台电脑安装 Godot 4.5.1 或兼容版本，再导入工程。字体已经附带，不依赖 Windows 系统字体。其他 Godot 小版本与 macOS/Linux 尚未实测。

通过命令行指定引擎：

```powershell
.\tools\Launch.ps1 -GodotPath 'C:\Tools\Godot.exe'
.\tools\Launch.ps1 -Editor -GodotPath 'C:\Tools\Godot.exe'
```

项目使用 Compatibility 渲染，优先桌面键鼠；本轮没有导出独立 EXE 或网页包。本机启动器直接调用项目内引擎运行完整工程。界面最低支持 960×640，可拖动窗口调整大小。

## Human Interface

人类模式：`启动游戏.cmd`，沿用以下操作与规则。

| 操作 | 按键 |
|---|---|
| 移动 | WASD |
| 小跑 | Shift；看手机时无效 |
| 交谈 | 靠近人物后按 E |
| 拿出、收起手机 | Tab |
| 回复、选项、菜单 | 鼠标点击 |
| 暂停、继续 | Esc |
| 演示状态与最近事件 | F1 |
| 结算后重新开始 | R |
| 结算后退出 | Esc |

向画面前方沿连廊走，即可抵达晚宴。中途右侧是合影花园，左侧是林荫小径。三名主要角色分别为老师、拍照同学和门口的朋友；合影背景中的另一人只是装饰角色。

- 初始时间 18:55，19:00 开宴；正常活动每现实秒推进 **1.5 个游戏秒**，约 3 分 20 秒活动时间后迟到。地图已压缩，熟悉路线后的活动时间约 24–61 秒（取决于互动与再次提醒）；阅读、观察、停留会延长实际体验，对话与暂停不计入活动时间。
- 人物统一放大为初版的 **1.5 倍**，碰撞体、老师视线高度、头顶名字同步适配。V0.5 普通步行速度 **5.1**，手机速度 **2.4**，小跑速度 **8.3**（世界单位/秒）。步行数值从初步目标 5.5 调整为 5.1，使当前直达路线保持约 20 秒；按住 Shift 确实加速，看手机时不能用 Shift 绕过减速。
- 熟悉路线后，直接赴宴约 **24 秒**；回复、拍照再赴宴约 **35 秒**；看手机经过老师、收起手机、拍照再赴宴约 **40 秒**。这些是输入驱动测试的活动时间，不代表首次玩家的阅读与探索时间。
- **到门口与朋友交谈**记录 `arrival_time`。必须严格早于 19:00 才算准时；对话后的确认按钮负责结束本局。朋友先听你讲述路上经历，再作出反馈，避免把远处事件表现为他凭空知道。
- 拍照小场景约 **3.2 秒**：镜头平顺转向两位同学，对方面向镜头，倒计时、快门和闪光后道谢，再恢复移动与原镜头；游戏时钟正常推进；完成后额外增加 **35 个游戏秒**。重复接受不会启动多份流程。曾婉拒仍可回来帮忙，两个行为都会留在日志中。
- 对话与暂停停止时钟和移动。手机不暂停。19:04 自动结束未完成的一局，保证玩家迷路或放置时仍有明确结果。
- 老师只提醒**附近、前方、视线无遮挡、正在移动且打开手机**的玩家。第一句只出现一次；收起后重开并经过至少 8 秒活动时间，才可能第二次提醒。总共最多两次。老师先转身示意，约 **0.7 秒**后才说话；在这之前收起手机可避免提醒。站着看手机不会触发新提醒，但停下不会取消已被发现的行为。收起手机后的回应也有短暂停顿。

## 体验打磨（2026-09-24）

- 沿用同一张地图，横向收紧至 72%、纵向缩短至 80%；人物和中文字不压缩。主路从 11 收窄至 7.92 个世界单位，拍照点移到主路线旁，保留通畅的横向入口。没有新增地图或主要 NPC。
- 靠近人物会转身回应，地面有克制的浅色高亮，头顶出现 `[E] 交谈`；拍照同学在主路可见范围招手，门口朋友也会招手招呼。
- 手机打开时玩家低头、抬手拿手机，界面显示正在看手机与移动变慢；老师有可见的观察、转身、示意、停顿和有限次数提醒。
- 拍照采用约 3.2 秒的小场景，拍摄期间隐藏姓名等浮动标识，暂停会同时冻结镜头、动作和时钟；结束恢复控制。
- HUD 收为简短目标、时钟和当前操作。完整按键说明放在开场和暂停页，演示状态与事件记录只按 F1 打开。提示按队列显示，避免一条台词被下一条直接替换。
- 结尾的故事由 `ChineseText.story_summary(snapshot)` 规则组合，继续保留任务、条件验证与 JSON 日志。消息、点击、到达、快门与轻脚步使用程序合成音效，无新音频资产或服务；无界面逻辑测试不播放音频，窗口版本保留声音。

复跑五条路线（无传送、不修改游戏时间）：

```powershell
.\.tools\godot\Godot_v4.5.1-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --polish-qa
```

带画面完整跑 B、C 两局并截图：

```powershell
.\.tools\godot\Godot_v4.5.1-stable_win64_console.exe --path . --fixed-fps 60 -- --polish-render
```

报告为 `tests/artifacts/polish-report.json`、`polish-report-render.json`，截图以 `polish-` 开头。具体路线结果及验证边界见 `QA.md`。这些测试属于本地引擎输入驱动验证，不是新增的 Agent controller。

## 三种任务

任务位于 `tasks/tasks.json`，开场可选，默认“顺手帮个忙”。

| ID | 玩家名称 | 验证条件 |
|---|---|---|
| `basic` | 准时赴约 | 到达晚宴即可 |
| `helpful_student` | 顺手帮个忙 | 拍照完成，并准时到达 |
| `careful_student` | 从容赴宴 | 拍照完成、准时到达、没有被老师提醒 |

`basic` 沿用需求中的名称，但**按原规范只验证到达，不验证准时**。选择界面明确提示“迟到仍可完成”。任务可以失败，结算逐项解释未满足条件。验证器对缺少的状态字段和空条件任务返回失败，并拒绝没有真实到达时间、或到达时间已过期却宣称准时的状态。

## 架构

```text
player/Player.gd             输入、移动、跟随镜头与手机外观
autoload/GameState.gd        独立世界状态与快照
autoload/EventBus.gd         统一语义事件和时序编号
autoload/EventLogger.gd      每局 JSON 日志、结束快照、原子替换
systems/GameClock.gd        时间推进、拍照成本、截止事件
systems/TaskSystem.gd       读取并选择结构化任务
systems/TaskVerifier.gd     纯函数：任务 + 状态 → 条件结果
systems/ChineseText.gd      中文字体、地点和事件显示名
systems/SoundCues.gd        无外部资源的消息、手机与快门提示音
npc/BaseNPC.gd              公共表现和交互信号
npc/TeacherNPC.gd           距离、朝向、射线感知与有限提醒
npc/StudentNPC.gd           请求、选择、拍照动作与完成
npc/FriendNPC.gd            到达状态与组合式结尾
world/MainWorld.gd          组装场景与流程协调
world/CampusBuilder.gd      校园几何体、灯光、道路、碰撞
world/MeshKit.gd            可复用几何体和人物构建
ui/GameUI.gd                HUD、手机、对话、暂停、结算、事件查看器
tests/IntegrationQA.gd      实际场景的输入、物理、日志、重开与渲染检查
```

`MainWorld.tscn` 和 `Player.tscn` 可以在编辑器打开；环境和 UI 在运行时构建，因此编辑模式的主场景不是完整手摆地图。按运行即可查看全部内容。

`GameState` 不负责渲染、日志或验证。NPC 通过信号请求 UI，不直接访问控件。`TaskVerifier.verify(task, snapshot)` 不引用场景、UI 或自动加载节点，便于独立使用。UI 中的中文不会改变底层事件与 JSON 的英文 ID。

## 日志

普通玩家运行：`user://logs/run_<日期时间>_<进程>_<微秒>_<序号>.json`。

Windows 本机通常对应：

```text
%APPDATA%\CUHKSZ-MicroWorld\logs\
```

每个事件到达时保存一次有效 JSON，通过临时文件替换；因此提前退出也保留已经完成的动作。重开生成新文件，不拼接到上一局。结束时还有同名前缀的 `_summary.json`，包含完整状态和验证结果。文件打开失败会显示中文提示；不要将“任务成功”等同于“日志写入成功”。

```json
{
  "sequence": 8,
  "timestamp": 34.517,
  "game_time": "18:55:51",
  "game_time_seconds": 68151.775,
  "actor": "teacher_01",
  "event": "TEACHER_WARNED_PLAYER",
  "data": {}
}
```

时间戳表示本局活动时长（不含暂停与对话），`game_time_seconds` 表示带动作时间成本的游戏时钟。关键事件包括手机开关、回复、感知、提醒、拍照选择与完成、地点变更、到达、结束、`VERIFIER_RESULT`。校验结果记录每个条件的布尔结果与中文说明。

结算时按 **F1** 打开“本局足迹”，读取已经落盘的事件文件，显示中文时间线，再按 F1 返回总结。默认结尾先显示基于真实状态组合的 1–3 句故事，再显示结构化任务结果。它不是确定性运动回放。现有日志没有逐帧输入、完整坐标轨迹或随机种子，不足以重建所有运动；未来应增加输入采样、初始快照、版本号和状态检查点。语义事件可用于行为分析与关键情节重建。

## 测试

双击 `运行测试.cmd`，或：

```powershell
.\tools\Launch.ps1 -Test
# 直接命令：
.\.tools\godot\Godot_v4.5.1-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --qa
```

带实际 GPU 渲染的检查：

```powershell
.\.tools\godot\Godot_v4.5.1-stable_win64_console.exe --path . --fixed-fps 60 -- --qa-render
```

测试自行退出，用非零退出码报告失败。报告和截图位于 `tests/artifacts/`，测试局写入 `user://qa_logs/`，与玩家日志隔离。测试覆盖：三任务组合、缺失状态、真实键位动作、手机减速、Shift 加速、手机减速优先级、按钮拥有焦点时的物理 Tab 按键、射线遮挡、视野背面、静止使用手机、两次提醒上限、拍照重复触发与时间成本、暂停、截止边界、状态驱动结尾、JSON 完整性、重开场景与日志隔离、超时失败，以及无传送的整条步行路线。无界面与 GPU 渲染模式均跑完整路线，实际点击回复和拍照选项；渲染模式生成中文界面截图并检查字形覆盖。

## 字体与资产

`assets/fonts/NotoSansSC.ttf` 来自 [Google Fonts 的 Noto Sans SC](https://github.com/google/fonts/tree/main/ofl/notosanssc)，随附 `OFL.txt`（SIL Open Font License）。`ChineseUI.tres` 使用数值 OpenType tag 固定字重为 500，避免可变字体默认落在过细字重。字形检查覆盖显示文本，失败标记使用字体确实包含的 `×`。所有建筑、路牌、人物和树木都由工程代码生成，无付费素材，无外部插件。消息、手机和快门提示音由程序生成，无录音资产；不包含背景音乐或语音。


## 稳定基线

本轮修改前已初始化 Git，提交 `7f0c539`，创建 `v0.2-playable` 标签。该标签包含完整人类试玩版源码和中文字体，不包含引擎、缓存和测试截图。需要独立查看时可使用 `git worktree add ../CUHKSZ-playable v0.2-playable`，无需覆盖当前工作目录。

## Agent Interface

现在同一场景支持结构化程序操作。没有模型、网络或键盘模拟。

- **观看规则演示.cmd**：打开窗口，观看规则策略完成“从容赴宴”。底部显示中文策略名称和当前动作；F1 仍可查看调试信息。运行期间禁用人类移动、手机按钮与对话按钮，避免双控制器同时操作。结尾可重新开始人类游戏。
- **运行程序评测.cmd**：无窗口连续运行规则策略 20 局、随机策略 20 局。也可以用 `tools/Launch.ps1 -AgentDemo` / `-AgentBatch` / `-AgentQA`。
- 普通 **启动游戏.cmd** 仍从人类任务选择页开始。

`agents/AgentEnvironment.gd` 是进程内 GDScript 接口，不是 HTTP 服务。将实例放在 SceneTree 根节点下、主场景之外；重置会替换完整主场景，接口自身保留。调用示例（从持久 Node 中）：

```gdscript
const AgentEnv = preload("res://agents/AgentEnvironment.gd")
var env = AgentEnv.new()
get_tree().root.add_child(env)
var observation = await env.reset("careful_student", 42)
var actions = env.get_available_actions()
var transition = await env.step({"type":"move_to", "target":"photo_spot"})
print(transition.observation)
```

| 方法 | 契约 |
|---|---|
| `await reset(task_id="", episode_seed=null)` | 空任务默认为 `careful_student`，空种子为 0；重建真实场景、NPC、时钟、UI、导航、对话、验证结果，打开新日志，返回首个 observation。未知任务返回 `valid:false`，不破坏当前局。 |
| `observe()` | 返回新的 JSON 可序列化字典，不读取 UI 控件。 |
| `get_available_actions()` | 返回当前合法的完整动作字典；执行中、重置中、终局返回空数组。 |
| `await step(action)` | 严格验证动作，执行真实交互并等待环境推进；返回 `valid / execution_error / observation / events / done / result`。 |
| `is_done()` | 当前真实世界是否结束。 |
| `get_result()` | 未结束返回空字典；结束返回原 `TaskVerifier` 结果的独立副本。 |

单环境同时只允许一个 `step`。非法动作返回 `valid:false` 和稳定 `reason`，不移动、不推进时间、不修改游戏状态，只增加拒绝计数并写 `AGENT_INVALID_ACTION`。未知动作、额外字段、错误目标、距离不足、对话阶段不匹配都会拒绝。并发动作返回 `action_in_progress`；终局动作返回 `episode_finished`。

执行中可调用 `reset`：旧协程以 `interrupted:true, reason:episode_reset` 结束，不返回属于新一局的观察；调用方应丢弃旧动作返回值。重置完成发出 `episode_reset(seed_value)`，runner 将其连接到策略的 `reset_episode`，随机策略因此重置自己的 RNG。不要在普通 `MainWorld` 子节点中运行跨局协程。

导航使用现有连廊和合影入口的固定折线路径。`Player` 只是把方向来源切为程序向量，仍共用 `move_and_slide`、碰撞、步行速度、手机减速、镜头、时钟和 NPC 感知。没有瞬移或直接写入任务完成标志。连续约 3 秒没有进展会返回 `execution_error:navigation_blocked`，停下角色；不冒充非法动作或成功抵达。移动期间若自然超时，返回终局结果。

## Observation Schema

下面是本轮真实轨迹中的第一条 observation：

```json
{
  "schema_version": 1,
  "game_time": "18:55:00",
  "elapsed_seconds": 0.0,
  "location": "start_plaza",
  "position": [
    0.0,
    0.09,
    49.6
  ],
  "phone_open": false,
  "current_task": {
    "id": "careful_student",
    "name": "从容赴宴",
    "description": "帮同学完成拍照，在 19:00 前到达高桌晚宴，并且不要因边走边看手机被老师提醒。"
  },
  "visible_entities": [],
  "nearby_interactions": [],
  "messages": [],
  "friend_replied": false,
  "personal_history": {
    "photo_completed": false,
    "warnings_heard": 0
  },
  "dialogue": {
    "speaker": "",
    "text": "",
    "options": []
  },
  "recent_events": [
    {
      "event": "FRIEND_MESSAGE_RECEIVED",
      "actor": "friend_01",
      "game_time": "18:55:00"
    }
  ],
  "done": false
}
```

观察边界：

- `position` 是玩家自身位置；`location` 是原世界位置判定；`game_time` 是校园时钟。`elapsed_seconds` 是活动时间，排除对话与暂停。
- `current_task` 仅含任务 ID、中文名称、描述，不提供 verifier 条件字典。
- `visible_entities` 仅含 18 单位范围内、眼部射线无遮挡的 NPC 名称、ID、距离。这是简化环境观察范围，不承诺与相机屏幕像素严格一致；没有读取全场 NPC 隐藏状态。
- `nearby_interactions` 是该观察范围内且进入原交谈距离的 NPC ID。
- 只有手机打开时才返回 `messages`。`friend_replied` 是自己的回复记录；`personal_history` 仅记录自己完成的拍照和实际听到的提醒。
- `dialogue` 是世界维护的当前谈话与玩家可见选项，不从 UI 反查。选项为空时没有活动对话。
- `recent_events` 最多 8 条，只保留可感知事件的类型、说话者、游戏时间。`step.events` 返回本动作期间的同类事件。明确排除老师内部感知射线、冷却、未来反应、全局快照、验证器结果；终局结果通过 `result` 单独提供。
- F1 为人类演示者的特权调试视图，两种策略均不读取它。完整 EventLogger 与评测 metrics 属于评测端，不是策略输入。

## Action Schema

动作必须与当前 `get_available_actions()` 中某个字典完全一致：

| `type` | 参数与合法条件 |
|---|---|
| `move_to` | `target` 为 `start_plaza`、`main_walkway`、`photo_spot`、`high_table`；可移动，且不在目标落点附近。 |
| `talk_to` | `target` 为 `teacher_01`、`photo_student`、`friend_01`；在原交谈半径内、无活动对话。人物先转身，再打开原有谈话。 |
| `open_phone` / `close_phone` | 可移动，且手机当前状态允许切换。 |
| `reply_to_friend` | 手机已打开，且尚未回复。 |
| `accept_photo_request` / `decline_photo_request` | 正在与拍照同学讨论尚未完成的拍照请求；接受会执行完整 3.2 秒场景和原时间成本。 |
| `continue_dialogue` | 老师方向提示、拍照完成后再次致谢等单选对话。 |
| `enter_high_table` | 已与门口朋友交谈，正在确认进入；与人类模式相同，在交谈时记录到达时间。 |
| `wait` | 无模态对话、可行动；固定等待 5 秒物理时间，不接受自定义时长。 |

例如 `{ "type":"talk_to", "target":"photo_student" }` 后，合法动作会变为接受或拒绝拍照；不能远处直接接受。对话期间游戏时钟暂停，必须选择回应，不能用 `wait` 绕过。

## Evaluation

`RuleBasedAgent` 只根据传入的 observation 和合法动作选择下一步：回复朋友、收起手机、走到合影点、交谈并拍照、走到晚宴门口、交谈并进入。`RandomAgent` 用局部带种子的 RNG 均匀采样当前合法动作。两者不导入 GameState、EventLogger、世界节点或 UI；runner 通过 Environment API 驱动策略。

每局最多 100 步；若仍未结束，runner 记录 `AGENT_EPISODE_TRUNCATED` 并结束该局，metrics 标记 `truncated:true` 且成功率计为失败，同时保留原 verifier 结果。游戏自身的 19:04 超时仍然生效。只有 evaluator 在结束后读取完整状态生成 metrics。

复跑：

```powershell
# 两个策略各 20 局；固定物理帧率用于可重复批量测试
.\.tools\godot\Godot_v4.5.1-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --agent-batch
# API 拒绝、并发取消、感知、重复种子、重置专项检查
.\.tools\godot\Godot_v4.5.1-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --agent-qa
# 窗口演示，保留正常实时速度
.\.tools\godot\Godot_v4.5.1-stable_win64.exe --path . -- --agent-demo
```

输出位于 `user://evaluation/`，Windows 为 `%APPDATA%\CUHKSZ-MicroWorld\evaluation\`：

- `rule_based_20_runs.json`、`random_20_runs.json`：最近一组汇总及逐局 metrics。
- `session_<时间>_<进程>/`：保留每次运行的独立汇总、检查报告、40 份 trajectory，后续运行不会覆盖旧 session。
- `event_logs/`：沿用原 EventLogger 的完整每局事件和结束快照。每个合法动作有 `AGENT_ACTION`；拒绝有 `AGENT_INVALID_ACTION`。
- `interface_qa.json`：最新专项检查结果。

每条 trajectory 包含任务、策略、种子、动作前 observation、动作、公开结果事件、完整日志中的 sequence 对应关系、动作返回（含动作后 observation）、最终 verifier 和 metrics。这是语义轨迹，不是逐帧录像或完整 replay。

metrics 包含 `episode, task_id, success, steps, invalid_actions, teacher_warned, helped_student, arrived_on_time, completion_time`，另外记录总事件数、第二次提醒、回复、截断、执行错误数。`completion_time` 单位为模拟活动秒，排除对话和暂停，不是计算机跑批耗时；拍照额外 35 秒只加到校园时钟。

### 本机实测（2026-09-24）

Godot 4.5.1，固定 60 物理帧，每策略种子 1000–1019，Task C：

| 策略 | 局数 | 成功 / 失败 | 非法动作 | 平均步数 | 平均活动秒 |
|---|---:|---:|---:|---:|---:|
| 规则策略 | 20 | 20 / 0 | 0 | 9.0 | 33.617 |
| 随机策略 | 20 | 1 / 19 | 0 | 18.0 | 178.492 |

40 局无导航执行错误，批量检查 1545 项、0 失败；API 专项检查 80 项、0 失败；人类原五路线 343 项、0 失败；旧综合检查 279 项、0 失败。另有一局真实 GPU 渲染的程序操作完整路线，33 项检查通过，步行、拍照、结算截图已核看。随机策略失败包括未帮忙、被提醒或超时，保留真实失败，不修改验证标准。这组有限种子用于回归与健壮性验证，不代表对一般策略能力的统计结论。

同种子、同动作的双次完整路线已比较 observation、事件与 verifier，完全一致；尚未承诺不同硬件、引擎版本或不固定帧率下逐位一致。

## LLM Agent Benchmark

已在 `v0.3-agent-env`（`864bce2`）之后接入独立的模型评测层。任务总数 **12 个**（新增 9 个），保留原有玩法与前三个任务。普通人类开场仍显示原三任务，评测界面提供全部任务。

- 双击 **打开模型评测.cmd**：选择模拟/已配置服务、任务、上下文条件，运行单局或完整矩阵。
- 双击 **运行模拟评测.cmd**：实际执行 12 任务 × 3 条件 × 1 局；模拟器是脚本测试夹具，不是真实模型。
- 模型层只接收公开 observation 和 available actions，不读取 GameState；当前观察中的 recent_events 从所有条件统一移除，历史只由 History / PlanHistory 显式注入。
- 模型请求期间整个校园处理暂停；动作执行期间仍是真实物理、时间和 NPC 感知。API 延迟单独记录。
- 真实 provider 从 `LLM_BASE_URL`、`LLM_MODEL`、可选 `LLM_API_KEY` 环境变量读取配置；没有配置时普通游戏和旧基线不受影响。

完整任务表、条件差异、provider 协议、配置、指标分母、异常语义与真实/模拟结果边界见 [BENCHMARK.md](../BENCHMARK.md)。

本机尚未配置真实模型 endpoint，本轮没有真实 LLM 实验成绩。模拟矩阵 36/36 通过只证明流程与任务可达性，不证明三种条件同样有效。

## Future Work

下一步固定实际模型版本，以相同任务和匹配种子运行多次三条件比较，重点分析否定约束和事件先后顺序的失败；不增加美术或地图。
