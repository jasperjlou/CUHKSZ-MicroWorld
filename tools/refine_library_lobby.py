"""Record observed G/2F interior details without changing library anchors."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
p=root/'systems/data/campus_visual_build.json'
d=json.loads(p.read_text(encoding='utf-8'))
if d['version']!='official-visual-build-21-administration-hillside':
    raise SystemExit('Expected v21; refuse to overwrite newer metadata')
for r in d['buildings']:
    if r['id']=='library':
        r['lobby_detail']={'sources':['https://campusvr-en.cuhk.edu.cn/?scene_id=41566368','https://campusvr-en.cuhk.edu.cn/?scene_id=41830774'],'observed':['G white-framed glazing, warm grid ceiling, collaboration furniture and pressed-board wall','2F deep seating steps beside a normal stair, dense slatted ceiling and linear lights'],'estimated':['eight seating tiers, fitted dimensions and room layout','existing 2F to 3F stair position retained'],'access':'Normal walking stair and 3F connection retained; broad deep seating bank is intentionally not a walking ramp.'}
d['version']='official-visual-build-22-library-lobby'
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(d['version'],'building anchors and routes unchanged')
