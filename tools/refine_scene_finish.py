"""Record the district-wide visual finish independently of surveyed campus geometry."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
path=root/'systems/data/campus_visual_build.json'
d=json.loads(path.read_text(encoding='utf-8'))
d.update(version='official-visual-build-11-vegetation-and-daylight',modified_date='2026-10-10')
d['visual_finish']={
    'vegetation':'branched trunks, geometric leaf sprays and clipped shrub beds; 48 m spatial batches',
    'lighting':'neutral daylight with stronger sky fill, restrained direct sun and matte library roof',
    'backdrop':'non-colliding visual ground apron and eastern grove; not a mapped campus extension',
    'geography_status':'existing building anchors, routes, ground collision and East Gate origin retained',
    'primary_references':['https://campusvr-en.cuhk.edu.cn/?scene_id=116410029','https://campusvr-en.cuhk.edu.cn/?scene_id=116440795'],
    'limits':'tree forms are procedural visual approximations; species and exact planting positions not surveyed'}
path.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('v11 visual finish recorded; 24 building groups and 44 routes retained')
