"""Fit photographed hardscape without changing the established East Gate coordinate frame."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
path = ROOT / 'systems/data/campus_visual_build.json'
data = json.loads(path.read_text(encoding='utf-8'))
data['version'] = 'official-visual-build-32-anniversary-ground'
regions = []
def region(name, bounds, kind='stone'):
    regions.append(dict(id=name, bounds=bounds, kind=kind,
                        color='838c8a' if kind == 'stone' else '78915c'))
region('gate_upper_landing', [-32,-97,32,-51])
region('central_mall', [-37,-253,44,-97])
region('library_mall', [-37,-338,44,-253])
region('student_west_bypass', [-37,-383,11,-338])
region('student_front', [-37,-428,42,-383])
region('bridge_landing', [-30,-490,42,-428])
region('zhixin_square', [-89,-779,-16,-691])
# The source's long green panels remain explicit islands within broad paving.
for name, bounds in [
    ('gate_left',[-15,-92,-6,-62]),('gate_right',[6,-92,15,-62]),
    ('mall_central_a',[-5,-195,5,-121]),('mall_central_b',[-5,-317,5,-226]),
    ('student_central',[-5,-377,5,-344]),('student_south',[-5,-422,5,-402]),
    ('bridge_west',[-20,-482,-4,-452]),('bridge_east',[2,-482,16,-452]),
]: region(name,bounds,'lawn')
for i,(z0,z1) in enumerate([(-141,-124),(-163,-146),(-185,-168),(-202,-190),(-242,-228)]):
    region(f'teaching_panel_{i}',[-33,z0,-18,z1],'lawn')
    region(f'admin_panel_{i}',[20,z0,39,z1],'lawn')
for i,(z0,z1) in enumerate([(-276,-258),(-301,-283),(-325,-308),(-362,-344),(-379,-367),(-420,-402)]):
    region(f'west_panel_{i}',[-33,z0,-18,z1],'lawn')
for ix,(x0,x1) in enumerate([(-78,-58),(-48,-28)]):
    for iz,(z0,z1) in enumerate([(-770,-750),(-720,-698)]):
        region(f'square_lawn_{ix}_{iz}',[x0,z0,x1,z1],'lawn')
data['surface_regions'] = regions
data['surface_exclusions'] = [
    dict(id='library_reflecting_pool',bounds=[18.7,-333,35.3,-253]),
    dict(id='sunken_court_open_void',bounds=[11,-381,49,-337]),
    dict(id='library_pool_bridge_ramps',bounds=[17,-279.1,37,-270.9]),
    dict(id='bridge_stair',bounds=[36.2,-442,39.8,-425.8]),
]
for r in data['routes']:
    if r['id'] == 'central_axis':
        # This is an orientation axis, not a continuous real lawn or road.
        r['render_surface'] = False
for b in data['buildings']:
    if b['id']=='zhi_xin':
        b['floor_levels']=[0,4.6,8.3,12.0,15.7,19.4,23.1]
        b['height_note']='Six-storey front ends; four-storey ribbon wing and five-storey rear return; absolute heights inferred.'
        b['geometry_reference']='10th anniversary Start-up Zone erxuanyi_2.jpg; built appearance, capture year unconfirmed.'
data['anniversary_reference_policy']={
    'primary_paving':'2023 marker visible in xiaoyuanhangpaisheyingchenming_2.jpg',
    'upload_is_not_capture_date':True,
    'zhixin':'Built/under-construction pair separated; built picture establishes missing wing and window rows, not a verified 2023 landscape.',
    'dimensions':'Fitted estimates; cardinal north and survey coordinates remain unresolved.'
}
path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(f"{data['version']}: {len(regions)} authored surface regions")
