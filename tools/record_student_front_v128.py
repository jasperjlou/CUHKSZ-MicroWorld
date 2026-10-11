"""Record the inspected facade batch; retain the complete lower-campus scope."""
import hashlib
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text(encoding='utf-8'))
def save(p,d):(ROOT/p).write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')

p=read('tests/artifacts/student_front_v128_physics.json')
v=read('tests/artifacts/student_front_v128_views.json')
assert len(p['physical_legs'])==18 and all(x['valid'] for x in p['physical_legs'])
assert len(p['checks'])==4 and all(x['valid'] for x in p['checks'])
assert not p['failures'] and not v['failures'] and len(v['captures'])==4
logs=['student-front-v128-physics.log','student-front-v128-visual.log']
for name in logs:
    assert not any(s.startswith(('ERROR:','SCRIPT ERROR:')) for s in (ROOT/'tests/artifacts'/name).read_text(encoding='utf-8').splitlines())
save('tests/artifacts/student_front_v128_accepted.json',{
    'version':p['version'],'physical_legs':18,'fixtures':1,'checks':4,
    'physics_report':'student_front_v128_physics.json','views':v['captures'],
    'all_four_views_inspected':True,'logs':logs,'geometry_changed_after_validation':False,
    'source_sha256':hashlib.sha256((ROOT/'world/visual_campus/StudentLowerConcourse.gd').read_bytes()).hexdigest(),
    'route_limit':'0.8m stopping tolerance; bay approaches terminate at X~25.0 under canopy, not flush at glazing X23.8.',
    'visual_limit':'First16m frontage refined; long rising section, plan, grades, complete public service level still fitted/unresolved.'})
save('references/visual_build_20261008/student_front_v128_evidence.json',{
    'reviewed':'2026-10-11','primary':'originals/zhang-lower-v126/r.jpg',
    'panorama':25308214,'scene':41803700,'capture_date':'unknown',
    'observed':['grey brick upper wall','dark thin canopy and square piers','recessed infill bays','white service door with louvre','grey stone paving'],
    'inferred':['metric position','four bays over16m','exact utility door bay','glazing vs closed pale infill in distant bays'],
    'legacy_views_reviewed':['references/legacy-gta-20261011/legacy-overview.png','references/legacy-gta-20261011/legacy-library1f-plan-cutaway.png'],
    'legacy_use':'Campus group/wing/court topology and library discussion pods. No local facade measurements taken from these overviews; source package unchanged.',
    'remaining':['actual complete lower plan and grades','current bank frontage','StudentCentre lower entry','north courtyard relationship','C-D rear road']})

d=read('docs/lower_campus_refinement_coverage.json')
d['updated']='2026-10-11';d['basis_version']=p['version'];d['previous_turn_classification']='progress'
d['next_action']=('V128 replaces first16m blank lower-lane wall with four recessed service bays, grey-brick upper band, dark canopy/piers, closed utility door/louvre and drainage. '
    '18 continuous local legs +4 collision/clearance checks pass;4 final views inspected. Bay count/positions and window infill fitted, capture date unknown. '
    'Next register actual lower plan/grade, current bank frontage, StudentCentre lower entrance and northern courtyard; then C-D rear road and full A-G. '
    'Keep library rear-to-Shaw/main-stair-under interior/116seam/5-6F, ICC registration/lower patterns/soffit seams, all backs/corners. East Gate fixed; true north unresolved.')
z=next(x for x in d['zones'] if x['id']=='D')
b=next(x for x in z['buildings'] if x['id']=='student_lower_services')
b['status']='V128_lower_lane_frontage_refined_registration_partial'
b['coverage']['side_left']='V128 first16m four recessed bays, brick upper, dark canopy/piers, utility door/louvre; exact bay identity and plan/grade unregistered'
b['coverage']['connections']='V128 18 single-start local frontage-to-Shaw-and-return legs +4 collision/headroom probes; V127 unaffected main stair/upper mall evidence retained'
for ev in ['docs/STUDENT_LANE_FRONT_V128.md','references/visual_build_20261008/student_front_v128_evidence.json','tests/artifacts/student_front_v128_accepted.json']:
    if ev not in b['evidence']:b['evidence'].append(ev)
z['stages']['7']='V128_18_single-start_frontage_legs_4_checks_4_views;D_E_plan_grade_fidelity_incomplete'
d['v128_evidence']={'doc':'docs/STUDENT_LANE_FRONT_V128.md','accepted':'tests/artifacts/student_front_v128_accepted.json','legs':18,'fixtures':1,'checks':4,'views':4}
save('docs/lower_campus_refinement_coverage.json',d)
goal=ROOT/'docs/LOWER_CAMPUS_ACTIVE_GOAL.md'
s=goal.read_text(encoding='utf-8')
if '\nV128：' not in s:
    goal.write_text(s+'\n\nV128：按入口25308214右面图，将下首层沿路平坦段16米整墙改为四开间退进立面、灰砖上部、深色柱/薄檐、封闭服务门/百叶及排水。18段单起点局部往返、4碰撞/净空检查一次通过，4最终图已看，无引擎错误，验证后未改几何。路线实际停在约x25廊前，不宣称贴近每个门窗；门窗身份/开间/米制/坡度仍拟合。旧GTA总览和1F剖切重新核对可作结构参考，未从中伪称测出本段尺寸，原包未改。下一批下层完整平面/标高、银行现状、学生中心实际下层入口及北侧庭院，再C-D后路；所有A–G、图书馆后路至逸夫/主梯下馆内下层/116接缝/5-6F、ICC配准及底面、背面边角保持，Goal active。详见docs/STUDENT_LANE_FRONT_V128.md。\n',encoding='utf-8')
print('V128 recorded: 18 local legs, 4 checks, 4 inspected views; whole-campus goal active.')
