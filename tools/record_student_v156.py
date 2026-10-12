"""Record the scoped V156 structural batch and two final visual fixes."""
from pathlib import Path
import json,hashlib,re
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text(encoding="utf-8-sig"))
def write(p,v):(ROOT/p).write_bytes((json.dumps(v,ensure_ascii=False,indent=2)+"\n").encode())
def sha(p):return hashlib.sha256((ROOT/p).read_bytes()).hexdigest()
prefix="tests/artifacts/student_rear_core_v156"
r=read(prefix+".json");v=read(prefix+"_views.json")
assert not r["failures"] and len(r["physical_legs"])==137 and len(r["checks"])==24
assert r["version"]==v["version"]==read("systems/data/campus_visual_build.json")["version"]
logs=["tests/artifacts/student-rear-core-v156"+s+".log" for s in ["","-views"]]
for p in logs:
 assert not any(line.startswith(("ERROR:","SCRIPT ERROR:")) for line in (ROOT/p).read_text(encoding="utf-8-sig").splitlines()),p
images=[r["captures"][0],v["captures"][0],v["captures"][1],r["captures"][3],r["captures"][4]]
assert all((ROOT/"tests/artifacts"/p).is_file() for p in images)
exports=re.findall(r'"(res://[^"]+)"',(ROOT/"export_presets.cfg").read_text(encoding="utf-8-sig"))
assert len(exports)==len(set(exports)) and all((ROOT/p[6:]).is_file() for p in exports)
assert "res://world/visual_campus/StudentRearCore.gd" in exports
sources=["world/visual_campus/"+s for s in ["StudentRegisteredPlan.gd","StudentRegisteredBuilding.gd","StudentRearCore.gd"]]+["systems/data/campus_visual_build.json","references/visual_build_20261008/student_rear_core_v156.json"]
receipt={"version":r["version"],"physical_legs":137,"fixtures":2,"checks":24,"failures":[],"engine_errors":0,"effective_images":images,"images_reviewed":7,"export_files":len(exports),"scope":"91 continuous ascent/gallery legs and46 descent legs from a separate fixture; not a single whole-campus run.","finish":"Only noncolliding25mm roof finish and camera changes after structural acceptance; no repeated walking tests.","retired_images":[r["captures"][1],r["captures"][2]],"limits":"Historic1F/5F registration; fitted heights/stair widths/doors,6F gallery repeat unverified,shared lower-ground and other cores/court steps remain open.","logs":logs,"source_sha256":{p:sha(p) for p in sources},"report_sha256":{p:sha(p) for p in [prefix+".json",prefix+"_views.json"]+logs}}
write(prefix+"_accepted.json",receipt)
report="docs/STUDENT_REAR_CORE_GALLERY_V156.md"
summary="V156：按历史1F/5F后核心配准补五组折返梯/平台/真实楼板洞，贯通当前G至六层；上层窄封闭条改宽通廊、前后翼开口和外侧护栏，中段两房内退并开门。137有效分批记录（91上行及两层通廊、46下行）、2起点、24检查、5终图通过，无引擎错误。原被墙遮挡核心机位及屋面共面闪纹已替换；收尾仅非碰撞屋面25mm饰面/机位，不重跑。2021发布032-1剖面新增前侧局部低房间约束但无层号；层高/梯细节、6F沿用5F、院落梯和真实下首层仍拟合或未核实。下一批四层院落与后核心关系、院落梯及南侧核心，再共享标高/图书馆后路及D至F/G和全A–G。稳定v2.0.0未覆盖，Goal active。详见docs/STUDENT_REAR_CORE_GALLERY_V156.md。"
cov=read("docs/lower_campus_refinement_coverage.json")
cov.update(updated="2026-10-12",basis_version=r["version"],previous_turn_classification="progress",status="active")
cov["next_action"]="V156 rear core G-6F and upper gallery/two room portals complete locally:137legs/2fixtures/24checks/5finalviews. First91legs continuously ascend and visit5F/6F gallery;46descent legs separate. FINAL visual-only roof finish25mm and core camera fixed,no new walks. NEXT use030+032-1 to reconcile court flights and fourth court/rear core interface,then south/core/service layout and real lower-front/shared datum.6F gallery repeats5F fit,not verified6F. Keep library rear-roadG/2F/front lift residual,thenD->F/G and entireA-G. Stablev2.0.0 unchanged;Goalactive."
cov["v156_evidence"]={"report":report,"accepted":prefix+"_accepted.json","legs":137,"fixtures":2,"checks":24,"effective_views":5,"diagrams_reviewed":3}
cov["release_convergence"]["development"]["model_version"]=r["version"]
for zone in cov["zones"]:
 if zone["id"]!="D":continue
 if report not in zone["evidence"]:zone["evidence"].append(report)
 for b in zone["buildings"]:
  if b["id"]!="student_centre":continue
  if report not in b["evidence"]:b["evidence"].append(report)
  note=" V156 rear G-6F core and5F/6F gallery/two room portals connected and locally verified;6F copy/fitted levels/current doors remain unresolved."
  if note not in b["coverage"]["ground_or_pilotis"]:b["coverage"]["ground_or_pilotis"]+=note
pending="V156:032-1 historical section has a local lower-front room without floor labels; do not automatically add a full basement.5F gallery trace corrected,6F copy not independently sourced.Other cores,court flight landings,lower shared datum and current doors remain open."
if pending not in cov["known_unfinished_features"]:cov["known_unfinished_features"].append(pending)
write("docs/lower_campus_refinement_coverage.json",cov)
for fn in ["docs/LOWER_CAMPUS_ACTIVE_GOAL.md","docs/NEXT_ITERATION_HANDOFF.md"]:
 p=ROOT/fn;s=p.read_text(encoding="utf-8-sig")
 if "\nV156：" not in s:s+="\n\n"+summary+"\n"
 if fn.endswith("HANDOFF.md"):
  s=s.replace("`official-visual-build-155-student-facade-finish`","`"+r["version"]+"`",1)
  s=s.replace("不能说这些改动已包含在稳定包。","V156 已补后核心G–6F及上层通廊/房门，137记录、24检查、5终图；6F平面仍沿用5F拟合。不能说这些改动已包含在稳定包。",1)
  s=s.replace("下一批院落梯分层、其余核心/独立上层块及真实侧门；","下一批四层院落/后核心关系、院落梯分层及南侧核心/真实侧门；",1)
 p.write_bytes(s.encode())
p=ROOT/"README.md";s=p.read_text(encoding="utf-8-sig").replace("`2.0.1-dev` / V155，[学生中心窗墙与铺地细化](docs/STUDENT_FACADE_FINISH_V155.md)","`2.0.1-dev` / V156，[学生中心后核心与上层通廊](docs/STUDENT_REAR_CORE_GALLERY_V156.md)");p.write_bytes(s.encode())
p=ROOT/report;s=p.read_text(encoding="utf-8-sig").replace("批次结果在", "137 段实走、24 项结构检查通过，无引擎错误；91 段连续上行/两层通廊和46 段独立下行，两个起点。7 图已检查，保留5张有效终图；原核心机位被墙遮挡、初屋面共面闪纹已替换。屋面最后增加25mm非碰撞饰面，未改通行碰撞，未重跑步行。批次结果在");p.write_bytes(s.encode())
print(json.dumps({"legs":137,"fixtures":2,"checks":24,"views":5,"exports":len(exports),"goal":"active","stable":"unchanged"}))
