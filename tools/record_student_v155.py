"""V155 visual finish: collision equivalence permits reuse of V154 scoped walks."""
from pathlib import Path
import json,hashlib,re
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text(encoding='utf-8-sig'))
def write(p,v):(ROOT/p).write_bytes((json.dumps(v,ensure_ascii=False,indent=2)+'\n').encode())
def sha(p):return hashlib.sha256((ROOT/p).read_bytes()).hexdigest()
prefix='tests/artifacts/student_finish_v155'
paths=[prefix+s+'.json' for s in ['', '_panel','_wrap']]
reports=[read(p) for p in paths]
baseline=read(prefix+'_collision_before.json')
assert baseline['version']=='official-visual-build-154-student-core-supports'
assert baseline['shape_count']==1629
for r in reports:
    assert not r['failures'] and r['after']['sha256']==baseline['sha256'] and r['after']['shape_count']==1629
logs=['tests/artifacts/student-finish-v155'+s+'.log' for s in ['-baseline','','-panel','-wrap']]
for p in logs:
    assert not any(s.startswith(('ERROR:','SCRIPT ERROR:')) for s in (ROOT/p).read_text(encoding='utf-8-sig').splitlines()),p
sources=['world/visual_campus/'+s for s in ['StudentCentre.gd','StudentRegisteredBuilding.gd','VisualCampusKit.gd','CampusSurface.gdshader']]+['systems/data/campus_visual_build.json']
final=reports[-1]
images=final['captures']+[reports[1]['captures'][1],reports[0]['captures'][4]]
assert all((ROOT/'tests/artifacts'/p).is_file() for p in images)
exports=re.findall(r'"(res://[^"]+)"',(ROOT/'export_presets.cfg').read_text(encoding='utf-8-sig'))
assert len(exports)==len(set(exports)) and all((ROOT/p[6:]).is_file() for p in exports)
receipt={'version':final['version'],'collision_equal':True,'student_collision_shapes':1629,'collision_sha256':baseline['sha256'],
    'walk_tests_this_batch':0,'reused_walk_evidence':'tests/artifacts/student_core_v154_accepted.json',
    'reuse_limit':'Collision equivalence of entire student subtree supports unchanged V154 scoped routes only, not other areas or geometric/dated fidelity.',
    'effective_images':images,'images_viewed':10,'export_files':len(exports),'engine_errors':0,
    'retired':'Initial north red joints faced away from court; corrected in panel pass. Pale floor-edge bands over brick were wrapped in final pass. Earlier views cannot prove these final details.',
    'limits':'Historic2021-published source/capture unknown; fitted opening proportions/material modules. Three2024 event photos reviewed but not usable for exterior doors/paving/currentness.',
    'logs':logs,'source_sha256':{p:sha(p) for p in sources},'report_sha256':{p:sha(p) for p in paths+logs+[prefix+'_collision_before.json']}}
write(prefix+'_accepted.json',receipt)
report='docs/STUDENT_FACADE_FINISH_V155.md'
summary='V155：学生中心灰砖外墙改暗色内退窄窗/薄窗台与砖包楼板边，黄色院落补窄窗分格/代表壁灯，红金属板补朝院落折边/横缝，院落方砖与低反射屋面细化。1629碰撞形状/世界变换摘要与V154完全一致，复用其局部通行，本轮零重走；10图查看、5分范围有效终图。初红板背向折边和白色楼板横带画面已替换，无引擎错误。3张2024十周年活动图已核查：电梯装饰/食品/临时舞台，不用于外立面门位或永久砖墙，截图日期不作拍摄日。下一批院落梯层位/其他核心/独立楼翼及真实下首层、图书馆后路G/2F，再D至F/G和全A–G。稳定v2.0.0未覆盖，Goal active。详见docs/STUDENT_FACADE_FINISH_V155.md。'
cov=read('docs/lower_campus_refinement_coverage.json')
cov.update(updated='2026-10-12',basis_version=final['version'],previous_turn_classification='progress',status='active')
cov['next_action']='V155 visual finish complete locally:dark recessed brick casements/floor-edge wrap,narrow yellow court windows,folded red panel joints,square paving/matte roof.1629 collision signatures equalV154;no repeated walks;5 final views. Three queued2024 anniversary photos inspected and rejected as exterior evidence (lift decor/food/stage). NEXT reconcile court stair layer projections with029/030/031+sections, build remaining cores/independent upper-wing connections and verify real side/shared lower-ground entry. Resolve5F front lift residual and library rear-roadG/2F datum. ContinueD->F/G and entireA-G;retaindated-source gaps and no true-north claim. Stablev2.0.0 fixed;Goalactive.'
cov['v155_evidence']={'report':report,'accepted':prefix+'_accepted.json','collision_shapes':1629,'unchanged_collision':True,'walks_this_batch':0,'effective_views':5,'anniversary_photos_reviewed':3}
cov['release_convergence']['development']['model_version']=final['version']
for zone in cov['zones']:
    if zone['id']!='D':continue
    if report not in zone['evidence']:zone['evidence'].append(report)
    for b in zone['buildings']:
        if b['id']!='student_centre':continue
        if report not in b['evidence']:b['evidence'].append(report)
        b['coverage']['front']+=' V155 dark recessed window profiles and grey-brick floor-edge wrap; historic photo fit,not current-site certification.'
        b['coverage']['ground_or_pilotis']+=' V155 square stone modules,narrow visible glazing and folded red panels; unchanged collision,full plan still partial.'
pending='V155: three anniversary pictures are elevator/event/food close-ups,not exterior evidence. Do not recreate stage brickwork as permanent building finish. V155 historic-photo finish does not close currentness,exact door/court/stair/room or shared lower-ground gaps.'
if pending not in cov['known_unfinished_features']:cov['known_unfinished_features'].append(pending)
write('docs/lower_campus_refinement_coverage.json',cov)
for fn in ['docs/LOWER_CAMPUS_ACTIVE_GOAL.md','docs/NEXT_ITERATION_HANDOFF.md']:
    p=ROOT/fn;s=p.read_text(encoding='utf-8-sig')
    if '\nV155：' not in s:s+='\n\n'+summary+'\n'
    if fn.endswith('HANDOFF.md'):
        s=s.replace('`official-visual-build-154-student-core-supports`','`'+final['version']+'`',1)
        s=s.replace('不能说这些改动已包含在稳定包。','V155 已细化窗墙/红板/方砖/屋面，1629碰撞摘要不变，5有效终图；复用V154局部通行。不能说这些改动已包含在稳定包。',1)
        s=s.replace('V154 前核心和柱网已落地，下一批院落梯分层投影、其余核心/独立上层块及2024十周年活动照片中的固定门位；','V155 窗墙铺地已细化，3张十周年活动近景已查看但不作外景依据；下一批院落梯分层、其余核心/独立上层块及真实侧门；')
    p.write_text(s,encoding='utf-8')
p=ROOT/'README.md';s=p.read_text(encoding='utf-8-sig').replace('`2.0.1-dev` / V154，[学生中心前核心与悬挑支撑](docs/STUDENT_CORE_SUPPORTS_V154.md)','`2.0.1-dev` / V155，[学生中心窗墙与铺地细化](docs/STUDENT_FACADE_FINISH_V155.md)');p.write_text(s,encoding='utf-8')
print(json.dumps({'collision_shapes':1629,'unchanged':True,'new_walk_tests':0,'effective_views':5,'goal':'active','stable':'unchanged'}))
