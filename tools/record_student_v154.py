"""Accept scoped V154 final core geometry, preserving failures and the full campus Goal."""
from pathlib import Path
import json, hashlib, re
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text(encoding='utf-8-sig'))
def write(p,v):(ROOT/p).write_bytes((json.dumps(v,ensure_ascii=False,indent=2)+'\n').encode())
def sha(p):return hashlib.sha256((ROOT/p).read_bytes()).hexdigest()
prefix='tests/artifacts/student_core_v154'
paths=[prefix+s+'.json' for s in ['', '_finish', '_clearance']]
a,b,c=[read(p) for p in paths]
initial_indices=list(range(6,13))
assert len(a['physical_legs'])==13 and all(a['physical_legs'][i]['valid'] for i in initial_indices)
assert len(c['physical_legs'])==104 and len(c['checks'])==23 and not c['failures']
assert all(r['valid'] for r in c['physical_legs']+c['checks'])
logs=['tests/artifacts/student-core-v154-'+s+'.log' for s in ['initial','finish','clearance']]
for p in logs:
    assert not any(line.startswith(('ERROR:','SCRIPT ERROR:')) for line in (ROOT/p).read_text(encoding='utf-8-sig').splitlines())
exports=re.findall(r'"(res://[^"]+)"',(ROOT/'export_presets.cfg').read_text(encoding='utf-8-sig'))
assert len(exports)==len(set(exports)) and all((ROOT/p[6:]).is_file() for p in exports)
assert 'res://world/visual_campus/StudentFrontCore.gd' in exports
sources=['world/visual_campus/'+p for p in ['StudentFrontCore.gd','StudentRegisteredBuilding.gd','StudentRegisteredPlan.gd','StudentCentre.gd']]+['systems/data/campus_visual_build.json','export_presets.cfg']
assert read('systems/data/campus_visual_build.json')['version']==c['version']
limits='Historic grid picks and1F front core envelope; rises,doors,section sizes fitted. 5F held-out lift residual6.38px remains. Other cores/rooms, individual upper blocks, complete supports/current facade details and shared lower-ground/rear datum still incomplete.'
receipt={'version':c['version'],'valid_records':111,'checks':23,'effective_fixtures':3,'not_single_tour':True,
    'accepted_legs':[{'file':paths[0],'indices':initial_indices},{'file':paths[2],'indices':list(range(104))}],
    'accepted_checks':[{'file':paths[2],'indices':list(range(23))}],
    'effective_images':c['captures'],'images_viewed':8,'export_files':len(exports),'engine_errors':0,
    'reuse':'Initial seven front-court support-bypass legs unaffected by subsequent local core opening/platform/guard repairs. Final104 core legs split into ascent and descent fixtures, not one unbroken campus tour.',
    'retired':'Initial and intermediate core legs/checks superseded. Original guard group pitch invaded landing turn; platform lips and incomplete midlanding overhead cut repaired. Inside-to-outside solid probes and underside single-sided-floor probes replaced with meaningful outward/top-down checks. All failed reports retained.',
    'limits':limits,'logs':logs,'source_sha256':{p:sha(p) for p in sources},'report_sha256':{p:sha(p) for p in paths+logs}}
