"""v31: source-led lower-campus topology; all metric distances remain fitted."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
p = ROOT / 'systems/data/campus_visual_build.json'
d = json.loads(p.read_text(encoding='utf-8'))
d['version'] = 'official-visual-build-31-lower-corridor'
for b in d['buildings']:
    if b['id'] == 'cheng_dao':
        b['position'], b['yaw'] = [59, 2.24, -666], -90
    elif b['id'] == 'le_tian':
        b['position'] = [108, 2.24, -713]
    else:
        continue
    b['evidence']['placement'] = 'v31: Cheng Dao and Zhi Ren on square-facing side; Le Tian behind, from official May 2026 map and Lower Campus View 2. Metres fitted.'

routes = {r['id']: r for r in d['routes']}
def route(id, points, width, kind='stone'):
    record = routes.get(id)
    if record is None:
        record = {'id': id}
        d['routes'].append(record)
    record.update(points=[[x, 2.24, z] for x, z in points], width=width, kind=kind)

route('main_road', [(48,-583),(25,-600),(9,-617),(0,-636),(0,-735),(0,-805),(0,-843)], 9, 'vehicle')
route('research_service',[(137,-330),(152,-490),(113,-575),(110,-605),(110,-650),(110,-677),(143,-686),(145,-705),(143,-760),(130,-790),(130,-880)],6,'vehicle')
route('student_south_garden',[(30,-400),(30,-428),(30,-476),(42,-502),(42,-571),(24,-601),(9,-632)],8)
route('shaw_walk',[(9,-535),(42,-535),(52,-535)],6)
route('cheng_dao_threshold',[(9,-666),(45.3,-666)],8)
route('le_tian_threshold',[(9,-697),(82,-697),(82,-713),(105.8,-713)],5)
route('garden_walk',[(9,-697),(82,-697),(82,-680),(110,-680),(110,-640),(121,-640)],5)
route('shaw_west_approach',[(42,-575),(61,-597),(92,-605),(110,-620),(110,-640),(121,-640)],5)
route('research_canopy_access',[(9,-805),(28,-811),(43,-837),(54,-845),(68,-849),(91,-849),(91,-845)],5)
route('library_shaw_approach',[(40,-320),(40,-332),(9,-332),(9,-386),(30,-400)],4.5)
route('sports_front',[(0,-839),(0,-853)],18)
route('research_sports_walk',[(61,-845),(55,-853),(0,-853)],7)
for m in d['landmarks']:
    if m['id']=='le_tian_garden':m['position']=[82,2.24,-697]
for id,name,pos in [('cheng_dao_entry','诚道楼前庭',[39,2.24,-666]),('le_tian_entry','乐天楼入口',[97,2.24,-713]),('shaw_square_turn','逸夫—主广场转角',[24,2.24,-601])]:
    if not any(m['id']==id for m in d['landmarks']):
        d['landmarks'].append({'id':id,'name':name,'position':pos,'hide_world_sign':True,'layout_status':'v31 map-based topology, estimated metres'})
d['corridor_revision'] = {
    'sources':['https://www.cuhk.edu.cn/zh-hans/page/4908','https://campusvr-en.cuhk.edu.cn/?scene_id=130027046','https://campusvr-en.cuhk.edu.cn/?scene_id=116443798'],
    'changes':['Cheng Dao moved to mountain side alongside Zhi Ren; Le Tian behind this pair','Bent Shaw-to-square road and connected grey-paved pedestrian frontage','Research service road diverted behind the corrected cluster','Street trees, forecourts and research-to-sports continuous paving'],
    'limits':'Topology cross-checked against official map and panorama. Distances, concealed facades and upper tower massing are estimates.'}
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
