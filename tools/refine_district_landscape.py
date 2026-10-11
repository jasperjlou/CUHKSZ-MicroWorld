"""Record district-scale visual integration without changing physical layout."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
p=root/'systems/data/campus_visual_build.json'
d=json.loads(p.read_text(encoding='utf-8'))
if d['version']!='official-visual-build-23-teaching-a-entry':
    raise SystemExit('Expected v23; refuse to overwrite newer metadata')
d['terrain']['visual_forest']={'source':'https://wwjarch.com/Central-Courtyard-of-Chinese-University-of-Hong-Kong-SZ','implementation':'CampusForest.gd; lobed low-detail crowns in spatial batches behind existing campus footprints','status':'approximate canopy massing, not surveyed tree positions or species','physical_collision':False}
d['surface_integration']={'grass_route_lift':0.012,'paved_route_lift':0.035,'reason':'Remove coplanar grass/paving overlap at crossing paths; physical terrain unchanged.'}
d['version']='official-visual-build-24-district-landscape'
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(d['version'],'24 groups /',len(d['routes']),'routes /',len(d['landmarks']),'landmarks')
