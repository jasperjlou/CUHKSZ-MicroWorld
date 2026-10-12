"""Record V153 scale-bar reconstruction and scoped validation; stable release stays fixed."""
from pathlib import Path
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[1]
def read(path):
    return json.loads((ROOT / path).read_text(encoding='utf-8-sig'))
def write(path, value):
    (ROOT / path).write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
def sha(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()

prefix = 'tests/artifacts/student_registered_v153'
paths = [prefix + '.json', prefix + '_finish.json']
initial, final = [read(path) for path in paths]
indices = list(range(6)) + list(range(7, 20))
checks = [0, 1, 3, 4, 5]
assert len(initial['physical_legs']) == 21
assert initial['failures'] == ['upper stair foot', 'library upper link enters corrected north wing']
assert all(initial['physical_legs'][i]['valid'] for i in indices)
assert all(initial['checks'][i]['valid'] for i in checks)
assert len(final['physical_legs']) == 25 and len(final['checks']) == 4 and not final['failures']
assert all(item['valid'] for item in final['physical_legs'] + final['checks'])
logs = ['tests/artifacts/student-v153-' + name + '.log' for name in ['initial', 'finish']]
for path in logs:
    assert not any(line.startswith(('ERROR:', 'SCRIPT ERROR:')) for line in (ROOT / path).read_text(encoding='utf-8-sig').splitlines()), path
exports = re.findall(r'"(res://[^"]+)"', (ROOT / 'export_presets.cfg').read_text(encoding='utf-8-sig'))
assert len(exports) == len(set(exports)) and all((ROOT / path[6:]).exists() for path in exports)
assert all('res://world/visual_campus/' + name in exports for name in ['StudentRegisteredPlan.gd', 'StudentRegisteredBuilding.gd'])
data = read('systems/data/campus_visual_build.json')
version = data['version']
assert initial['version'] == final['version'] == version
building = next(item for item in data['buildings'] if item['id'] == 'student_centre')
sources = ['world/visual_campus/' + name for name in ['StudentRegisteredPlan.gd', 'StudentRegisteredBuilding.gd', 'StudentCentre.gd', 'StudentLowerEntrances.gd', 'StudentTerracedCourts.gd', 'LibrarySpaces.gd', 'LibraryRearRoad.gd']]
sources += ['systems/data/campus_visual_build.json', 'world/product/ShowcaseChapters.gd', 'export_presets.cfg']
images = initial['captures'] + final['captures']
assert all((ROOT / 'tests/artifacts' / name).is_file() for name in images)
limits = 'Historical plan ruler, fitted world anchor/rises. 3F manually co-framed and5F boundary transform, not shared-core least-squares registration. Library-side2F portal provisional. Complete cores/supports/rooms, upper access, current facade/detail/roof, shared lower-ground entry and real rear-road datum remain unresolved.'
receipt = {
    'version': version, 'valid_records': 44, 'checks': 9, 'effective_fixtures': 7,
    'not_single_tour': True,
    'accepted_legs': [{'file': paths[0], 'indices': indices}, {'file': paths[1], 'indices': list(range(25))}],
    'accepted_checks': [{'file': paths[0], 'indices': checks}, {'file': paths[1], 'indices': list(range(4))}],
    'effective_images': images, 'images_viewed': 6,
    'image_scope': 'Initial4 reviewed for massing/courts/rear, not final library portal; final2 show portal and upper stair.',
    'engine_errors': 0, 'logs': logs, 'export_files': len(exports),
    'reuse': 'Only library-side2F wall portal changed after initial run; nineteen unaffected initial legs and five meaningful probes reused. JSON prose metadata updated after final test without geometry changes.',
    'retired': 'Initial indices6/20 failed. Side-rail crossing route replaced by approach around stair foot; library wall portal repaired. Initial check2 diagnostic wall-plane ray excluded. V49/V151 student absolute-coordinate routes no longer validate the rebuilt footprint.',
    'limits': limits, 'source_sha256': {path: sha(path) for path in sources},
    'report_sha256': {path: sha(path) for path in paths + logs}
}
write(prefix + '_accepted.json', receipt)
report = 'docs/STUDENT_REGISTERED_PLAN_V153.md'
evidence_path = 'references/visual_build_20261008/student_registered_plan_v153.json'
write(evidence_path, {
    'version': version, 'date': '2026-10-12',
    'source': {'url': 'https://www.gooood.cn/en/student-center-chinese-university-of-hong-kong-shenzhen-campus-by-wang-weijen-architecture.htm', 'published': '2021-05-28', 'project_period': '2012-2019', 'capture_date': 'unknown', 'drawing_revision': 'unknown', 'local_folder': 'originals/student-rear-20261010', 'plans': ['architect-029.jpg', 'architect-030.jpg', 'architect-031.jpg'], 'sections': ['architect-032.jpg', 'architect-033.jpg']},
    'scale_basis': 'references/visual_build_20261008/central_datum_review_v152.json',
    'pixels_per_metre': 13.785714285714285, 'drawing_bounds': [25, 24, 924, 691],
    'world_mapping': {'X': '44+(u-100)/13.785714285714285', 'Z': '-400+(458-v)/13.785714285714285', 'Y': '2.24+fitted_level'},
    'new_building_position': building['position'], 'new_width_depth': [building['width'], building['depth']],
    'levels': building['floor_levels'], 'third_floor': 'Manual court/stair correspondence to1F; third_to_first helper not used in geometry',
    'fifth_floor': 'Independent outline converted by bounding-frame scale; shared-core residual not measured',
    'library_portal': {'u': [235, 296], 'v': 24, 'local_y': 4.4, 'status': 'fitted functional connector, exact current doorway not verified'},
    'limits': limits, 'accepted': prefix + '_accepted.json'
})
cov = read('docs/lower_campus_refinement_coverage.json')
next_action = 'V153 student body rebuilt at historical ruler48.38x65.21m with unequal wing fronts, upper cantilever, three courts/stairs, relocated rear doors/pavement/road.44 scoped legs/9 checks/6 views; stablev2.0.0 unchanged. NEXT jointly register shared1F/3F/5F cores/column points and sections; correct middle/upper notches, exact court openings and cantilever supports, connect upper two levels. Keep fitted library2F portal flagged until true side-entry is corroborated. Then shared lower-ground service entry and library rear-road G/2F datum, D->F/G and allA-G. Do not repeat unchanged checks or assume historic publication date is capture date. Goalactive.'
cov.update(updated='2026-10-12', basis_version=version, previous_turn_classification='progress', status='active', next_action=next_action)
cov['v153_evidence'] = {'report': report, 'registration': evidence_path, 'accepted': prefix + '_accepted.json', 'valid_records': 44, 'checks': 9, 'effective_views': 6, 'limits': limits}
cov['release_convergence']['development']['model_version'] = version
for zone in cov['zones']:
    if zone['id'] != 'D':
        continue
    if report not in zone.setdefault('evidence', []):
        zone['evidence'].append(report)
    for entry in zone['buildings']:
        if entry['id'] != 'student_centre':
            continue
        entry['anchor'] = building['position']
        entry['status'] = 'V153_scale_bar_asymmetric_massing_built;core_registration_and_details_partial'
        entry['coverage'].update(
            front='V153 slanted lower projecting wing, opposite14m setback and separately traced upper cantilever; full column/core support and facade rhythm pending.',
            rear='V153 two historical1F openings relocated with48x65m footprint; actual grade/current service identity and full cores unresolved.',
            ground_or_pilotis='V153 traced continuous hard floor, yellow court doors and schematic dining/lobby; full1F2F rooms and support grid incomplete.',
            stairs_ramps='V153 three court stairs locally walked; higher two floors and core access pending.',
            connections='V153 front interface retained, library-side2F fitted portal walkable, rear walk/road connect retained Shaw junctions. Real library doorway location and shared lower-ground interface unverified.',
            corners_drains_retaining_edges='V153 rear paving relocated with building; full perimeter drainage, grade and corners pending.')
        entry['superseded'] += ' V153 replacesV49/V151 student body and absolute route coordinates; only reports scoped to unchanged adjacent structures remain reusable. StableV145 receipts still apply to that fixed release.'
        if report not in entry['evidence']:
            entry['evidence'].append(report)
for feature in cov['known_unfinished_features']:
    if isinstance(feature, dict) and feature.get('id') == 'student_centre_courtyards_and_storey_registration':
        feature['status'] = 'V153_ruler_scaled_asymmetric_massing_and_three_courts;precise_shared_core_and_level_registration_open'
pending = 'V153: student massing now ruler-scaled, but1F/3F/5F shared-core fit, middle/high notches, complete support columns, upper two-level access, actual library-side doorway and shared lower-ground entry unresolved. Historical source is not current-site certification.'
if pending not in cov['known_unfinished_features']:
    cov['known_unfinished_features'].append(pending)
write('docs/lower_campus_refinement_coverage.json', cov)
summary = 'V153：学生中心按历史1F比例尺从70×95米改为约48.38×65.21米，重建错位两翼、斜边/上部悬挑、三级院落及楼梯洞；后侧双门、硬铺/道路及展示局部路线同步。44有效分批移动、7起点、9检查、6分范围视图通过；初横穿梯侧栏杆与连廊撞墙失败保留，绕梯脚及拟合通口后续查，未重跑全区。共同核心配准、各层凹口/支撑、上两层通路、连廊实景门位/共享下首层及G/2F后路标高仍待核；不将历史2021发表当拍摄日期或现状。下一批核心/柱网/剖面与层间开口，再D至F/G及全A–G。稳定v2.0.0不覆盖，开发2.0.1-dev，Goal active。详见docs/STUDENT_REGISTERED_PLAN_V153.md。'
for filename in ['docs/LOWER_CAMPUS_ACTIVE_GOAL.md', 'docs/NEXT_ITERATION_HANDOFF.md']:
    p = ROOT / filename
    text = p.read_text(encoding='utf-8-sig')
    if '\nV153：' not in text:
        text += '\n\n' + summary + '\n'
    if filename.endswith('HANDOFF.md'):
        text = text.replace('`official-visual-build-151-student-lower-entries`', '`' + version + '`', 1)
        text = text.replace('不能说这些改动已包含在稳定包。', 'V153 已重建学生中心比例尺体量及局部连接，44 分批通行、9 检查、6 视图；精确核心/楼层/支撑与下层门位仍未完。不能说这些改动已包含在稳定包。', 1)
        text = text.replace('V152 比例尺复核发现学生中心外包尺寸及两翼前缘关系需重建，先登记各层核心/轮廓/楼梯与连廊定位点，再更新受影响道路；', 'V153 比例尺体量及道路重建已落地，下一批共同核心/柱网/剖面配准，修中高层凹口、支撑和上两层通路，核实拟合侧门；')
    p.write_text(text, encoding='utf-8')
p = ROOT / 'README.md'
text = p.read_text(encoding='utf-8-sig').replace('`2.0.1-dev` / V151，[学生中心下层入口与院落围护](docs/STUDENT_LOWER_ENTRIES_V151.md)', '`2.0.1-dev` / V153，[学生中心比例尺体量与院落重建](docs/STUDENT_REGISTERED_PLAN_V153.md)')
p.write_text(text, encoding='utf-8')
print(json.dumps({'records': 44, 'checks': 9, 'views': 6, 'export_files': len(exports), 'goal': 'active', 'stable': 'unchanged'}))
