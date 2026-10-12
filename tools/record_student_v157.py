"""Retain the verified prefix and promenade; accept only the corrected route suffix."""
from pathlib import Path
import json,re,hashlib
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text(encoding="utf-8-sig"))
def write(p,v):(ROOT/p).write_bytes((json.dumps(v,ensure_ascii=False,indent=2)+"\n").encode())
def sha(p):return hashlib.sha256((ROOT/p).read_bytes()).hexdigest()
prefix="tests/artifacts/student_court_flights_v157"
a=read(prefix+".json");b=read(prefix+"_finish.json");c=read(prefix+"_panels.json")
accepted=a["physical_legs"][:12]+a["physical_legs"][14:]+b["physical_legs"]
assert len(accepted)==58 and all(x["valid"] for x in accepted) and not b["failures"]
assert len(a["checks"])==9 and len(a["failures"])==1
logs=["tests/artifacts/student-court-flights-v157"+s+".log" for s in ["","-finish","-panels"]]
for p in logs:assert not any(l.startswith(("ERROR:","SCRIPT ERROR:")) for l in (ROOT/p).read_text(encoding="utf-8-sig").splitlines()),p
images=c["captures"]+[a["captures"][3]]
assert all((ROOT/"tests/artifacts"/p).is_file() for p in images)
exports=re.findall(r'"(res://[^"]+)"',(ROOT/"export_presets.cfg").read_text(encoding="utf-8-sig"))
assert len(exports)==len(set(exports)) and all((ROOT/p[6:]).is_file() for p in exports)
sources=["world/visual_campus/StudentCourtStairs.gd","world/visual_campus/StudentRegisteredBuilding.gd","systems/data/campus_visual_build.json","references/visual_build_20261008/student_court_flights_v157.json"]
write(prefix+"_accepted.json",{"version":b["version"],"physical_legs":58,"fixtures":3,"checks":9,"failures":[],"initial_retained_indices":list(range(12))+list(range(14,19)),"initial_rejected_indices":{"12":"Superseded table approach waypoint","13":"Straight path collided with table,corrected by aisle detour"},"finish_legs":41,"scope":"12initial stair legs+5promenade legs+41corrected continuous suffix;three fixtures,not one continuous campus run.","effective_images":images,"images_viewed":12,"finish":"Opaque guard face winding corrected only;no collision changes after walking acceptance.","engine_errors":0,"export_files":len(exports),"logs":logs,"source_sha256":{p:sha(p) for p in sources},"report_sha256":{p:sha(p) for p in [prefix+s+".json" for s in ["","_finish","_panels"]]+logs}})
report="docs/STUDENT_COURT_FLIGHTS_V157.md"
summary="V157：以已配准3F平面重定三组院落梯，第一梯内移加宽、后两梯缩短，补中途平台和中央/侧边深色栏板、顶接板及新梯井护栏；第四院落接后核心，前连廊绕新洞口。58有效分批记录（12初始+5连廊+41续测）、3起点、9检查、5终图通过，无引擎错误。初路线撞现有餐桌，改绕桌接续；最后只修栏板面朝向并复看，不重复步行。2021发布平面/011013实景拍摄日未知；0/4.4/8.8/12.4层高、平台长度仍拟合，真实下首层未闭合。受影响V153/V154院落路线坐标退休。下一批南侧核心/下层出口和较新现状照片，再共享标高/图书馆后路及D至F/G、全A–G。稳定v2.0.0未覆盖，Goal active。详见docs/STUDENT_COURT_FLIGHTS_V157.md。"
cov=read("docs/lower_campus_refinement_coverage.json")
cov.update(updated="2026-10-12",basis_version=b["version"],previous_turn_classification="progress",status="active")
cov["next_action"]="V157 three court flight projections corrected from registered030;first inward/wider,two upper shorter with landings and opaque centre panels.58legs/3fixtures/9checks/5finalviews accepted;table collision corrected by detour,final face winding visual-only. AffectedV153/V154 court/promendade coordinates retired;not whole-campus validation. NEXT south stair/service cores and lower exits from029/030/031,seek newer dated official court images to verify level/currentness;real lower-front/shared datum and library rear-roadG/2F still unresolved. ThenD->F/G and allA-G. Stablev2.0.0 untouched,Goalactive."
cov["v157_evidence"]={"report":report,"accepted":prefix+"_accepted.json","legs":58,"fixtures":3,"checks":9,"effective_views":5}
cov["release_convergence"]["development"]["model_version"]=b["version"]
for z in cov["zones"]:
 if z["id"]!="D":continue
 if report not in z["evidence"]:z["evidence"].append(report)
 for building in z["buildings"]:
  if building["id"]!="student_centre":continue
  if report not in building["evidence"]:building["evidence"].append(report)
  building["coverage"]["ground_or_pilotis"]+=" V157 registered3F court stair projections/landings/opaque guards and fourth-court/rear-core link implemented;58locallegs. Supersedes affectedV153/V154 courtyard routes. Heights and current condition still fitted/unverified."
pending="V157 first stair well now inward/wider and upper flights shortened from registered3F drawing;affectedV153/V154 route coordinates retired.Fitted floor levels and landings not current survey.South cores,real lower-front datum/current photos remain open."
if pending not in cov["known_unfinished_features"]:cov["known_unfinished_features"].append(pending)
write("docs/lower_campus_refinement_coverage.json",cov)
for fn in ["docs/LOWER_CAMPUS_ACTIVE_GOAL.md","docs/NEXT_ITERATION_HANDOFF.md"]:
 p=ROOT/fn;s=p.read_text(encoding="utf-8-sig")
 if "\nV157：" not in s:s+="\n\n"+summary+"\n"
 if fn.endswith("HANDOFF.md"):
  s=s.replace("`official-visual-build-156-student-rear-core-gallery`","`"+b["version"]+"`",1)
  s=s.replace("不能说这些改动已包含在稳定包。","V157 已校正三组院落梯及平台/栏板，58有效记录、9检查、5终图；旧受影响院落路线退休。不能说这些改动已包含在稳定包。",1)
  s=s.replace("下一批四层院落/后核心关系、院落梯分层及南侧核心/真实侧门；","V157已验证第四院落与后核心连接，下一批南侧核心/下层出口及较新院落实景；",1)
 p.write_bytes(s.encode())
p=ROOT/"README.md";s=p.read_text(encoding="utf-8-sig").replace("`2.0.1-dev` / V156，[学生中心后核心与上层通廊](docs/STUDENT_REAR_CORE_GALLERY_V156.md)","`2.0.1-dev` / V157，[学生中心院落梯平面校正](docs/STUDENT_COURT_FLIGHTS_V157.md)");p.write_bytes(s.encode())
p=ROOT/report;s=p.read_text(encoding="utf-8-sig").replace("通过数量、最终画面和日志哈希见", "58条有效分批记录（12初始梯段、5前连廊、41续测）及9结构检查通过，3个起点，不是一次全区闭环；无引擎错误。12图已看，5张有效终图；最终仅修复栏板视觉面朝向，碰撞未改。通过数量、最终画面和日志哈希见");p.write_bytes(s.encode())
print(json.dumps({"legs":58,"fixtures":3,"checks":9,"views":5,"exports":len(exports),"goal":"active"}))
