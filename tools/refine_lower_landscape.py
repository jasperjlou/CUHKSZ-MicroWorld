"""Record photo-supported site relationships while retaining all building anchors."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
path=root/'systems/data/campus_visual_build.json'
d=json.loads(path.read_text(encoding='utf-8'))
d['version']='official-visual-build-9-pond-and-south-gate'
d['modified_date']='2026-10-10'
for p in d['landmarks']:
    if p['id']=='lotus_pond':
        p.update(position=[122,2.24,-350],name='荷花池 · 图书馆与学生中心之间',hide_world_sign=True,
                 source='https://campusvr-en.cuhk.edu.cn/?scene_id=116440795',
                 position_status='relationship corrected from architect aerial; metres inferred')
    if p['id']=='south_gate':p.update(position=[-158,2.24,-167],hide_world_sign=True)
if not any(p['id']=='south_gate' for p in d['landmarks']):
    d['landmarks'].append(dict(id='south_gate',name='南门 · 教学A/B之间',position=[-158,2.24,-167],
        source='https://campusvr-en.cuhk.edu.cn/?scene_id=116410029'))
d['routes']=[r for r in d['routes'] if not r.get('site_detail')]
for r in d['routes']:
    if r['id']=='student_lotus':
        r['id']='student_south_garden'
        r['note']='Former detached pool replaced by planting; actual lotus pond is between library and student centre.'
for ident,width,points in [
    ('south_gate_avenue',12,[[-143,2.24,-167],[0,2.24,-167]]),
    ('south_gate_pedestrian',4,[[-181,2.24,-178],[-151,2.24,-178],[-143,2.24,-167]]),
    ('lotus_east_bank',4,[[130,2.24,-380],[123,2.24,-373],[123,2.24,-332],[114,2.24,-332]])]:
    d['routes'].append(dict(id=ident,kind='stone',width=width,points=points,site_detail=True))
d['public_spaces']=[p for p in d.get('public_spaces',[]) if not p.get('site_detail')]
d['public_spaces'] += [
 dict(id='lotus_pond',bounds=[65,-363,116,-337],water_level=1.98,bed_level=1.60,site_detail=True,
      source='https://wwjarch.com/Central-Courtyard-of-Chinese-University-of-Hong-Kong-SZ',
      features=['pond between student centre and university library','curved paved quay','notched lily pads','white end screen','waterside seating'],
      position_status='relative relationship verified in aerial and panorama; numerical footprint and water depth inferred'),
 dict(id='south_gate',position=[-158,2.24,-167],site_detail=True,
      source='https://campusvr-en.cuhk.edu.cn/?scene_id=116410029',
      features=['low university name wall','flanking gatehouse','tree-lined entrance avenue','pedestrian side opening'],
      position_status='between Teaching A and B per official map; dimensions fitted to current anchors')]
path.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(f'v9: {len(d["buildings"])} building groups, {len(d["routes"])} routes, {len(d["landmarks"])} landmarks')
