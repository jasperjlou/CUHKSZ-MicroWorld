"""Record the bounded experience gate; raw failures stay alongside accepted evidence."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / 'tests/artifacts'
def read(name):
    return json.loads((ART / (name + '.json')).read_text('utf-8-sig'))
def write(path, value):
    (ROOT / path).write_bytes((json.dumps(value, ensure_ascii=False, indent=2) + '\n').encode())
def sha(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()

tour = read('product_experience_finish_v185')
main = read('lower_main_route_v185')
inputs = read('product_input_finish_v185')
before = read('product_presentation_v185')
after = read('product_presentation_finish_v185')
study = read('study_camera_finish_v185')
for data in [tour, main, inputs]:
    assert not data['failures']
    assert all(item['valid'] for item in data.get('physical_legs', []) + data.get('checks', []))
assert len(tour['physical_legs']) == 151 and len(main['physical_legs']) == 129
assert len(inputs['checks']) == 14
views = [p.removeprefix('res://') for p in after['captures'] if 'library-study' not in p]
views += [p.removeprefix('res://') for p in study['captures']]
assert len(views) == 34
files = views + ['tests/artifacts/' + n + '.json' for n in [
    'product_experience_finish_v185', 'lower_main_route_v185', 'product_input_finish_v185',
    'product_presentation_v185', 'product_presentation_finish_v185', 'study_camera_finish_v185']]
files += ['world/product/CampusProduct.gd', 'world/product/CampusShowcase.gd',
          'world/product/ShowcaseChapters.gd', 'world/visual_campus/VisualCampus.gd',
          'world/visual_campus/CampusRenderBatches.gd']
accepted = {
    'model': tour['model_version'], 'batch': 'V185', 'status': 'bounded_experience_gate_passed',
    'product_at_route_validation': tour['product_version'],
    'showcase': {'chapters': 16, 'physical_legs': 151, 'checks': 26, 'failures': 0,
                 'scope': 'Chapter cuts explicit; normal walk speed; holds accelerated only.'},
    'main_itinerary': {'physical_legs': 129, 'fixtures': 1, 'failures': 0,
                       'scope': main['scope'], 'all_campus_spaces_accepted': False},
    'rendered_input': {'checks': 14, 'failures': 0, 'scope': inputs['scope'],
                       'counts_overlap_headless_checks': True},
    'batching': after['batching'],
    'timing': {'before': before['timing'], 'after': after['timing'],
               'scope': 'RTX5070Ti Laptop,1440x900,40 uncapped rendered frames per fixed viewpoint; not sustained full-route performance guarantee.'},
    'views': views, 'effective_views': 34, 'raw_reviewed_views': 70, 'views_reviewed': True,
    'retention': 'Last batching/camera changes do not alter physical geometry or chapter paths; retain route tests rather than repeat.',
    'excluded': ['initial study-core and Zhixin route failures superseded by complete corrected playback',
                 'first rendered input driver failures; final two failures caused by viewport/window coordinate mismatch',
                 'first34 views and final study pair superseded by listed effective images'],
    'remaining': ['East Gate median35.109ms still needs further performance work; no constant60FPS claim',
                  'sampled camera fixtures do not prove all intermediate frames unobstructed',
                  'full A-G fidelity backlog remains active; geography and unseen interiors still fitted'],
    'files': {p: sha(p) for p in files}}
write('tests/artifacts/product_experience_v185_accepted.json', accepted)
write('references/visual_build_20261008/product_experience_v185.json', {
    'model': tour['model_version'], 'doc': 'docs/PRODUCT_EXPERIENCE_V185.md',
    'accepted': 'tests/artifacts/product_experience_v185_accepted.json',
    'changes': ['camera reset and held-drag clearing', 'study-core and Zhixin route alignment',
                'heading/per-leg showcase camera', 'spatial opaque static box batches'],
    'physical_geometry_changed': False, 'new_architectural_source': False,
    'date_basis': 'Product/rendering batch; reuses documented V146-V184 source and date limits.',
    'limits': accepted['remaining']})
p = ROOT / 'docs/lower_campus_refinement_coverage.json'
d = json.loads(p.read_text('utf-8-sig'))
d.update(updated='2026-10-12', basis_version=tour['model_version'], status='active',
         previous_turn_classification='progress', previous_turn_progress_kind='experience_and_release_convergence',
         next_action='V185 bounded player/showcase gate passed:16chapters151legs,129main legs,14rendered input checks,34effective views. Package2.1.0,verify actual exported Player/Agent,curate source/tag/Release and local two shortcuts,record receipt;then resume C-D shared lower-level registration and fullA-G backlog. No deep model expansion before release.')
d['v185_evidence'] = {'doc': 'docs/PRODUCT_EXPERIENCE_V185.md',
                       'accepted': 'tests/artifacts/product_experience_v185_accepted.json',
                       'source': 'references/visual_build_20261008/product_experience_v185.json',
                       'status': 'bounded_experience_gate_passed'}
pipeline = d['release_pipeline']
pipeline['current_stage'] = 'formal_packaging_github_local_sync'
pipeline['stage_status']['player_experience_and_agent_showcase'] = 'V185_passed_with_performance_and_camera_sampling_limits'
pipeline['stage_status']['formal_packaging_github_local_sync'] = '2.1.0_build_in_progress'
d['release_convergence']['development'].update(product_version='2.1.0', model_version=tour['model_version'], published=False)
write('docs/lower_campus_refinement_coverage.json', d)
print('V185 evidence recorded; full campus Goal remains active; formal publication pending.')
