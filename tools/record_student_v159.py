"""Record the photo-informed upper wing batch without overstating its floor evidence."""
from pathlib import Path
import json, hashlib, re
ROOT = Path(__file__).resolve().parents[1]
def read(p): return json.loads((ROOT/p).read_text(encoding="utf-8-sig"))
def write(p, value): (ROOT/p).write_bytes((json.dumps(value, ensure_ascii=False, indent=2)+"\n").encode())
def sha(p): return hashlib.sha256((ROOT/p).read_bytes()).hexdigest()
prefix = "tests/artifacts/student_upper_cross_wing_v159"
r = read(prefix+".json")
assert not r["failures"] and len(r["physical_legs"]) == 34 and len(r["checks"]) == 9
assert all(p["valid"] for p in r["physical_legs"]+r["checks"])
assert r["fixtures"] == 1
log = "tests/artifacts/student-upper-cross-v159.log"
assert not any(l.startswith(("ERROR:", "SCRIPT ERROR:")) for l in (ROOT/log).read_text(encoding="utf-8-sig").splitlines())
assert len(r["captures"]) == 5 and all((ROOT/"tests/artifacts"/p).is_file() for p in r["captures"])
exports = re.findall(r'"(res://[^"]+)"', (ROOT/"export_presets.cfg").read_text(encoding="utf-8-sig"))
assert len(exports) == len(set(exports)) and all((ROOT/p[6:]).is_file() for p in exports)
sources = ["world/visual_campus/StudentUpperCrossWing.gd", "world/visual_campus/StudentRegisteredBuilding.gd", "systems/data/campus_visual_build.json", "references/visual_build_20261008/student_upper_cross_wing_v159.json"]
write(prefix+"_accepted.json", {
    "version": r["version"], "physical_legs": 34, "fixtures": 1, "checks": 9,
    "failures": [], "effective_images": r["captures"], "images_reviewed": 5,
    "image_limits": "Front court close-up crops the upper facade; back court image shows the complete windowed wing. Views verify local geometry, not whole-campus likeness.",
    "engine_errors": 0, "export_files": len(exports),
    "scope": "One continuous upper-gallery/wing route with south and rear core lobby interfaces. Existing full stair flights and whole campus not rerun.",
    "source_boundary": "Photo012 establishes upper enclosed yellow wing. Placement at19.6m and raw5F410..592/228..440 footprint are inferred, not independently verified6F plan.5F void retained. Rear low closed stair differs from high open stair trace; no fourth full-height core added.",
    "source_sha256": {p: sha(p) for p in sources},
    "report_sha256": {p: sha(p) for p in [prefix+".json", log]},
    "image_sha256": {p: sha("tests/artifacts/"+p) for p in r["captures"]}
})
report = "docs/STUDENT_UPPER_CROSS_WING_V159.md"
summary = "V159：根据新读012院落实景补黄色封闭上层跨院楼翼、双面高窗、底梁和屋面，并接通两端上层空间；保留五层空院及边界。34段连续实走、1起点、9检查、5局部画面通过，无引擎错误。照片文章发布2021-05-28，拍摄日未知；19.6m层位及进深仍为照片/五层平面约束拟合，不能冒充独立六层图。029/030后侧封闭梯与031高层开敞梯迹分开核对，未盲目加第四根G–6F核心。下一批低层核心终止/高层梯连接，再2024池边入口及共享下首层/图书馆后路标高，D至F/G及全A–G继续。正式v2.0.0不变、Goal active。详见docs/STUDENT_UPPER_CROSS_WING_V159.md。"
cov = read("docs/lower_campus_refinement_coverage.json")
cov.update(updated="2026-10-12", basis_version=r["version"], previous_turn_classification="progress", status="active")
cov["next_action"] = "V159 photo-observed upper yellow cross-court wing added locally:34continuous legs/1fixture/9checks/5views. Placement19.6m and footprint are fitted, not independent6F plan;5F void retained. NEXT distinguish029/030 rear closed lower core termination from031 separate high open stair before adding geometry; then register2024-01 pond/central-entry photo and resolve shared lower-front/library-rearG2F datum. ContinueD->F/G and allA-G. Stablev2.0.0 remains unchanged;Goalactive."
cov["v159_evidence"] = {"report": report, "accepted": prefix+"_accepted.json", "legs": 34, "fixtures": 1, "checks": 9, "effective_views": 5, "floor_footprint_independently_verified": False}
cov["release_convergence"]["development"]["model_version"] = r["version"]
for z in cov["zones"]:
    if z["id"] != "D": continue
    if report not in z["evidence"]: z["evidence"].append(report)
    for b in z["buildings"]:
        if b["id"] != "student_centre": continue
        if report not in b["evidence"]: b["evidence"].append(report)
pending = "V159 yellow upper cross-court wing exists in historic photo012; current19.6m floor and footprint remain inferred. Independent6F room plan, rear low-core termination versus separate high court stair, and2024pond/shared lower-front datum remain unresolved."
if pending not in cov["known_unfinished_features"]: cov["known_unfinished_features"].append(pending)
write("docs/lower_campus_refinement_coverage.json", cov)
for fn in ["docs/LOWER_CAMPUS_ACTIVE_GOAL.md", "docs/NEXT_ITERATION_HANDOFF.md"]:
    p = ROOT/fn
    s = p.read_text(encoding="utf-8-sig")
    if "\nV159：" not in s: s += "\n\n"+summary+"\n"
    if fn.endswith("HANDOFF.md"):
        s = s.replace("`official-visual-build-158-student-south-core`", "`"+r["version"]+"`", 1)
        s = s.replace("不能说这些改动已包含在稳定包。", "V159 已补照片可见的上层黄色跨院楼翼，34段连续通行、9检查、5图；层位和进深仍拟合。不能说这些改动已包含在稳定包。", 1)
        s = s.replace("下一批后侧另一核心和服务空间，再新池边照片的中央入口配准；", "V159先补上层跨院楼翼；下一批区分后侧低层封闭梯和高层开敞梯，再新池边照片的中央入口配准；", 1)
    p.write_bytes(s.encode())
p = ROOT/"README.md"
s = p.read_text(encoding="utf-8-sig").replace("`2.0.1-dev` / V158，[学生中心下侧核心与三层通廊](docs/STUDENT_SOUTH_CORE_V158.md)", "`2.0.1-dev` / V159，[学生中心上层跨院楼翼](docs/STUDENT_UPPER_CROSS_WING_V159.md)")
p.write_bytes(s.encode())
p = ROOT/report
s = p.read_text(encoding="utf-8-sig").replace("局部结果见", "34段连续实走、1起点、9检查通过，无引擎错误；5局部画面已复核。正面近景裁切上沿，完整外观以背面视角为准。局部结果见")
p.write_bytes(s.encode())
print(json.dumps({"legs": 34, "fixtures": 1, "checks": 9, "views": 5, "exports": len(exports), "goal": "active"}))
