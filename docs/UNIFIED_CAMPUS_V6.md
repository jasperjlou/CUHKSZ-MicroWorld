# Unified Campus V6

A stylized, reference-grounded campus shared by Human input and software Agent control. This is not a survey-grade digital twin, a real shuttle simulator, or autonomous visual navigation.

## Product world

44 exterior building shells across Upper, Middle, Fairy Lake and Lower; ten modeled public interiors: Ling, Muse, Music, Sports Hall, Library, Student Centre, Administration, Conference Centre, Teaching A and Shaw East. Seven limited public stair/platform slices. Same V5 roads, terrain, lake, building transforms, indoor coordinates and collision. No V6 geometry changes are required.

Normal Godot launch presents a small Chinese menu: 人类探索 / 智能体演示 / 研究与复现实验. Human WASD and Shift feed the original Player; Agent navigation feeds its existing navigation_direction. Both use the original CharacterBody3D and GodotPhysics3D, including phone slowdown, door thresholds and stair ramps. Indoor camera and streaming remain shared. F1 reports confidence.

## Authoritative semantics

`systems/data/campus_locations_v6.json` derives Campus → Region → Building → Entrance → Floor → Zone → Room, with outdoor destinations and public interaction anchors. Coordinates are stored once as graph-point references, derived from V5; outdoor elevations sample the collision terrain. All 44 buildings have hierarchy records; only ten modeled public interiors are enterable. Closed areas are not legal interior targets.

Public knowledge lists names, region and destination identity. Current perception lists nearby visible anchors through distance/physics-ray checks. It does not reveal the full graph, shortest path, verifier, hidden teacher state or future outcomes. This is a structured navigation environment with public target IDs, not camera-only perception research.

## Public API

`CampusAgentEnvironment`: async `reset(task)` / `step(action)`; synchronous `observe()`, `get_available_actions()`, `is_done()`, `get_result()`.

- `navigate_to(target)` plans AStar3D waypoints and walks the physical body.
- `open_door(target)` is offered only at nearby deployed automatic doors.
- `interact(photo_student)` reuses the original photo sequence.
- `open_phone`, `close_phone`, `reply`, and bounded `wait(duration=5)`.
- Enter/exit are destination IDs in navigate_to, avoiding redundant action types.

A policy never writes body position. Only reset initialization and explicit Human developer reset can assign it. Action completion checks actual position, including vertical floor separation. Bounded local recovery and one replacement route prevent indefinite stalls; failures are explicit NO_PATH / INVALID_TARGET / PHYSICS_BLOCKED / ACTION_TIMEOUT or interrupted reset. Planner retries are executor infrastructure, not model reasoning.

## Time, events and transport

Shared WorldTime ticks during physical actions or Human play. Decision/provider wait is paused. Photo uses the original additional 35 game seconds. GameState stores authoritative flags; EventBus emits physical region/building/floor/zone/room transitions and observable interactions. Teacher perception and two reminders use original NPC scripts.

High Table remains PROTOTYPE_EVENT_INTERIOR. V5 shuttle stop meshes align with public stop IDs; boarding is **unavailable in V6** until a synchronized adapter exists. Old RC1 transport abstraction remains reproducible in its separate historical scene. No physical bus is implied.

## Logs, verifier, replay

Existing EventLogger writes V6 event logs under `user://v6_logs`. Compact step trajectories under `user://v6_trajectories` include observations, legal actions, chosen action, physical result, time, location, navigation statistics and sanitized provider metadata; no internal reasoning. Final results inspect physically reached milestones in order, deadline and event flags. Agent prose cannot satisfy a goal.

CampusReplay resets and executes recorded actions through the same campus, comparing verdict, visited IDs, actions, distance and time within tolerance. The 16-task integration suite covers cross-campus, public interiors, stairs, exit/re-entry, multi-stop ordering, photo and reverse navigation. Rule-based policy uses only public observations/actions. Random and local mock providers are bounded infrastructure tests; no paid model calls or scores.

## Validation

Run with Python 3 and Godot 4.5.1:

```powershell
python tools/check_unified_campus.py
python tools/check_unified_campus.py --qa
python tools/check_unified_campus.py --render
python tools/check_unified_campus.py --human
python tools/check_unified_campus.py --rc1
```

Driver uses `.tools/godot/Godot_v4.5.1-stable_win64.exe` for local Windows development; normal launchers also discover Godot on PATH or accept -GodotPath. Godot editor needs no developer-local data. Detailed release measurements and clean-clone receipts are in [main release](MAIN_PRODUCT_V6_RELEASE.md).

## Limits

All interiors are inferred and replaceable; exact real floor labels, dimensions, surveyed coordinates and permanent High Table venue are unconfirmed. Historical map/cache binaries are project-authored. Raw photography, official panorama images and legacy 14 GB models are not included. Campus identity does not imply university endorsement. License remains pending; existing third-party notices apply.

RC1 benchmark scores describe its frozen journey-v1 environment only. New V6 research would require a separate benchmark protocol. This release integrates a playable world and reproducible infrastructure, not a new scientific model result.
