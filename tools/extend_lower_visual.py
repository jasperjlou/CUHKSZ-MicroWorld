"""Update the authored district once, retaining the East Gate coordinate frame."""
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
path = root / 'systems/data/campus_visual_build.json'
data = json.loads(path.read_text(encoding='utf-8'))
# Idempotent: keep the original district records and replace this expansion's records.
data['buildings'] = [b for b in data['buildings'] if not b.get('lower_expansion')]
data['landmarks'] = [b for b in data['landmarks'] if not b.get('lower_expansion')]
data['routes'] = [b for b in data['routes'] if not b.get('lower_expansion')]
data['version'] = 'official-visual-build-3-lower-campus'
data['terrain']['bounds'] = [-220, -1120, 245, 100]
data['overview_size'] = 1240

def building(id, name, x, z, width, depth, yaw, model, floors, scene=None):
    data['buildings'].append(dict(id=id, name=name, position=[x, 2.24, z],
        width=width, depth=depth, yaw=yaw, model=model,
        floor_levels=floors, lower_expansion=True,
        evidence={'scene_id':scene, 'placement':'official illustrated map and panorama hotspot adjacency',
                  'scale':'estimated metres', 'storeys':'model estimates; not a verified floor inventory'}))

building('zhang_lingbin', '张岭彬楼（原教学D）', -65,-420,70,45,90,'laboratory',[0,4.8,8.5,12.2,15.9,19.6,23.3],116443796)
building('hl_tu', '涂辉龙楼', -64,-535,78,42,90,'academic',[0,4.6,8.3,12,15.7,19.4,23.1],116443797)
building('lee_yin_yee', '李贤义楼', -120,-530,70,42,90,'academic',[0,4.6,8.3,12,15.7,19.4],116443797)
building('shaw_east', '逸夫书院 · 东座', 80,-540,68,50,-90,'dormitory',[0,4.8,8.1,11.4,14.7,18,21.3,24.6,27.9],116443797)
building('shaw_west', '逸夫书院 · 西座', 145,-640,66,44,-90,'dormitory',[0,4.8,8.1,11.4,14.7,18,21.3,24.6,27.9],116440787)
building('cheng_dao', '诚道楼', -32,-646,50,38,90,'academic',[0,4.6,8.3,12,15.7,19.4],116440774)
building('le_tian', '乐天楼', 46,-652,56,40,-90,'academic',[0,4.6,8.3,12,15.7,19.4,23.1],116846253)
building('zhi_ren', '知仁楼', 57,-734,58,38,-90,'academic',[0,4.6,8.3,12,15.7,19.4],116846254)
building('zhi_xin', '知新楼 · Philip Yu 图书馆', -115,-733,84,52,90,'academic',[0,4.6,8.3,12,15.7,19.4],116440774)
building('dao_yuan', '道远楼', -65,-805,50,48,90,'academic',[0,4.6,8.3,12,15.7,19.4],116440775)
building('research', '科研楼', 91,-845,68,46,-90,'research',[0,5,9,13,17,21,25,29,33,37,41],116443791)
building('sports_hall', '大学体育馆', -10,-890,90,60,0,'sports',[0,5.2,10.4,16],116440784)
building('old_gate', '旧南门', -120,-861,38,8,0,'gate',[0,7.5],116443799)
building('track', '大学田径场', -14,-1018,176,92,0,'track',[0],116443789)
building('west_gate', '西门方向', 0,-1100,36,8,0,'gate',[0,7.5],116443789)

def landmark(id, name, x, z, scene):
    data['landmarks'].append(dict(id=id, name=name, position=[x,2.24,z], scene_id=scene, lower_expansion=True))

for rec in [
    ('sc_td_corridor','学生中心—教学区连廊',0,-444,116443796),
    ('lotus_pond','荷花池',60,-461,116440795),
    ('zhang_entry','张岭彬楼入口',-36,-420,116443796),
    ('shaw_entry','逸夫书院东座',52,-535,116443797),
    ('hl_tu_entry','涂辉龙楼入口',-38,-532,116443797),
    ('le_tian_garden','知仁—乐天花园',40,-695,116846254),
    ('main_square','主广场',0,-735,116440774),
    ('philip_library','Philip Yu 图书馆（知新楼）',-86,-735,116440774),
    ('t_junction','主广场丁字路口',0,-805,116443799),
    ('dao_entry','道远楼入口',-38,-805,116440775),
    ('sports_entry','体育馆入口',0,-853,116440784),
    ('research_entry','科研楼入口',61,-845,116443791),
    ('bell_tower','钟楼方向',43,-846,116443791),
    ('old_south_gate','旧南门',-120,-851,116443799),
    ('track_entry','田径场',-14,-961,116443789),
    ('west_gate_entry','西门方向',0,-1094,116443789)]: landmark(*rec)

def route(id, kind, width, points):
    data['routes'].append(dict(id=id, kind=kind, width=width,
        points=[[x,2.24,z] for x,z in points], lower_expansion=True))

for r in data['routes']:
    if r['id']=='central_axis':
        r['kind']='green';r['width']=10
        r['points']=[[0,2.24,z] for z in [-51,-105,-170,-265,-355,-435,-580]]
for side in [-1,1]:
    route(f'mall_walk_{side}','stone',4.5,[(side*8,-51),(side*8,-435),(side*8,-584)])
    route(f'west_sidewalk_{side}','stone',3,[(side*9,-584),(side*9,-805),(side*9,-848)])
route('main_road','vehicle',9,[(0,-588),(0,-735),(0,-805),(0,-843)])
route('west_crossroad','vehicle',8,[(-174,-805),(0,-805),(47,-805),(61,-832),(61,-845)])
route('research_service','vehicle',6,[(137,-330),(152,-490),(113,-575),(110,-710),(130,-790),(130,-880)])
route('south_perimeter','vehicle',7,[(-174,-180),(-174,-650),(-174,-861),(-150,-920),(-112,-960)])
route('old_gate_access','stone',7,[(0,-851),(-120,-851),(-120,-877)])
route('teaching_d_walk','stone',8,[(0,-420),(-36,-420)])
route('hl_tu_walk','stone',8,[(0,-532),(-38,-532)])
route('shaw_walk','stone',6,[(0,-535),(52,-535)])
route('student_lotus','stone',4,[(35,-400),(35,-430),(60,-434),(60,-480),(35,-500),(35,-535),(52,-535)])
route('main_square_walk','stone',9,[(-86,-735),(0,-735),(35,-735)])
route('garden_walk','stone',4,[(9,-695),(40,-695),(110,-695)])
route('sports_front','stone',18,[(0,-839),(0,-853)])
route('sports_to_track','stone',6,[(0,-840),(65,-840),(65,-929),(-14,-940),(-14,-964)])
route('track_west_walk','stone',5,[(-14,-940),(-112,-940),(-112,-1065),(0,-1094)])
route('track_east_walk','stone',5,[(65,-929),(91,-968),(91,-1065),(0,-1094)])

path.write_text(json.dumps(data, ensure_ascii=False, indent=2)+'\n',encoding='utf-8')
print(f'Lower campus: {len(data["buildings"])} building records, {len(data["routes"])} routes, {len(data["landmarks"])} landmarks')
