"""One-time v18 route correction; building anchors remain unchanged."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
path=root/'systems/data/campus_visual_build.json'
data=json.loads(path.read_text(encoding='utf-8'))
if data['version'] != 'official-visual-build-17-start-zone-public':
    raise SystemExit('Expected v17; refuse to overwrite a newer route dataset')
for route in data['routes']:
    if route['id']=='west_crossroad':
        route['points']=[[-174,2.24,-839],[0,2.24,-839]]
        route['evidence']='Estimated fit below Dao Yuan: former z=-805 segment crossed the building. Exact surveyed alignment unresolved.'
data['routes'].append({'id':'east_crossroad','kind':'vehicle','width':8,'points':[[0,2.24,-805],[47,2.24,-805],[61,2.24,-832],[61,2.24,-845]],'evidence':'Retained eastern part of the former west_crossroad; no building moved.'})
for ident,points,width in [
    ('cheng_dao_threshold',[[-9,2.24,-646],[-18.4,2.24,-646]],7),
    ('le_tian_threshold',[[9,2.24,-652],[43.8,2.24,-652]],8),
    ('zhi_ren_threshold',[[9,2.24,-734],[52,2.24,-734]],8),
    ('zhi_xin_threshold',[[-9,2.24,-735],[-96,2.24,-735]],9),
    ('dao_yuan_threshold',[[-9,2.24,-805],[-47,2.24,-805]],8),
]:
    data['routes'].append({'id':ident,'kind':'stone','width':width,'points':points,'evidence':'Entry connector fitted to retained model, surfaced by StartZoneLandscape; dimensions estimated.'})
data['version']='official-visual-build-18-start-zone-streets'
path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(data['version'],len(data['buildings']),'buildings',len(data['routes']),'routes',len(data['landmarks']),'landmarks')
