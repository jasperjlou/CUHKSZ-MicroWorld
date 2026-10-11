"""Record a completed local modeling batch without narrowing the whole-campus goal."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text(encoding='utf-8'))
def save(p,d):(ROOT/p).write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')

physics=read('tests/artifacts/student_shaw_v127_physics.json')
assert len(physics['physical_legs'])==26 and not physics['failures']
assert all(r['valid'] for r in physics['physical_legs'])
views=read('tests/artifacts/student_shaw_v127_views.json')
assert not views['failures'] and len(views['captures'])==4
for name in ['student-shaw-v127-physics.log','student-shaw-v127-final-visual.log']:
    lines=(ROOT/'tests/artifacts'/name).read_text(encoding='utf-8').splitlines()
    assert not any(s.startswith(('ERROR:','SCRIPT ERROR:')) for s in lines),name
save('references/visual_build_20261008/student_shaw_v127_evidence.json',{
    'reviewed':'2026-10-11','source_manifest':'references/visual_build_20261008/originals/student-lower-v127/manifest.json',
    'panoramas':[{'scene_id':116443797,'pano_id':70040609,'capture_date':'unknown','supports':'Shaw east paver road / reverse lower lane'},
        {'scene_id':116440786,'pano_id':70037193,'capture_date':'unknown','supports':'upper lawn, flanking galleries and courtyard context'},
        {'scene_id':41566328,'pano_id':25181826,'capture_date':'unknown','visible_year_mark':'2020 New Year decoration','use':'historical structural reference only; decoration not built'}],
    'crosscheck':'Entrance panorama 25308214 and user 20261010_222313 upper sign; dates not interchangeable',
    'placement':'East Gate retained; X25..34, Z-451..-493; fitted 4m rise over26m, not survey or accessibility claim',
    'source_viewing':'12 horizontal cube faces viewed',
    'remaining':['true grade and plan registration','lower service facade/window strip','StudentCentre real lower entry','northern sunken court relationship','bank current condition']})
save('tests/artifacts/student_shaw_v127_accepted.json',{
    'version':physics['version'],'physics':'student_shaw_v127_physics.json','legs':26,'fixtures':1,
    'views':views['captures'],'all_four_final_views_inspected':True,
    'final_logs':['student-shaw-v127-physics.log','student-shaw-v127-final-visual.log'],
    'finish':'Coplanar apron terrain removed; wall base extended below road; brown pavers. Walkable surface and clear width unchanged.',
    'retired':'V126 upper path at X30 from Z-451 southward; replaced by actual lower-stair/lane route, no transfer of old upper-y test validity',
    'limits':'Local traversability only, not photo-exact registration or full D/E/campus acceptance'})
d=read('docs/lower_campus_refinement_coverage.json')
d['updated']='2026-10-11';d['basis_version']=physics['version'];d['previous_turn_classification']='progress'
d['next_action']=('V127 opens lower service hall to Shaw east paved road with real terrain/roof aperture, retaining wall/grass bank and fitted rising stone lane. '
    '26 continuous local legs one start pass; final4 views inspected. Next register actual lower plan/grade and service window strip, bank current frontage, '
    'StudentCentre lower door and northern courtyard relationship; then C-D real rear grade and all A-G. '
    'Keep library rear-to-Shaw/main-stair-under interior/116seam/5-6F, ICC exact registration/bright patterns/soffit seams,all backs/corners. '
    'East Gate unchanged, north uncalibrated; 2020 bank decoration historical, exterior capture dates unknown.')
z=next(x for x in d['zones'] if x['id']=='D')
b=next(x for x in z['buildings'] if x['id']=='student_lower_services')
b['status']='V127_lower_open_lane_to_Shaw_connected_fitted_partial'
b['coverage']['side_left']='V127 open lower lane to Shaw east built; actual lower service window/door strip and grade still unregistered'
b['coverage']['connections']='V127 26 continuous legs main stair/lower lane/Shaw east/return/upper mall; full photographic registration and northern courtyard relationship unresolved'
b['coverage']['corners_drains_retaining_edges']='V127 gray retaining edge, grass bank, drain, Shaw apron; actual terrain shape/planting pending'
for ev in ['docs/STUDENT_SHAW_LOWER_LANE_V127.md','references/visual_build_20261008/student_shaw_v127_evidence.json','tests/artifacts/student_shaw_v127_accepted.json']:
    if ev not in b['evidence']:b['evidence'].append(ev)
z['stages']['7']='V127_26_single-start_lower-to-Shaw-and-return_legs;final4_views;wholeD_E_fidelity_incomplete'
d['v127_evidence']={'doc':'docs/STUDENT_SHAW_LOWER_LANE_V127.md','accepted':'tests/artifacts/student_shaw_v127_accepted.json',
    'legs':26,'fixtures':1,'final_views':4,'previous_turn':'progress: V126 actual service-concourse construction'}
save('docs/lower_campus_refinement_coverage.json',d)
p=ROOT/'docs/LOWER_CAMPUS_ACTIVE_GOAL.md';text=p.read_text(encoding='utf-8')
if '\nV127：' not in text:
    p.write_text(text+'\n\nV127：入口与逸夫东座道路70040609、草坪70037193全景交叉支持开放下层长廊；拆V126末端墙/盖板，补至逸夫的露天石路、挡墙草坡与棕色铺地接口，导航改经宽梯和下层。26段单起点连续往返一次通过，最终4图已看；修旧草地共面和墙脚小缝，通行面尺寸未改。4米/26米高差坡长为拟合，不能当实测。银行全景25181826有2020布置，未照搬装修；外景拍摄日期未知。下一批真实下层窗带/服务门、学生中心入口/北侧庭院配准、C-D后路，继续全A–G、图书馆后路至逸夫/主梯下馆内下层/116亮缝/5-6F、ICC与全部背面边角。详见docs/STUDENT_SHAW_LOWER_LANE_V127.md，Goal active。\n',encoding='utf-8')
print('V127: 26 continuous legs, four final views; full-scope goal remains active.')
