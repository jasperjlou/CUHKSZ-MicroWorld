"""Record the differentiated Research A/B envelope and public circulation."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
p=root/'systems/data/campus_visual_build.json'
d=json.loads(p.read_text(encoding='utf-8'))
if d['version']!='official-visual-build-27-shaw-east-detail':
    raise SystemExit('Expected v27; refuse to overwrite newer metadata')
for r in d['buildings']:
    if r['id'] in ['lee_yin_yee','hl_tu']:
        r['public_detail']='plain pale narrow-window shell and glazed public entrance hall' if r['id']=='lee_yin_yee' else 'passage-side ribbon glazing and dark screens; roadside vertical fins, two recessed terraces and suspended bronze screen; public hall'
        r['detail_reference']='https://campusvr-en.cuhk.edu.cn/?scene_id=116697227'
        r['detail_limit']='Exterior motifs observed; footprint, storeys, dimensions, hall depth and terrace layout are fitted. Laboratory rooms and upper inter-building access are not reconstructed.'
for ident,name,position in [('research_a_public_hall','李贤义楼公共门厅',[-120,2.24,-530]),('research_b_public_hall','涂辉龙楼公共门厅',[-64,2.24,-535]),('research_b_front_terrace','涂辉龙楼临路平台',[-44.8,6.965,-559.96])]:
    d['landmarks'].append(dict(id=ident,name=name,position=position,indoor=ident.endswith('hall'),research_detail=True))
d['version']='official-visual-build-28-research-detail'
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(d['version'],len(d['landmarks']),'landmarks; anchors and routes retained')
