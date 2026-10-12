"""Capture dated pond reference, scoped walking evidence and outstanding facade alignment."""
from pathlib import Path
import json,hashlib,re
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text(encoding="utf-8-sig"))
def write(p,v):(ROOT/p).write_bytes((json.dumps(v,ensure_ascii=False,indent=2)+"\n").encode())
def sha(p):return hashlib.sha256((ROOT/p).read_bytes()).hexdigest()
prefix="tests/artifacts/lotus_pond_edges_v161"
r=read(prefix+".json");f=read("tests/artifacts/lotus_pond_finish_v161.json")
assert not r["failures"] and not f["failures"] and len(r["physical_legs"])==15
assert all(x["valid"] for x in r["physical_legs"]+r["checks"]+f["checks"])
logs=["tests/artifacts/lotus-pond-edges-v161.log","tests/artifacts/lotus-pond-finish-v161.log"]
for log in logs:assert not any(l.startswith(("ERROR:","SCRIPT ERROR:")) for l in (ROOT/log).read_text(encoding="utf-8-sig").splitlines())
views=[r["captures"][0],r["captures"][2]]+f["captures"]
assert all((ROOT/"tests/artifacts"/p).is_file() for p in views)
exports=re.findall(r'"(res://[^"]+)"',(ROOT/"export_presets.cfg").read_text(encoding="utf-8-sig"))
assert len(exports)==len(set(exports)) and all((ROOT/p[6:]).is_file() for p in exports)
sources=["world/visual_campus/LotusPondEdges.gd","world/visual_campus/LowerCampusLandscape.gd","world/visual_campus/CentralCourtyard.gd","systems/data/campus_visual_build.json","references/visual_build_20261008/lotus_pond_edges_v161.json"]
write(prefix+"_accepted.json",{"version":r["version"],"physical_legs":15,"fixtures":1,"checks":8,"effective_images":views,"images_reviewed":6,"engine_errors":0,"export_files":len(exports),"failures":[],"image_scope":"Two initial wide views retained for screen/shore relationship; final close circle and mall images replace earlier captures after small corner-mesh/finish changes. Circular rim retains subtle shading seams; not final render quality.","scope":"15continuous perimeter legs,7initial probes plus1after ring mesh correction.Only local corner geometry and decorative paving/column finish changed after walking; route collision unchanged.","source_sha256":{p:sha(p) for p in sources},"report_sha256":{p:sha(p) for p in [prefix+".json","tests/artifacts/lotus_pond_finish_v161.json"]+logs},"image_sha256":{p:sha("tests/artifacts/"+p) for p in views}})
report="docs/LOTUS_POND_EDGES_V161.md"
summary="V161：用2024-01-29校方书展室外照片与荷花池全景四向图对应，补白色池端景墙的真实透空格/圆洞/石基，池岸和弧形平台改深灰方石，增黑栏杆。画面再补柱下石铺、改池侧连廊浅色柱面，修圆洞网格四角；15段连续池岸绕行、1起点、7初检+1收尾洞口检查通过，无引擎错误，6图查看/4分范围有效图。复用未变步行，未重跑全区。活动日期不等拍摄日，全景日期未知；池塘/景墙尺寸仍拟合，圆洞边缘轻微着色接缝待渲染收尾。新对照暴露学生中心池侧黄凹廊/上部红板与现有配准模型仍不相符，下一批优先核对该立面和入口，再共享下层/图书馆后路G2F、D至F/G和全A–G。稳定v2.0.0不变，Goal active。详见docs/LOTUS_POND_EDGES_V161.md。"
cov=read("docs/lower_campus_refinement_coverage.json")
cov.update(updated="2026-10-12",basis_version=r["version"],previous_turn_classification="progress",status="active")
cov["next_action"]="V161 pond screen real apertures/grey stone/black rail/white colonnade finish complete locally:15continuous perimeter legs/1fixture/8checks/4scoped effective views.2024bookfair plus undated official pond cube reveal STUDENT POND FACADE remains mismatched:yellow double-height recesses and upper red panels missing/misplaced in registered north wall. NEXT reconcile1F/3F/5F traces against pond-facing facade and dated2024image,repair openings/lining before declaring entry registration. Then shared lower-front/library-rearG2F,retained high-stair questions,D->F/G/allA-G. Dimensions fitted,stablev2.0.0unchanged,Goalactive."
cov["v161_evidence"]={"report":report,"accepted":prefix+"_accepted.json","legs":15,"fixtures":1,"checks":8,"effective_views":4,"all_images_reviewed":6}
cov["release_convergence"]["development"]["model_version"]=r["version"]
for z in cov["zones"]:
 if z["id"] not in ["C","D"]:continue
 if report not in z.setdefault("evidence",[]):z["evidence"].append(report)
pending="V161 dated2024pond features partly modelled,but student pond-facing yellow recesses/upper red panels differ from registered facade. Need facade/entrance reconciliation,shared lower-front/library-rear datum. Pond/wall dimensions not surveyed; round rim subtle shading seams and seasonal vegetation remain."
if pending not in cov["known_unfinished_features"]:cov["known_unfinished_features"].append(pending)
write("docs/lower_campus_refinement_coverage.json",cov)
for fn in ["docs/LOWER_CAMPUS_ACTIVE_GOAL.md","docs/NEXT_ITERATION_HANDOFF.md"]:
 p=ROOT/fn;s=p.read_text(encoding="utf-8-sig")
 if "\nV161：" not in s:s+="\n\n"+summary+"\n"
 if fn.endswith("HANDOFF.md"):
  s=s.replace("`official-visual-build-160-student-rear-lower-core`","`"+r["version"]+"`",1)
  s=s.replace("不能说这些改动已包含在稳定包。","V161已补荷花池景墙真实开孔/灰石/黑栏杆/浅色连廊柱，15记录/8检查/4有效图；池侧学生立面仍待校正。不能说这些改动已包含在稳定包。",1)
  s=s.replace("下一批优先2024池边照片的中央入口/硬铺配准；","V161已对应2024池边景墙与硬铺，下一批优先学生池侧黄凹廊/红板与入口配准；",1)
 p.write_bytes(s.encode())
p=ROOT/"README.md";s=p.read_text(encoding="utf-8-sig").replace("`2.0.1-dev` / V160，[学生中心后侧低层梯与三层服务区](docs/STUDENT_REAR_LOWER_CORE_V160.md)","`2.0.1-dev` / V161，[荷花池景墙与真实铺地](docs/LOTUS_POND_EDGES_V161.md)");p.write_bytes(s.encode())
p=ROOT/report;s=p.read_text(encoding="utf-8-sig").replace("原始结果及最终验收索引见", "15段连续实走、1起点、8检查（7初检+1收尾）通过，无引擎错误。6张画面已看，4张分范围有效图；圆洞边缘仍有轻微着色接缝待渲染收尾。柱下草带和旧绿砖柱面已按全景修正为灰石与浅色饰面，未变通行复用。原始结果及最终验收索引见")
s+="\n\n此次宽景对照还确认：注册后的学生中心池侧立面仍缺/错配黄色双层凹廊及上部红板。下一批优先核对该立面和入口，不能将池墙材料修复当作整片外观已像实景。\n"
p.write_bytes(s.encode())
print(json.dumps({"legs":15,"checks":8,"views":4,"exports":len(exports),"goal":"active"}))
