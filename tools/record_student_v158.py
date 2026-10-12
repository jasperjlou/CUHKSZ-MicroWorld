"""Record south-core/gallery structural batch and dated official reference review."""
from pathlib import Path
import json,hashlib,re
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text(encoding="utf-8-sig"))
def write(p,v):(ROOT/p).write_bytes((json.dumps(v,ensure_ascii=False,indent=2)+"\n").encode())
def sha(p):return hashlib.sha256((ROOT/p).read_bytes()).hexdigest()
prefix="tests/artifacts/student_south_core_v158"
r=read(prefix+".json");assert not r["failures"] and len(r["physical_legs"])==120 and len(r["checks"])==14
assert all(p["valid"] for p in r["physical_legs"])
log="tests/artifacts/student-south-core-v158.log"
assert not any(l.startswith(("ERROR:","SCRIPT ERROR:")) for l in (ROOT/log).read_text(encoding="utf-8-sig").splitlines())
assert all((ROOT/"tests/artifacts"/p).is_file() for p in r["captures"])
exports=re.findall(r'"(res://[^"]+)"',(ROOT/"export_presets.cfg").read_text(encoding="utf-8-sig"))
assert len(exports)==len(set(exports)) and all((ROOT/p[6:]).is_file() for p in exports)
sources=["world/visual_campus/StudentSouthCore.gd","world/visual_campus/StudentRegisteredBuilding.gd","systems/data/campus_visual_build.json","references/visual_build_20261008/student_south_core_v158.json"]
write(prefix+"_accepted.json",{"version":r["version"],"physical_legs":120,"fixtures":3,"checks":14,"failures":[],"effective_images":r["captures"],"images_reviewed":5,"engine_errors":0,"export_files":len(exports),"scope":"59ascent+47descent+14third-gallery legs in3independent fixtures,not a single whole-campus run.","source_boundary":"Historical1F/3F/5F common core envelope/compact flights fitted;6F repeat and shared lower-front datum unresolved.New2024 event photos reviewed but do not locate this core doorway.","source_sha256":{p:sha(p) for p in sources},"report_sha256":{p:sha(p) for p in [prefix+".json",log]}})
report="docs/STUDENT_SOUTH_CORE_V158.md"
summary="V158：新增图纸下侧G至六层折返核心、楼板真洞和关闭服务电梯井；补030平面中三层院落至南楼翼漏失通廊，撤横挡栏杆、仅留落差边护栏。120分批记录（59上行、47下行、14通廊）、3起点、14检查、5终图通过，无引擎错误。新读2024-01-29校方书展报道及两图，活动1月15–19日不等于精确拍摄日；室外池边硬铺/栏杆/暗砖及圆洞池墙保留为中央入口新参照，室内图房间不明，不移植为本核心。历史共同范围/梯尺寸/层高和6F重复仍拟合，G出口仅接公共厅。下一批后侧另一核心/服务房间，再2024池边入口配准和真实下首层/图书馆后路标高，继续D至F/G及全A–G。稳定v2.0.0未覆盖，Goal active。详见docs/STUDENT_SOUTH_CORE_V158.md。"
cov=read("docs/lower_campus_refinement_coverage.json")
cov.update(updated="2026-10-12",basis_version=r["version"],previous_turn_classification="progress",status="active")
cov["next_action"]="V158 drawing-lower-side core G-6F/closed service lift and missing3F court-south-gallery complete locally:120legs(59up47down14gallery)/3fixtures/14checks/5views.No runtime failures. NEXT remaining rear-side core/service room envelope from029/030/031,then register new2024-01 bookfair outdoor pond/entry photo with central site and resolve shared lower-front/library-rearG2F datum.2024image shows paving/rail/darkbrick/circular-perforated pond wall;door crop incomplete,indoor secondphoto roomunknown. Do not treat eventinterval as EXIF or label south as calibrated geography. ThenD->F/G and allA-G,stablev2.0.0 unchanged,Goalactive."
cov["v158_evidence"]={"report":report,"accepted":prefix+"_accepted.json","legs":120,"fixtures":3,"checks":14,"effective_views":5,"new_official_photos_reviewed":2}
cov["release_convergence"]["development"]["model_version"]=r["version"]
for z in cov["zones"]:
 if z["id"]!="D":continue
 if report not in z["evidence"]:z["evidence"].append(report)
 for b in z["buildings"]:
  if b["id"]!="student_centre":continue
  if report not in b["evidence"]:b["evidence"].append(report)
  b["coverage"]["ground_or_pilotis"]+=" V158 drawing-lower-side G-6F core and public-hall exit/closed lift,missing3F gallery filled and linked;120scoped legs. Shared lower-ground/outdoor exit datum remains unresolved."
pending="V158 lower-side core is a common historic envelope fit,not exact stacked doors or independently sourced6F. New2024 bookfair pond-side photograph retained for site registration;room in secondphoto unidentified. Remainingrear/service core and true lower-front/site datum continue."
if pending not in cov["known_unfinished_features"]:cov["known_unfinished_features"].append(pending)
write("docs/lower_campus_refinement_coverage.json",cov)
for fn in ["docs/LOWER_CAMPUS_ACTIVE_GOAL.md","docs/NEXT_ITERATION_HANDOFF.md"]:
 p=ROOT/fn;s=p.read_text(encoding="utf-8-sig")
 if "\nV158：" not in s:s+="\n\n"+summary+"\n"
 if fn.endswith("HANDOFF.md"):
  s=s.replace("`official-visual-build-157-student-court-flights`","`"+r["version"]+"`",1)
  s=s.replace("不能说这些改动已包含在稳定包。","V158 已补图纸下侧核心和三层漏失通廊，120记录、14检查、5终图。不能说这些改动已包含在稳定包。",1)
  s=s.replace("下一批南侧核心/下层出口及较新院落实景；","V158已补图纸下侧核心/公共厅出口并查看2024校方两图，下一批后侧另一核心和服务空间，再新池边照片的中央入口配准；",1)
 p.write_bytes(s.encode())
p=ROOT/"README.md";s=p.read_text(encoding="utf-8-sig").replace("`2.0.1-dev` / V157，[学生中心院落梯平面校正](docs/STUDENT_COURT_FLIGHTS_V157.md)","`2.0.1-dev` / V158，[学生中心下侧核心与三层通廊](docs/STUDENT_SOUTH_CORE_V158.md)");p.write_bytes(s.encode())
p=ROOT/report;s=p.read_text(encoding="utf-8-sig").replace("结果及有效画面见", "120有效分批通行记录（59上行、47下行、14通廊往返）、3起点、14检查通过，无引擎错误；5最终图已复核。结果及有效画面见");p.write_bytes(s.encode())
print(json.dumps({"legs":120,"fixtures":3,"checks":14,"views":5,"exports":len(exports),"goal":"active"}))
