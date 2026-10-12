"""Record separate lower core and scoped outer-edge correction."""
from pathlib import Path
import json, hashlib, re
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text(encoding="utf-8-sig"))
def write(p,v):(ROOT/p).write_bytes((json.dumps(v,ensure_ascii=False,indent=2)+"\n").encode())
def sha(p):return hashlib.sha256((ROOT/p).read_bytes()).hexdigest()
prefix="tests/artifacts/student_rear_lower_core_v160"
r=read(prefix+".json");edge=read("tests/artifacts/student_rear_lower_edge_v160.json")
assert not r["failures"] and not edge["failures"]
assert len(r["physical_legs"])==46 and len(r["checks"])+len(edge["checks"])==10
assert all(v["valid"] for v in r["physical_legs"]+r["checks"]+edge["checks"])
logs=["tests/artifacts/student-rear-lower-v160.log","tests/artifacts/student-rear-lower-edge-v160.log"]
for log in logs:assert not any(l.startswith(("ERROR:","SCRIPT ERROR:")) for l in (ROOT/log).read_text(encoding="utf-8-sig").splitlines())
views=r["captures"][:3]+edge["captures"]
assert len(views)==4 and all((ROOT/"tests/artifacts"/p).is_file() for p in views)
exports=re.findall(r'"(res://[^"]+)"',(ROOT/"export_presets.cfg").read_text(encoding="utf-8-sig"))
assert len(exports)==len(set(exports)) and all((ROOT/p[6:]).is_file() for p in exports)
sources=["world/visual_campus/StudentRearLowerCore.gd","world/visual_campus/StudentRegisteredBuilding.gd","systems/data/campus_visual_build.json","references/visual_build_20261008/student_rear_lower_core_v160.json"]
write(prefix+"_accepted.json",{"version":r["version"],"physical_legs":46,"fixtures":1,"checks":10,"failures":[],"effective_images":views,"images_reviewed":5,"effective_images_count":4,"superseded_image":r["captures"][3],"engine_errors":0,"export_files":len(exports),"scope":"Single46-leg lower-core up/down and third-service route,8initial probes plus2outer fourth-court closure probes. Outer glazing patch does not intersect accepted lower route; no repeated walking.","source_boundary":"1F/3F common lower-core envelope;2F continuation/heights fitted,exact4Ftermination unknown.Third-service shell only,no fixture/room identity claim. Separate5Fopen stair remains unresolved.","source_sha256":{p:sha(p) for p in sources},"report_sha256":{p:sha(p) for p in [prefix+".json","tests/artifacts/student_rear_lower_edge_v160.json"]+logs},"image_sha256":{p:sha("tests/artifacts/"+p) for p in views}})
report="docs/STUDENT_REAR_LOWER_CORE_V160.md"
summary="V160：区分029/030后侧低层封闭梯和031另处开敞梯，补前者G至三层两组折返梯/真梯洞及仅三层服务区隔墙、门口。四层院落底板保留，梯的更高终止仍待核。46段连续实走、1起点、8初检通过；画面发现四层最外黄色墙误生两扇悬空门，改封闭窗墙，仅加2边界探针/1替代终图，不重走楼梯。合计10检查、4有效终图（5已查看）、无引擎错误。历史图2021发布、修订日未知，二层连续性/梯宽/层高仍拟合。下一批优先2024池边中央入口与硬铺配准，再共享下首层/图书馆后路G2F；高层梯疑点保留、D至F/G及全A–G继续。稳定v2.0.0不变，Goal active。详见docs/STUDENT_REAR_LOWER_CORE_V160.md。"
cov=read("docs/lower_campus_refinement_coverage.json")
cov.update(updated="2026-10-12",basis_version=r["version"],previous_turn_classification="progress",status="active")
cov["next_action"]="V160 rear lower closed core G-3F and third-only service shell complete locally:46continuous legs/1fixture/10checks/4effective views; fourth-court generic unsupported exterior doors replaced with closed glazing. Actual4Ftermination and separate5Fopen stair remain unresolved,do not blindlystack. NEXT prioritize2024-01 bookfair pond/central-entry photograph registration and real hardscape,then shared lower-front/library-rearG2F datum; retain high-stair research lead without blocking exterior progress. ContinueD->F/G and wholeA-G,stablev2.0.0 unchanged,Goalactive."
cov["v160_evidence"]={"report":report,"accepted":prefix+"_accepted.json","legs":46,"fixtures":1,"checks":10,"effective_views":4,"all_images_reviewed":5}
cov["release_convergence"]["development"]["model_version"]=r["version"]
for z in cov["zones"]:
 if z["id"]!="D":continue
 if report not in z["evidence"]:z["evidence"].append(report)
 for b in z["buildings"]:
  if b["id"]!="student_centre":continue
  if report not in b["evidence"]:b["evidence"].append(report)
  b["coverage"]["ground_or_pilotis"]+=" V160 separate rear lower core connects G-3F with real slab holes; third-floor service shell added.46scoped continuous legs; exact fourth-floor termination not proven."
pending="V160 separate rear lower core implemented G-3F provisionally; exact4Ftermination,independent2Fplan and separate5Fopen stair unresolved.Third-service envelope historical only,current fixtures/room use unverified.2024pond/entry and shared lower-front datum next."
if pending not in cov["known_unfinished_features"]:cov["known_unfinished_features"].append(pending)
write("docs/lower_campus_refinement_coverage.json",cov)
for fn in ["docs/LOWER_CAMPUS_ACTIVE_GOAL.md","docs/NEXT_ITERATION_HANDOFF.md"]:
 p=ROOT/fn;s=p.read_text(encoding="utf-8-sig")
 if "\nV160：" not in s:s+="\n\n"+summary+"\n"
 if fn.endswith("HANDOFF.md"):
  s=s.replace("`official-visual-build-159-student-upper-cross-wing`","`"+r["version"]+"`",1)
  s=s.replace("不能说这些改动已包含在稳定包。","V160已补后侧G至三层独立梯和三层服务区，46记录/10检查/4终图，关闭四层外缘悬空门。不能说这些改动已包含在稳定包。",1)
  s=s.replace("下一批区分后侧低层封闭梯和高层开敞梯，再新池边照片的中央入口配准；","V160已补独立低层梯，高层连接仍待核；下一批优先2024池边照片的中央入口/硬铺配准；",1)
 p.write_bytes(s.encode())
p=ROOT/"README.md";s=p.read_text(encoding="utf-8-sig").replace("`2.0.1-dev` / V159，[学生中心上层跨院楼翼](docs/STUDENT_UPPER_CROSS_WING_V159.md)","`2.0.1-dev` / V160，[学生中心后侧低层梯与三层服务区](docs/STUDENT_REAR_LOWER_CORE_V160.md)");p.write_bytes(s.encode())
p=ROOT/report;s=p.read_text(encoding="utf-8-sig").replace("收据见", "46段连续实走、1起点、10检查（8结构/2外缘）通过，无引擎错误；5图已查看、4有效终图。收据见");p.write_bytes(s.encode())
print(json.dumps({"legs":46,"fixtures":1,"checks":10,"effective_views":4,"exports":len(exports),"goal":"active"}))
