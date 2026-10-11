"""Keep per-building evidence and inferred public-space geometry separate from campus anchors."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
path=root/'systems/data/campus_visual_build.json'
data=json.loads(path.read_text(encoding='utf-8'))
data['version']='official-visual-build-8-teaching-public-spaces'
data['modified_date']='2026-10-10'
profiles={
 'teaching_a':('ta_open_gallery_switchback',116443786,'warm narrow-window stone; broad open courtyard gallery; concrete switchback stair; sheltered tables'),
 'teaching_b':('tb_ground_lobby',41566303,'dark ceiling-grid lobby; recessed black entrance frames; freestanding notice boards; school sign'),
 'teaching_c':('tc_screened_glazed_arcade',41566307,'long glass ground-floor frontage; exposed beams; suspended bronze fins; open black entrance doors; services'),
 'zhang_lingbin':('td_closed_service_wing',116697228,'warm slit-window court; enclosed dark side-wing ends and roof; tall ground piers; D public-service entrance')}
for building in data['buildings']:
    if building['id'] in profiles:
        profile,scene,details=profiles[building['id']]
        building.update(detail_profile=profile,details=details,
            public_reference=f'https://campusvr-en.cuhk.edu.cn/?scene_id={scene}',
            public_layout_status='view-supported architectural features; exact dimensions, room plan and connecting upper passages inferred')
data['landmarks']=[p for p in data['landmarks'] if not p.get('teaching_detail')]
for ident,name,pos in [('ta_upper_gallery','教学A内院上层回廊',[-52,10.865,-106.92]),
                       ('tb_lobby','教学B入口门厅',[-47.5,2.24,-207]),
                       ('tc_glazed_arcade','教学C玻璃柱廊',[-48,2.24,-325])]:
    data['landmarks'].append(dict(id=ident,name=name,position=pos,teaching_detail=True,indoor=True))
path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(f'Teaching profiles recorded; {len(data["landmarks"])} places; building anchors retained')
