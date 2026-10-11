"""Add the fitted back-slope walking link without moving any building anchor."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
p=root/'systems/data/campus_visual_build.json'
d=json.loads(p.read_text(encoding='utf-8'))
if d['version']!='official-visual-build-20-administration-public':
    raise SystemExit('Expected v20; refuse to overwrite newer terrain metadata')
d['terrain']['admin_hillside']={'status':'estimated continuous grade, not surveyed','bounds':[99,-242,190,-118],'terrace_elevation':14.64,'sources':['https://campusvr-en.cuhk.edu.cn/?scene_id=116443781','https://campusvr-en.cuhk.edu.cn/?scene_id=116443793']}
d['routes'].append({'id':'admin_hill_walk','kind':'stone','width':3.8,'points':[[117,14.64,-180],[137,14.64,-180],[137,14.64,-200]],'evidence':'Fitted terrace-to-service-road connection; retained terrace and road anchors. Exact real-world walk alignment unverified.'})
for route in d['routes']:
    if route['id']=='library_service':
        route['points'][0][1]=14.64
        route['grade_note']='Initial segment now follows the continuous admin back-slope, descending to retained lower ground by z=-242.'
for r in d['buildings']:
    if r['id']=='administration':r['remaining_site_limit']='Rear grade now continuous and walkable to the service road; exact contour elevations and landscape plan remain estimated.'
d['version']='official-visual-build-21-administration-hillside'
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(d['version'],len(d['routes']),'routes; all building anchors retained')
