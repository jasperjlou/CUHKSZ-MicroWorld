"""Accept the reviewed shared room batch, retaining historical-source uncertainty."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text(encoding='utf-8'))
def save(p,d):(ROOT/p).write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
p=read('tests/artifacts/card_bank_v130_physics.json');v=read('tests/artifacts/card_bank_v130_views.json')
assert len(p['physical_legs'])==20 and all(x['valid'] for x in p['physical_legs']) and not p['failures']
assert max(x['distance'] for x in p['physical_legs'])<.1
assert len(p['checks'])==4 and all(x['valid'] for x in p['checks'])
assert len(v['captures'])==4 and not v['failures']
finish=read('tests/artifacts/card_bank_v130_finish.json')
assert len(finish['captures'])==2 and not finish['failures']
logs=['card-bank-v130-final-physics.log','card-bank-v130-final-visual.log','card-bank-v130-upholstery-finish.log']
for name in logs:
    assert not any(s.startswith(('ERROR:','SCRIPT ERROR:')) for s in (ROOT/'tests/artifacts'/name).read_text(encoding='utf-8').splitlines())
save('tests/artifacts/card_bank_v130_accepted.json',{
    'version':p['version'],'physical_legs':20,'fixtures':1,'checks':4,'max_route_error':max(x['distance'] for x in p['physical_legs']),
    'physics_report':'card_bank_v130_physics.json','views':v['captures'],'all_four_final_views_inspected':True,'logs':logs,
    'retired':'Initial outdoor0.8m stopping tolerance turned before clearing open door leaf. Final indoor0.18m arrivals and deeper entrance waypoint pass; door collision not removed.',
    'finish_after_physics':'Rounded seats retain original box colliders; ATM shells turned180deg with symmetric collider; back wall extends0.43m at both ends closing corner seam outside verified paths. Missing upholstery underside cap then closed,2 affected views replaced/reviewed,2 unaffected views retained; physics retained.',
    'source_sha256':{f:hashlib.sha256((ROOT/'world/visual_campus'/f).read_bytes()).hexdigest() for f in ['CampusCardBankInterior.gd','StudentLowerConcourse.gd']},
    'limits':'Historical interior reference, not verified2026 furniture. Dimensions/orientation fitted, whole lower campus incomplete.'})
save('references/visual_build_20261008/card_bank_v130_evidence.json',{
    'reviewed':'2026-10-11',
    'sources':[
        {'url':'https://itso.cuhk.edu.cn/article/339','article_date':'2024-01-06 per ITSO search listing','supports':'Card centre inside CITIC in lower-first-floor between Zhang and StudentCentre; not furniture layout'},
        {'url':'https://campusvr-en.cuhk.edu.cn/?scene_id=41566328','pano_id':25181826,'capture_date':'unknown','visible_year_mark':'2020 New Year decoration in b face','local_manifest':'originals/student-lower-v127/manifest.json','viewed_this_batch':['f','l','r'],'supports':'Shared public room,2 teller windows,waiting row/island,card desks/purple partitions,cabinets','use':'historical structure/interior reference; no festival decoration copied'}],
    'new_neighbor_finding':{'photos':['originals/student-context-v129/commercial-10.jpg','originals/student-context-v129/commercial-11.jpg'],'observation':'Print shop and optician are adjacent; portion of print front visible at left of optician view','limit':'No absolute lower-campus door registration yet'},
    'fitted':['room16x9.7m','bank-card orientation','seat/desk counts and spacing','ceiling heights','current furnishings'],
    'remaining':['up-to-date interior photo','precise overall lower plan','real StudentCentre lower entrance','other commercial fronts and C-D back grade','all A-G and library/ICC scope']})
d=read('docs/lower_campus_refinement_coverage.json')
d['updated']='2026-10-11';d['basis_version']=p['version'];d['previous_turn_classification']='progress'
d['next_action']=('V130 expands card/bank shell to a fitted9.7m public room with teller windows, waiting seats, terminals, white island, purple card stations and cabinet aisle. '
    '20 continuous indoor-tight route legs +4 probes pass;4 final views. Historical panorama has2020 decoration;2024 ITSO verifies shared use only, not current furniture. '
    'Next register print/optics adjacency visible in official photos, Uchiyama skylight/shopfront and actual StudentCentre lower entrance in full lower plan; do not scatter tenants at guessed coordinates. '
    'Then C-D rear road/grades and all A-G. Retain library rear-Shaw/main-stair-under interior/116seam/5-6F, ICC registration/lowerpatterns/soffitseams,all backs/corners; EastGate fixed,north unresolved.')
z=next(x for x in d['zones'] if x['id']=='D');b=next(x for x in z['buildings'] if x['id']=='student_lower_services')
b['status']='V130_shared_card_bank_public_interior_historical_reference_partial'
b['coverage']['public_levels']='V130 shared card/bank public room and retained gift frontage; dated2024 shared-use confirmation, historical panorama furniture only; complete lower plan/tenant map unresolved'
b['coverage']['connections']='V13020 precise continuous interior/concourse legs +4probes;V129 north link andV127 Shaw route retained. Full real-plan correspondence unverified.'
for ev in ['docs/CARD_BANK_SHARED_ROOM_V130.md','references/visual_build_20261008/card_bank_v130_evidence.json','tests/artifacts/card_bank_v130_accepted.json']:
    if ev not in b['evidence']:b['evidence'].append(ev)
z['stages']['7']='V130_20_single-start_indoor_legs_4checks_4finalviews;D_current_fidelity_incomplete'
d['v130_evidence']={'doc':'docs/CARD_BANK_SHARED_ROOM_V130.md','accepted':'tests/artifacts/card_bank_v130_accepted.json','legs':20,'fixtures':1,'checks':4,'views':4}
save('docs/lower_campus_refinement_coverage.json',d)
goal=ROOT/'docs/LOWER_CAMPUS_ACTIVE_GOAL.md';s=goal.read_text(encoding='utf-8')
if '\nV130：' not in s:
    goal.write_text(s+'\n\nV130：按2024校方校园卡说明确认中信共用关系，并以历史25181826内景加深原浅壳至拟合9.7米，补双服务窗、等候座、自助终端、白柜台、紫色办卡席位、柜体/吊顶/分区地面，切原西围墙并补楼板顶板。20段精确到达的单起点连续室内/公共廊路线、4探针通过；初轮室外停止阈值导致未过门扇即转弯的记录作废。4终图已看，无引擎错误；圆角座椅保持原碰撞、终端正面转向室内、后墙角缝收口后只复看画面。全景有2020节庆，家具不声称2026现状，房间朝向/尺寸待配准。新商店图能确认文印与眼镜相邻，但整层门位未定；下一批补其连续关系、内山采光顶/门面和学生中心下层入口，再C-D后路。全A–G、图书馆后车道至逸夫/主梯下馆内下层/116接缝/5-6F、ICC及背面边角不缩减，Goal active。详见docs/CARD_BANK_SHARED_ROOM_V130.md。\n',encoding='utf-8')
print('V130 recorded:20 continuous legs,4probes,4final views;full campus goal remains active.')
