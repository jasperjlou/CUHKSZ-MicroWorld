# Journey benchmark protocol v1

This protocol evaluates decisions in the frozen Phase F world, using Godot **4.5.1 stable**, GL Compatibility, GodotPhysics3D, CharacterBody3D and the existing AStar3D action executor. It does not replace the older High Table protocol in [BENCHMARK.md](../BENCHMARK.md).

## Task suite and trust boundary

`benchmark/tasks/journey-v1/` contains **16 tasks**: four navigation, four timing, four transport, two controlled branch recovery and two information-condition tasks. `suite.json` lists IDs and mock fixture expectations. Each task defines semantic spawn, destination, start/event/end times, transport permissions, required visits, deterministic seed, step/time bounds, setup disturbances and independent verifier rules. Geometry is frozen by `systems/data/environment_release.json`; normalized source hashes tolerate Windows line endings, not geometry changes.

`JourneyTask` applies configuration once before the episode starts. Initial spawning is scenario setup; it is not an Agent action. Recovery tasks first execute a declared wrong-branch navigation through real collision. Wait disturbances similarly advance the clock through the existing wait action. These are logged as `actor=setup`, included in elapsed time/distance, and excluded from Agent action count. They test recovery from a controlled disturbance, not whether a model spontaneously makes that mistake.

The provider receives only `JourneyObservation`'s current-state projection and legal actions. It does **not** receive the full task JSON, setup actions, verifier configuration, expected outcomes, world graph, shortest path, correct route, future state, source coordinate conversion helpers or hidden state. Current object coordinates and semantic destination IDs already belong to the public API. Published schedule estimates are current public information; they are not a simulation of future world states.

`navigate(target)` remains a high-level AStar route action, physically executed with `move_and_slide()`. The policy chooses destinations and transport, not every turn or steering vector. These results therefore cannot establish low-level visual navigation ability. The abstract shuttle moves an embarked passenger to its destination after simulated travel; its displacement is excluded from walking distance. It is explicitly labelled `transport_abstraction`, not physical bus driving.

## Three stable conditions

| Condition | Input |
| --- | --- |
| Reactive | Current task instruction, observation, legal actions |
| History | Same current input plus at most four recent observation/action/result transitions |
| PlanHistory | Same bounded history plus one initial 1–5-step action plan |

Completed waypoint flags are current world state shared by all three conditions, not private memory. Raw accumulated events, visited-zone history and verifier state are omitted from all prompts. History is deep-copied and cleared between episodes. Plans are short observable actions, not hidden chain-of-thought; provider `reasoning_content` is ignored. A separate Godot process isolates each episode.

## Execution and verification

World time is **decision-gated**: paused while obtaining model output, advanced while executing movement/wait/ride. Network timeouts use monotonic wall time, separately from accelerated `--fixed-fps 60` simulation. Maximum steps, simulated duration, per-request timeout, per-episode wall timeout and total real-provider call reservations bound execution. The last action can be interrupted by the simulated-duration guard. Every chosen action must exactly match a currently legal object; JSON numeric fields are normalized to that canonical object. Invalid provider outputs count toward invalid actions; parse/provider errors are also retained. No invalid response silently becomes a successful action.

`JourneyVerifier` reads the actual position, inspected destination, event attendance time, required visits, invalid actions, collision recovery and transport state. Model text and `world.result.success` are not authoritative. Arrival categories follow existing CampusEvents: early before start−60s, on_time from start−60s through start inclusive, late after start but before end, missed at/after end. Navigation tasks use generous artificial deadlines; `time_late_allowed` explicitly accepts late attendance. `time_missed` is intentionally unsatisfiable and must remain a failed task even when the pipeline works.

Wrong-branch count means physically reaching Ling/Other when it is not the task destination. Replanning counts a completed return to FirstJunction/CollegeBranch_Fork plus existing wait-to-walk replans. Neither metric asserts hidden cognition. A required lake visit is independently enforced. Boundary recovery invalidates success.

## Commands

Python 3.10+ standard library suffices. Install Godot 4.5.1 and set `GODOT_BIN` to its executable (or put `godot` on PATH). Run from the repository root:

```powershell
python benchmark/run_benchmark.py --provider mock
python benchmark/verify_results.py benchmark/results/<batch>
python benchmark/report.py benchmark/results/<batch>
python benchmark/replay.py benchmark/results/<batch>/<run>
```

