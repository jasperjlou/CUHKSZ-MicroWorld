# Campus Masterplan V1 — 2026-10-07

The complete **major-object skeleton** of the mapped campus is now present in one authoring frame: Upper → Middle / Fairy Lake → Lower. This is a replaceable, guide-derived masterplan, not a surveyed digital twin or finished architectural model. The future/new medical-campus construction is not represented as completed buildings.

## Extent and placement

61 database objects include **44 building sites**, seven upper/middle colleges (Ling, Muse, Diligentia, Harmonia, Duan Family, Minerva, Eighth), five staff residences, service facilities, Music, and the main lower-campus academic/public clusters. Four instanced region scenes share one macro terrain and one coordinate system.

- **Upper:** staff residences along the northern ridge; Duan/Minerva below them; Amenity Centre and a fitness placeholder; Muse, Diligentia and Ling around the internal circulation; Harmonia farther south. Basketball, tennis, central plaza and a shuttle-stop placeholder provide context.
- **Middle / lake:** a 15-vertex concave lake, western pavilion, eastern stone and reservoir-sign placeholder; a scenic pedestrian loop; Eighth College and three simplified Music volumes; continuous upper/lower connector. Landmark registration is inferred or placeholder.
- **Lower:** track and sports halls on the west; Research/Bell/Zhi Ren/Le Tian/Cheng Dao and Shaw blocks to their east; Student Centre/Library in the central band; HLTu/Lee Yin Yee/Zhang Ling Bin/Teaching A–C to the south; Administration/Conference/Liwen/Teaching Complex A–D toward the east. Lower courts, memorial garden, gates and a stop complete the planning context.

All 44 sites have compositional **MASSING**, not just one full-volume box: courtyard wings, tower/podium, academic wings, stepped student volumes, library reading volumes, administration bridge and sports roof. No windows/interiors/final facade pass. Future architectural replacement should retain the database ID and replace its footprint/massing together.

**6 vehicle-route polylines, 9 pedestrian-route polylines, 28 high-level nodes.** Their inferred bends avoid building/track envelopes with a 6-game-unit centreline clearance and do not cross lake water. This is an authoring planning graph; RC1 Agent navigation is not redirected into it. Only the designated cross-campus corridor has full physical traversal certification; other branches have geometric-clearance checks, not exhaustive human/Agent route certification.

## Coordinates and evidence

See [coordinate policy](CAMPUS_COORDINATE_SYSTEM.md), [inventory](CAMPUS_OBJECT_INVENTORY.md), [placements](CAMPUS_PLACEMENT_TABLE.md), [distances](CAMPUS_DISTANCE_MATRIX.md), and [conflicts](SPATIAL_CONFLICTS.md).

- Origin = qualitative Fairy Lake centre, Y up, +X east, −Z north. Guide visual up is **provisional north**: no usable compass arrow was located. Yaws remain axis-aligned approximations; no geographic bearing is claimed.
- **APPROXIMATED_METRIC_SCALE**; nominal metre-like game units. Track/court dimensions are conventional sanity anchors, not measured campus anchors. REAL_DISTANCE = UNKNOWN.
- Macro upper plateau 54, lower plateau 8, lake water 24 game units; the elevation field is placeholder, with building-pad blending and lake-basin shaping. Landmark Y and exported path points sample the same grid as physical terrain.
- Official guide/name evidence supports object identity and qualitative adjacency. It does **not** verify any exported world-space footprint. All geometry is inferred or placeholder; none is labelled surveyed/verified. Fitness/transport/sign locations remain explicitly weak.
- Existing local guide/photos, source URLs, panorama metadata and legacy numerical audits were consulted. No original reference media or legacy mesh/DAE/Unity asset is copied into this world or Git. Existing raw originals remain local and ignored.

High Table remains `PROTOTYPE_UNREGISTERED` in its existing scene. No arbitrary venue registration or RC1 placement transformation is performed.

## Open and inspect

Run **启动校园主规划.cmd**, or open `world/campus_master/CampusMaster.tscn` in Godot 4.5.1 and run the current scene. A normal project run still opens RC1.

- F2: overview / ground traversal with the existing Player controller.
- F1: Chinese/English object names, `[A]` inferred and `[?]` placeholder; normal ground traversal hides these developer labels.
- 0: full campus; 1/2/3/4: Upper/Middle/Lake/Lower. Mouse wheel zooms; arrows pan the overview.
- Ground: WASD and Shift; R returns to Upper. R is a user convenience; QA never uses it during traversal.

The initial view is the unlabelled whole-campus overhead layout. F1 reveals the placement audit overlay. The camera far plane is extended only in the new world.

## Validation and images

```text
python tools/build_campus_masterplan.py
python tools/check_campus_masterplan.py --render --rc1
```

Verified final receipt: **1,770 spatial checks / 0 failures**, **446 rendered-world checks / 0 failures**, **279 RC1 core checks / 0 failures**. Spatial QA includes the 21 frozen RC1 source hashes, normalized to LF as in the release manifest; Windows CRLF checkout bytes are not treated as geometry changes. No benchmark matrix, provider/API call, or task-system rewrite.

The rendered automated route uses the unchanged `CharacterBody3D` / `move_and_slide()` human controller, existing movement bindings, gravity, collision and camera. It follows Upper Central → lake → Music-side connector → lower sports-side corner → Lower Central, including two inferred bends. **8,431 physics samples**, approximately **1,163 game units** travelled; no teleport/time editing. This is scripted traversal evidence, not independent first-time-human testing. Terrain contact and camera bounds are checked during the route.

Corrected in the alignment passes: touching/overlapping major footprints; sports volumes overlapping the field; roads crossing buildings/water; a basketball-platform slope trap; a lower-court edge trap; floating lake/gate/sign landmarks; wide road ribbons disappearing into terrain; crowded labels. Roads use terrain as the physical floor, avoiding duplicate triangle contact floors.

Generated local, ignored receipts/images:

- `tests/artifacts/campus_masterplan_pass1.png` — earlier PLACEMENT pass; historical image.
- `tests/artifacts/campus_masterplan_pass2.png`, `campus_masterplan_overview.png`, `campus_masterplan_labels.png` — final full layout.
- `upper_masterplan.png`, `fairy_lake_masterplan.png`, `lower_masterplan.png` — final regional oblique views.
- `campus_walk_upper_central.png`, `campus_walk_lake_east.png`, `campus_walk_lower_central.png` — rendered corridor captures.
- `campus_data_qa.json`, `campus_physics_qa.json`, engine logs — precise reproduction receipts.

The images contain project-authored geometry only. They can be regenerated from a clean source checkout; no ignored reference original is required to run the scene. Sparse placeholder vegetation and simple daylight are deliberately retained. Doors, windows, interiors, surveyed heights/rotations and precise landscaping are a **FUTURE ART PASS**.

## Collaboration / RC1

Work branch: `world/campus-masterplan-fast`, based on `bcbfc9431ae73e3d94a8f440f88ad3c0f56bcb63`. Six staged commits cover coordinates/inventory, skeleton, footprints, massing, alignment, and delivery audit. Main is not merged into or overwritten by the feature branch.

`project.godot`, its default RC1 scene/version/physics, existing player controller, Agent/benchmark code and frozen world implementations remain unchanged from `v1.0.0-rc1`. The benchmark release manifest remains frozen. The new geometry/data, scene, QA and launch entry are separate. Full navigation integration and individual building upgrades are future work.

Collaborator-ready summary: [CAMPUS_MASTERPLAN_PR_SUMMARY.md](CAMPUS_MASTERPLAN_PR_SUMMARY.md).
