"""Record this local source/model batch; preserve all existing coverage entries."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def save(relative, value):
    (ROOT / relative).write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

save('references/visual_build_20261008/student_lower_v126_evidence.json', {
    'reviewed': '2026-10-11',
    'sources': [
        {'url': 'https://itso.cuhk.edu.cn/page/316', 'publication_date': 'unknown',
         'supports': 'D/Student Centre lower-first-floor service centre beside gift shop; shared CITIC office'},
        {'url': 'https://campusvr-en.cuhk.edu.cn/?scene_id=41803700', 'pano_id': 25308214,
         'capture_date': 'unknown', 'manifest': 'references/visual_build_20261008/originals/zhang-lower-v126/manifest.json',
         'assembly': 'Five native 768x768 cube faces viewed; artificial black margins removed'},
        {'file': 'references/user/photos-20261010/previews/20261010_222313.jpg',
         'device_capture_date': '2026-10-10', 'clock_independently_verified': False,
         'supports': 'Upper link sign points downstairs to gift shop; not a dimensioned plan'}],
    'implemented': 'Shop/card frontage, lower slab/beam hall, two stair apertures and rectangular stone',
    'placement': 'Fitted East Gate frame, X[-26,34],Z[-467,-407],Y[-1.76,2.24]; north uncalibrated',
    'unresolved': ['full lower-plan registration', 'research-facing open lane', 'bank frontage',
                   'actual Student Centre lower entry', 'northern sunken courtyard relationship', 'lighting'],
    'preceding_goal_turn': 'no_progress: existing legacy extraction reconfirmed only; construction resumed this turn'
})

path = ROOT / 'docs/lower_campus_refinement_coverage.json'
d = json.loads(path.read_text(encoding='utf-8'))
d['basis_version'] = 'official-visual-build-126-student-lower-concourse'
d['previous_turn_classification'] = 'progress'
d['updated'] = '2026-10-11'
d['next_action'] = ('V126 adds missing D/Student Centre lower gift/card concourse, gray stone/white beams/two stair apertures. '
    '30 continuous local legs pass from one start. Next register full lower plan, research-facing open lane, bank frontage '
    'and true StudentCentre lower interface; reconcile northern sunken court, then C-D rear real grade and all A-G. '
    'Keep library rear-to-Shaw/main-stair-under interior/116seam/5-6F, ICC exact registration/bright patterns/soffit seams, '
    'all backs/corners. Coordinates fitted, East Gate origin retained, true north uncalibrated.')
zone = next(z for z in d['zones'] if z['id'] == 'D')
if not any(b['id'] == 'student_lower_services' for b in zone['buildings']):
    zone['buildings'].append({
        'id': 'student_lower_services', 'name': '张岭彬楼与学生中心之间下首层服务区',
        'status': 'V126_structure_built_metric_fit_partial', 'anchor': [-21,-1.76,-443],
        'coverage': {'front': 'gift horizontal fins/glazed doorway and card frontage built',
            'rear': 'not_registered', 'side_left': 'research open lane pending; temporary retaining boundary',
            'side_right': 'true StudentCentre lower door unregistered',
            'ground_or_pilotis': 'gray stone and coffer beams/columns built',
            'basement_or_sunken_presence': 'official text + entrance panorama confirmed lower-first-floor services',
            'stairs_ramps': 'two fitted stairs and terrain/slab holes; local up/down passed; actual ramp pending',
            'connections': 'local upper-lower loop only; full open continuation and northern courtyard unresolved',
            'corners_drains_retaining_edges': 'local drains/planted edge; real site extents unregistered'},
        'evidence': ['docs/STUDENT_LOWER_CONCOURSE_V126.md',
                     'references/visual_build_20261008/student_lower_v126_evidence.json',
                     'tests/artifacts/student_lower_v126_physics.json']})
for building in zone['buildings']:
    if building['id'] in ['student_centre','zhang_lingbin']:
        building['coverage']['basement_or_sunken_presence'] = (
            'V126 shared lower services confirmed between buildings; see student_lower_services; internal basements not inferred')
zone['stages']['7'] = 'V126_30_single-start_local_service_loop;wholeD_fidelity_incomplete'
d['v126_evidence'] = {'doc': 'docs/STUDENT_LOWER_CONCOURSE_V126.md',
    'source': 'references/visual_build_20261008/student_lower_v126_evidence.json',
    'physics': 'tests/artifacts/student_lower_v126_physics.json',
    'accepted': 'tests/artifacts/student_lower_v126_accepted.json',
    'preceding_goal_turn_audit': 'no_progress: legacy extraction reconfirmed only; actual modeling resumed V126'}
save('docs/lower_campus_refinement_coverage.json', d)

path = ROOT / 'docs/LOWER_CAMPUS_ACTIVE_GOAL.md'
text = path.read_text(encoding='utf-8')
if '\nV126：' not in text:
    path.write_text(text + '\n\nV126：校方ITSO说明、入口全景25308214和用户下楼标志照片支持D/学生中心之间下首层服务廊。已建商店/校园卡门面、灰石地、白梁柱和两处楼梯洞口；30段单起点连续闭环一次通过。后续画面修掉旧铺地盖洞口、悬空树木/长椅与店招遮挡。尺度及位置拟合，科研方向开放长廊、银行侧、学生中心实际下层入口、北侧庭院关系未完；先继续配准这些接口，再C/D后路真实地形和全A–G。图书馆后路至逸夫/主梯下馆内下层/116亮缝/5-6F、ICC与背面边角全部保留。上轮仅复核旧资产为no_progress，本批恢复实际模型progress。详见docs/STUDENT_LOWER_CONCOURSE_V126.md，Goal active。\n', encoding='utf-8')

physics = json.loads((ROOT / 'tests/artifacts/student_lower_v126_physics.json').read_text(encoding='utf-8'))
assert not physics['failures'] and len(physics['physical_legs']) == 30
assert all(leg['valid'] for leg in physics['physical_legs'])
logs = ['student-lower-v126-physics.log', 'student-lower-v126-final-visual.log',
        'student-lower-v126-finish.log', 'student-lower-v126-south.log']
for name in logs:
    lines = (ROOT / 'tests/artifacts' / name).read_text(encoding='utf-8').splitlines()
    assert not any(line.startswith(('ERROR:', 'SCRIPT ERROR:')) for line in lines), name
save('tests/artifacts/student_lower_v126_accepted.json', {
    'version': d['basis_version'], 'physics': 'student_lower_v126_physics.json', 'legs': 30, 'fixtures': 1,
    'final_views': ['courtyard-refined-student-lower-v126-gift.png',
                    'courtyard-refined-student-lower-v126-final-stair.png',
                    'courtyard-refined-student-lower-v126-final-card.png',
                    'courtyard-refined-student-lower-v126-final-south.png'],
    'final_views_inspected': True,
    'concourse_geometry_view': 'courtyard-refined-student-lower-v126-concourse.png; before final stair material, not whole lighting acceptance',
    'southern_aperture': 'Old woodland trees intersecting the stair removed; replacement local view inspected and clear',
    'engine_logs_without_errors': logs,
    'finish_physics_scope': 'No new obstacles or collider changes after 30-leg batch; only removal of overlapping props, decal cuts, labels and stone material',
    'limits': 'Not full D, photo-exact site placement or open research continuation verification; lighting still partial'
})
print('V126 source, coverage, goal and 30-leg evidence recorded.')
