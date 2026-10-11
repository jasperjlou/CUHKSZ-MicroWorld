"""Record the completed student-centre public-space batch, preserving all campus anchors."""
from pathlib import Path
import json
root=Path(__file__).resolve().parents[1]
p=root/'systems/data/campus_visual_build.json'
d=json.loads(p.read_text(encoding='utf-8'))
d['version']='official-visual-build-16-student-public'
for b in d['buildings']:
    if b['id']=='student_centre':
        b.update(model_storeys=5,detail_profile='five_level_double_court_yellow_canteen_arcades_red_portal_wall_and_complete_upper_galleries',
            observed='completed architect aerial shows double courts and tall portal; official canteen panorama shows yellow mosaic piers, dark tall glazing, beam-column arcade, outdoor tables, suspended fabric and red wall',
            scenes=[116440789,116440795],excluded_evidence={'41803705':'indoor activity scene; not used as exterior evidence'},
            count_confidence='five model storeys follow the existing 0/4.4/8.8/13.2/17.6/22.0 levels; vertical and horizontal dimensions remain estimated',
            details='replaced generic ground-court windows with canteen glazing and real door openings; paired upper galleries and finished roof court rims; matte roofs, fine yellow mosaic, plain soffits and front paving',
            interior_plan='arcade expression based on panorama; two compact dining rooms, door locations, furniture counts and rear hall are inferred within retained anchors')
d['landmarks']=[v for v in d['landmarks'] if not v.get('student_public_detail')]
for ident,name,pos in [('student_dining_pond','学生中心池侧餐厅',[75,2.24,-370]),('student_dining_other','学生中心内院餐厅',[69,2.24,-430]),('student_upper_court','学生中心二层内院廊',[70,6.64,-418])]:
    d['landmarks'].append(dict(id=ident,name=name,position=pos,indoor=True,student_public_detail=True,source='https://campusvr-en.cuhk.edu.cn/?scene_id=116440789'))
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(f'{len(d["buildings"])} buildings, {len(d["routes"])} routes, {len(d["landmarks"])} landmarks; student source record updated')
