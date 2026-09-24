# CUHKSZ MicroWorld：首轮模型行为基准

`benchmark_version = cuhksz_microworld_v0.1`。当前实现让模型选择结构化动作，在原校园中执行，再通过独立验证器生成轨迹与比较结果。未增加地图、NPC、美术或玩法。

**本轮没有配置真实模型服务，没有真实 LLM 成绩。** 默认模拟 provider 是明确按任务编写的测试路径，用于验证管道和任务可达性；它不是模型，也不能用于推断三种上下文条件的优劣。本地 HTTP 测试服务器也只是协议夹具。

原结构化环境已先提交为 `864bce2`，标签 `v0.3-agent-env`；更早的人类版本为 `v0.2-playable`。

## 任务集

`tasks/tasks.json`，`task_suite_version = campus_tasks_v1`。原三任务语义保留，新增九个，共十二个。

| 任务 ID | 中文任务 | 类别 | 验证重点 |
|---|---|---|---|
| basic | 准时赴约 | 基础 | 到达即可，仍沿用旧语义，不检查准时 |
| helpful_student | 顺手帮个忙 | 合取 | 拍照且准时到达 |
| careful_student | 从容赴宴 | 约束 | 拍照、准时、未被老师提醒 |
| reply_arrive | 回个消息再赴宴 | 基础 | 回复朋友且到达 |
| all_on_time | 一路照应 | 合取 | 回复、拍照、准时到达 |
| quiet_arrival | 专心走路 | 约束 | 准时且全程未被提醒 |
| direct_dinner | 先去赴宴 | 否定 | 不拍照，准时到达 |
| silent_helper | 默默帮忙 | 否定 | 不回复，拍照并到达 |
| read_then_pass | 看完再走 | 时序 | 首次打开手机 → 首次收起 → 首次经过老师；经过时手机关闭；到达 |
| once_is_enough | 提醒一次就够了 | 状态/时序 | 确实收到第一次提醒 → 收起手机 → 到达；没有第二次提醒 |
| reply_before_photo | 先报个平安 | 时序 | 首次回复 → 首次拍照完成 → 首次到达 |
| polite_decline | 礼貌地赶时间 | 否定 | 当面婉拒、不拍照、准时到达 |

所有任务都有中文完整 instruction、英文 ID、声明式条件。验证器 `TaskVerifier.verify(task, state, events)` 是独立纯函数，不读取模型、提示词或动作名称。

时序以原 EventBus 的真实事件为证据。唯一新增的世界事件 `TEACHER_PASSED` 只是记录玩家在老师左右 5 个单位以内跨过老师所在横截面，并附当时手机状态；它不新增玩法。该距离刻画“经过身边”，不是老师感知射线。验证使用每个里程碑的**首次出现**，防止先违规经过、之后补做一次正确顺序而蒙混过关。

`once_is_enough` 特意要求真的触发第一次提醒，避免“从未靠近老师”就满足一个空泛的条件句。观看手机在现有玩法中会展示消息，因此 `PHONE_OPENED` 是该任务的查看证据，不代表测量人的阅读理解。时间仍由原 GameClock 与到达事件决定。

## 分层与可观察性

```text
BenchmarkRunner（调度、版本、评测权限、结果落盘）
    → LLMAgent（统一提示词、上下文、严格输出检查、有限重试）
        → Provider（模型服务或明确标注的模拟夹具）
    → AgentEnvironment.observe / get_available_actions / step
        → 原 Player / NPC / GameState / EventBus / EventLogger
    → 原 TaskVerifier → metrics / aggregate / trajectory
```

- `LLMAgent` 与 provider 不导入 GameState，不读取世界节点或 F1。模型只能得到公开观察和合法动作。
- `BenchmarkRunner` 的 evaluator 在结束后读取特权状态计算指标。manifest、metrics、完整事件文件不会送回模型。
- 模型看到的当前 observation 统一移除 `recent_events`，避免即时条件偷偷获得轨迹。保留自身回复、拍照完成、听到提醒次数等原有公开状态摘要；因此这里比较的是**额外动作历史与计划**，不是完全消除记忆的模型。
- 时序信息由 B/C 的历史辅助推断，验证器仍只使用真实世界事件。Provider 无法写完成标记或跳过移动。

