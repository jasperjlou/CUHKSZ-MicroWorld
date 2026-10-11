"""Record new primary-source plans without changing the established campus reference frame."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
path=root/'systems/data/campus_visual_build.json'
d=json.loads(path.read_text(encoding='utf-8'))
architect='https://www.rocco.hk/?lang=en&view=projects,typology,featured-project&p=comprehensive-master-plan-and-phase-one-construction-of-the-chinese-university-of-hong-kong-shenzhen-campu'
d.update(version='official-visual-build-14-plan-massing',modified_date='2026-10-10')
for b in d['buildings']:
    if b['id'] in ['teaching_b','teaching_c','zhang_lingbin']:
        b.update(detail_profile='oblique_classroom_bar_short_returns_and_open_court',
                 plan_source=architect,
                 plan_images=['16_cuhksz_gf68.jpg','18_cuhksz_3f65.jpg','19_cuhksz_rooff.jpg'],
                 plan_mapping='three diagonal courts identified as B/C/D using the May 2026 campus guide and 2018 official aerial; the separate rectilinear court is A',
                 observed='diagonal long classroom wing, shorter perpendicular returns, narrow promenade connector and open ground arcade',
                 floor_levels=[0,4.8,8.5,12.2,15.9,19.6],model_storeys=5,
                 count_confidence='five model storeys; B return wing is shorter; storey heights and horizontal scale fitted to retained anchors, not surveyed',
                 footprint_confidence='topology corrected from architect plans; aspect ratio and inter-building spacing remain adapted to existing campus anchors')
    elif b['id']=='teaching_a':
        b.update(plan_source=architect,scenes=sorted(set(b.get('scenes',[])+[116440778,116443786])),
                 detail_profile='rectilinear_court_switchback_and_finned_ground_arcade')
    elif b['id']=='administration':
        b.update(detail_profile='seven_level_finned_front_horizontal_window_rear_and_4f_terrace',
                 scenes=[116440794,116443793,116443781],model_storeys=7,
                 floor_levels=[0,4.4,8.8,12.4,16.1,19.8,23.5,27.2],
                 storey_source='https://jdlab.cuhk.edu.cn/zh-hans/announcement/4545',
                 storey_source_scope='official tender explicitly confirms a seventh floor; it does not establish metric heights or an exact total-storey count',
                 observed='low white vertical-panel wings; tall screened bridge; four upper rows of grouped horizontal rear windows; glazed return and fourth-floor backdoor terrace',
                 inferred_dimensions={'4f_terrace_height':12.4,'main_roof_top':27.52,'central_stair_width':26},
                 count_confidence='seven model levels corroborated by official seventh-floor tender and four-row rear panorama; all metric heights remain estimated')
for p in d['landmarks']:
    if p['name']=='教学楼A':p['hide_world_sign']=True
d['landmarks']=[p for p in d['landmarks'] if not p.get('plan_detail')]
for ident,name,p in [('administration_4f','行政楼四层后门',[91,14.64,-180]),('administration_rear_terrace','行政楼后平台',[112,14.64,-180])]:
    d['landmarks'].append(dict(id=ident,name=name,position=p,plan_detail=True,indoor=True,scene_id=116443793))
path.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(f'v14 source-based massing profiles; {len(d["landmarks"])} landmarks')
