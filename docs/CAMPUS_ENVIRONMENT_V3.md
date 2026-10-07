# Campus Environment V3 — Ground Plane, Circulation and Campus Identity

Branch: `world/campus-environment-v3`. Architecture baseline:
`75ded2f3832092586a8c3932f181fe9cbe607882`. No automatic merge into `main`.

V3 is an additive ground/environment pass over the frozen V2 campus. It keeps
the 44 building transforms/profiles, the six vehicle and nine pedestrian route
skeletons, shoreline, macro terrain and original RC1 environment unchanged.
It does not introduce interiors, NPC AI, a new Agent controller or a benchmark.

## Run and reproduce

Run `启动校园主规划.cmd`, or open
`world/campus_master/CampusMaster.tscn` with Godot 4.5.1.
F2 switches overview/third person; F1 shows Chinese names and confidence,
including environment inference and placeholder transport facilities.
0 frames the whole campus; 1–4 frame regions; WASD/Shift walk/jog.

```powershell
python tools/check_campus_environment.py --render --rc1
```

This imports/checks scripts, audits frozen sources and authoring geometry,
captures V2 and V3 from identical cameras, physically walks the main corridor
both ways and side routes, measures uncapped rendering separately, and runs
the unchanged RC1 core checks. Every engine process has a bounded lifetime.
Artifacts/logs are local under ignored `tests/artifacts/`.

`--environment-baseline` selects the original V2 architecture + landscape
within the same explorer. `--architecture-baseline` still selects original V1.
The default `project.godot` launch remains RC1.

## Reference and reconstruction policy

The existing May 2026 guide, Upper courtyard/overall photos, Lower overall and
sports photos, lake references and chat-supplied field observations informed
the environmental vocabulary. No broad new research or asset import was used.
Upper: warm paving, open columns and collegiate courts. Lower: light stone,
public forecourts and restrained planting. Lake: open views, grouped greenery,
short approach paths and quieter fixtures. Exact paving joints, species,
fixture models and furniture coordinates are conservative approximations.

All 16 zones and the entrance/landmark connections are `inferred`, except the
unresolved Tier C entrance and transport facility details (`placeholder`).
Records contain references, inference basis and `replaceable = true`.
No new environmental placement is claimed to be verified survey geometry.
The original geometry's independent confidence is retained.

Raw images and the legacy 14.2 GB asset dump remain local-only. Source metadata
does not grant image/model redistribution rights. No original photograph is
used as a texture. No third-party binary, LFS upload or license change.

## Zone coverage

Authoritative records: `systems/data/campus_environment_zones.json`.

| Zone | Treatment |
| --- | --- |
| UPPER_COLLEGE_CORE | Warm arrivals, shaded open corridors, courtyard paving, seating, noticeboards |
| UPPER_RESIDENTIAL_EDGE | Slender/grouped trees; quiet service edges |
| UPPER_SERVICE_AREA | Short entrance lane, practical forecourt, service noticeboard |
| UPPER_SPORTS | Open approach, surrounding planting without blocking courts |
| UPPER_TO_MIDDLE_TRANSITION | Sloped walk, denser canopy vocabulary, clear walking lane |
| FAIRY_LAKE_NORTH | Grouped planting and long open views |
| FAIRY_LAKE_WEST | Pavilion view opening and connected approach |
| FAIRY_LAKE_EAST | Inscription-stone view opening and water-facility signage |
| FAIRY_LAKE_SOUTH | Sparse scenic furniture and walking continuity |
| MIDDLE_MUSIC_AREA | Arrival paving and approach; V2 Music shell remains approximate |
| LOWER_SPORTS | Sports-hall arrival and road/court boundary readability |
| LOWER_LIBRARY_STUDENT_CORE | Broad public forecourts, converging paths, light stone and informal seating |
| LOWER_ACADEMIC_CORE | Courts, simple covered arrival links, planting and benches |
| LOWER_ADMIN_CONFERENCE | Formal arrival axes, broad paving, fewer informal fixtures |
| LOWER_SHAW | Warmer collegiate court language within the Lower campus |
| LOWER_GATE_EDGE | Existing gate/path transitions; no invented gates |

## Circulation and entrance interfaces

- All six vehicle routes retain their centre-lines/widths and receive asphalt,
  edge strips and restrained markings where the walking network does not overlap.
- All nine walking routes receive region-based paving and low visual edges.
  Shared segments use the same material to avoid equal-height palette flicker.
- Twelve major authored junctions have broadened landing areas; selected
  pedestrian convergence points receive crossing bars.
- All 44 entrances join an exact point on an existing pedestrian segment.
  Authoring A* detours avoid building footprints and water. The planner's free
  grid anchors are validated separately from exact entrance/network endpoints.
