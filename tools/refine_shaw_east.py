"""Record Shaw East's distinct grey/louver elevation and public threshold refinement."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
p=root/'systems/data/campus_visual_build.json'
d=json.loads(p.read_text(encoding='utf-8'))
if d['version']!='official-visual-build-26-shaw-west-detail':
    raise SystemExit('Expected v26; refuse to overwrite newer metadata')
for r in d['buildings']:
    if r['id']=='shaw_east':
        r['public_detail']='grey rendered shell; projecting white louver boxes; courtyard-facing galleries; open-door lower public rooms; aligned roof walk and courtyard stair'
        r['detail_reference']='https://campusvr-en.cuhk.edu.cn/?scene_id=116443797'
        r['secondary_reference']='https://shaw.cuhk.edu.cn/page/37'
        r['detail_limit']='Three interconnected wings supported by college source; exterior motifs from road panorama. Height, repeated bays, gallery layout and public room function/plan remain fitted, not surveyed.'
for ident,name,position in [('shaw_east_north_room','逸夫东座右侧休憩室',[64,2.24,-518.24]),('shaw_east_south_room','逸夫东座左侧休憩室',[64,2.24,-561.76]),('shaw_east_public_roof','逸夫东座公共连桥',[62,7.165,-540])]:
    d['landmarks'].append(dict(id=ident,name=name,position=position,indoor=ident.endswith('room'),shaw_detail=True))
d['version']='official-visual-build-27-shaw-east-detail'
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(d['version'],len(d['landmarks']),'landmarks; building anchors and routes retained')
