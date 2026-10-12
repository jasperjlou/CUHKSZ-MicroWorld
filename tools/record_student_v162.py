"""Record upper pond facade only; keep the unresolved lower datum explicit."""
from pathlib import Path
import json,hashlib,re
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text(encoding="utf-8-sig"))
def write(p,v):(ROOT/p).write_bytes((json.dumps(v,ensure_ascii=False,indent=2)+"\n").encode())
def sha(p):return hashlib.sha256((ROOT/p).read_bytes()).hexdigest()
prefix="tests/artifacts/student_pond_upper_v162"
r=read(prefix+".json");f=read("tests/artifacts/student_pond_finish_v162.json")
assert not r["failures"] and not f["failures"] and len(r["physical_legs"])==6
assert all(x["valid"] for x in r["physical_legs"]+r["checks"]+f["checks"])
logs=["tests/artifacts/student-pond-upper-v162.log","tests/artifacts/student-pond-finish-v162.log"]
for log in logs:assert not any(l.startswith(("ERROR:","SCRIPT ERROR:")) for l in (ROOT/log).read_text(encoding="utf-8-sig").splitlines())
views=f["captures"]
assert len(views)==3 and all((ROOT/"tests/artifacts"/p).is_file() for p in views)
exports=re.findall(r'"(res://[^"]+)"',(ROOT/"export_presets.cfg").read_text(encoding="utf-8-sig"))
assert len(exports)==len(set(exports)) and all((ROOT/p[6:]).is_file() for p in exports)
sources=["world/visual_campus/StudentPondUpperFacade.gd","world/visual_campus/StudentRegisteredBuilding.gd","world/visual_campus/CampusSurface.gdshader","systems/data/campus_visual_build.json","references/visual_build_20261008/student_pond_upper_v162.json"]
write(prefix+"_accepted.json",{"version":r["version"],"physical_legs":6,"fixtures":2,"checks":5,"failures":[],"effective_images":views,"images_reviewed":7,"engine_errors":0,"export_files":len(exports),"superseded_detail_images":r["captures"][1:],"initial_context_only":r["captures"][0],"scope":"Two separate three-leg upper galleries,4initial probes plus1final sheet boundary probe. Single-sheet red/perforation filter and decorative reveal offset do not intersect gallery routes; walking reused. Final close camera in upper void is inspection only,not player navigation.","fidelity_boundary":"Yellow upper reveals and red screen are photo-informed proportions. Lower entrance/storey datum unresolved; no claim entire pond facade matches,global building shift not justified.","source_sha256":{p:sha(p) for p in sources},"report_sha256":{p:sha(p) for p in [prefix+".json","tests/artifacts/student_pond_finish_v162.json"]+logs},"image_sha256":{p:sha("tests/artifacts/"+p) for p in views}})
report="docs/STUDENT_POND_UPPER_V162.md"
summary="V162：补学生池侧上层凹口黄色饰面及后段红色透空屏/竖肋横框；近看真透孔、远看像素过滤。新读建筑师005另一侧/003中庭/014红网内侧，结合全景与2024局部照片，明确不能混当池侧现状。首图发现双层网面摩尔纹/旧窗台穿出/近裁剪，改单双面网格、提前过滤、饰面避开窗台并换正确近景。两层通廊6记录/2起点、5检查、3最终细部图通过，无引擎错误，7图已看。池岸层数/主桥/下沉院与统一底标高尚未闭合，未整体移动建筑或切低层板，低层黄色入口仍未修复。下一批优先剖面和官方节点统一入口标高关系，再下层/图书馆后路及D至F/G、全A–G。正式v2.0.0不变，Goal active。详见docs/STUDENT_POND_UPPER_V162.md。"
cov=read("docs/lower_campus_refinement_coverage.json")
cov.update(updated="2026-10-12",basis_version=r["version"],previous_turn_classification="progress",status="active")
cov["next_action"]="V162 upper pond yellow reveals/red single perforated sheet added locally:6legs/2fixtures/5checks/3final detail views. LOWER facade remains wrong/unresolved: pond-visible storeys,main bridge and sunken court do not close with uniform current student base. NEXT compare032local lower-room/033section and official entry nodes against common datum; establish whether local split level or broader vertical registration needs correction before lower opening edits. Do not infer global shift from row count alone or repeat decorative upper work. Then library rearG2F/D->F/G/allA-G,stablev2.0.0 unchanged,Goalactive."
cov["v162_evidence"]={"report":report,"accepted":prefix+"_accepted.json","legs":6,"fixtures":2,"checks":5,"effective_views":3,"all_images_reviewed":7}
cov["release_convergence"]["development"]["model_version"]=r["version"]
for z in cov["zones"]:
 if z["id"]!="D":continue
 if report not in z.setdefault("evidence",[]):z["evidence"].append(report)
 for b in z["buildings"]:
  if b["id"]=="student_centre" and report not in b["evidence"]:b["evidence"].append(report)
pending="V162 upper pond cladding only; lower yellow entrance,local low room and common pond/bridge/sunken-court vertical registration not solved. Do not extrapolate exact red extent/current layout from undated photos or shift all building levels solely by counting visible rows."
if pending not in cov["known_unfinished_features"]:cov["known_unfinished_features"].append(pending)
write("docs/lower_campus_refinement_coverage.json",cov)
for fn in ["docs/LOWER_CAMPUS_ACTIVE_GOAL.md","docs/NEXT_ITERATION_HANDOFF.md"]:
 p=ROOT/fn;s=p.read_text(encoding="utf-8-sig")
 if "\nV162：" not in s:s+="\n\n"+summary+"\n"
 if fn.endswith("HANDOFF.md"):
  s=s.replace("`official-visual-build-161-lotus-pond-screen`","`"+r["version"]+"`",1)
  s=s.replace("不能说这些改动已包含在稳定包。","V162已补池侧上层黄饰面/红透空网，6记录/5检查/3终图，低层入口和共同标高仍未解决。不能说这些改动已包含在稳定包。",1)
  s=s.replace("下一批优先学生池侧黄凹廊/红板与入口配准；","V162已补上层黄饰面/红屏，下一批集中核对池岸/主桥/下沉院/低层入口标高关系；",1)
 p.write_bytes(s.encode())
p=ROOT/"README.md";s=p.read_text(encoding="utf-8-sig").replace("`2.0.1-dev` / V161，[荷花池景墙与真实铺地](docs/LOTUS_POND_EDGES_V161.md)","`2.0.1-dev` / V162，[学生中心池侧上层与标高待办](docs/STUDENT_POND_UPPER_V162.md)");p.write_bytes(s.encode())
p=ROOT/report;s=p.read_text(encoding="utf-8-sig").replace("结果见", "6段分批实走（2起点）、5检查通过，无引擎错误；7图已查看、3最终细部图有效。结果见");p.write_bytes(s.encode())
print(json.dumps({"legs":6,"fixtures":2,"checks":5,"final_views":3,"exports":len(exports),"goal":"active"}))
