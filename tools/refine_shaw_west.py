"""Record the source-backed Shaw West facade and inferred accessible public base."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
p=root/'systems/data/campus_visual_build.json'
d=json.loads(p.read_text(encoding='utf-8'))
if d['version']!='official-visual-build-25-courtyard-enclosure':
    raise SystemExit('Expected v25; refuse to overwrite newer metadata')
for r in d['buildings']:
    if r['id']=='shaw_west':
        r['public_detail']='projecting white window frames; recessed double-height terraces; glass entrance canopy; open court; shared lounge and podium stair'
        r['detail_reference']='https://campusvr-en.cuhk.edu.cn/?scene_id=116440787'
        r['detail_limit']='Facade motifs are reference-backed; retained heights, precise recess positions, lounge layout and stair connection are fitted, not measured. No private-room reconstruction.'
for ident,name,position in [('shaw_west_lounge','逸夫西座公共休憩室',[145,2.24,-617]),('shaw_west_podium','逸夫西座公共平台',[145,7.165,-658])]:
    d['landmarks'].append(dict(id=ident,name=name,position=position,indoor=ident.endswith('lounge'),shaw_detail=True))
d['version']='official-visual-build-26-shaw-west-detail'
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(d['version'],len(d['landmarks']),'landmarks; building anchors and routes retained')