## 三种条件

三个条件使用字节相同的 `SYSTEM_PROMPT`、相同 model/temperature/token 限制和 action schema；不写任务专属决策规则。

| 条件 | 发送给模型的信息 |
|---|---|
| Reactive／即时观察 | 任务、当前观察、当前合法动作 |
| History／观察与历史 | 上述内容 + 最近 10 步的动作和公开重要事件 |
| PlanHistory／计划与历史 | 上述历史 + 开局额外一次简短计划请求，此后每步携带计划 |

计划只允许 `{"plan":["简短行动步骤"]}`，1–5 条、每条最多 80 字。不会索取长篇推理；只保存通过校验的简短计划。provider 的 reasoning/reasoning_content 不读取、不记录。

一般动作只允许一个完整可用 JSON 动作，如 `{"type":"move_to","target":"photo_spot"}`。不执行模型代码，不解析 Markdown 代码围栏，也不容许多余 rationale 字段。额外字段、未知动作和不可用动作都拒绝。

每次选择最多 **2 次请求**（首次 + 一次重试）。重试只附错误类别，不附上一条原始响应。所有条件使用相同重试规则。计划请求消耗的 token 和延迟单独纳入总数，因此 PlanHistory 的额外调用成本可见。

## 时间与模式

基准采用 `decision_gated`：reset 和每个动作结束后停用主世界的 process，等待模型期间时钟、NPC 感知/动画计时器与移动一起暂停；provider 和评测 UI 在主世界外仍然工作。step 内恢复原物理与时间，完成后再暂停。

这样 API 延迟不会变成迟到惩罚。该规则是本次实验协议，不是声称研究真实异步延迟下的游戏表现。原人类和旧规则/随机基线默认不启用该选项，保留原可玩版本行为。F1 在等待模型时仍可由演示者打开，模型无法读取。

时钟在对话期间仍按旧规则暂停；拍照仍有原来的额外 35 游戏秒成本。`completion_time` 是活动模拟秒，不是请求耗时，也不是墙上实际时间。

## Provider 配置

内置 `OpenAICompatibleProvider` 调用 `/chat/completions`；它不是某个品牌的专用客户端。`Provider.gd` 定义 `generate_action(context)` / `generate_plan(context)`，返回：

```json
{
  "ok": true,
  "content": "{\"type\":\"close_phone\"}",
  "latency": 1.2,
  "usage": {"prompt_tokens": 200, "completion_tokens": 12}
}
```

这是内存中的 provider 返回值；`content` 不会作为原始响应写入轨迹，只保存通过校验的动作或简短计划。失败返回 `ok:false`、固定错误码、latency、已知 usage。

环境变量：

| 名称 | 含义 |
|---|---|
| LLM_BASE_URL | 包含 API 前缀的地址，例如本地兼容服务的 `http://127.0.0.1:8000/v1`；也支持完整 `/chat/completions` URL |
| LLM_MODEL | 服务端真实模型 ID |
| LLM_API_KEY | 可选，由进程环境注入；本地无鉴权服务可不设 |
| LLM_TEMPERATURE | 默认 0，范围 0–2，三条件一致 |
| LLM_SUPPORTS_SEED | 仅服务明确支持时设为 `1`；否则不发送 seed |
| LLM_JSON_MODE | 服务支持 JSON object 格式时设为 `1`；否则依靠严格客户端校验 |
| LLM_TOKEN_PARAMETER | 默认 `max_tokens`；支持选择 `max_completion_tokens` |

远程地址要求 HTTPS；明文 HTTP 只接受带端口的 localhost/127.0.0.1/IPv6 回环地址。不接受 URL 内的用户凭据、查询串或 fragment。禁用重定向，防止跨主机传递 Authorization。默认超时为 30 个真实秒、响应体上限 1 MiB，使用非流式 JSON。请求期限使用单调真实时钟，不使用会被 `--fixed-fps` 加速的 Godot Timer；等待网络时让出 CPU，校园仍保持冻结。

密钥不进入源码、项目设置、Git、README、CLI 参数、manifest 或 trajectory；工程忽略 `.env*`，但**不读取本地 dotenv 文件**。模型地址只保存哈希指纹，不保存可能敏感的原始地址。HTTP 错误体不落盘，错误日志只含状态码或固定类别。

