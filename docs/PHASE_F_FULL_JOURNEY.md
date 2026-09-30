# V1.0 Phase F — Full Journey + Destination Anchoring

Comparison baseline: `560a898da54cdb2852c463fabae6b41f92bcb062` (Phase E).
The baseline commit, `systems/data/junction_world.json`, and historical D/D2/E reference records are retained.

## Play

Choose **跨园赴约** on the main menu, or launch Godot with `-- --cross-campus`.
The original **漫步神仙湖** and High Table modes remain available with their original tasks and clocks.

The new task starts at 18:00 in **上园出发广场**. Visit **湖畔观景处**, then return through the junction and sign in at **下园活动广场** before the 18:30 activity. The fictional event ends at 18:50. One real simulation second advances 12 game seconds. WASD moves, Shift jogs, E interacts, C/V changes the view, Esc pauses, and F1 shows confidence.

```text
UpperCampus_Start (UpperBranch_End anchor)
  → UpperBranch_Bend → FirstJunction
  → Option B access → inferred middle road → forest / entrance corridor
  → FairyLake_Viewpoint_01
  → return along lake / corridor → FirstJunction
  → CollegeBranch_Fork → LowerBranch_Bend
  → LowerCampus_Event_Area (LowerBranch_End anchor)
```

This is a connected authored game world, not a measured journey through the actual full campus.
The start and destination use the existing branch-end paving as small playable plazas, with new signs, planters, seating and original background building massing. No arbitrary extra road length or second navigation framework is introduced.

## Runtime authority and evidence

- Phase E route geometry / graph: `systems/data/junction_world.json`.
- Phase F anchors, task, event and prototype schedules: `systems/data/cross_campus_journey.json`.
- `JourneyLayout` binds semantic anchor IDs to existing graph points. `JourneyBuilder` adds bounded destination dressing; each new mesh and collider carries confidence, inference basis and `replaceable=true`.
- Upper / lower plazas are **inferred** from the illustrated Campus Guide topology and existing branch directions. Their dimensions, architecture and placement are authored approximations. The lower event itself is **placeholder**.
- The Ling College gate is an **inferred** silhouette guided by user-supplied photos visible in the conversation: gray columns / lintel, Chinese title and LING COLLEGE lettering, shallow display steps and background massing. No college interior is accessible.
- The roadside access remains **placeholder**, option B. D2 continuity remains **inferred**. No blocking unknown is reintroduced; geographic registration remains unverified.
- Photo originals and legacy models are not redistributed. `legacy_models_imported=0`. No new license grant is implied; existing asset notices still apply.

## Shared systems

`FairyLakeWorld` selects either the legacy lake task or Phase F configuration. Both use the same WorldTime, CampusEvents, LakeTransport/ShuttleSystem, EventBus/EventLogger, AStar3D and CharacterBody3D movement. Physics remains Godot 4.5.1's default GodotPhysics3D (`physics/3d/physics_engine=DEFAULT` at runtime, no Jolt setting or extension).

The prototype stop remains at the lake entrance. In Phase F, its abstract ride ends at the new lower activity anchor. Riding displacement does not count as walking distance. Stations, service times, delays and ride durations are fictional placeholders. This is not a physical bus driving simulation.

## Observation, policy and metrics

`FairyLakeEnvironment.observe()` uses `journey-1` in Phase F, adding current_zone, nearest_landmark, junction_branches and journey progress while preserving event, destination, time_remaining and transport state. Branches retain four walking destinations plus a non-walkable vehicle road. Upper/lower now identify bounded destination slices; Ling identifies the gate only. Copies do not mutate the historical Phase E definition.

No best_branch or correct_route is emitted. `CrossCampusPolicy` is a small deterministic baseline that reads only public observations, recognizes alternative endpoints from branch semantics and returns to the junction, then selects outstanding task landmarks and the destination, and uses the existing navigate/inspect actions. It neither teleports nor edits time. It is not an LLM experiment or a new planner framework.

Run one standalone episode:

```powershell
godot --headless --path . --fixed-fps 60 -- --cross-campus-agent
```

The `CROSS CAMPUS BENCHMARK` completion receipt includes the result and local summary path. Normal EventLogger output persists the trajectory and final summary. QA's scenario matrix also writes `tests/artifacts/phase_f_qa.json` (ignored by Git).

Metrics: success, arrival_time, lateness, path_length, walking_time, waiting_time, shuttle_used, transport_mode, wrong_branch_count, replanning_count, invalid_actions and visited_zones. Times are **game seconds**, distance is **game units**; travel_time separately records simulation seconds. Success requires the lake visit and arrival no later than event start. Exactly event end counts as missed, following the existing event verifier.

A wrong branch is counted on physically reaching Ling/Other while the lower event is the task destination; lingering there does not repeatedly increment it. A branch replan is counted upon returning to FirstJunction or CollegeBranch_Fork. This measures a completed return from a detour, not hidden cognitive planning. `replanning_count` sums branch returns and existing wait-to-walk transport replans; both component counts are retained. Exploring a branch is allowed and does not itself fail the task.

## Validation and stop point

New suite: `--cross-campus-qa` / `--cross-campus-render`. It covers held-input upper–lake–lower, reverse anchor travel, both alternative branches, observation-only policy completion, real wait/board, delay-to-walk, late/missed outcomes, required-visit rejection, multiple restarts including during transit, collision grounding, camera validity, Chinese UI and logging. Existing JunctionQA remains independent.

See [QA.md](../QA.md) for final measured results and known limitations. Rendered automatic routes are distinguished from native-window visual/input checks; neither is an independent first-time-user study. After Phase F, stop expanding the map. The next proposed scope is Final Polish / Benchmark / Release Candidate, not part of this change.
