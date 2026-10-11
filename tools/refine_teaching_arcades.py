"""Record the v19 public-arcade reconstruction without changing building anchors."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
p=root/'systems/data/campus_visual_build.json'
d=json.loads(p.read_text(encoding='utf-8'))
if d['version']!='official-visual-build-18-start-zone-streets':
    raise SystemExit('Expected v18; refuse to overwrite newer scene metadata')
for r in d['buildings']:
    if r['id']=='teaching_c':
        r['details']='High public arcade; plain concrete beams, ground glass and clerestory band, suspended bronze fins, gray long-strip floor; open transom entrance and inner corridor'
        r['arcade_height_status']='8.5 m model datum, fitted to existing second-floor level; high/clerestory space observed, exact clear height not measured'
        r['component_storeys']={'oblique_classroom_bar':5,'promenade_end_block':4,'short_road_return':5,'straight_court_return':5,'public_arcade':'high ground space below existing 8.5 m datum'}
        r['sources']=['https://www.cuhk.edu.cn/en/article/2278','https://campusvr-en.cuhk.edu.cn/?scene_id=41566307',r['plan_source']]
    elif r['id']=='teaching_b':
        r['details']='Transparent lobby doors, perforated grid ceiling, exhibits beside the through route, extended internal corridor with open rear exit'
        r['corridor_layout_status']='View-supported lobby depth and corridor character; length, side-room positions and exit fit are inferred'
d['landmarks'].extend([
    {'id':'teaching_c_high_arcade','name':'教学 C 高窗长廊','position':[-47,2.24,-309],'indoor':False,'source':'https://campusvr-en.cuhk.edu.cn/?scene_id=41566307'},
    {'id':'teaching_b_inner_corridor','name':'教学 B 内廊','position':[-68,2.24,-207],'indoor':True,'source':'https://campusvr-en.cuhk.edu.cn/?scene_id=41566303'},
])
d['version']='official-visual-build-19-teaching-arcades'
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(d['version'],len(d['landmarks']),'landmarks; building anchors unchanged')