Default configuration: `rc1-mock.json`, suite journey-v1, all 16 tasks × three conditions × one repeat, seeds beginning at 42, history four, two attempts, 256 output tokens. Select smaller subsets with `--tasks nav_upper_lower,transport_shuttle --conditions Reactive --repeats 2`. `--rendered` runs the same benchmark visibly with the human HUD hidden; headless is default. The launcher automatically imports a fresh clone before running. On Windows it selects the direct engine executable beside an official `_console.exe` wrapper so wall-time termination does not leave an engine child. No private images, engine cache, model key or legacy assets are needed for mock validation.

Action replay reads a run's `job.json` and trajectory, re-executes setup and recorded legal actions through the same runtime, then compares verdict, branch/transport counters, action count and distance. It is not a video/frame replay. New runs include a runtime source fingerprint; use the exact source checkout and environment hash when replaying. CPU/GPU timing can differ slightly; cross-machine bitwise determinism is not promised.

## Opt-in real provider

The existing OpenAI-compatible **Chat Completions** adapter is reused. This is a protocol adapter, not a claim that every model supports the same temperature/token/JSON-mode parameters. Configure those in the pilot JSON when necessary; no vendor-specific SDK is required.

Set `AGENT_BASE_URL`, `AGENT_MODEL` and `OPENAI_API_KEY` locally. Existing `LLM_BASE_URL`, `LLM_MODEL`, `LLM_API_KEY` aliases also work. A base URL must use HTTPS (loopback HTTP only for tests), without URL credentials/query/fragment. Redirects are disabled. Do not paste keys into commands, config files or issue reports. `.env` is ignored and **not automatically loaded**.

```powershell
python benchmark/run_benchmark.py --provider openai-compatible --config benchmark/configs/rc1-pilot.json --dry-run
python benchmark/run_benchmark.py --provider openai-compatible --config benchmark/configs/rc1-pilot.json --allow-network
```

Pilot: four representative tasks × three conditions × two repetitions = 24 requested episodes, seeds 42/43, one attempt, 256 output-token cap, 200-call global budget. Before each episode, the runner reserves its worst-case remaining calls. If that cannot fit, it stops scheduling episodes; requested/completed coverage is recorded. Prices and input-token totals depend on the selected provider; the dry run reports call/output-token ceilings, **not a fabricated monetary quote**. Inspect provider pricing and lower budgets before enabling calls if needed. Repository QA never requires external credentials.

## Output and metrics

Each ignored `benchmark/results/<batch>/<run>/` contains `job.json`, `result.json`, `trajectory.jsonl`, `engine.log` and the existing EventLogger files under `events/`. Job files contain local output paths; they are not public artifacts. There are no raw provider envelope dumps. Trajectories record current observation, legal actions, chosen action, result, next observation, clock/location, public provider context, sanitized usage receipts, branch target and evaluator state. Evaluator snapshots are audit-only and never fed back to the provider. Failed or interrupted runs retain partial evidence.

Result schema: `benchmark/result_schema.json`. Metrics include success/reason, arrival time/category/lateness, action count, invalid outputs/actions, wrong branches/replans, distance, walking/waiting/ride time, shuttle/mode, visited zones, tokens and latency, task/environment/source hashes and seeds. All durations except latency are **game seconds**; distance is **game units**, not measured metres. `latency_ms` is total measured provider request latency per episode. Token aggregates are null unless every call supplies prompt/completion usage; total is their sum. Mock/replay token and latency fields are null. A wall-killed process emits failure with unknown live metrics as null, rather than inventing zero values.

`summary.json` and `report.md` group by provider/model/condition/suite/environment/evidence type; missing metrics include reported-run counts. Mock, loopback-contract and replay are not real-model results. Failed tasks remain in denominators. Always compare matching task coverage and seeds; the unsatisfiable task and incomplete budgets make an unqualified overall success percentage misleading. Do not publish local raw trajectories or endpoints without review.

## QA and limits

```powershell
godot --headless --path . --fixed-fps 60 -- --rc1-qa
python -m unittest discover -s tests -p test_rc1_pipeline.py
python tests/rc1_failure_cases.py benchmark/results/<batch>/nav_upper_lower--Reactive--0
godot --headless --path . --fixed-fps 60 -- --cross-campus-qa
godot --path . --fixed-fps 60 -- --cross-campus-render
```

The old provider contract QA needs `tests/provider_stub.py` running locally before `--benchmark-qa`. `tests/rc1_http_fixture.py` is an additional loopback-only journey contract fixture. Neither is a model experiment. Exact delivery receipts are recorded in [QA.md](../QA.md).

No real-model study was run for RC1 because no supported credentials/configuration were present. Mock policy deliberately follows public task semantics; it is a reachability/protocol fixture, not a competitive learned policy. The small suite does not establish generalization, memory necessity, model superiority or real campus transport quality.
