"""Record v20 public-base and frontage changes; preserve all anchors and routes."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
p=root/'systems/data/campus_visual_build.json'
d=json.loads(p.read_text(encoding='utf-8'))
if d['version']!='official-visual-build-19-teaching-arcades':
    raise SystemExit('Expected v19; refuse to overwrite newer model metadata')
for r in d['buildings']:
    if r['id']=='administration':
        r['frontage_detail']='White upper fin field separated from a warm lower window strip; smooth white low-wing panels; recessed ground glazing, framed entry doors and shaded public lobbies'
        r['public_layout_status']='Ground recesses and facade hierarchy observed in 116440794; lobby dimensions, room enclosure and furnishings inferred, not an administrative-office floor plan'
        r['site_detail']='Continuous stone forecourt, dark meander pavement bands, separate flower troughs, low planting and supported trees; rear terrace planting and horizontal screen from 116443793'
        r['remaining_site_limit']='Rear platform to hillside grade connection still approximate; no surveyed slope model'
d['version']='official-visual-build-20-administration-public'
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(d['version'],len(d['buildings']),'buildings',len(d['routes']),'routes',len(d['landmarks']),'landmarks')
