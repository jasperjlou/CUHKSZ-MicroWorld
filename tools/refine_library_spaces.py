"""Record reference-led G/2F details and public approaches, retaining all campus anchors."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
path=root/'systems/data/campus_visual_build.json'
data=json.loads(path.read_text(encoding='utf-8'))
data['version']='official-visual-build-6-library-public-spaces'
data['modified_date']='2026-10-09'
for b in data['buildings']:
    if b['id']=='library':
        b['detail_profile']='curved_library_g_2f'
        b['scenes']=[116440792,41566368,41830774,41830772]
        b['public_space_status']='visible features from named G/2F panoramas; room layout, furniture count and annex dimensions inferred'
        b['details']='recessed curved window bays, pool annex, lower shared hall, upper foyer, wide stairs, railings and ceiling lights'
    if b['id'] in ['teaching_a','teaching_b','teaching_c','zhang_lingbin','administration','student_centre','hl_tu','lee_yin_yee']:
        b['base_detail']='continuous hard paving, edge bands and drainage; no grass exposed inside authored arcades'
data['routes']=[r for r in data['routes'] if not r.get('library_detail')]
data['routes'].append(dict(id='library_ground_approach',kind='stone',width=3.4,points=[[38,2.24,-275],[46,2.24,-272],[65,2.24,-272]],library_detail=True))
data['landmarks']=[r for r in data['landmarks'] if not r.get('library_detail')]
for id,name,p in [('library_ground_entry','图书馆G门厅',[65,2.24,-272]),('library_lower_hall','图书馆下层共享空间',[86,2.24,-290]),('library_upper_foyer','图书馆2F平台',[94,6.64,-290])]:
    data['landmarks'].append(dict(id=id,name=name,position=p,library_detail=True,indoor=True,layout_status='inferred'))
path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(f'Library G/2F details: {len(data["routes"])} routes, {len(data["landmarks"])} landmarks; anchors retained')