- Tier A receives broader arrivals; Library, Student Centre, Administration and
  Conference receive larger public forecourts. Existing building plaques are
  reduced to a human-scale size in V3 only. V2 source files are unchanged.
- Twelve short covered entrance links use light roofs, open sides, columns and
  beam rhythm. These are local inferred interfaces, not an asserted surveyed
  continuous corridor network.
- Six side-step groups describe selected graded pad edges. Three smooth local
  ramp interfaces have simple low-profile box collision. Existing terrain
  supplies all other gradients. This is not an accessibility certification.
- Pavilion, inscription stone and reservoir sign each have a dedicated short
  walking approach tied to the existing shoreline network.

Roads and walking routes sometimes share the frozen V1 corridor. This pass
does not invent physically separated road/sidewalk alignments or real traffic.
The shared-space treatment preserves authoring topology; precise separation
remains a future reference-driven correction.

## Landscape, furniture and signs

Five efficient vegetation families: broad canopy, slender, ornamental,
shrub clusters and low planter vegetation. Stable nonuniform placements avoid
roads, entrances, playing surfaces, buildings and water. Lake east/west view
openings intentionally remain unplanted; regional lawns are not filled merely
to increase prop counts. A few isolated trunks have cylinder collision;
canopies, shrubs and most trunks are non-colliding. Planters and benches use
simple boxes. Low shrub batches have distance culling; major landmarks do not.

Furniture follows route cadence and proximity suppression. Lake lamps are
shorter/more spaced; Lower public paths have closer spacing. Noticeboards are
limited to collegiate/service/student spaces. Posters are authored Chinese
layouts (research participation, research discussion, High Table, lost-and-found),
not real published event advertisements. No ambient NPC expansion.

Wayfinding shares one dark-green/light lettering family. Physical destination
signs may be bilingual; HUD/debug interfaces remain Simplified Chinese.
The existing RC1 “走路不看手机” plaque is untouched; V3 reuses the brown-wood /
green vertical-lettering vocabulary at an explicitly inferred Ling approach.
It does not claim to relocate the real plaque based on an unarchived original.

Both existing masterplan shuttle-stop IDs/positions/regions are retained, with
waiting pad, bench, campus-scale sign, information placeholder, boarding-point
and waiting-area metadata. Two short paved approaches remove the grass gap to
the existing pedestrian network; the visual boarding cue is aligned to that
network endpoint. This does not establish a surveyed vehicle boarding curb.
No unsupported shelter, bus fleet or timetable is
invented. These are visual prototypes, not newly operational transport stops;
the original RC1 wait/board/replanning systems remain unchanged.

Bike racks, new gates and complex fences were deliberately omitted where
current references did not justify a useful placement. The module catalog is
a vocabulary: it does not claim every listed optional module has been deployed.

## Collision, camera and rendering

Ground overlays do not add parallel trimesh floors: they follow the original
terrain triangles exactly. Static environment geometry is merged by material;
zone records and simple collision remain separate. Indexed box meshes and
unindexed paving are normalized before merging: otherwise the paving vertices
can exist in arrays but be absent from the final draw index buffer. A runtime
regression check verifies indexed forecourt triangles, beyond vertex counts.

The original CharacterBody3D / move_and_slide controller and physics settings
are unchanged. The local ramp edge was reduced after actual traversal exposed
a capsule snag on its raised end. New corridor roofs retain the existing
`camera_overhead` fade behavior and are excluded from static material merging.
No general camera/controller rewrite.

## Acceptance and performance

See the final receipt section below for the measured run. Headless fixed-FPS
frame durations are not GPU performance results. Physical route samples are
scripted input to the actual existing controller, not manual first-time-human
playtesting or independent recognition testing.

Main route: Upper → lake → Lower, then reverse, without teleport during the
route. Side smoke routes are independently initialized before each route;
they physically approach and return from Ling court, Amenity, Music, Library,
Student Centre, Administration, Conference, Teaching A court, Shaw court,
Sports Hall, the three lake landmarks, both stop approaches and the east/west shoreline loop.
They do not claim one unbroken human walk through all locations.

## Captures and visual review

V2 before images use identical cameras and the `_v2_before` suffix. Required
V3 files are:

`campus_environment_v3_overview.png`, `upper_environment_v3.png`,
`upper_college_walk_v3.png`, `fairy_lake_environment_v3.png`,
`fairy_lake_walk_v3.png`, `lower_environment_v3.png`, `library_plaza_v3.png`,
`student_centre_v3.png`, `admin_conference_v3.png`,
`sports_environment_v3.png`, `shaw_environment_v3.png`,
`shuttle_stop_v3.png`, `corridor_v3.png`.

