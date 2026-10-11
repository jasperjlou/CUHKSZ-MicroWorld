"""Record the connected lower court milestone without narrowing the campus goal."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text(encoding='utf-8'))
def save(p,d):(ROOT/p).write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
p=read('tests/artifacts/student_north_v129_physics.json');v=read('tests/artifacts/student_north_v129_views.json')
assert len(p['physical_legs'])==28 and all(x['valid'] for x in p['physical_legs']) and not p['failures']
assert len(p['checks'])==4 and all(x['valid'] for x in p['checks'])
assert len(v['captures'])==4 and not v['failures']
logs=['student-north-v129-final-physics.log','student-north-v129-final-visual.log']
for name in logs:
    assert not any(s.startswith(('ERROR:','SCRIPT ERROR:')) for s in (ROOT/'tests/artifacts'/name).read_text(encoding='utf-8').splitlines())
files=['StudentLowerConcourse.gd','CentralCourtyard.gd','CourtyardPublicDetail.gd','VisualCampusBuilder.gd']
save('tests/artifacts/student_north_v129_accepted.json',{
    'version':p['version'],'physical_legs':28,'fixtures':1,'checks':4,'physics_report':'student_north_v129_physics.json',
    'views':v['captures'],'all_four_final_views_inspected':True,'logs':logs,
    'retired':'Initial route at X32 Z-331 went into reflecting pool; initial log retained but not accepted. Non-colliding decorative paving removed; route uses real shore Z-334.4.',
    'finish_after_physics':'Removed one legacy upper-height bench floating over lower lawn; no walking surfaces, dimensions or tested obstacles added/changed. Final visual repeated, physics retained.',
    'source_sha256':{f:hashlib.sha256((ROOT/'world/visual_campus'/f).read_bytes()).hexdigest() for f in files},
    'limits':'Local route only. Link position/width/length/height and full lower plan remain fitted; all A-G goal active.'})
save('references/visual_build_20261008/student_north_v129_evidence.json',{
    'reviewed':'2026-10-11','manifest':'originals/student-context-v129/manifest.json',
    'sources':[
        {'url':'https://campusvr-en.cuhk.edu.cn/?scene_id=41803700','pano_id':25308214,'face':'l','capture_date':'unknown','supports':'card-front lower route continues, lawn/stair/covered hall topology; not exact registration'},
        {'url':'https://campusvr-en.cuhk.edu.cn/?scene_id=116443796','pano_id':70040610,'capture_date':'unknown','viewed':'f,b,l,r','supports':'upper stone walks, white column rows, separate upper tree lawns and Shaw-side path'},
        {'url':'https://wwjarch.com/Central-Courtyard-of-Chinese-University-of-Hong-Kong-SZ','capture_date':'unknown','local':['originals/central-courtyard-20261010/wwj-courtyard-aerial.jpg','originals/central-courtyard-20261010/wwj-courtyard.jpg'],'supports':'single rectangular lower lawn distinct from upper tree garden'},
        {'url':'https://www.cuhk.edu.cn/zh-hans/page/14377','publication_date':'unknown','capture_dates':'unknown','supports':'FamilyMart/Uchiyama/print/optics at Zhang lower level, barber in D-SC lower area','viewed':['commercial-03.jpg','commercial-06.jpg','commercial-07.jpg','commercial-09.jpg','commercial-10.jpg','commercial-11.jpg'],'warning':'07 is Starbucks next section, not Zhang lower shop; downloaded neighboring images not automatically attributed'}],
    'placement':'Connector x22..34 z-407..-380, lowerY-1.76,upperY2.24; fitted, not survey. EastGate origin unchanged, north uncalibrated.',
    'remaining':['true lower plan/grade and door correspondence','current bank/card frontage','actual StudentCentre lower entry','D lower commercial interiors/frontages','C-D rear roads','all remaining A-G scope']})
d=read('docs/lower_campus_refinement_coverage.json')
d['updated']='2026-10-11';d['basis_version']=p['version'];d['previous_turn_classification']='progress'
d['next_action']=('V129 connects service lower hall and north court with a fitted27m covered passage, replaces four generic tree boxes with one reference lawn, removes false decorative floor over pond and floating bench. '
    '28 continuous local legs +4 checks pass;4 final views inspected. Exact lower plan/grade/width still unregistered. '
    'Next match newly saved official FamilyMart/Uchiyama/print/optics/barber photos to actual continuous lower plan; correct bank/card shared frontage and StudentCentre lower entrance without guessing tenant positions. '
    'Then C-D rear grades and full A-G; retain library rear-Shaw/main-stair-under interior/116seam/5-6F, ICC registration/soffit/lighting, all backs/corners. Dates unknown unless independently established; EastGate fixed, north uncalibrated.')
z=next(x for x in d['zones'] if x['id']=='D');b=next(x for x in z['buildings'] if x['id']=='student_lower_services')
b['status']='V129_north_lower_court_connected_fitted_plan_partial'
b['coverage']['connections']='V129 covered link to north lower courtyard, lower room route and pool-side stair shore;28 continuous legs,4checks. Absolute correspondence not validated.'
b['coverage']['corners_drains_retaining_edges']='V129 north wall openings/roof/columns/stone/drains; north court one lawn replaces generic tree boxes. Exact topology/grade remains fitted.'
ev=['docs/STUDENT_NORTH_CONNECTION_V129.md','references/visual_build_20261008/student_north_v129_evidence.json','tests/artifacts/student_north_v129_accepted.json']
for item in ev:
    if item not in b['evidence']:b['evidence'].append(item)
z['stages']['7']='V129_28_single-start_lower_court_shore_return_legs_4checks_4finalviews;wholeD_fidelity_incomplete'
d['v129_evidence']={'doc':ev[0],'accepted':ev[2],'legs':28,'fixtures':1,'checks':4,'views':4}
save('docs/lower_campus_refinement_coverage.json',d)
goal=ROOT/'docs/LOWER_CAMPUS_ACTIVE_GOAL.md';s=goal.read_text(encoding='utf-8')
if '\nV129：' not in s:
    goal.write_text(s+'\n\nV129：服务廊与北侧下沉庭院拆封墙、补拟合27米下层通道/顶板/梁柱/灰石排水，庭院四个通用树池改参考图的单块矩形草坪。初查误入池内，撤掉旧无碰撞装饰铺装，采用真实池岸路线；最终28段单起点连续往返、4结构检查通过，4终图已看，无引擎错误。收尾移除上层高度悬空长椅后仅复看画面，通行面未改。新校方商业页照片补全家/内山/文印/眼镜/理发参考，未任意分配门位；网页/照片/全景年份未知。通道宽长、位置、标高和完整下层对应仍拟合，下一批核准商店连续关系、银行校园卡共用门面、学生中心实际下层入口，再C-D后路。全A–G、图书馆后车道至逸夫/主梯下馆内下层/116接缝/5-6F、ICC及全部背面边角保持，Goal active。详见docs/STUDENT_NORTH_CONNECTION_V129.md。\n',encoding='utf-8')
print('V129: 28 continuous legs, 4 checks, 4 final views. Whole-campus scope remains active.')
