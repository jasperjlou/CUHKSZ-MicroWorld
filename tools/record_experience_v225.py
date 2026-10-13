"""Record reviewed V225 evidence, preserving the original Agent failure and scoped replacement."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / 'tests/artifacts'
def read(p): return json.loads(p.read_text(encoding='utf-8'))
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
old = read(ROOT / 'references/visual_build_20261008/stage_experience_v218.json')
player = read(ART / 'student_stage_camera_v225_physical.json')
agent = read(ART / 'student_stage_agent_v225.json')
intro = read(ART / 'student_stage_finish_v225_visual.json')
framing = read(ART / 'student_stage_framing_v225.json')
assert not player['failures'] and len(player['physical_legs']) == 96
assert player['camera_samples'] == 5042 and not player['bad_samples']
assert len(agent['physical_legs']) == 83 and all(x['valid'] for x in agent['physical_legs'])
assert agent['failures'] == ['Agent camera volumes clear including intros']
assert len(agent['camera_overlaps']) == 1
assert agent['camera_overlaps'][0]['phase'] == 'intro' and agent['camera_overlaps'][0]['eye'] == '(0.0, 0.0, 0.0)'
assert not intro['failures'] and intro['intro_first_frames'] == 26 and not intro['overlaps']
assert not framing['failures'] and framing['overlaps'] == 0 and framing['intro_samples'] == 301
kept = [x for x in old['physical_legs'] if x['chapter'] not in agent['chapters']]
assert len(kept) == 177
legs = kept + agent['physical_legs']
assert len(legs) == 260 and len({x['chapter'] for x in legs}) == 26
reports = ['student_stage_camera_v225_physical.json','student_stage_agent_v225.json',
           'student_stage_camera_v225_visual.json','student_stage_finish_v225_visual.json','student_stage_framing_v225.json']
images = sorted(ART.glob('student-stage-camera-v225-*.png')) + sorted(ART.glob('student-stage-finish-v225-*.png')) + sorted(ART.glob('student-stage-framing-v225-*.png'))
assert len(images) == 21
sources = list((ROOT/'world/product').glob('*.gd')) + list((ROOT/'world/visual_campus').glob('*.gd'))
sources += [ROOT/'player/CampusPlayer.gd',ROOT/'systems/data/campus_visual_build.json',ROOT/'world/visual_campus/CampusSurface.gdshader']
receipt = {
    'version':'official-visual-build-225-student-stage-experience','date':'2026-10-14',
    'valid_with_targeted_replacement':True,'single_uninterrupted_run':False,
    'chapter_count':26,'effective_physical_legs':260,'physical_legs':legs,
    'retained_v218_legs':177,'current_v225_legs':83,
    'player_camera':player,'initial_agent_report':agent,'intro_replacement':intro,'final_framing':framing,
    'source_checks':intro['checks']+framing['checks'],
    'visual_review':'21 images reviewed; initial Serenity views superseded by final framing; rooms HUD initial wall-facing frame superseded. Static images do not prove continuous movement.',
    'source_sha256':{p.relative_to(ROOT).as_posix():sha(p) for p in sources},
    'report_sha256':{name:sha(ART/name) for name in reports},
    'image_sha256':{p.name:sha(p) for p in images},
    'scope':'V219-V224 student interior geometry, V225 showcase/HUD. 20 unchanged chapters retain177 V218 legs; six chapters83 legs with failed origin intro replaced by all26-intro audit, then Serenity framing-only audit. Not an uninterrupted260-leg run or whole-campus fidelity acceptance.',
    'remaining':'301 skylight remains capped; west-door datum,032 lower rooms,1F front stairs/bar,library2F hidden vestibule,C-D datum and full A-G backlog remain open.'
}
(ROOT/'references/visual_build_20261008/stage_experience_v225.json').write_text(json.dumps(receipt,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('V225:96 player legs;83 current+177 retained Agent legs;26 intros and final framing;21 reviewed images.')
