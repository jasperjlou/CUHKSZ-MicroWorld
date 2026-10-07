# Campus Masterplan V1

Adds a complete major-building campus skeleton in a separate Godot scene, so the next architectural passes can replace individual buildings without inventing the whole map piecemeal. Upper colleges/residences, Middle/Music/Eighth, Fairy Lake, and Lower academic/public/sports clusters now share one data-driven authoring frame.

- **Branch:** `world/campus-masterplan-fast`
- **Commit range:** `bcbfc94..world/campus-masterplan-fast` (six logical commits).
- **Buildings:** 44 compositional massing sites, 61 total objects, 4 region subscenes.
- **Roads:** 6 vehicle routes, 9 independent pedestrian routes, 28 semantic planning nodes; inferred obstacle-avoiding bends.
- **Lake:** concave shoreline polygon and scenic loop, inferred lake landmarks.
- **Terrain:** upper/lower relief, basin, shared walkable triangle floor, estimated building pads.
- **Scale:** APPROXIMATED_METRIC_SCALE; geographic north, yaw, dimensions and relative elevations are unmeasured. REAL_DISTANCE remains UNKNOWN.
- **Uncertainties:** exact footprint/yaw/height, lake landmark registration, fitness/stop/sign placement and precise route construction. Every geometry record is replaceable. New medical-campus construction is omitted; High Table remains a separate unregistered prototype.
- **Screenshots:** `tests/artifacts/campus_masterplan_{pass1,pass2,overview,labels}.png`; regional `{upper,fairy_lake,lower}_masterplan.png`; three `campus_walk_*.png`. Local/ignored, reproducible via the render command below.
- **Added files:** `world/campus_master/` scripts and five scenes; `systems/data/campus_masterplan.json`, `campus_paths.json`; generator, bounded QA driver, scene QA, dedicated launch entry; coordinate/inventory/placement/distance/conflict/delivery documents.
- **RC1 impact:** old world, default scene, version, physics, controller, Agent, navigation and benchmark are unchanged. No new task/provider/LLM functionality or raw reference/legacy-asset import.

Validation: `python tools/check_campus_masterplan.py --render --rc1` passes 1,770 spatial checks (including LF-normalized frozen source hashes), 446 rendered-world checks and 279 old-scene core checks. An actual collision-driven scripted Upper → Fairy Lake → Lower traversal travels ~1,163 game units without teleporting. Other branches are geometrically checked, not fully certified by an Agent. No independent human test or real-model result is claimed.

Open `启动校园主规划.cmd`; F2 switches overview/ground, F1 labels/confidence, 0 full campus, 1–4 regional views. Full evidence and limitations: [CAMPUS_MASTERPLAN_V1.md](CAMPUS_MASTERPLAN_V1.md).
