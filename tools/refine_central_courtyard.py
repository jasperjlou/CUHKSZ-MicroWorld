"""Reference-linked district geometry metadata; preserve every existing building anchor."""
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
path = root / 'systems/data/campus_visual_build.json'
data = json.loads(path.read_text(encoding='utf-8'))
data['version'] = 'official-visual-build-7-central-courtyard'
data['modified_date'] = '2026-10-10'
data['refinement_status'] = 'active: lower-campus modelling; this milestone is not district completion'
source = 'https://wwjarch.com/Central-Courtyard-of-Chinese-University-of-Hong-Kong-SZ'
for record in data['buildings']:
    if record['id'] == 'student_centre':
        record.update(detail_profile='student_double_courtyard', floor_levels=[0,4.4,8.8,13.2,17.6,22.0],
                      details='gray-white recessed vertical windows; double-height portal; two roof courts; terracotta/yellow inner elevations; public upper gallery',
                      sources=[source,'https://campusvr-en.cuhk.edu.cn/?scene_id=116440789'])
    elif record['id'] == 'library':
        record.update(detail_profile='curved_library_continuous_envelope',
                      details='continuous concave panel shell; bronze recessed jambs; shaped roof and roof lantern; G and 2F public rooms; upper gallery connection', sources=[source])
    elif record['id'] == 'administration':
        record.update(detail_profile='admin_white_wings_glass_bridge',
                      details='two white vertical-panel wings; dark open base; projecting glass-bridge fins; central two-flight staircase',
                      sources=['https://campusvr-en.cuhk.edu.cn/?scene_id=116440794'])
    if record['id'] in ['student_centre','library','administration']:
        record['measurement_status'] = 'visible form supported; metric dimensions, hidden elevations and connective floor plan remain inferred'
data['public_spaces'] = [s for s in data.get('public_spaces',[]) if s.get('id') != 'student_sunken_court']
data['public_spaces'].append(dict(id='student_sunken_court', bounds=[12,-380,48,-338], lower_level=-1.76,
    ground_level=2.24, source=source, features=['retaining walls','north walking stair','stepped seating','west ramp','lower arcade','upper covered walk'],
    position_status='fitted between existing anchors; not a surveyed georeference'))
data['landmarks'] = [p for p in data['landmarks'] if not p.get('courtyard_detail')]
for ident,name,p in [('sunken_court_entry','中庭台阶入口',[32,2.24,-334]),
                     ('sunken_lower_court','下沉中庭',[38,-1.76,-360]),
                     ('student_upper_gallery','学生中心二层连廊',[78,6.64,-382]),
                     ('administration_upper_stair','行政楼后侧平台',[95,11.04,-180])]:
    data['landmarks'].append(dict(id=ident,name=name,position=p,courtyard_detail=True,indoor=True))
data['routes'] = [p for p in data['routes'] if not p.get('courtyard_detail')]
data['routes'].append(dict(id='student_forecourt_approach',kind='stone',width=6,
                          points=[[0,2.24,-400],[37,2.24,-400],[45,2.24,-400]],courtyard_detail=True))
path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(f'{len(data["buildings"])} groups / {len(data["routes"])} routes / {len(data["landmarks"])} landmarks; refinement active')
