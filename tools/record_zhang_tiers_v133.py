"""Record the actual tier batch; retain full lower-campus scope and fitted-geometry limits."""
import json,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text(encoding='utf-8'))
def save(p,d):(ROOT/p).write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
def sha(p):return hashlib.sha256((ROOT/p).read_bytes()).hexdigest()
p=read('tests/artifacts/zhang_tiers_v133_physics.json')
f=read('tests/artifacts/zhang_tiers_v133_finish_physics.json')
assert len(p['physical_legs'])==60 and len(f['physical_legs'])==15
assert all(x['valid'] for d in [p,f] for x in d['physical_legs']+d['checks'])
assert not p['failures'] and not f['failures']
logs=['zhang-tiers-v133-physics.log','zhang-tiers-v133-finish-physics.log','zhang-tiers-v133-visual.log','zhang-tiers-v133-final-visual.log']
for name in logs:
    assert not any(x.startswith(('ERROR:','SCRIPT ERROR:')) for x in (ROOT/'tests/artifacts'/name).read_text(encoding='utf-8').splitlines())
data=read('systems/data/campus_visual_build.json')
b=next(x for x in data['buildings'] if x['id']=='zhang_lingbin')
b['floor_levels']=[0,4.8,8.5,12.2,15.9,19.6,23.3]
b['model_storeys']=6
b['count_confidence']='V133 legacy triangle intersections support six main-bar slab levels versus three low-return levels; floor names/current inventory and physical metre heights unresolved.'
b['details']='V133 differentiated tall oblique/rear/front bars and low planted return roof; observed V131 entrance retained, deep duplicate service wall removed.'
b['v133_tiers']={'main_roof_local_y':23.3,'low_roof_local_y':12.2,'low_walk_top':12.325,'occupied_core_tops':[4.925,8.625,12.325,16.025,19.725],'source':'references/legacy-gta-20261011/zhang-height-probes-v133.json','limits':'Fitted4.8/3.7 storey spacing, not raw legacy units or surveyed metric heights. Low-roof footprint/planting approximate; current-year confirmation incomplete.'}
b['v125_court_core']['superseded_by']='V133 extends core one level; former upper long gallery retired, lower two photo-gallery joins retained.'
save('systems/data/campus_visual_build.json',data)
files=['world/visual_campus/TeachingBlocks.gd','world/visual_campus/ZhangCourtCore.gd','world/visual_campus/ZhangLowRoof.gd','world/visual_campus/LandmarkBuildings.gd','systems/data/campus_visual_build.json']
views=['courtyard-refined-zhang-tiers-v133-'+s+'.png' for s in ['overview','low-roof','court','upper-core','through-entry']]
save('tests/artifacts/zhang_tiers_v133_accepted.json',{'version':data['version'],'physical_legs':75,'fixtures':2,'checks':7,'max_route_error':max(x['distance'] for d in [p,f] for x in d['physical_legs']),'reports':['zhang_tiers_v133_physics.json','zhang_tiers_v133_finish_physics.json'],'logs':logs,'views':views,'all_five_final_views_inspected':True,'after_physics':'Removed four non-colliding ground glass placeholders and recaptured affected views. Data floor/storey/evidence fields synchronized; Zhang geometry reads explicit level arrays, these metadata updates do not change generated geometry.','source_sha256':{s:sha(s) for s in files},'limits':'Local tier/core/roof/entry routes only; current-year full room plan, XY registration, grade and all-campus fidelity incomplete.'})
d=read('docs/lower_campus_refinement_coverage.json')
d.update(updated='2026-10-11',basis_version=data['version'],previous_turn_classification='progress')
d['next_action']='V133 corrects D height tiers using actual legacy triangle heights: low return roof12.2 versus tall bars23.3, five-flight rear core, low roof terrace; retires unsupported upper long galleries and duplicate deep doorway.75 local legs/2starts+7checks,5final views. Next register D full XY footprint/aspect, stepped low roof and separate lower/first-floor rooms/landscape against architect plans and newer photos, then C-D rear hardscape/grade. Keep all A-G, student lower door plan, library rear-Shaw/main-stair-under/116/5-6F,ICC and backs/corners;EastGate fixed,north unresolved.'
z=next(x for x in d['zones'] if x['id']=='D');b=next(x for x in z['buildings'] if x['id']=='zhang_lingbin')
b['status']='V133_height_tiers_core_low_roof_built_XY_lower_plan_incomplete'
b['coverage']['connections']='V13375 local legs across2continuous fixtures,7checks:five-flight rear core/low-roof loop and separate entry-rear route;upper unsupported galleries removed. Existing first2 photo gallery joins retained.'
b['coverage']['ground_or_pilotis']='V131 observed apron/entry;V133 duplicate inner doorway and unbacked glass removed. Whole lower room/landscape outline still schematic and too open.'
for ev in ['docs/ZHANG_STEPPED_HEIGHT_V133.md','references/legacy-gta-20261011/zhang-height-probes-v133.json','tests/artifacts/zhang_tiers_v133_accepted.json']:
    if ev not in b['evidence']:b['evidence'].append(ev)
z['stages']['7']='V13375_local_legs_2starts_7checks_5finalviews;wholeD_fidelity_incomplete'
d['v133_evidence']={'doc':'docs/ZHANG_STEPPED_HEIGHT_V133.md','accepted':'tests/artifacts/zhang_tiers_v133_accepted.json','legs':75,'fixtures':2,'checks':7,'views':5,'preceding_turn':'V132_reference_only_no_model_progress;continued_with_triangle_height_evidence_and_actual_tier_edits'}
save('docs/lower_campus_refinement_coverage.json',d)
goal=ROOT/'docs/LOWER_CAMPUS_ACTIVE_GOAL.md';s=goal.read_text(encoding='utf-8')
if '\nV133：' not in s:
    goal.write_text(s+'\n\nV133：旧GLB九条竖向三角面求交确认低侧翼42.590与主楼66.608旧单位，交叉建筑师屋面/三楼图，游戏区分12.2低屋面与23.3主楼（现有层高拟合，非实测）。后核心增一层、低屋面接第三廊并补绿化石路护墙，撤上部悬空长廊；清深处重复服务门墙与孤立无碰撞玻璃片。60段单起点核心/屋面+15段另一单起点入口后路=75分批记录，7检查，5最终图已看，无引擎错误。收尾纯视觉删除复看画面，元数据同步不改生成几何。70×94平面/低屋面转折/种植形状、下层房间和后路仍拟合，下轮先配准再改D院内及C-D路。全A–G、学生下层门位、图书馆后路至逸夫/梯下馆内下层/116/5-6F、ICC及全部背面边角保持，Goal active。详见docs/ZHANG_STEPPED_HEIGHT_V133.md。\n',encoding='utf-8')
print('V133 recorded:75 legs,2fixtures,7checks,5inspected final views;Goal active.')
