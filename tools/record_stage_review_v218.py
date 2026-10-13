"""Record targeted replacement evidence without treating a failed full run as passed."""
import json, hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
ART=ROOT/'tests/artifacts'
def read(name):return json.loads((ART/name).read_text('utf-8'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
a=read('product_review_v218.json');b=read('product_review_v218_accepted.json');camera=read('stage_camera_v218_physical.json')
assert a['chapter_count']==22 and len(a['failures'])==1
assert all(c['valid'] for c in a['checks']) and not a['camera_overlap_samples'] and a['avatar_visible_frames']==0
assert not b['failures'] and not b['camera_overlaps'] and all(c['valid'] for c in b['checks'])
unchanged=[c for c in a['physical_legs'] if c['chapter']!='library-pool']
assert len(unchanged)==199 and len(b['physical_legs'])==7
assert all(c['valid'] for c in unchanged+b['physical_legs'])
assert all(c['chapter']=='library-pool' for c in b['physical_legs'])
assert len(camera['physical_legs'])==82 and camera['camera_samples']==5520
assert not camera['failures'] and camera['overlap_frames']==camera['blocked_frames']==0
files=['world/product/ShowcaseChapters.gd','world/product/CampusShowcase.gd','systems/data/campus_visual_build.json']
reports=['product_review_v218.json','product_review_v218_accepted.json','stage_camera_v218_physical.json','stage_camera_v218_visual.json','pool_clearance_v218.json']
images=sorted(ART.glob('stage-camera-v218-*.png'));assert len(images)==23
record={'version':'official-visual-build-218-stage-presentation','date':'2026-10-14','valid_with_targeted_replacement':True,'single_uninterrupted_run':False,'chapter_count':22,'effective_physical_legs':206,'source_checks':a['checks'],'physical_legs':unchanged+b['physical_legs'],'player_camera':{'legs':82,'samples':5520,'overlaps':0,'blocked':0},'agent_camera':{'initial_samples_including_failed_pool':a['camera_samples'],'replacement_pool_samples':b['camera_samples'],'overlaps':0},'initial_failure_retained':a['failures'],'replacement':'Only library-pool route changed after the full run; 199 unchanged legs retained, all 7 final pool legs replace its initial 6. Intro/outro composition edits do not change paths or camera positions during physical legs.','visual_review':'21 initial images and 2 composition corrections inspected; still fixtures do not prove uninterrupted playback.','source_sha256':{f:sha(ROOT/f) for f in files},'report_sha256':{f:sha(ART/f) for f in reports},'image_sha256':{f.name:sha(f) for f in images},'scope':'Stage experience only. Geometry fidelity, shared heights, interior fit and whole-campus free-roam remain open. Exported binary acceptance separate.'}
(ROOT/'references/visual_build_20261008/stage_experience_v218.json').write_text(json.dumps(record,ensure_ascii=False,indent=2)+'\n',encoding='utf-8',newline='\n')
print('V218 receipt: 206 effective Agent legs, 82 player legs; 23 reviewed images; full-run failure retained.')
