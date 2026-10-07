# Unified Campus V6 — main product acceptance

2026-10-07. Product built on immutable V5 `af907bcc3926fc1330a2e29a224e8547e9906682`. [PR #1](https://github.com/jasperjlou/CUHKSZ-MicroWorld/pull/1) was normally merged into main at `e26a8a2470e4df266ba4aa6314df9be460b6d24b`, preserving all preceding collaborator history. Fresh-main-clone validation passed.

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

| Sample | V5 | V6 |
|---|---:|---:|
| Scene startup | 676 ms | 806 ms |
| 120-frame Human overview average | 5.172 ms | 3.451 ms |
| Overview draw calls | 513 | 516 |
| Overview nodes | 2,497 | 2,509 |

V6 during physical library navigation measured 2.848 ms / 98 draw calls; library idle view 2.471 ms / 90. Actual navigation accumulated 376 physics samples and 30.839 game units, 0.033 ms planning, 6.265 s wall time. The short overview difference is not evidence of a general performance improvement; no obvious regression was observed in these samples.

## Publication and clean clone

A fresh remote-main clone at `f5b6dc0c222efd22eb00ff25d0e227b41c7fc6dc` rebuilt its own Godot import cache, then passed the 353-check / 77-episode suite and 15-check rendered normal-product smoke. The engine executable was supplied externally; no developer `.godot` cache, `.tools` folder, reference originals or legacy models were copied into the clone. The normal Human button drove the original body; Tab opened the phone and the reply button updated shared state. The normal Agent button physically reached the library public stairs and exit through 12 demo actions.

One Windows console encoding defect interrupted the *driver output* after the RC1 core had passed. Main `4ab5d0b8992e4f4a05b639ffe2088e1b76e4469a` fixed UTF-8 output and added V6 source import metadata; the clone was normally fast-forwarded and both RC1 core **279 / 0** and contract **77 / 0** were rerun successfully. No gameplay source changed after the clone's physical tests. Generated historical editor sidecars remain local; tracked source diff is empty.

Final documentation/capture cleanup is followed by a normal main push, clone fast-forward and source/link audit. The annotated `v2.0.0-beta1` tag identifies that final main documentation commit (`refs/tags/v2.0.0-beta1^{commit}`), rather than replacing RC1. Main and the public repository remain public with unchanged collaborator permissions. Original V4/V5 branches and all historical QA receipts are retained.

## Limits and preservation

- RC1 tag object remains `976924f3c5c299012b2131b7abfd91524e6f13e5`; historical scores and receipts are unchanged.
- Ten interiors are inferred / replaceable, not surveyed floor plans. High Table is a prototype event room.
- V6 shuttle stop meshes are placeholders; boarding is unavailable. Historical RC1 transport remains separate.
- No paid model calls, AI NPCs, new research benchmark scores or new geometry are introduced.
- No raw reference media, unclear-license legacy assets, LFS or new blanket license is added.
- File-size scan found only the previously tracked 17,772,300-byte NotoSansSC font above 10 MB, with its existing SIL OFL notice. No tracked file exceeds 50 or 100 MB. New screenshots are compact, project-rendered JPEGs.
- Bounded execution failures remain explicit; no teleport, collision bypass or hidden success mutation is allowed.
