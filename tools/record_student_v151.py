"""Record scoped student-entry evidence without retiring the unfinished campus Goal."""
from pathlib import Path
import json, hashlib, re

ROOT=Path(__file__).resolve().parents[1]
def read(p): return json.loads((ROOT/p).read_text(encoding='utf-8-sig'))
def write(p,v): (ROOT/p).write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
def sha(p): return hashlib.sha256((ROOT/p).read_bytes()).hexdigest()
prefix='tests/artifacts/student_lower_entries_v151'
paths=[prefix+'.json',prefix+'_finish.json',prefix+'_visual.json']
a,b,c=[read(p) for p in paths]
initial_legs=list(range(13))+[24,25]
initial_checks=[0,1,2,3,7]
assert len(a['physical_legs'])==29 and a['failures']==['front bridge approach']
assert all(a['physical_legs'][i]['valid'] for i in initial_legs)
assert all(a['checks'][i]['valid'] for i in initial_checks)
assert len(b['physical_legs'])==19 and len(b['checks'])==18 and not b['failures']
assert all(v['valid'] for v in b['physical_legs']+b['checks']) and not c['failures']
logs=['tests/artifacts/student-lower-v151-'+v+'.log' for v in ['initial','finish','visual']]
for p in logs:
    assert not any(s.startswith(('ERROR:','SCRIPT ERROR:')) for s in (ROOT/p).read_text(encoding='utf-8').splitlines()),p
src=['world/visual_campus/'+v for v in ['StudentLowerEntrances.gd','StudentCentre.gd','StudentTerracedCourts.gd','CampusSurface.gdshader']]+['world/product/ShowcaseChapters.gd','systems/data/campus_visual_build.json','export_presets.cfg']
exports=re.findall(r'"(res://[^"]+)"',(ROOT/'export_presets.cfg').read_text(encoding='utf-8-sig'))
assert len(exports)==len(set(exports)) and all((ROOT/p[6:]).exists() for p in exports)
assert 'res://world/visual_campus/StudentLowerEntrances.gd' in exports
images=['courtyard-refined-student-lower-v151-'+v+'.png' for v in ['rear','lobby','court-filtered','threshold-filtered','section-filtered']]
receipt={'version':c['version'],'valid_records':34,'fixtures':5,'not_single_tour':True,
    'accepted_legs':[{'file':paths[0],'indices':initial_legs},{'file':paths[1],'indices':list(range(19))}],
    'checks':23,'accepted_checks':[{'file':paths[0],'indices':initial_checks},{'file':paths[1],'indices':list(range(18))}],
    'images_viewed':11,'effective_images':images,'export_files':len(exports),'engine_errors':0,
    'retired':'Initial direct upper route crossed the existing table. Initial court legs/checks and views are superseded by facade closure; pre-filter mosaic views retired for moire.',
    'reuse':'Initial rear doors and first-stair ascent unchanged by later court closure. Final material-only change checked with three GPU views; walks were not rerun after that shader change.',
    'scope':'Two fitted rear 1F entries and lobby; two lower court doors; three yellow facades; selected court stairs and upper promenade/library interface. Not full campus or current-site datum verification.',
    'limits':'Rear door ratios follow historical 1F drawing fitted to V49 dimensions. Actual street level, service leaf placement, shared lower-ground entry, complete cores/rooms and geographic north unresolved.',
    'logs':logs,'source_sha256':{p:sha(p) for p in src},'report_sha256':{p:sha(p) for p in paths+logs}}
write(prefix+'_accepted.json',receipt)
evidence={'date':'2026-10-12','version':c['version'],
    'sources':[{'url':'https://www.gooood.cn/student-center-chinese-university-of-hong-kong-shenzhen-campus-by-wang-weijen-architecture.htm','published':'2021-05-28','capture_date':'unknown','drawing_revision':'unknown','local_images':['architect-'+v+'.jpg' for v in ['029','030','031','032','033','001','004','010','011','012','013']]},
    {'url':'https://campusvr-en.cuhk.edu.cn/?scene_id=116440789','image_resource':'70037188','capture_date':'unknown','note':'2023 appears on a peripheral poster, not a verified panorama date','local_manifest':'originals/central-courtyard-20261010/student-canteen/manifest.json'},
    {'local_inventory':'references/user/photos-20261010/inventory.json','date':'EXIF 2026-10-10; device clock not independently calibrated','limit':'Nearby mall and lower-shop direction only; these rear entries are not visible'}],
    'drawing_frame':[960,832],'reference_bounds_uv':[25,24,924,689],
    'mapping':{'local_x':'35 - (v - 24) * 70 / 665','local_z':'47.5 - (u - 25) * 95 / 899','scale_status':'Retained V49 fitted 70x95 footprint; not independently calibrated to drawing scale bar'},
    'door_image_v':[447.5,580],'final_local_x':[-9.6,-24.0],
    'legacy_status':'Prior legacy sections consulted; no new student/library rear height correspondence established in this batch',
    'scope_and_limits':receipt['limits']}
