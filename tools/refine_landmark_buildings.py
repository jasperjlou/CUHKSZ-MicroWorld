"""Record specific-building profiles without changing the East Gate coordinate frame."""
import json
from pathlib import Path

root=Path(__file__).resolve().parents[1]
path=root/'systems/data/campus_visual_build.json'
data=json.loads(path.read_text(encoding='utf-8'))
profiles={
    'zhang_lingbin':('td_courtyard','staggered teaching wings, screened return and porous ground arcade'),
    'lee_yin_yee':('research_a','pale narrow-window shell, glazed research entry and covered passage'),
    'hl_tu':('research_b','road-facing vertical fins, nameplate, bronze passage screens and external stair'),
    'shaw_east':('shaw_east_court','three residential wings, enclosed courtyard, lower canteen podium and terraces'),
    'shaw_west':('shaw_west_courts','three staggered residential wings, two open courts and sky garden'),
    'cheng_dao':('cheng_dao_classrooms','long plain classroom block, narrow vertical windows, open base and motto panel'),
    'le_tian':('le_tian_entry','long pale window bar, ground glazing, glass canopies and red brick forecourt'),
    'zhi_ren':('zhi_ren_garden','equipment cages, vertical window pairs, sheltered garden court and red brick paths'),
    'zhi_xin':('zhi_xin_ribbons','lower L-shaped ribbon-window wings, library ground glazing and flag forecourt'),
    'dao_yuan':('dao_yuan_portal','parallel white wings, deep coffered entrance canopy, vertical grilles and motto banner'),
    'research':('research_backdoor','round-column cantilever, horizontal louvers, sheltered glazing; tower remains estimated')}
for b in data['buildings']:
    if b['id'] in profiles:
        b['detail_profile'],b['details']=profiles[b['id']]
        b['evidence']['detail_status']='reference-led exterior; unseen footprint, metric scale and storeys remain estimated'
        if b['id'] in ('hl_tu','lee_yin_yee'):b['evidence']['scene_id']=116697227
        if b['id'] in ('cheng_dao','zhi_xin'):
            b['evidence']['photo_source']='https://10.cuhk.edu.cn/en/start-zone'
        if b['id']=='zhi_xin':
            b['name']='知新楼 · 黄宜弘梁凤仪图书馆'
            b['floor_levels']=[0,4.6,8.3,12,15.7]
            b['evidence']['detail_scene_id']=126106538
        if b['id']=='zhang_lingbin':b['evidence']['scene_id']=116697228
        if b['id'].startswith('shaw_'):
            top=34.5 if b['id']=='shaw_east' else 41.1
            b['floor_levels']=[0]+[round(4.8+3.3*i,2) for i in range(round((top-4.8)/3.3)+1)]
            b['evidence']['height_status']='stepped tower heights inferred from panorama window rows; not surveyed storey counts'
data['version']='official-visual-build-5-start-zone-buildings'
data['modified_date']='2026-10-09'
data['routes']=[r for r in data['routes'] if not r.get('landmark_detail')]
for id,width,points in [
    ('research_passage',8,[(-92,-490),(-92,-534),(-92,-578)]),
    ('research_north_approach',4,[(0,-490),(-92,-490)]),
    ('research_south_approach',4,[(8,-584),(-92,-584),(-92,-578)]),
    ('research_stair_approach',4,[(-38,-532),(-25,-532),(-25,-560)]),
    ('shaw_west_approach',4,[(110,-695),(110,-640),(121,-640)]),
    ('research_canopy_access',3,[(9,-845),(9,-849),(91,-849),(91,-845)])]:
    data['routes'].append(dict(id=id,kind='stone',width=width,points=[[x,2.24,z] for x,z in points],landmark_detail=True))
data['landmarks']=[p for p in data['landmarks'] if not p.get('landmark_detail')]
for id,name,x,z in [('research_passage_entry','实验楼A/B廊道',-92,-490),('lee_entry','李贤义楼入口',-95,-532),('shaw_west_entry','逸夫西座院落',121,-640)]:
    data['landmarks'].append(dict(id=id,name=name,position=[x,2.24,z],landmark_detail=True))
path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(f'{len(profiles)} specific profiles, {len(data["routes"])} routes, {len(data["landmarks"])} landmarks; anchors unchanged')
