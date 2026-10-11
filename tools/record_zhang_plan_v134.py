"""Persist scoped proof for the stepped low wing, not whole-campus completion."""
import json,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text(encoding='utf-8'))
def save(p,d):(ROOT/p).write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
def sha(p):return hashlib.sha256((ROOT/p).read_bytes()).hexdigest()
p=read('tests/artifacts/zhang_plan_v134_physics.json')
assert len(p['physical_legs'])==55 and len(p['checks'])==6 and not p['failures']
assert all(x['valid'] for x in p['physical_legs']+p['checks'])
logs=['zhang-plan-v134-physics.log','zhang-plan-v134-visual.log','zhang-plan-v134-finish-visual.log']
for log in logs:
    assert not any(x.startswith(('ERROR:','SCRIPT ERROR:')) for x in (ROOT/'tests/artifacts'/log).read_text(encoding='utf-8').splitlines())
data=read('systems/data/campus_visual_build.json');b=next(x for x in data['buildings'] if x['id']=='zhang_lingbin')
b['v134_low_wing']={'outline_script':'world/visual_campus/ZhangSteppedWing.gd','source':'references/legacy-gta-20261011/zhang-horizontal-slabs-v134.json','legacy_anchor':[-379,-229],'local_anchor':[-34.3,-24.44],'uniform_scale':.4625,'source_date':'unknown','fit_status':'single fitted rear joint; no global XY or metric registration','retained_front_bridges_local_z':[16.26,39.64],'floor_centres':[4.8,8.5,12.2],'limits':'manual contour picks; roof planting/facade bays/room allocation not surveyed current conditions'}
b['v133_tiers']['low_roof_footprint_superseded_by']='V134 shorter stepped polygon; V133 rectangular roof/route obsolete.'
b['public_layout_status']='V134 stepped low wing and two front bridge doorways; interior room partitions and lower-ground plan remain incomplete; all dimensions fitted.'
save('systems/data/campus_visual_build.json',data)
files=['world/visual_campus/TeachingBlocks.gd','world/visual_campus/ZhangSteppedWing.gd','world/visual_campus/ZhangCourtCore.gd','world/visual_campus/ZhangCourtGround.gd','systems/data/campus_visual_build.json']
save('tests/artifacts/zhang_plan_v134_accepted.json',{'version':data['version'],'physical_legs':55,'fixtures':1,'checks':6,'max_route_error':max(x['distance'] for x in p['physical_legs']),'physics':'zhang_plan_v134_physics.json','logs':logs,'views':['courtyard-refined-zhang-plan-v134-'+s+'.png' for s in ['overview','roof','interior','bridge','notch']],'all_five_effective_views_inspected':True,'after_physics':'Visual frames/fins reversed outward and noncolliding hardscape strip added; .7m seam wall x[-34.3,-33.6] outside route/capsule envelope, floor/door/window colliders unchanged. Four affected views checked; roof view retained.','superseded':'V133 rectangular low-roof loop and former third-level gallery footprint; older evidence remains historical only.','source_sha256':{s:sha(s) for s in files},'limits':'Single local continuous route, not whole building/campus; one fitted horizontal anchor, room plan and actual grade/current-year facade unresolved.'})
outline=[[-379,-229],[-336.5,-229],[-327.5,-212.5],[-334.1,-208.5],[-334.1,-191.9],[-350.3,-191.9],[-350.3,-178.1],[-334.1,-178.1],[-334.1,-141],[-379,-141]]
save('references/visual_build_20261008/zhang_stepped_plan_v134_evidence.json',{'reviewed':'2026-10-11','method':'Horizontal legacy triangle projection and manual boundary picks; not screenshot shadow tracing','legacy_outline':outline,'local_outline':[[-34.3+(x+379)*.4625,-24.44+(z+229)*.4625] for x,z in outline],'source_model_year':'unknown','architect_drawing_revision':'unknown','sources':['references/legacy-gta-20261011/zhang-horizontal-slabs-v134.json','references/visual_build_20261008/originals/massing-plan-20261010/architect-plans/f378f6f2b544179e.jpg','references/visual_build_20261008/originals/massing-plan-20261010/architect-plans/ab093db0e413ed62.jpg'],'inspected_projection_images':['zhang-horizontal-slabs-42-v134.png','zhang-horizontal-slabs-all-v134.png'],'scale_limit':'Uniform0.4625 chosen from retained storey spacing; horizontal equality assumed, not proven by exterior control points.','current_user_photo_scope':'Front arcade/stair anchors retained; photos do not prove new low-wing individual windows/roof planting.'})
d=read('docs/lower_campus_refinement_coverage.json');d.update(updated='2026-10-11',basis_version=data['version'],previous_turn_classification='progress')
d['next_action']='V134 replaces D low return with uniformly fitted ten-corner stepped footprint, three slabs/two occupied shell levels, real notch and front bridge doors;55continuous legs+6checks,5effective views. Next focus D ground/lower courtyard and C-D rear hardscape/grade using separate Ground/First plans, not more roof decoration. Current main-bar aspect/low-room plan and complete XY registration still open. Keep all A-G, student lower door plan, library rear-Shaw/main-stair-under/116/5-6F,ICC and backs/corners;EastGate fixed,north unresolved.'
z=next(x for x in d['zones'] if x['id']=='D');b=next(x for x in z['buildings'] if x['id']=='zhang_lingbin')
b['status']='V134_stepped_low_wing_built_full_ground_and_XY_incomplete'
b['coverage']['side_left']='V134 traced stepped low wing replaces long rectangle;two shell levels/three slabs/roof notch;facade bays still fitted,current-year individual-window review pending.'
b['coverage']['roof']='V134 low roof follows stepped footprint with planted outer strip and guarded recess;V133 rectangular roof retired;roof planting fit.'
b['coverage']['stairs_ramps']='V133 five-flight rear core;V134 first-three flights traversed with new low-wing/photo bridge route,upper flights retained without repeat. Exact floor labels/metric fit unresolved.'
b['coverage']['connections']='V13455 single-start legs and6checks:both low-wing/front-gallery levels,notched roof,core descent/rear exit;V133 old rectangular roof routes retired.'
b['coverage']['ground_or_pilotis']='V131 observed entry;V133 duplicate doorway removed;V134 stone fills under extended low-wing edge. Whole ground/lower-room/landscape plan remains schematic.'
for ev in ['docs/ZHANG_STEPPED_PLAN_V134.md','references/visual_build_20261008/zhang_stepped_plan_v134_evidence.json','tests/artifacts/zhang_plan_v134_accepted.json']:
    if ev not in b['evidence']:b['evidence'].append(ev)