write('references/visual_build_20261008/student_lower_entries_v151.json',evidence)
cov=read('docs/lower_campus_refinement_coverage.json')
cov.update(updated='2026-10-12',basis_version=c['version'],previous_turn_classification='progress',status='active')
cov['next_action']='V151 fitted student rear 1F doors/lobby and lower court doors built; three yellow facades closed and split by floors, mosaic filtered. 34 scoped movement records, 23 checks, 5 effective views. NEXT establish matching legacy corners/slabs and architect sections for library rear-road G/2F datum and the actual shared lower-ground Student Centre interface. These rear 1F doors do not resolve the shared lower-ground entry. Continue D->F/G and all A-G: side/back/corners/cores/interiors and modern dated-reference gaps. Do not redo unaffected V146-151 checks. Stable v2.0.0 fixed, development 2.0.1-dev; Goal active.'
cov['v151_evidence']={'report':'docs/STUDENT_LOWER_ENTRIES_V151.md','evidence':'references/visual_build_20261008/student_lower_entries_v151.json','accepted':prefix+'_accepted.json','valid_records':34,'checks':23,'effective_views':5,'limits':receipt['limits']}
cov['release_convergence']['development']['model_version']=c['version']
for zone in cov['zones']:
    if zone['id']!='D': continue
    report='docs/STUDENT_LOWER_ENTRIES_V151.md'
    if report not in zone.setdefault('evidence',[]): zone['evidence'].append(report)
    for building in zone['buildings']:
        if building['id']=='student_centre':
            building['coverage']['rear']='V151 two historical-plan-fitted offset 1F doors and lobby replace central placeholder. Street datum, exact scale, side service leaf and full stair core pending.'
            building['coverage']['ground_or_pilotis']+=' V151 two lower court doors and stone threshold; three yellow court walls closed with floor-specific windows. Full hall/dining remains schematic.'
            building['coverage']['connections']+=' V151 selected court stairs and front/library upper interfaces checked; developer showcase now visits offset rear door.'
            if report not in building['evidence']:building['evidence'].append(report)
pending='V151: rear 1F entrances are historical-plan-fitted, not proof of current road datum or shared lower-ground access. Calibrate drawing scale/cores and student-library rear road together; shared lower-ground actual entry remains open.'
if pending not in cov['known_unfinished_features']:cov['known_unfinished_features'].append(pending)
write('docs/lower_campus_refinement_coverage.json',cov)
summary='V151：学生中心后墙中央占位门改为按历史1F图拟合的两处侧门，补内退门框、门厅/关闭服务门、石材门槛；下层黄色院落补两门，并修三段立面未封竖缝、分层窗/灰窗楣与砖纹摩尔纹。34有效分批移动、5起点、23检查、5有效视图；初穿桌直线失败和旧围护/摩尔纹图退休，材质最后只做GPU复核，无引擎错误。后门1F比例非实测，不等于下首层服务区真实入口；后路对G/2F标高/共享下层接口仍待旧模型同点剖面核准，再D至F/G及全A–G。开发2.0.1-dev，固定v2.0.0不覆盖，Goal active。详见docs/STUDENT_LOWER_ENTRIES_V151.md。'
for fn in ['docs/LOWER_CAMPUS_ACTIVE_GOAL.md','docs/NEXT_ITERATION_HANDOFF.md']:
    p=ROOT/fn;s=p.read_text(encoding='utf-8-sig')
    if '\nV151：' not in s:s+='\n\n'+summary+'\n'
    if fn.endswith('HANDOFF.md'):
        s=s.replace('`official-visual-build-150-library-lower-rear`','`official-visual-build-151-student-lower-entries`',1)
        s=s.replace('不能说这些改动已包含在稳定包。','V151 已补学生后侧/院落入口和分层黄色围护，34 分批记录、23 检查、5 有效视图。不能说这些改动已包含在稳定包。',1)
    p.write_text(s,encoding='utf-8')
p=ROOT/'README.md';s=p.read_text(encoding='utf-8-sig').replace('`2.0.1-dev` / V150，[图书馆下层后翼与露台](docs/LIBRARY_LOWER_REAR_V150.md)','`2.0.1-dev` / V151，[学生中心下层入口与院落围护](docs/STUDENT_LOWER_ENTRIES_V151.md)');p.write_text(s,encoding='utf-8')
print(json.dumps({'records':34,'checks':23,'views':5,'export_files':len(exports),'goal':'active','stable':'unchanged'}))