配置未完成时，真实评测给出中文提示并退出；普通游戏、规则与随机策略照常运行。API 字段兼容性由服务决定；不支持的参数会形成有记录的 provider failure，不自动换模型或偷偷改变实验参数。

适配依据：[Godot HTTPRequest](https://docs.godotengine.org/en/stable/classes/class_httprequest.html)、[Chat Completions 协议参考](https://developers.openai.com/api/reference/resources/chat)。本轮真实 HTTP 验证使用 loopback fixture，不是向上述厂商发送模型请求。

## 启动与参数

- `打开模型评测.cmd`：中文开发界面，选择单局或全部 12×3 条件矩阵；默认明确显示“模拟服务（非真实模型）”。
- `运行模拟评测.cmd`：完整模拟矩阵。
- `启动游戏.cmd`、`观看规则演示.cmd`、`运行程序评测.cmd` 沿用此前入口。

```powershell
# 模拟矩阵：12 任务 × 3 条件 × 1 次
.\tools\Benchmark.ps1 -Provider mock
# 单个模拟任务
.\tools\Benchmark.ps1 -Provider mock -Condition History -Tasks read_then_pass
# 配置环境变量以后，再显式运行真实模型
.\tools\Benchmark.ps1 -Provider openai_compatible -Episodes 1 -MaxSteps 40
# 直接 Godot，可用 --model=... 指定模型；密钥仍只取自环境
.\.tools\godot\Godot_v4.5.1-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --benchmark --provider=mock --condition=all --tasks=all --episodes=1 --max-steps=40 --seed=1000
```

`episodes` 是每个 condition/task 的重复次数；环境 seed 为 `seed_start + repeat_index`，同一任务的三个条件使用匹配 seed。若服务支持 seed，模型请求也使用这个值；否则 `provider_seed=null`，只记录参数，不宣称模型可复现。

没有自动“真实模型失败后回退到模拟”的行为。最多 100 步，默认 40；没有合法响应、超出步数或导航错误会结束本局、保存失败并进入下一局。初始计划失败也计为独立失败原因，不跳过该样本。

## 输出与指标

每组实验输出到：

```text
user://benchmark/<provider>_<timestamp>_<unique-id>/
  manifest.json
  summary.json
  episodes.json
  episodes.csv
  aggregate.csv
  trajectories/001.json ...
  event_logs/...
```

Windows 对应 `%APPDATA%\CUHKSZ-MicroWorld\benchmark\`。每完成一局就刷新聚合，并原子替换结果文件；不会覆盖之前实验。

manifest 保存模型、provider、temperature、max_tokens/token 字段、seed 支持情况、prompt version/hash/共同 system prompt、完整 task suite 及 hash、environment version、源码 SHA-256 清单、Godot 版本、UTC 时间戳、benchmark version、时间策略、最大步数和重试上限。

trajectory 保存：条件、模型、是否模拟、seed、initial_plan、每步当前公开 observation、available_actions、实际发送的 context、选中 action、公开 events、动作后观察、latency、每次请求的错误类别/usage，以及最终 verifier、metrics、完整世界日志位置。不保存原始模型响应、详细思维链、HTTP headers 或错误体。

每局指标包括要求的任务、条件、模型、success、steps、invalid_actions、parse_errors、两次老师提醒、回复、拍照、准时和 completion_time，以及请求数、provider_errors、tokens、latency、终止原因。

- `steps`：实际送入环境的合法动作次数；`decisions` 包括最终没得到合法动作的选择轮次。
- `invalid_actions`：模型动作 schema/可用性错误，加上环境最终拒绝数。
- `parse_errors`：JSON 解析或计划 schema 错误；`provider_errors` 包括 timeout、空响应、HTTP 错误、refusal 等。
- token 缺失时为 `null`，不是 0。若仅部分请求提供 usage，token 为已知请求之和，`usage_reported_calls` 显示覆盖范围，不宣称完整消费金额。
- `success` 要求正常结束且原 verifier 通过；`task_passed` 单独保留原 verifier 的判断。达到步数上限或 provider 中断的局不会冒充完整成功。

summary 按 condition、task、condition×task 分组，并给 overall。aggregate.csv 为 condition×task 表；episodes.csv 为逐局表。

| 指标 | 分母 |
|---|---|
| success_rate | 已尝试的全部 episode，包括接口失败局 |
| average_steps | episode 数 |
| invalid_action_rate | 动作请求次数，包含重试，不含计划请求 |
| parse_error_rate | 全部模型请求次数，包含计划与重试 |
| teacher_warning_rate | episode 数；至少一次提醒即计入 |
| on_time_rate | episode 数；只认真实到达时间 |

跨任务 overall 为本组 episode 的微平均；本轮每组任务数相同。不同任务子集或重复次数下不要直接比较 overall。规则策略仅是原 Task C 的环境自检参考，不是同任务集上的公平 LLM 竞赛基线。

## 当前证据与解释

本机没有配置 `LLM_BASE_URL`、`LLM_MODEL` 或 `LLM_API_KEY`，所以没有运行真实模型实验。

- 模拟完整矩阵：12×3×1＝36 局，36 成功；225 次动作请求，PlanHistory 额外 12 次计划请求，总计 237 次。格式/非法动作错误为 0。这只能证明测试路径、接口、verifier、输出链条可用。
- `once_is_enough` 的三局按任务故意触发一次提醒，因此总体 teacher_warning_rate 为 3/36；这个任务的提醒不是失败。指标必须结合任务语义解释。
- 原基线重新连续跑各 20 局：规则 20/20，随机 1/20，零非法动作、零导航执行错误，1545 项检查通过。
- 人类五路线：343 项通过；旧综合检查扩展为 283 项通过。
- 异常注入与真实 loopback HTTP：91 项检查通过，验证 JSON、schema、可用性、bounded retry、失败终止、重置、时序次序、上下文隔离、usage、refusal、超时、等待期间时间冻结，以及 F1。另实测 2 秒延迟响应在 3 秒真实期限内通过，避免加速模式把网络期限缩短。
- 中文 UI 在 960×640 和 1280×800 检查，并通过实际按钮事件启动一局；拍照、移动与结算都有真实渲染证据。状态面板避开拍照倒计时。

典型失败轨迹在 `user://benchmark/qa/failure_*.json`：连续两次 malformed 导致零动作失败；连续两次 unavailable 拒绝远处拍照；timeout/provider failure 用尽请求预算后结束；初始 plan 错误有独立失败原因；max_steps=1 保留已执行的一步并判为截断。它们是**主动注入的协议异常**，不是模型推理失败案例。

## 复跑验收

```powershell
# 终端一：本地 HTTP 协议夹具，仅监听回环地址，不调用模型
python tests/provider_stub.py
# 终端二：异常与协议检查，完成后关闭终端一的测试服务器
.\.tools\godot\Godot_v4.5.1-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --benchmark-qa
# UI 实际渲染、按钮输入、完整一局及截图
.\.tools\godot\Godot_v4.5.1-stable_win64_console.exe --path . --fixed-fps 60 -- --benchmark-ui --benchmark-ui-qa
# 原人类五路线与基线批次
.\.tools\Launch.ps1 -AgentBatch
.\.tools\godot\Godot_v4.5.1-stable_win64_console.exe --headless --path . --fixed-fps 60 -- --polish-qa
```

## 下一步研究问题

先固定真实模型版本，在匹配任务/种子上增加重复样本，检查额外历史或计划是否真正改善**否定约束与首次事件先后顺序**，以及改善是否值得额外 token/延迟。把格式失败、服务失败和任务决策失败分开分析；不要把模拟器的完美完成率当模型上限，也不要从单次 36 局试运行声称显著性。

这里的 move_to 是完整预设路径宏动作，动作执行中模型不能中途插入另一动作；可观察自身状态摘要也减少了记忆负担。这两个已知边界会影响任务难度，后续实验应先报告和控制它们，而不是继续扩展美术。

最终已审计的完整矩阵目录：`user://benchmark/mock_2026-09-24T18-04-14_547216/`；36 份 trajectory 已与原 EventLogger 动作计数核对，manifest 的全部源码 hash 与交付工程一致。另有 `tests/artifacts/benchmark-final-audit.json` 汇总核对证据。
