"""Record the local photo-prioritized entry fit, without claiming surveyed datum."""
from pathlib import Path
import json,hashlib,re
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text(encoding="utf-8-sig"))
def write(p,v):(ROOT/p).write_bytes((json.dumps(v,ensure_ascii=False,indent=2)+"\n").encode())
def sha(p):return hashlib.sha256((ROOT/p).read_bytes()).hexdigest()
prefix="tests/artifacts/student_pond_entry_v163"
r=read(prefix+".json");f=read("tests/artifacts/student_pond_entry_finish_v163.json")
assert not r["failures"] and not f["failures"] and len(r["physical_legs"])==23 and len(r["checks"])==10
assert all(x["valid"] for x in r["physical_legs"]+r["checks"])
logs=["tests/artifacts/student-pond-entry-v163.log","tests/artifacts/student-pond-entry-finish-v163.log"]
for log in logs:assert not any(l.startswith(("ERROR:","SCRIPT ERROR:")) for l in (ROOT/log).read_text(encoding="utf-8-sig").splitlines())
views=[r["captures"][1],r["captures"][2]]+f["captures"]
assert len(views)==4 and all((ROOT/"tests/artifacts"/p).is_file() for p in views)
exports=re.findall(r'"(res://[^"]+)"',(ROOT/"export_presets.cfg").read_text(encoding="utf-8-sig"))
assert len(exports)==len(set(exports)) and all((ROOT/p[6:]).is_file() for p in exports)
sources=["world/visual_campus/StudentPondEntry.gd","world/visual_campus/StudentRegisteredBuilding.gd","systems/data/campus_visual_build.json","references/visual_build_20261008/student_pond_entry_v163.json"]
write(prefix+"_accepted.json",{"version":r["version"],"physical_legs":23,"fixtures":4,"checks":10,"effective_images":views,"images_reviewed":6,"failures":[],"engine_errors":0,"export_files":len(exports),"scope":"14ground entry/hall legs,3second aisle legs,3legs each at8.8/12.4 cap in4fixtures. Final7cm side-wall inset and noncolliding finish do not alter accepted paths,so no repeated walking.","fidelity_boundary":"Photo-prioritized local fit explicitly conflicts with earlier historic3F notch front strip. Width/depth/levels remain fitted; whole-building/shared lower datum not solved.","source_sha256":{p:sha(p) for p in sources},"report_sha256":{p:sha(p) for p in [prefix+".json","tests/artifacts/student_pond_entry_finish_v163.json"]+logs},"image_sha256":{p:sha("tests/artifacts/"+p) for p in views}})
report="docs/STUDENT_POND_ENTRY_V163.md"
summary="V163：按池侧建成实景作局部拟合，打开低处黄色两层凹入口、切4.4m前段板、补退后玻璃/地面门/石铺；8.8/12.4m前段补回楼板灰砖窗带，内井留洞并加边护栏。矩形内洞用不重叠掩模裁切。23记录（14入口/3二层/6上方板）、4起点、10检查通过，6图已看/4有效图，无引擎错误；最终仅侧墙缩进7cm及非碰撞饰面收口，不重走。历史030凹口前段与照片拟合楼板存在明确冲突，未声称逐线还原；032仅支持局部低房间，未整体下移楼体，统一标高仍未闭合。旧GTA V152交点结论已复用，未重复77点扫描。下一批前部局部下层/主桥/下沉院关系，再图书馆后路G2F、D至F/G及全A–G。稳定v2.0.0不变，Goal active。详见docs/STUDENT_POND_ENTRY_V163.md。"
cov=read("docs/lower_campus_refinement_coverage.json")
cov.update(updated="2026-10-12",basis_version=r["version"],previous_turn_classification="progress",status="active")
cov["next_action"]="V163 local pond two-storey recess/door/cap/inner-well geometry fitted to built panorama:23legs/4fixtures/10checks/4effective views. Historical030front-strip conflict explicit; not surveyed/global datum solved. NEXT investigate local front lower room from032section with actual courtyard entry/user photos and preserved V152legacy sections (do not repeat77point scan without new anchors). Establish front-local lower connection,then library rearG2F andD->F/G/allA-G. Avoid another decorative upper-only turn. Stablev2.0.0unchanged,Goalactive."
cov["v163_evidence"]={"report":report,"accepted":prefix+"_accepted.json","legs":23,"fixtures":4,"checks":10,"effective_views":4,"all_images_reviewed":6,"historical_plan_conflict_retained":True}
cov["release_convergence"]["development"]["model_version"]=r["version"]
for z in cov["zones"]:
 if z["id"]!="D":continue
 if report not in z.setdefault("evidence",[]):z["evidence"].append(report)
 for b in z["buildings"]:
  if b["id"]!="student_centre":continue
  if report not in b["evidence"]:b["evidence"].append(report)
  b["coverage"]["ground_or_pilotis"]+=" V163 photo-prioritized pond recess now reaches ground hall; historic front-notch conflict retained,shared local lower datum unverified."
pending="V163 pond entry is local built-photo fit,not verified historic030slab exactness or global vertical calibration. Local front lower room from032and main bridge/sunken court remain unresolved; V152legacy old-unit intersections cannot assign building storeys directly."
if pending not in cov["known_unfinished_features"]:cov["known_unfinished_features"].append(pending)
write("docs/lower_campus_refinement_coverage.json",cov)
for fn in ["docs/LOWER_CAMPUS_ACTIVE_GOAL.md","docs/NEXT_ITERATION_HANDOFF.md"]:
 p=ROOT/fn;s=p.read_text(encoding="utf-8-sig")
 if "\nV163：" not in s:s+="\n\n"+summary+"\n"
 if fn.endswith("HANDOFF.md"):
  s=s.replace("`official-visual-build-162-student-pond-upper-facade`","`"+r["version"]+"`",1)
  s=s.replace("不能说这些改动已包含在稳定包。","V163已作池侧低凹入口局部照片拟合，23记录/10检查/4有效图；共享下层标高及历史平面冲突仍保留。不能说这些改动已包含在稳定包。",1)
  s=s.replace("下一批集中核对池岸/主桥/下沉院/低层入口标高关系；","V163已作池侧凹入口局部拟合，下一批前部局部下层/主桥/下沉院，复用V152旧几何证据；",1)
 p.write_bytes(s.encode())
p=ROOT/"README.md";s=p.read_text(encoding="utf-8-sig").replace("`2.0.1-dev` / V162，[学生中心池侧上层与标高待办](docs/STUDENT_POND_UPPER_V162.md)","`2.0.1-dev` / V163，[学生中心池侧凹入口](docs/STUDENT_POND_ENTRY_V163.md)");p.write_bytes(s.encode())
p=ROOT/report;s=p.read_text(encoding="utf-8-sig").replace("收据见", "23段分批实走、4起点、10检查通过，无引擎错误；6图已看、4分范围有效图。收尾缩进侧墙前缘7cm并补非碰撞饰面，消除黄/砖共面和楼板边穿出，不重走未受影响路线。收据见")
s+="\n\n已复用V152旧几何标高复核：旧坐标交点可能为楼板、梁或地面，不能直接排序成楼层；没有重复已有77点扫描。\n"
p.write_bytes(s.encode())
print(json.dumps({"legs":23,"fixtures":4,"checks":10,"views":4,"exports":len(exports),"goal":"active"}))
