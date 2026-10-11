"""Record the source-based TA arcade rebuild; preserve campus anchors."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
p=root/'systems/data/campus_visual_build.json'
d=json.loads(p.read_text(encoding='utf-8'))
if d['version']!='official-visual-build-22-library-lobby':
    raise SystemExit('Expected v22; refuse to overwrite newer metadata')
for r in d['buildings']:
    if r['id']=='teaching_a':
        r['entry_refinement']={'sources':['https://campusvr-en.cuhk.edu.cn/?scene_id=116440778','https://campusvr-en.cuhk.edu.cn/?scene_id=116443786'],'observed':['tall concrete beam-and-column arcade','warm wall with horizontal clerestories above dark fins','tall glazed entry and inner SME corridor','suspended outside fins and braces'],'fitted_datum':8.5,'retained_lower_gallery_datum':4.8,'limits':'Arcade height, clerestory grouping, frame dimensions and corridor depth are fitted, not surveyed. Lower stair and upper courtyard routes retained.'}
d['version']='official-visual-build-23-teaching-a-entry'
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(d['version'],'anchors, routes and landmarks retained')
