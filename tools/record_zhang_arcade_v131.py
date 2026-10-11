"""Record inspected source-led arcade work without claiming the full campus complete."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text(encoding='utf-8'))
def save(p,d):(ROOT/p).write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
def sha(p):return hashlib.sha256((ROOT/p).read_bytes()).hexdigest()
p=read('tests/artifacts/zhang_arcade_v131_physics.json')
v=read('tests/artifacts/zhang_arcade_v131_views.json')
f=read('tests/artifacts/zhang_arcade_v131_finish.json')
assert len(p['physical_legs'])==23 and all(x['valid'] for x in p['physical_legs']) and not p['failures']
assert len(p['checks'])==5 and all(x['valid'] for x in p['checks'])
assert len(v['captures'])==4 and len(f['captures'])==3 and not v['failures'] and not f['failures']
logs=['zhang-arcade-v131-physics.log','zhang-arcade-v131-visual.log','zhang-arcade-v131-soffit-finish.log']
for log in logs:
    assert not any(line.startswith(('ERROR:','SCRIPT ERROR:')) for line in (ROOT/'tests/artifacts'/log).read_text(encoding='utf-8').splitlines())
views=sorted(set(v['captures']+f['captures']))
files=['world/visual_campus/ZhangEntranceArcade.gd','world/visual_campus/ZhangPhotoFront.gd','world/visual_campus/PhotoMallGround.gd','systems/data/campus_visual_build.json']
save('tests/artifacts/zhang_arcade_v131_accepted.json',{
    'version':p['version'],'physical_legs':23,'fixtures':1,'checks':5,'max_route_error':max(x['distance'] for x in p['physical_legs']),
    'physics':'zhang_arcade_v131_physics.json','views':views,'all_five_final_views_inspected':True,'logs':logs,
    'after_physics':'Decorative stone clipped at arcade intersections, no floor or door collision changed. Service wall/header tops extended6cm above all tested walking envelopes and non-colliding soffit infill closes the horizontal facade/gallery slit; lower wall and upper gallery contacts unchanged. Reviewed3 affected final views, retained door/recess views.',
    'source_sha256':{s:sha(s) for s in files},
    'limits':'Local frontage/recess and retained stair route only. Exact metric placement, deep corridor, whole lower/first-floor registration and all-campus fidelity incomplete.'})
base='references/visual_build_20261008/originals/teaching-lower-v131/'
save('references/visual_build_20261008/zhang_arcade_v131_evidence.json',{
    'reviewed':'2026-10-11','version':p['version'],
    'sources':[
        {'url':'https://campusvr-en.cuhk.edu.cn/?scene_id=116697228','pano_id':70215342,'identity':'references/vr/scene_catalog.json','capture_date':'unknown','manifest':base+'panorama-manifest.json','viewed':['f','l','r','b'],'supports':'wood-look apron, pale service wall/doors, double glass entry with transom, dark ceiling, glazed wing and exterior stair','not_copied':'historical SSE sign and temporary posters'},
        {'file':'references/user/photos-20261010/previews/20261010_222257.jpg','device_date':'2026-10-10, clock not independently verified','supports':'current Zhang name, utility wall, warm strip floor, grey outer stone/drain/lawn separation, stair and bronze screen'},
        {'url':'https://www.gooood.cn/chinese-university-of-hong-kong-shenzhen-china-by-rocco-design-architects.htm','published':'2020-02-03','provider':'Rocco Design Architects + Wang Weijen Architecture + Gravity Partnership','drawing_revision_date':'unknown','project_year_label':'2012-2018','images':[{'file':base+name,'sha256':sha(base+name)} for name in ['lower-ground-plan.jpg','first-floor-plan.jpg']],'finding':'Lower ground and first floor have different outlines, courts and landscape; design group labels must not be directly mapped to current TeachingA/B/C/D names. Need registration before courtyard/rear-grade reconstruction.'}],
    'implemented':['continuous wood-look arcade and stone exclusion','solid utility wall/current name','collidable open double door and glazed transom','short fitted public entry recess','right glass and clerestory bands'],
    'fitted':['door coordinate and widths','utility door allocation','5.54m recess depth','material module/color under daylight'],
    'not_implemented':['deep photographed corridor and room plan','court lawn/elevation edits from newly found lower-ground plan','whole D rear registration','shopfront tenant placement','all A-G remaining work']})
d=read('docs/lower_campus_refinement_coverage.json')
d.update(updated='2026-10-11',basis_version=p['version'],previous_turn_classification='progress')
d['next_action']=('V131 corrects Zhang front apron to wood-look strips, service wall/doors, real double entry/transom, short dark recess and glazed wing;23 continuous local legs+5checks,5final views. '
    'New2020 architect lower-ground/first-floor drawings differ and use historical design-group names; register them against retainedB/C/D court/front anchors before changing lower volumes/lawns/grade. '
    'Prioritize D full lower/court/rear envelope and C-D rear route; existing deeper generic service doorway and entry corridor remain schematic. '
    'Keep student lower full tenant/door plan, library rear-Shaw/main-stair-under interior/116seam/5-6F,ICC registration/soffits,all A-G backs/corners. EastGate fixed,north unresolved.')
z=next(z for z in d['zones'] if z['id']=='D');b=next(b for b in z['buildings'] if b['id']=='zhang_lingbin')
b['status']='V131_observed_front_arcade_and_entry_built_full_lower_plan_incomplete'
b['coverage']['front']='V131 corrected solid utility wall, current Zhang name, double doorway/transom and right glass;V85 fins/galleries retained;metric fit'
b['coverage']['ground_or_pilotis']='V131 observed wood-look apron and stone exclusion;short5.54m public entry recess. Interior long corridor and lower/first-floor courtyard map registration incomplete.'
b['coverage']['connections']='V13123 single-start local front/recess/retained exterior-stair legs +5probes;V125 rear-core/gallery retained,not retested. True rear-grade plan unresolved.'
for ev in ['docs/ZHANG_OBSERVED_ARCADE_V131.md','references/visual_build_20261008/zhang_arcade_v131_evidence.json','tests/artifacts/zhang_arcade_v131_accepted.json']:
    if ev not in b['evidence']:b['evidence'].append(ev)
z['stages']['7']='V13123_single-start_front-recess-stair_legs_5probes_5finalviews;wholeD_fidelity_incomplete'
d['v131_evidence']={'doc':'docs/ZHANG_OBSERVED_ARCADE_V131.md','accepted':'tests/artifacts/zhang_arcade_v131_accepted.json','legs':23,'fixtures':1,'checks':5,'views':5,'preceding_asset_review':'no model progress;revalidated safe next action via official panorama and user photo'}
save('docs/lower_campus_refinement_coverage.json',d)
goal=ROOT/'docs/LOWER_CAMPUS_ACTIVE_GOAL.md';s=goal.read_text(encoding='utf-8')
if '\nV131：' not in s:
    goal.write_text(s+'\n\nV131：新核对官方张岭彬楼70215342四面和用户20261010_222257夜景，修暖色长条木纹前廊、浅色设备墙/门、真实双开入口/高侧窗及短暗色入口凹段、右侧玻璃分区；通用石铺与端部接路裁出木纹廊，墙顶6cm亮缝收口。23段单起点连续门廊/内侧公共空间/外梯往返、5探针一次通过，5最终图已看，无引擎错误；收尾未改通行面/门扇，墙顶延伸在已检路线净空之外，仅复看受影响画面。新2020发布建筑师下首层/首层图轮廓不同且旧组团标签不能直接当现楼名，未强套来改院内高差或草坪。下一批优先配准两层与B/C/D，修D下层/院内/后路、深处长廊及旧示意门，再C-D接头；商店真实门位、全A–G、图书馆后路至逸夫/梯下馆内下层/116/5-6F、ICC和背面边角全部保持，Goal active。详见docs/ZHANG_OBSERVED_ARCADE_V131.md。\n',encoding='utf-8')
print('V131 recorded:23 continuous legs,5probes,5final inspected views;full Goal active.')
