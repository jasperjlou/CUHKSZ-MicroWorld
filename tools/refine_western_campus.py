"""Preserve campus anchors while recording the western models' actual source coverage."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
path=root/'systems/data/campus_visual_build.json'
d=json.loads(path.read_text(encoding='utf-8'))
d.update(version='official-visual-build-13-western-campus',modified_date='2026-10-10')
for b in d['buildings']:
    if b['id']=='sports_hall':
        b.update(detail_profile='folded_roof_recessed_portal_glazed_gallery_and_reception',
                 scenes=[116440784,116440785,116443789],floor_levels=[0,.84,4.8,9.2],
                 observed='deep front portal with dark fins, ribbed soffit, raised glass entrance; field-side folded roof, coloured fins, elevated glazing and open base; pale reception desk and red chairs',
                 inferred_dimensions={'portal_top':17.125,'roof_peak':18.2,'entry_level':.84,'field_gallery_level':4.8},
                 count_confidence='exterior and reception are fitted; internal sports-room plan, roof structure and metric dimensions are not surveyed')
    elif b['id']=='old_gate':
        b.update(detail_profile='paired_freestanding_granite_blades',scenes=[116410028],width=55,
                 observed='two separate stone pylons with projecting crosspieces, low campus name wall, bollards and zebra crossing',
                 inferred_dimensions={'pylon_height':13,'pylon_spacing':7},
                 count_confidence='shape visually checked; position retained and dimensions fitted')
    elif b['id']=='track':
        b.update(detail_profile='parallel_straights_semicircular_ends_and_pitch',scenes=[116443789],
                 observed='red running surface, football pitch, goal nets and field lighting beside sports-hall folded elevation',
                 inferred_dimensions={'outer_radius':40,'straight_length':88,'lane_count':8,'pitch':[90,54]},
                 count_confidence='lane count, pitch dimensions, bleachers and light placement are approximations, not certified athletics dimensions')
    elif b['id']=='west_gate':
        b.update(detail_profile='unverified_direction_waypoint',name='西侧出口方向',
                 observed='direction retained; no verified gate facade available in consulted official panoramas',
                 count_confidence='removed unsupported overhead portal; only paved waypoint and lamps')
for p in d['landmarks']:
    if p.get('id') in ['sports_entry','old_south_gate']:p['hide_world_sign']=True
    if p.get('id')=='old_south_gate':p.update(name='旧校门',scene_id=116410028)
    if p.get('id')=='west_gate_entry':p['name']='西侧出口方向'
d['landmarks']=[p for p in d['landmarks'] if not p.get('western_detail')]
for ident,name,p in [('sports_reception','体育馆服务中心',[0,3.08,-878]),('sports_gallery','体育馆场侧回廊',[-10,7.04,-921])]:
    d['landmarks'].append(dict(id=ident,name=name,position=p,western_detail=True,indoor=True))
path.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(f'v13 western profiles; {len(d["landmarks"])} landmarks; all anchors retained')