z['stages']['7']='V13455_single-start_legs_6checks_5effective_views;wholeD_fidelity_incomplete'
d['v134_evidence']={'doc':'docs/ZHANG_STEPPED_PLAN_V134.md','accepted':'tests/artifacts/zhang_plan_v134_accepted.json','legs':55,'fixtures':1,'checks':6,'views':5}
save('docs/lower_campus_refinement_coverage.json',d)
goal=ROOT/'docs/LOWER_CAMPUS_ACTIVE_GOAL.md';s=goal.read_text(encoding='utf-8')
if '\nV134：' not in s:
    goal.write_text(s+'\n\nV134：旧GLB水平三角面精确投影后人工拾取低翼十角轮廓，以单后接头/统一0.4625比例拟合，重建较短较宽的三楼板/两层壳体、凹口及屋面护墙，首两层仅保留通向原照片前廊的桥；院下外缘补硬铺。55段单起点连续低翼/前廊/屋面/核心下行后路与6检查通过，5有效图已看。修朝内窗片及后端0.7缝，通行面和门窗碰撞未变、封缝在路径外，仅复看受影响画面，无引擎错误。V133矩形低屋面旧路线退休；单锚比例/主楼平面/房间/现状窗型仍未核实。下一批D地面下层及C-D后路真实铺地标高；全A–G、学生下层门位、图书馆后路至逸夫/梯下馆内下层/116/5-6F、ICC及全部背面边角保持，Goal active。详见docs/ZHANG_STEPPED_PLAN_V134.md。\n',encoding='utf-8')
print('V134 recorded:55 continuous legs,6checks,5effective inspected views;Goal active.')
