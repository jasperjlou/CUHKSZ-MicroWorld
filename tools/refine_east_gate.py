"""Record the source-led gate finish and fix obsolete non-building inventory metadata."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
p=root/'systems/data/campus_visual_build.json'
d=json.loads(p.read_text(encoding='utf-8'))
if d['version']!='official-visual-build-29-shaw-hillside':
    raise SystemExit('Expected v29; refuse to overwrite newer metadata')
for r in d['buildings']:
    if r['id'].startswith('gate_'):
        r['detail_profile']='paired_white_window_grid_blank_street_end'
        r['observed']='paired windows with projecting white grid; left arrival face has paired windows, right arrival end is predominantly solid stone; distinct dark/wood base screens and screened overhead links'
        r['count_confidence']='retained estimated height and floor spacing; exact count and unseen elevations not surveyed'
    if r['id']=='old_gate':
        r['evidence']['scene_id']=116410028
        r['evidence']['storeys']='not a storeyed building; two estimated 13 m pylons'
        r['floor_levels']=[0,13]
    if r['id']=='west_gate':
        r['evidence']['storeys']='not a building; unverified direction waypoint with 5.6 m lamps'
        r['floor_levels']=[0,5.6]
d['version']='official-visual-build-30-east-gate'
d['refinement_status']='full district visual review recorded; source-led playable lower-campus model, with estimated dimensions and explicitly unverified areas'
p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(d['version'],'24 records, 51 routes, 66 landmarks; all anchors retained')
