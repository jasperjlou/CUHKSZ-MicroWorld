"""Record this structural batch without treating local routes as full-campus proof."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
def read(path):
    return json.loads((ROOT / path).read_text(encoding="utf-8-sig"))
def write(path, value):
    (ROOT / path).write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
def sha(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()

initial = "tests/artifacts/library_core_boundary_v147.json"
final = "tests/artifacts/library_core_boundary_v147_finish.json"
a, b = read(initial), read(final)
assert not b["failures"] and len(b["physical_legs"]) == 41
assert len(a["checks"]) == 41 and all(c["valid"] for c in a["checks"])
indices = list(range(16)) + list(range(17, 28))
assert all(a["physical_legs"][i]["valid"] for i in indices)
logs = ["tests/artifacts/library-core-v147-initial.log", "tests/artifacts/library-core-v147-finish.log"]
for path in logs:
    assert not any(line.startswith(("ERROR:", "SCRIPT ERROR:")) for line in (ROOT / path).read_text(encoding="utf-8").splitlines()), path
source = ["world/visual_campus/LibraryServiceCores.gd", "world/visual_campus/LibraryRareReading.gd", "world/visual_campus/LibraryRegisteredUpper.gd", "world/visual_campus/LibraryUpperRegisteredPlan.gd", "systems/data/campus_visual_build.json"]
accepted = {
    "version": b["version"], "accepted_legs": [{"file": initial, "indices": indices}, {"file": final, "indices": list(range(41))}],
    "valid_records": 68, "effective_fixtures": 4, "not_single_tour": True,
    "checks": {"file": initial, "count": 41}, "images_viewed": 4,
    "effective_final_images": ["courtyard-refined-library-core-v147-" + n + ".png" for n in ["room", "shared-wall", "sixth"]],
    "excluded": "Initial legs16/29 blocked at atrium railing and room612;leg28 is zero-movement start. Upper-door image viewed but foreground rail obstructs the composition;not a useful overview.",
    "logs": logs, "engine_errors": 0, "geometry_changed_between_runs": False,
    "source_sha256": {p: sha(p) for p in source},
    "report_sha256": {p: sha(p) for p in [initial, final] + logs},
    "scope": "Relocated G-5F core stairs/side exits,5F rare-room shared wall,6F group outer aisles and29 room-centre floor probes;not wholelibrary/campus or interior room access.",
    "limits": "Schematic maps and hand landmarks.5F202401/6F2025-08 are version/hosting clues,not photo dates.6F fit residual remains10.08px;rooms,roof,rearwing andlower/upper supports remain partial.",
    "stable_release_unchanged": "v2.0.0 / V145;development only,not committed or pushed",
}
write("tests/artifacts/library_core_boundary_v147_accepted.json", accepted)
evidence = {
    "date": "2026-10-12", "source": "https://library.cuhk.edu.cn/zh-hans/floor-maps",
    "local_manifest": "references/visual_build_20261008/originals/library-plan-20261010/manifest.json",
    "registration": "references/visual_build_20261008/library_upper_registration_v112.json",
    "5F_display_frame": [1728, 1470], "previous_core_z_pixels": [798.28, 971.21],
    "revised_core_z_pixels": [785, 952], "core_centre_5F_pixels": [288, 868.5],
    "revised_core_local_position": [-26.84291846, 0, 8.45674881], "fitted_depth": 8.696327407,
    "source_dates": {"4F": "2021-11 hosting path", "5F": "202401 filename", "6F": "2025-08 hosting path", "photos": "no new room photographs this batch"},
    "inference": "Align the core end to rare-room shared boundary.Whole shaft moves coherently;enclosure width/inner circulation and lower-level correspondence remain schematic.",
    "sixth": "All5 room groups and602-605 now use independent point6 including yaw;retired rough .97/+156/-11 placement.",
    "limits": accepted["limits"],
}
write("references/visual_build_20261008/library_core_boundary_v147.json", evidence)
c = read("docs/lower_campus_refinement_coverage.json")
c.update(updated="2026-10-12", previous_turn_classification="progress", basis_version=b["version"], status="active")
c["next_action"] = "V147 left-core/5F rare shared-wall intrusion resolved;G-5F coherent shaft/cuts and6F room-group independent fit implemented,68 accepted local records/41checks. NEXT trace6F room-group shared boundaries/door orientations andfront isolated-room identity from its own official map;continue rearwing/roof/cross-floor supports,then student actual lower doors andallA-G road/grade/rear/corner backlog. Stablev2.0.0/V145 fixed;development2.0.1-dev only. Do not redo116light or leftcore intrusion;full Goal active."
c["v147_evidence"] = {"report": "docs/LIBRARY_CORE_BOUNDARY_V147.md", "evidence": "references/visual_build_20261008/library_core_boundary_v147.json", "accepted": "tests/artifacts/library_core_boundary_v147_accepted.json", "valid_records": 68, "checks": 41, "effective_final_images": 3, "limits": accepted["limits"]}
c["release_convergence"]["development"]["model_version"] = b["version"]
for zone in c["zones"]:
    if zone["id"] != "C":
        continue
    zone.setdefault("evidence", []).append("docs/LIBRARY_CORE_BOUNDARY_V147.md")
    for building in zone["buildings"]:
        if building["id"] == "library":
            building["coverage"]["stairs_ramps"] += " V147 leftcore G-5F shifted/shrunk tosharedwall;slabholes/stairs move together,localascent/descent/allsideexitsverified."
            building["coverage"]["upper_public_levels"] += " V147 rare-room coreintrusion closed;6F5groups+602-605 usepoint6;fullroom/door/roof fidelity remains partial."
c["known_unfinished_features"].append("V147: specific leftcore/5F intrusion closed.6F room-group shape/sharedwalls/doororientation,front isolated-room identity,rearwing/roof/cross-floor support andwholemetric alignment remain open;datedcurrentinterior not established.")
write("docs/lower_campus_refinement_coverage.json", c)
summary = "V147：按校方4/5/6F图复核，左核心筒末端原侵入珍藏室约19图像像素，改5F785–952边界及共同竖井位置，楼梯/平台/楼板洞口同步，珍藏室改共墙；六层五组房间及602–605改独立point6配准。68有效分批移动、4有效起点、41检查，4图已看/3有效终图，无引擎错误。初贴中庭护栏/穿612房间边缘路线及零移动记录排除，仅续查未完段，模型未再改。尺寸、室内、六层残差/门向/后翼屋顶及跨层支撑仍未完；下一批先六层共墙门向与前端房间身份，再学生实际下层门位及全A–G。开发2.0.1-dev，稳定v2.0.0/V145不覆盖，Goal active。详见docs/LIBRARY_CORE_BOUNDARY_V147.md。"
for p in ["docs/LOWER_CAMPUS_ACTIVE_GOAL.md", "docs/NEXT_ITERATION_HANDOFF.md"]:
    content = (ROOT / p).read_text(encoding="utf-8-sig")
    if "\nV147：" not in content:
        (ROOT / p).write_text(content + "\n\n" + summary + "\n", encoding="utf-8")
p = ROOT / "README.md"
s = p.read_text(encoding="utf-8-sig")
s = s.replace("`2.0.1-dev` / V146，[图书馆116灯板越界修正](docs/LIBRARY_LIGHT_BOUNDARY_V146.md)", "`2.0.1-dev` / V147，[图书馆核心共墙与六层配准](docs/LIBRARY_CORE_BOUNDARY_V147.md)")
p.write_text(s, encoding="utf-8")
print(json.dumps({"accepted_records": 68, "checks": 41, "effective_views": 3, "goal": "active"}))
