"""Update the library envelope profile without moving the existing building anchors."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
path=root/'systems/data/campus_visual_build.json'
d=json.loads(path.read_text(encoding='utf-8'))
d.update(version='official-visual-build-10-library-returns',modified_date='2026-10-10')
for b in d['buildings']:
    if b['id']=='library':
        b.update(detail_profile='continuous_curved_metal_shell_with_pond_return',
                 pond_reference='https://campusvr-en.cuhk.edu.cn/?scene_id=116440795',
                 envelope_details=['three recessed horizontal window rows on all return walls','bronze jambs','shallow concave side wall','tall lower fins and recessed glazing','continuous coping and shaped roof return','inset upper gallery'],
                 side_curvature_status='2.8 m recess inferred from panorama; not a surveyed footprint')
path.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Library return envelope recorded; anchors retained')
