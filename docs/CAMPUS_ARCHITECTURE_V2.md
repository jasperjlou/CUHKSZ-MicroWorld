# Campus Architecture V2

Full building-shell pass on `world/campus-architecture-v2`, based on Masterplan V1 `faa4370`. The 44 sites now instantiate architectural profiles: **16 Tier A, 27 Tier B, 1 Tier C**. No unexplained MASSING remains in the V2 profile layer. The old V1 data intentionally retain their historical massing stages; `--architecture-baseline` renders that baseline for comparison.

Library uses interlocking C-shaped volumes and a recessed/open ground level; Administration uses paired stone wings and an overhead bridging bar; Student Centre uses layered courtyard bars and warm screens. Upper colleges have open podiums, window grids, colored vertical accents, stepped rooflines and courts. Staff residences have slim towers and balcony ledges. Academic blocks use stone bars, warm screened bases and recessed glass bands. Sports Hall has a white large-span shell and clerestory; Music retains an interpreted three-part curved silhouette. These forms improve regional reading, but college-specific tower topology and Music's current performing-arts outline remain approximations.

Sources: [official Library description](https://www.cuhk.edu.cn/en/article/6130), [official Music campus description](https://www.cuhk.edu.cn/en/article/15580), [designer research](https://www.arch.hku.hk/secondary_category/weijen-wang/), existing official regional photographs and May 2026 guide. Library and Sports have strong feature references; regional photos do not verify an individual building's unseen facade. No raw photos, panorama textures or legacy binaries were imported into game assets or Git.

The reusable kit includes 21 named vocabulary modules via `CampusModuleCatalog.gd`, backed by procedural boxes, arcade columns, glass planes, facade MultiMeshes and screens. Eight base material roles plus restrained college/vegetation accents are shared. Facades have no per-window nodes or colliders. Solid boxes and column shapes are grouped in a building-level StaticBody3D; visual boxes are baked by material. The full terrain remains the existing single concave floor. No visual facade trimesh was introduced.

Covered/open circulation is local to college podiums and lower building arcades, not invented campus-wide bridges. Existing route geometry is unchanged. Central canopy gaps and level forecourts stay open; no new stairs/ramps are needed for the existing level entrances. Stair/ramp modules are available but not placed without a local level requirement. Entrance points, courtyard and walkable opening metadata prepare future navigation authoring; no NavigationMesh or new Agent navigation integration is claimed.

Landscaping uses authored upper residential rows, lower organized planting and denser lake-edge groups, filtered against roads/building/track/court envelopes and water. Courtyard paving, planters, benches, path-side lamps, pavilion rails and Chinese physical signs are restrained supporting details. Placement is inferred and replaceable. Existing road/court/track/plaza paving plus courtyard stone form the small ground palette. Trees/furniture are visual dressing; they do not certify real current planting or lighting.

F1 displays Chinese names and separate spatial/architecture confidence. F2 switches aerial/ground mode, 0 full campus, 1–4 regions. Normal HUD is concise Chinese. Regional cameras now provide a clearer oblique view; silhouette checks also render neutral-material geometry without color cues.

## Performance and validation

| Same-machine overview metric | V1 | V2 |
|---|---:|---:|
| nodes | 953 | 1666 |
| mesh_instances | 457 | 354 |
| facade_batches | 0 | 170 |
| collision_shapes | 199 | 922 |
| material_count | 85 | 45 |
| draw_calls | 457 | 521 |
| measured_frame_ms | 2.386 | 3.138 |
| startup_msec | 6572 | 6733 |

Measured on the same Intel Arc 130T, Compatibility renderer, 1280×800, overview camera, vsync disabled, 120 actual process frames after warm-up. Frame time is an uncapped local rendering sample, not a promised player FPS or cross-device benchmark. Startup includes engine/scene startup until the first test sampling point and can vary with filesystem caches. Physics/camera traversal uses a fixed 60 Hz simulation separately; its wall-clock speed is not human walking time. No LOD/streaming subsystem was necessary at the observed cost.

The final rendered acceptance run passed **875 checks**, including 132 entrance capsule-clearance probes across 44 sites. The existing CharacterBody3D controller walked Upper → Fairy Lake → Lower → Fairy Lake → Upper with **16,857 physics samples / approximately 2,325 game units**, no teleport or time editing, and bounded camera distance (~15.76). This is automated collision-driven traversal, not independent human recognition or first-time-user testing. Entrance probes establish capsule-space clearance, not full interior accessibility. The bell approach is explicitly outside its solid shaft.

Spatial/RC1 verification: 1,770 masterplan assertions, frozen-source hashes, and 279 RC1 core checks passed. World Time, events, shuttle, waits/boarding/replanning, semantic navigation and logging sources remain unchanged. Default project scene/version/physics backend remain RC1. Geometry/collision fixes were limited to the separate master scene's shells.

Run `python tools/check_campus_architecture.py --render --rc1` for reproducible captures, two-way traversal, uncapped V1/V2 timing and frozen-core checks. Open `启动校园主规划.cmd` for the interactive V2 scene.

## Capture index

Local-only `tests/artifacts/`: `campus_architecture_v2_overview.png`, `campus_architecture_v2_labels.png`, `upper_architecture_v2.png`, `fairy_lake_v2.png`, `lower_architecture_v2.png`; `library_v2.png`, `admin_v2.png`, `student_centre_v2.png`, `ling_v2.png`, `shaw_v2.png`, `music_v2.png`, `sports_v2.png`; Library front/pedestrian/aerial; all 16 `<id>_architecture_review.png`; `architecture_neutral_silhouettes.png`; physical route captures. Capture cameras are scripted inspection views, not manual camera operation.

The correction pass strengthened college accents/roof screens, added Music facade rhythm and staff balcony ledges, exposed signs beyond facade planes, changed the regional camera angle, removed central doorway columns and moved the bell approach outside its shaft. Main circulation still uses the unchanged V1 ground and routes. Focused gap records remain in [ARCHITECTURE_REFERENCE_GAPS.md](ARCHITECTURE_REFERENCE_GAPS.md); transform freeze in [ARCHITECTURE_SPATIAL_CORRECTIONS.md](ARCHITECTURE_SPATIAL_CORRECTIONS.md).

## 44-building coverage

| ID / 名称 | Tier | Stage | Architecture confidence | Signature |
|---|---|---|---|---|
| ling / 道扬书院 | A | LANDMARK | SUPPORTED | tower and open podium, enclosed courtyard, college-specific accent and roof screen |
| muse / 思廷书院 | A | LANDMARK | SUPPORTED | tower and open podium, enclosed courtyard, college-specific accent and roof screen |
| diligentia / 学勤书院 | A | LANDMARK | SUPPORTED | tower and open podium, enclosed courtyard, college-specific accent and roof screen |
| harmonia / 祥波书院 | A | LANDMARK | SUPPORTED | tower and open podium, enclosed courtyard, college-specific accent and roof screen |
| duan / 永平书院 | A | LANDMARK | SUPPORTED | tower and open podium, enclosed courtyard, college-specific accent and roof screen |
| minerva / 厚含书院 | B | ARCHITECTURAL_SHELL | APPROXIMATED | tower and open podium, enclosed courtyard, college-specific accent and roof screen |
| eighth / 第八书院 | A | LANDMARK | SUPPORTED | tower and open podium, enclosed courtyard, college-specific accent and roof screen |
| amenity / 服务中心 | B | ARCHITECTURAL_SHELL | APPROXIMATED | layered podium, window rhythm, recessed entrance |
| upper_gym / 上园健身设施（近似） | C | ARCHITECTURAL_SHELL | PLACEHOLDER | layered podium, window rhythm, recessed entrance |
| staff_1 / 教职员宿舍1 | B | ARCHITECTURAL_SHELL | APPROXIMATED | slim gridded tower, lower podium, roof screen |
| staff_2 / 教职员宿舍2 | B | ARCHITECTURAL_SHELL | APPROXIMATED | slim gridded tower, lower podium, roof screen |
| staff_3 / 教职员宿舍3 | B | ARCHITECTURAL_SHELL | APPROXIMATED | slim gridded tower, lower podium, roof screen |
| staff_4 / 教职员宿舍4 | B | ARCHITECTURAL_SHELL | APPROXIMATED | slim gridded tower, lower podium, roof screen |
| staff_5 / 教职员宿舍5 | B | ARCHITECTURAL_SHELL | APPROXIMATED | slim gridded tower, lower podium, roof screen |
| music / 音乐学院 | A | LANDMARK | SUPPORTED | three faceted elliptical volumes, stepped curved roof silhouette, glazed lobby |
| research / 科研楼 | B | ARCHITECTURAL_SHELL | APPROXIMATED | slim gridded tower, lower podium, roof screen |
| bell / 钟楼 | B | ARCHITECTURAL_SHELL | APPROXIMATED | slender stone shaft, open belfry, roof cap |
| zhiren / 志仁楼 | B | ARCHITECTURAL_SHELL | APPROXIMATED | stone teaching bars, warm screened base, recessed glazed bay |
| letian / 乐天楼 | B | ARCHITECTURAL_SHELL | APPROXIMATED | stone teaching bars, warm screened base, recessed glazed bay |
| chengdao / 诚道楼 | B | ARCHITECTURAL_SHELL | APPROXIMATED | stone teaching bars, warm screened base, recessed glazed bay |
| shaw_west / 逸夫书院（西座） | A | LANDMARK | SUPPORTED | perimeter residential wings, open pedestrian entrance, courtyard planting |
| shaw_east / 逸夫书院（东座） | A | LANDMARK | SUPPORTED | perimeter residential wings, open pedestrian entrance, courtyard planting |
| sports_hall / 大学体育馆 | A | LANDMARK | STRONG_REFERENCE | white large-span hall, clerestory ribbon, fine vertical fins |
| sports_complex / 综合运动馆 | B | ARCHITECTURAL_SHELL | APPROXIMATED | stone teaching bars, warm screened base, recessed glazed bay |
| zhixin / 知新楼 | B | ARCHITECTURAL_SHELL | APPROXIMATED | stone teaching bars, warm screened base, recessed glazed bay |
| daoyuan / 道远楼 | B | ARCHITECTURAL_SHELL | APPROXIMATED | stone teaching bars, warm screened base, recessed glazed bay |
| library_annex / 图书馆附馆 | B | ARCHITECTURAL_SHELL | APPROXIMATED | stone teaching bars, warm screened base, recessed glazed bay |
| student_centre / 学生中心 | A | LANDMARK | SUPPORTED | terraced horizontal courtyards, open ground arcade, warm vertical screens |
| library / 大学图书馆 | A | LANDMARK | STRONG_REFERENCE | two interlocking C volumes, recessed veranda, open reading court |
| hllu / 涂辉龙楼 | B | ARCHITECTURAL_SHELL | APPROXIMATED | stone teaching bars, warm screened base, recessed glazed bay |
| leeyin / 李贤义楼 | B | ARCHITECTURAL_SHELL | APPROXIMATED | stone teaching bars, warm screened base, recessed glazed bay |
| zhangling / 张灵斌楼 | B | ARCHITECTURAL_SHELL | APPROXIMATED | stone teaching bars, warm screened base, recessed glazed bay |
| teaching_c / 教学楼C | B | ARCHITECTURAL_SHELL | APPROXIMATED | stone teaching bars, warm screened base, recessed glazed bay |
| teaching_b / 教学楼B | A | LANDMARK | SUPPORTED | perimeter residential wings, open pedestrian entrance, courtyard planting |
| teaching_a / 教学楼A | A | LANDMARK | SUPPORTED | perimeter residential wings, open pedestrian entrance, courtyard planting |
| administration / 行政楼 | A | LANDMARK | SUPPORTED | paired stone wings, elevated bridging volume, glass entrance |
| conference / 逸夫国际会议中心 | A | LANDMARK | SUPPORTED | broad glazed foyer, large auditorium volume, low side wings and canopy |
| conference_2 / 会议楼II | B | ARCHITECTURAL_SHELL | APPROXIMATED | broad glazed foyer, large auditorium volume, low side wings and canopy |
| conference_1 / 会议楼I | B | ARCHITECTURAL_SHELL | APPROXIMATED | broad glazed foyer, large auditorium volume, low side wings and canopy |
| liwen / 礼文堂 | B | ARCHITECTURAL_SHELL | APPROXIMATED | layered podium, window rhythm, recessed entrance |
| teaching_complex_c / 综合教学楼C座 | B | ARCHITECTURAL_SHELL | APPROXIMATED | stone teaching bars, warm screened base, recessed glazed bay |
| teaching_complex_d / 综合教学楼D座 | B | ARCHITECTURAL_SHELL | APPROXIMATED | stone teaching bars, warm screened base, recessed glazed bay |
| teaching_complex_b / 综合教学楼B座 | B | ARCHITECTURAL_SHELL | APPROXIMATED | stone teaching bars, warm screened base, recessed glazed bay |
| teaching_complex_a / 综合教学楼A座 | B | ARCHITECTURAL_SHELL | APPROXIMATED | stone teaching bars, warm screened base, recessed glazed bay |
