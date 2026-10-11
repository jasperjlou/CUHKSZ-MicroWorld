"""Conference Centre: distinguish observed hall height from inferred envelope dimensions."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
path=root/'systems/data/campus_visual_build.json'
d=json.loads(path.read_text(encoding='utf-8'))
d.update(version='official-visual-build-12-conference-centre',modified_date='2026-10-10')
for b in d['buildings']:
    if b['id']=='conference':
        b.pop('source_hall_clear_height',None)
        b.update(name='逸夫国际会议中心',depth=50,footprint_offset=[0,0,-6],model_storeys=3,
                 floor_levels=[0,4.4,8.8],detail_profile='stone_hall_glazed_foyer_and_upper_service_block',
                 scenes=[116443785,116443783,41792321],
                 observed='tall glazed name frontage, pale stone hall block, taller rooftop volume, lower recessed arcade and marble foyer stair',
                 count_confidence='public ground/raised foyer/mezzanine are modelled; total exterior height and service storeys remain estimated',
                 hall_height_source='https://tencentlab.cuhk.edu.cn/zh-hans/node/3315',
                 source_hall_storey_height=15,
                 height_source_scope='2017 tender states hall storey height 15 m; it does not establish clear height, total exterior height or as-built dimensions',
                 inferred_dimensions={'entrance_level':4.4,'mezzanine_level':8.8,'main_roof':19.83,'upper_block_top':27.53})
for r in d['routes']:
    if r['id']=='conference_walk':
        r['points']=[[0,2.24,-80],[27,2.24,-80]]
        r['note']='Ground route ends at the new public stair foot; upper entry is physical staircase and terrace.'
d['landmarks']=[p for p in d['landmarks'] if not p.get('conference_detail')]
for ident,name,p in [('conference_entry','逸夫国际会议中心门厅',[49,6.64,-80]),('conference_mezzanine','会议中心门厅夹层',[58,11.04,-80]),('conference_lower_arcade','会议中心下层柱廊',[60,2.24,-111])]:
    d['landmarks'].append(dict(id=ident,name=name,position=p,conference_detail=True,indoor=True))
path.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(f'v12 conference profile recorded; {len(d["landmarks"])} landmarks; anchor retained')
