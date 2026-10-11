"""Record the fitted rear bench without changing campus anchors or road coordinates."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
p=root/'systems/data/campus_visual_build.json'
d=json.loads(p.read_text(encoding='utf-8'))
if d['version']!='official-visual-build-28-research-detail':
    raise SystemExit('Expected v28; refuse to overwrite newer metadata')
d['terrain']['shaw_west_grade']={
    'bounds':[145,-700,215,-580],
    'flat_bench_height':2.24,'retaining_x':175.7,'retaining_height':1.8,
    'reference':'https://campusvr-en.cuhk.edu.cn/?scene_id=116440787',
    'measurement_status':'Fitted ground around retained buildings; exact contours, retaining location and dimensions are inferred, not surveyed.'}
d['landmarks'].append(dict(id='shaw_west_rear_walk',name='逸夫西座山侧步道',position=[170.5,2.24,-640],indoor=False))
d['version']='official-visual-build-29-shaw-hillside'
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(d['version'],len(d['landmarks']),'landmarks; all building anchors and 51 existing routes retained')
