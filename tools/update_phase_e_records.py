"""Record current construction separately from historical source-verification reports."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
def read(path):
    return json.loads((ROOT / path).read_text('utf8'))
def write(path, value):
    (ROOT / path).write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n', 'utf8')

world = read('systems/data/junction_world.json')
baseline = read('references/regions/fairy_lake/v10d_frozen_baseline.json')
changed = {}
for path in ['world/ForestConnectorBuilder.gd', 'world/ForestConnectorLayout.gd']:
    changed[path] = {'before': baseline['geometry_sha256'][path],
                     'after': hashlib.sha256((ROOT / path).read_bytes()).hexdigest()}
report = {'version': world['version'], 'updated_at': '2026-09-29',
          'authority': 'User explicitly replaced stop-on-unknown with evidence-aware inference and authorized D2 construction then Phase E.',
          'principle': world['principle'], 'world_definition': 'systems/data/junction_world.json',
          'world_definition_sha256': hashlib.sha256((ROOT / 'systems/data/junction_world.json').read_bytes()).hexdigest(),
          'd2_status': 'playable_connection_completed_by_inference', 'phase_e_status': 'five_branch_directions_implemented',
          'evidence_fully_verified': False, 'blocking_unknowns': 0, 'legacy_models_imported': 0,
          'chosen_option': {'id': 'B', 'confidence': 'placeholder', 'reason': world['access_reason_zh']},
          'geometry_freeze_superseded': changed, 'preserved_baseline': 'references/regions/fairy_lake/v10d_frozen_baseline.json',
          'segments': world['segments'], 'branches': world['branches'],
          'sources': {'field_photos': 'references/regions/fairy_lake/field_20260929.json',
                      'guide': 'FIELD_328 May 2026 illustrated campus map (observed in user attachment)',
                      'legacy_dae': 'references/regions/fairy_lake/v10d_ground_evidence.json',
                      'legacy_player': 'references/regions/fairy_lake/local_player_build_inventory.json'},
          'limits': ['Game coordinates, dimensions, slopes and compass orientation are not surveyed.',
                     'Branch stubs establish directions, not complete arrival at real upper/lower campuses.',
                     'Ling gate is an original simplified silhouette with inferred placement.',
                     'Historical source gaps remain in old reports; they no longer block construction.',
                     'Legacy records are not localized geometry; no unsupported DAE topology claim.',
                     'Photo originals remain unavailable locally; inference uses already reviewed conversation images.']}
write('references/regions/fairy_lake/phase_e_construction.json', report)
catalog = read('assets/campus/environment_catalog.json')
catalog['version'] = world['version']
asset = {'asset_id': 'replaceable_junction_world', 'name_zh': '可替换的湖口连接与岔路分支',
         'category': 'Path', 'path': 'world/JunctionBuilder.gd', 'implementation': 'data-driven procedural',
         'reusable': True, 'version': world['version'], 'source_reference_ids': ['VR_116384446', 'VR_42078153'],
         'provenance': 'Original authored geometry, inferred topology plus placeholder access; field-photo/map reasoning in junction_world.json.',
         'license': 'Project-authored; no legacy mesh or photo texture imported',
         'confidence': {'topology': 'inferred', 'access': 'placeholder', 'dimensions': 'placeholder', 'position': 'inferred'},
         'replaceable': True, 'definition': 'systems/data/junction_world.json'}
catalog['assets'] = [a for a in catalog['assets'] if a['asset_id'] != asset['asset_id']] + [asset]
write('assets/campus/environment_catalog.json', catalog)
viewer = ROOT / 'references/viewer.html'
content = viewer.read_text('utf8')
if 'id="phase-e-construction"' not in content:
    section = '<section id="phase-e-construction"><h2>当前：推断建设已接通第一岔路</h2><p>中间道路为推断；选用沿路侧人行道接入，具体入口为临时占位。已建立上园、下园、道扬书院和其他区域支路；车行道独立标识。所有新增连接可替换，未宣称实测准确。</p><p><a href="regions/fairy_lake/phase_e_construction.json">当前建设依据</a> · <a href="../docs/PHASE_E_JUNCTION_WORLD.md">可玩范围与验收</a></p><p>下方D/D2调查内容为策略调整前的历史记录，不再作为禁止建设的门槛。</p></section>'
    content = content.replace('<section id="field-photo-review">', section + '<section id="field-photo-review">', 1)
    viewer.write_text(content, 'utf8')
print('Recorded Phase E world, construction provenance and two explicitly superseded freeze hashes.')