Additional `environment_side_*.png` captures show actual route arrivals. All
remain ignored/local. Visual review compares ground connections, planting
rhythm, readable signage, public vs collegiate forecourts and open lake views.
It is a developer review, not a user study claiming campus recognition rates.

## Empty-space and clutter audit

Retain lawns/slope buffers, lake view corridors and sports fields. Replace the
formerly disconnected entrance grass with short lanes/forecourts. Do not fill
the macro campus's large unregistered green margins with speculative buildings
or furniture. Preserve open court axes; benches/planters sit to the side.
Suppress repeated route lamps within 18 game units; do not distribute bins at
every waypoint. Formal arrivals omit informal poster clusters.

Macro terrain is frozen: steep estimated pad transitions and visible polygonal
lake/slope forms remain approximation limits. Draped paving removes overlay
clipping; a small local retaining edge provides a bounded slope interface.
This pass does not certify every off-path hillside as walkable.

## Remaining highest-value gaps

1. Exact pedestrian/vehicle separation at shared guide-derived corridors.
2. Specific plaza/corridor connections and terrace dimensions from ground photos.
3. Faithful current Music-campus forms (V2 shell is an aggregate approximation).
4. Exact college forecourt planting and fixture identities, not generic species guesses.
5. Real shuttle-stop operating/boarding documentation; current V3 metadata is placeholder.

No `ENVIRONMENT_SPATIAL_CORRECTION` moving a building was needed. Further
architecture/interior/Agent expansion requires a separate scope.

## Final measured receipt — 2026-10-07

Commit range: `75ded2f..world/campus-environment-v3` (seven logical commits:
zone/entrance authoring, ground kit/circulation, landscape/facilities, visual and
camera corrections, stop approaches, controller QA, and delivery documentation).
Use `git log --oneline 75ded2f..world/campus-environment-v3` for exact hashes.

Final coverage: 16 zones, 15 frozen route skeletons, 44 entrance connections,
12 short open corridors, 12 junction landings, 3 lake-landmark approaches,
2 stop approaches, 6 decorative side-step groups and 3 local collision ramps.
257 trees in five vegetation families, 91 lamps, 79 benches and 7 noticeboards.
Two previously possible tree placements were suppressed by the stop approaches.

The rendered controller run passed **2,417 checks**, with **42,535 physical
samples / 5,808.84 game units**, main corridor forward/reverse and **16 successful
independent side-route round trips**. No mid-route teleport, time rewrite or
collision bypass. Maximum sampled camera/body separation was 16.40 game units.
Data audit passed 272,588 sampled assertions (including 1-unit path sampling;
this is not a count of independent gameplay scenarios). Original spatial/freeze
audit passed 1,770 checks. RC1 core passed **279 checks**. All had zero failures.
Final visual-only approach batching and capture-camera corrections were followed
by a fresh rendered capture/performance pass (**577 checks**, zero failures).
They did not change physics or the tested route coordinates.

| Same-machine overview measurement | V2 | V3 |
| --- | ---: | ---: |
| Uncapped process-frame time, 120-frame sample | 3.118 ms | 3.152 ms |
| Draw calls | 521 | 541 |
| Nodes | 1,656 | 2,134 |
| Mesh instances | 354 | 317 |
| MultiMesh batches | 170 | 255 |
| Collision shapes | 912 | 1,140 |
| Override materials | 44 | 58 |
| Startup to QA sample | 6,730 ms | 10,493 ms |

Godot 4.5.1, GL Compatibility, Intel Arc 130T. Both runs used the same overview,
disabled vsync and the same background applications, including one pre-existing
campus instance not owned by this task. These are short local samples, not a
portable FPS guarantee or a first-time human traversal timing. Startup grew
because clipped paving meshes are generated at runtime; material consolidation
keeps the draw-call increase to 20. A future cache could reduce startup without
changing the authored geometry, but was not added in this pass.

Local receipts: `tests/artifacts/environment_v2_baseline.json`,
`environment_v3_walk.json`, `environment_v3_performance.json` and
`environment_rc1_core.log`. Thirteen before/after views and side-route captures
remain local/ignored. No large source assets or screenshot binaries are shipped.

Final remote check found no collaborator changes. `origin/main` remains
`bcbfc9431ae73e3d94a8f440f88ad3c0f56bcb63`; the V2 branch remains
`75ded2f3832092586a8c3932f181fe9cbe607882`. No default-scene, RC1, physics,
Agent, benchmark, tag, raw-reference or legacy-asset changes. Only this feature
branch is delivered; no automatic merge or force push.
