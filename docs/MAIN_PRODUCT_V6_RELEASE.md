# Unified Campus V6 — main product acceptance

2026-10-07. Product candidate: `agent/unified-campus-v6`, based on immutable V5 `af907bcc3926fc1330a2e29a224e8547e9906682`. Main promotion uses a normal merge preserving collaborator history. The final merge and fresh-main-clone evidence are recorded below after those operations complete.

## Product

The default scene is `world/unified/UnifiedCampus.tscn`; project version is `2.0.0-beta1`. Chinese choices expose Human Explore, physical Agent Demo and explicit historical RC1 reproduction. Root launchers discover an installed Godot or accept its executable path. No local reference photo, recovered GTA model, baked import cache or developer engine is needed to clone the project.

Human and Agent use the same 44 exteriors, ten inferred public interiors, seven stair/platform slices and unchanged original CharacterBody3D / GodotPhysics3D. V5 geometry and RC1 sources remain frozen. AStar3D supplies waypoints to the original movement input; navigation never assigns body position. Episode initialization is separate from walking.

## Executed acceptance

| Gate | Result | Evidence |
|---|---|---|
| Frozen world, graph, RC1 source and physics audit | 222 / 0 failures | `tools/check_unified_campus.py` |
| Final headless Agent suite | 353 / 0; 77 episodes | final headless receipt |
| Full rendered physical Agent suite | 349 / 0; 77 episodes | rendered receipt |
| Full rendered Human routes and events | 3,782 / 0 | Human receipt |
| Normal menu → Human movement → Tab/reply → Agent library stairs/exit | 15 / 0 rendered; 11 / 0 headless | product smoke |
| Original RC1 core / contract | 279 / 0 and 77 / 0 | explicit `world/MainWorld.tscn` regression |

Agent acceptance includes 16 Rule tasks, physical replay, all ten buildings with entry/exit/re-entry, seven public stairs, 50 mixed physical episodes, reset isolation, reverse campus route, and full continuous showcase. Random and mock provider actions are bounded infrastructure checks. The four additional final headless assertions cover the real local mock contract and bounded failure/replanning against a temporary collidable entrance blocker. That test fixture is removed and never becomes product geometry. Rendered physical routes were recorded before those additional assertions; the final menu smoke exercises the shipping adapter.

These are scripted inputs and rendered viewport captures, **not manual first-time student tests or external-model benchmark results**. The final Human route accumulated 81,668 physical samples and approximately 11,100 game units. Original logs and detailed trajectories remain local; a compact public receipt records results without provider data or personal paths.

## Performance

Sequential uncapped render measurements use Godot 4.5.1 Compatibility on Intel Arc 130T. The same background application remains present for both versions. These small machine-specific samples are descriptive, not a portable FPS guarantee. Final baseline/current measurements are in [receipt](MAIN_PRODUCT_V6_RECEIPT.json). Headless timing is explicitly not rendering performance.

## Publication and clean clone

Pending normal main merge and fresh remote-main clone validation. Do not treat this subsection as completed until the recorded main SHA and clone gates are present in the receipt.

## Limits and preservation

- RC1 tag object remains `976924f3c5c299012b2131b7abfd91524e6f13e5`; historical scores and receipts are unchanged.
- Ten interiors are inferred / replaceable, not surveyed floor plans. High Table is a prototype event room.
- V6 shuttle stop meshes are placeholders; boarding is unavailable. Historical RC1 transport remains separate.
- No paid model calls, AI NPCs, new research benchmark scores or new geometry are introduced.
- No raw reference media, unclear-license legacy assets, LFS or new blanket license is added.
- Bounded execution failures remain explicit; no teleport, collision bypass or hidden success mutation is allowed.