write(prefix+'_accepted.json',receipt)
report='docs/STUDENT_CORE_SUPPORTS_V154.md'
summary='V154：以八个共同柱符号配准历史1/3/5F，5F轮廓改相似变换；补七根前部支撑、前核心五组折返梯/真实楼板洞和关闭电梯井，贯通G至六层，修中层凹口及立面虚墙。111有效分批移动、3起点、23检查、4终图通过；初/中间平台立边、净高、护栏伸入转弯及无效射线失败保留，核心以最终clearance验收。5F独立电梯点残差6.38px约0.46米，门位/层高仍拟合，其他核心/房间/院落梯层位和完整支撑未完。新读2024-03-20校方十周年活动报道，明确3月9日学生中心一/四楼活动；照片尚未检查，截图文件日非拍摄日。下一批院落梯分层与其余核心/较新门位，保留共享下层、图书馆后路G/2F及全A–G。稳定v2.0.0未覆盖，Goal active。详见docs/STUDENT_CORE_SUPPORTS_V154.md。'
cov=read('docs/lower_campus_refinement_coverage.json')
cov.update(updated='2026-10-12',basis_version=c['version'],previous_turn_classification='progress',status='active')
cov['next_action']='V154 historical eight-column registration and front G-6F core/supports built:111 scoped legs,23 checks,4 final views. NEXT reconcile individual courtyard stair projections/end floors and middle/upper wing notches against029/030/031 and sections; inspect official2024 anniversary photos queued in student_anniversary_followup_v154.json for fixed entry/current finishes, not temporary scenery. Resolve5F front lift held-out6.38px residual, other cores/upper-block connections and real library-side portal. Then shared lower-ground student access and library rear-road G/2F datum, D->F/G and allA-G. Do not repeat unaffected V154 tests. Stablev2.0.0 remains fixed; Goalactive.'
cov['v154_evidence']={'report':report,'registration':'references/visual_build_20261008/student_shared_grid_v154.json','anniversary_followup':'references/visual_build_20261008/student_anniversary_followup_v154.json','accepted':prefix+'_accepted.json','valid_records':111,'checks':23,'effective_views':4,'limits':limits}
cov['release_convergence']['development']['model_version']=c['version']
for zone in cov['zones']:
    if zone['id']!='D':continue
    if report not in zone['evidence']:zone['evidence'].append(report)
    for building in zone['buildings']:
        if building['id']!='student_centre':continue
        building['status']='V154_grid_registered_and_front_core_G6F_built;other_cores_rooms_court_level_fidelity_partial'
        building['coverage']['stairs_ramps']='V154 front core connectsG-6F with real floor openings and locally verified up/down; historic envelope/fitted heights/doors. Other cores and independent upper blocks pending. Court stair projections/endfloor identity still require source reconciliation.'
        building['coverage']['front']+=' V154 seven grid-located support columns and5F similarity fit added. Complete frame andcurrent facade details pending.'
        if report not in building['evidence']:building['evidence'].append(report)
        building['superseded']+=' V154 new support columns require front-court bypass, so affected V153 straight paths no longer validate that part. Unchanged rear-road/doors retain scoped evidence.'
for feature in cov['known_unfinished_features']:
    if isinstance(feature,dict) and feature.get('id')=='student_centre_courtyards_and_storey_registration':
        feature['status']='V154_shared_column_fit_and_front_coreG6F;other_core_court_projections_and_current_detail_unresolved'
        feature['missing']=[x for x in feature['missing'] if x!='highest two floor access']
        feature['missing'] += ['independent upper wing connections and remaining cores; front G-6F stairs locally verified','5F held-out lift6.38px discrepancy and exact current entry/court stair layer mapping']
pending='V154: front core G-6F locally walkable butnot exact as-built verification.5F lift held-out6.38px, other cores/independent upper wings, court stair layer mapping/full supports/current finishes, library-side true doorway/shared lower-ground access and rear-roadG/2F datum remain open.'
if pending not in cov['known_unfinished_features']:cov['known_unfinished_features'].append(pending)
write('docs/lower_campus_refinement_coverage.json',cov)
for filename in ['docs/LOWER_CAMPUS_ACTIVE_GOAL.md','docs/NEXT_ITERATION_HANDOFF.md']:
    p=ROOT/filename;s=p.read_text(encoding='utf-8-sig')
    if '\nV154：' not in s:s+='\n\n'+summary+'\n'
    if filename.endswith('HANDOFF.md'):
        s=s.replace('`official-visual-build-153-student-plan-massing`','`'+c['version']+'`',1)
        s=s.replace('不能说这些改动已包含在稳定包。','V154 已补柱网配准、前核心 G–6F 和悬挑支撑，111 分批记录、23 检查、4 终图；其余核心/独立上层楼翼仍待补。不能说这些改动已包含在稳定包。',1)
        s=s.replace('V153 比例尺体量及道路重建已落地，下一批共同核心/柱网/剖面配准，修中高层凹口、支撑和上两层通路，核实拟合侧门；','V154 前核心和柱网已落地，下一批院落梯分层投影、其余核心/独立上层块及2024十周年活动照片中的固定门位；')
    p.write_text(s,encoding='utf-8')
p=ROOT/'README.md';s=p.read_text(encoding='utf-8-sig').replace('`2.0.1-dev` / V153，[学生中心比例尺体量与院落重建](docs/STUDENT_REGISTERED_PLAN_V153.md)','`2.0.1-dev` / V154，[学生中心前核心与悬挑支撑](docs/STUDENT_CORE_SUPPORTS_V154.md)');p.write_text(s,encoding='utf-8')
print(json.dumps({'records':111,'checks':23,'views':4,'export_files':len(exports),'goal':'active','stable':'unchanged'}))
