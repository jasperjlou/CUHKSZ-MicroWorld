"""Record bounded V145 route/build acceptance without closing the campus Goal."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VERSION = 'official-visual-build-145-zhixin-crossing'
DOC = 'docs/STAGE_ROUTE_EXPORT_V145.md'

def read(path):
    return json.loads((ROOT / path).read_text('utf-8-sig'))

def write(path, data):
    (ROOT / path).write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', 'utf-8')

def sha(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()

assert read('systems/data/campus_visual_build.json')['version'] == VERSION
reports = ['tests/artifacts/' + name + '.json' for name in [
    'product_showcase_v145', 'lower_main_route_v145', 'main_crossing_v145_views',
    'export_smoke_v145_human', 'export_smoke_v145_agent-demo']]
for path in reports:
    data = read(path)
    assert not data.get('failures'), path
    assert all(x['valid'] for x in data.get('physical_legs', []) + data.get('checks', [])), path
logs = ['tests/artifacts/' + name + '.log' for name in [
    'product_showcase_v145', 'lower_main_route_v145_final', 'main_crossing_v145_paving',
    'windows_export_v145_final', 'export_smoke_v145_human', 'export_smoke_v145_agent-demo',
    'export_native_v145_human', 'export_native_v145_agent-demo']]
for path in logs:
    assert not any(x.startswith(('ERROR:', 'SCRIPT ERROR:'))
                   for x in (ROOT / path).read_text('utf-8').splitlines()), path
images = ['tests/artifacts/courtyard-refined-main-crossing-v145-' + x + '.png'
          for x in ['overview', 'approach', 'corner']]
images += ['tests/artifacts/export_smoke_v145_' + x + '.png' for x in ['human', 'agent-demo']]
package = 'builds/stage-v145/Windows/'
manifest = read(package + 'build-manifest.json')
for path, item in manifest['files'].items():
    assert sha(package + path) == item['sha256'], path
closure = read('tests/artifacts/export_resource_closure_v145.json')['files']
files = closure + reports + logs + images + [
    'export_presets.cfg', 'tools/build_stage_v145.py', 'tests/ExportSmokeV145.gd',
    'tests/LowerMainRouteV145.gd', 'tests/ProductShowcaseV145.gd',
    'tests/MainCrossingViewsV145.gd', 'tests/artifacts/export_resource_closure_v145.json',
    package + 'build-manifest.json']
accepted = 'tests/artifacts/stage_route_export_v145_accepted.json'
write(accepted, {
    'version': VERSION, 'status': 'candidate_verified_not_published',
    'full_showcase': {'model_at_run': 'official-visual-build-144-shaw-public-glazing',
                      'chapters': 15, 'movement_records': 151, 'checks': 12,
                      'retention': 'V145 navigation crossing outside chapter paths; finishing surfaces non-colliding.'},
    'continuous_main_route': {'records': 133, 'fixtures': 1, 'not_all_rooms_or_branches': True},
    'export': {'checks': 17, 'native_main_modes': 2, 'resource_files': len(closure),
               'product_version': '2.0.0-rc1', 'package': package, 'manifest': manifest},
    'views': images, 'views_reviewed': True,
    'excluded': ['two earlier main-route guard/wall-corner failures',
                 'initial export filter missing preload dependencies',
                 'pre-paving crossing images', 'opening-fade Agent screenshot'],
    'files': {p: sha(p) for p in files}})
source = 'references/visual_build_20261008/stage_route_export_v145.json'
write(source, {'version': VERSION, 'doc': DOC, 'accepted': accepted,
               'reference': 'V87 user photos222548/552/556/613',
               're_viewed': ['20261010_222548.jpg', '20261010_222613.jpg'],
               'date_basis': 'EXIF2026-10-10;device clock not independently calibrated',
               'limits': ['metric alignment/road width/paving polygon fitted',
                          'East Gate origin retained; geographic north unresolved'],
               'changes': ['navigation through crossing opening, around real wall corner',
                           'photo-led brick surface replaces generic stone ribbon at junction']})
next_action = ('V145:15chapter audit151records12checks retained from V144;continuous main route133records1fixture;'
               'Windows candidate actual EXE/PCK verified17checks2native modes5finalviews. '
               'NEXT stage publication:inspect remote main/tags,curate current source/research metadata without originals,'
               'unify formal version and release notes,build/publish GitHub and pin local stable binary;'
               'archive old public shortcuts with rollback and leave Player/Agent only. '
               'Then organize baseline and immediately continue all A-G fidelity backlog;Goal/heartbeat active.')
d = read('docs/lower_campus_refinement_coverage.json')
ev = {'doc': DOC, 'source': source, 'accepted': accepted, 'status': 'stage_route_and_binary_candidate_verified'}
d.update(updated='2026-10-12', basis_version=VERSION, status='active',
         previous_turn_classification='progress', previous_turn_progress_kind='model_and_stage_validation',
         next_action=next_action, v145_evidence=ev)
zone = next(z for z in d['zones'] if z['id'] == 'F')
zone['v145_update'] = ev
candidate = d['release_convergence']['candidate']
candidate.update(current_model_version=VERSION, model_version=VERSION, chapters=15,
                 physical_legs=151, product_checks=12, accepted=accepted, published=False,
                 showcase_validation_model_version='official-visual-build-144-shaw-public-glazing',
                 physical_legs_note='151 full15chapter records on V144 retained:V145 route edit outside chapter paths;non-colliding visual finishes.',
                 windows_export_verified=True, windows_package=package, windows_manifest=package+'build-manifest.json',
                 full_campus_route_accepted=False,
                 main_itinerary={'accepted':True, 'records':133, 'fixtures':1, 'scope':'selected continuous cross-campus itinerary,not all rooms/rear branches'},
                 full_campus_route_note='Keep false:all A-G spaces not exhaustively accepted;selected main itinerary passed.')
d['release_convergence']['product_entries'] = ['玩家游玩', 'Agent 自动展示']
write('docs/lower_campus_refinement_coverage.json', d)
note = ('V145：当前15章集中检查151移动/12产品检查通过（运行时V144，V145不改章内路线）；'
        '主线从东门经图书馆、学生下层、知新至科研体育前场133记录单起点连续通过。修旧直线穿护栏、转角切馆墙，'
        '铺地按实拍换砖并保留绿带；3终图已看。Windows候选实际EXE/PCK在干净目录17检查、2原生入口启动通过，'
        '2最终GPU图已看，包内168产品依赖/许可，原件及测试未打包。保留路口/导出失败，未反复重测未变物理。'
        '正式GitHub/本地发布尚未做，下一批直接整理源码、版本、正式包与两个稳定入口，随后继续全A–G；Goal active。详见'+DOC+'。')
p = ROOT / 'docs/LOWER_CAMPUS_ACTIVE_GOAL.md'
s = p.read_text('utf-8-sig')
if '\nV145：' not in s:
    p.write_text(s+'\n\n'+note+'\n', 'utf-8')
for name in ['NEXT_ITERATION_HANDOFF.md', 'FORMAL_RELEASE_CONVERGENCE.md', 'PRODUCT_SHOWCASE_CANDIDATE.md']:
    p = ROOT / 'docs' / name
    s = p.read_text('utf-8-sig')
    if '\n## V145 当前接续点' not in s:
        s += '\n## V145 当前接续点\n\n'+note+'\n\nWindows候选：`'+package+'`，内含 `build-manifest.json`。当前产品仍2.0.0-rc1；下文历史待办中主线/15章/导出已由本条更新，但正式tag/commit/Release/本地稳定快捷入口仍待发布批次完成。\n'
    s = s.replace('模型已至V144', '模型已至V145')
    s = s.replace('模型：`official-visual-build-144-shaw-public-glazing`；', '模型：`'+VERSION+'`；[V145主线及独立包](STAGE_ROUTE_EXPORT_V145.md)；')
    s = s.replace('GitHub 正式 tag、发布 commit、Windows 发行包及 SHA-256：**尚未生成**。',
                  'GitHub 正式 tag、发布 commit：**尚未生成**。Windows候选包已生成并验证，SHA-256见 `builds/stage-v145/Windows/build-manifest.json`；尚未升为正式版。')
    p.write_text(s, 'utf-8')
p = ROOT/'README.md'; s = p.read_text('utf-8-sig').replace('模型 V144', '模型 V145').replace('（现 14 章）','（现 15 章）')
s = s.replace('尚未发布这一阶段的 GitHub 正式版或 Windows 独立包。',
              'Windows独立候选包已生成并通过两个入口验证；这一阶段的GitHub正式版尚未发布。')
if '[V145 主线' not in s:
    s = s.replace('- [V144 ', '- [V145 主线通行与 Windows 候选包](docs/STAGE_ROUTE_EXPORT_V145.md)\n- [V144 ', 1)
p.write_text(s, 'utf-8')
print('V145 saved:current source hashes,retained15chapter,continuous main route,independent Windows candidate;Goal active.')
