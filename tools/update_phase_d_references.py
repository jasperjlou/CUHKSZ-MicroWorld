"""Ground evidence segmentation, explicitly separate from game route registration."""
import collections
import json
import pathlib
import re

ROOT=pathlib.Path(__file__).resolve().parents[1]


def read(path): return json.loads((ROOT/path).read_text('utf8'))
def write(path,data):
    p=ROOT/path
    p.parent.mkdir(parents=True,exist_ok=True)
    p.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf8')


def main():
    reviews={
        'VR_42078153':'Phase D 地面审阅：湖口灰石通行带在方形树池与两侧弧形浅阶之间连续延伸；阶脚有条形排水开口。外向可追踪至远侧广场铺地可见边缘，未读出与环岛连续接缝。局部次序可靠，米数、指南针与跨画面物体同一性未知。',
        'VR_116384446':'Phase D 反向地面审阅：可见环岛种植岛浅色路缘、沥青车道、红灰路侧铺地、路灯、路边柱和过街标志。湖口热点所在朝向没有清晰显示湖口弧形浅阶的同一接缝。车道形状可见不等于完整行人连接。',
        'VR_42078166':'Phase D 补查球场中间视角：拍摄点位于蓝色场地内，网栏、球网和灯柱清楚；相邻热点是球场/足球场。已审阅方向不能证明绕过围栏后与湖口、环岛的连续通行。'
    }
    vr=read('references/vr/scene_catalog.json')
    for r in vr['references']:
        if r['reference_id'] in reviews:
            r['phase_d_ground_review']=reviews[r['reference_id']]
            r['review_status']='PARTIALLY_VISUALLY_REVIEWED'
            r['reviewed_at']='2026-09-28'
    write('references/vr/scene_catalog.json',vr)
    segments=[]
    def segment(number,title,start,end,sources,confidence,geometry,walk,sequence,missing,conflict):
        segments.append(dict(id=f'GroundSegment_D{number:02}',name_zh=title,from_anchor=start,to_anchor=end,
            evidence=sources,confidence=confidence,confidence_scope='local_reference_pedestrian_continuity',geometry_confidence=geometry,
            pedestrian_continuity=walk,geometry_source=sources if geometry=='verified' else [],visual_source=sources,
            fixed_object_sequence=sequence,sequence_scope='within_one_panorama_only',missing_evidence=missing,conflict=conflict,
            geographic_registration='unknown',game_position=None,game_instantiated=False,new_walkable=False,
            metric_length_m=None,source_capture_date='unknown'))
    segment(1,'湖口树池间的通行带','题字石附近灰石前庭','弧形浅阶之间的通行带',['VR_42078153'],'verified','verified','verified',
        ['题字石附近前庭','方形树池','弧形浅阶之间的灰石通行带'],
        '缺少实测尺寸；不把全景透视长度换算成米。','局部铺地可见；原型题字石/台阶并未与全景坐标配准。')
    segment(2,'通行带至广场外沿可见部分','弧形浅阶之间的通行带','外向灰石广场可见边缘',['VR_42078153'],'verified','verified','verified',
        ['阶脚排水开口','连续灰石带','细黑灯柱与树列','远侧铺地可见边缘'],
        '需要外沿之外的下一拍摄点、相同灯柱或铺地接缝作为跨视角锚点。','仅在同一画面可见范围内连续；没有证明终止于车道或环岛。')
    segment(3,'广场外沿至环岛接近段','外向灰石广场可见边缘','候选环岛接近段',['VR_42078153','VR_116384446','VR_130095287','LEGACY_DAE'],'unknown','unknown','unknown',
        [],'缺失中间地面画面；需要连续的铺地、路缘、灯柱次序及反向照片。','两个拍摄点互设热点，不代表没有中间转折；DAE没有对应湖口锚点。')
    segment(4,'环岛接近段与行人接入','候选环岛接近段','候选第一岔路',['VR_116384446'],'unknown','verified','unknown',
        ['弯曲车道边线','浅色路缘与红灰侧铺地','路边柱与过街标志'],
        '需清晰的过街落脚点、路缘开口和两侧连续步行视图。','固定物列表为单幅画面可见排列，不是已确认步行顺序；车道连续不等于行人连续。')
    segments[3]['sequence_scope']='visible_features_not_walk_order'
    nodes={r['pano_id']:r for r in vr['references']}
    focus={'VR_42078153','VR_116384446','VR_130095287','VR_42078166','VR_42078167'}
    edges=[dict(from_id=nodes[e['from_pano_id']]['reference_id'],to_id=nodes[e['to_pano_id']]['reference_id'],relation='PANORAMA_HOTSPOT_NOT_WALKABILITY',visual_match='unknown',pedestrian_continuity='unknown') for e in vr['edges'] if nodes[e['from_pano_id']]['reference_id'] in focus]
    chains=[
        dict(id='CHAIN_DIRECT',nodes=['VR_42078153','VR_116384446'],status='metadata_candidate',matched_fixed_objects=[],continuous_ground=False,missing_link='GroundSegment_D03'),
        dict(id='CHAIN_VIA_GATE',nodes=['VR_42078153','VR_130095287','VR_116384446'],status='metadata_candidate_not_validated',matched_fixed_objects=[],continuous_ground=False,reason='North-gate road views are not proven intermediate points on the lake-to-roundabout footway.'),
        dict(id='CHAIN_COURT',nodes=['VR_116384446','VR_42078166','VR_42078167'],status='insufficient_for_ground_bridge',matched_fixed_objects=[],continuous_ground=False,reason='Court interior fencing does not establish an exit or continuity to the lake.')
    ]
    coverage=dict(reference_pedestrian_continuity=dict(collections.Counter(s['confidence'] for s in segments)),
        visible_ground_geometry=dict(collections.Counter(s['geometry_confidence'] for s in segments)),
        game_registration=dict(unknown=len(segments)),continuous_lake_to_junction=False,new_walkable_segments=0,unknown_gap_length_m=None,
        note='Coverage counts inquiry units, not equal-length surveyed segments. It is not a percentage of real route length.')
    report=dict(version='1.0.0-phase-d',reviewed_at='2026-09-28',frozen_baseline='references/regions/fairy_lake/v10d_frozen_baseline.json',
        segment_order_is='hypothesis_not_a_measured_route',segments=segments,panorama_chains=chains,panorama_edges=edges,coverage=coverage,
        dae_analysis='references/legacy_models/ground_topology.json',junction=dict(id='CANDIDATE_JUNCTION_D01',source='VR_116384446',first_junction_confidence='unknown',branches=[],game_instantiated=False),
        gate=dict(new_main_path_enabled=False,reason='Two reference-local patches confirmed; cross-view ground gap and pedestrian junction access unresolved.'),
        next_phase='Remain in Phase D evidence resolution; do not enter branch resolution yet.',reviews=reviews,assets_imported=False,screenshots_saved=False)
    write('references/regions/fairy_lake/v10d_ground_evidence.json',report)
    # Small portable runtime copy: reference-only records, never substitute coordinates.
    write('systems/data/ground_survey.json',dict(version=report['version'],segments=segments,coverage=coverage,next_unknown='GroundSegment_D03',new_path_enabled=False))
    index=read('references/index.json');index['scope']='V1.0 Phase D: ground continuity investigation; four inquiry segments, no new path or geographic registration'
    for r in index['references']:
        if r['reference_id']=='OFFICIAL_VR':r['phase_d_note']='重新审阅湖口/环岛的地面与反向视角，补查球场；四段调查单元仍有两段行人连续性未知。'
        if r['reference_id']=='LEGACY_DAE':r['ground_topology_analysis']='references/legacy_models/ground_topology.json'
    write('references/index.json',index)
    catalog=read('assets/campus/environment_catalog.json');catalog['version']='1.0.0-phase-d';catalog['phase_d']=dict(new_geometry_assets=0,ground_geometry_unchanged=True,ground_evidence='references/regions/fairy_lake/v10d_ground_evidence.json');write('assets/campus/environment_catalog.json',catalog)
    pack=read('references/regions/fairy_lake/pack.json');pack['phase_d_ground_evidence']='references/regions/fairy_lake/v10d_ground_evidence.json';write('references/regions/fairy_lake/pack.json',pack)
    gaps=read('references/unresolved/gaps.json');gaps['gaps']=[g for g in gaps['gaps'] if not g['gap_id'].startswith('ground_d')]
    for s in segments:
        if s['confidence']=='unknown':gaps['gaps'].append(dict(gap_id='ground_d'+s['id'][-2:],region='fairy_lake',status='NEEDS_REFERENCE',request=s['missing_evidence'],searched_reference_ids=s['evidence'],reason=s['conflict']))
    write('references/unresolved/gaps.json',gaps)
    names={'verified':'已核实','unknown':'未知','inferred':'推断','placeholder':'临时占位'}
    rows=''.join('<tr><td>'+s['id'][-3:]+' '+s['name_zh']+'</td><td>'+names[s['geometry_confidence']]+'</td><td>'+names[s['confidence']]+'</td><td>未知</td></tr>' for s in segments)
    panel='<section id="ground-review"><h2>地面证据：局部可见，跨段仍有缺口</h2><p>四个调查单元：行人连续性已核实 2、未知 2；游戏位置配准 4 项均未知。它们不等长，不能换算成路线完成率。</p><table><thead><tr><th>调查段</th><th>可见地面</th><th>行人连续性</th><th>游戏配准</th></tr></thead><tbody>'+rows+'</tbody></table><p>湖口前庭 → 树池间通行带 → 广场外沿 → <strong>缺失中间地面</strong> → 环岛接入待核对</p><p><a href="regions/fairy_lake/v10d_ground_evidence.json">地面矩阵与候选全景链</a>　<a href="legacy_models/ground_topology.json">旧模型三角面审计</a>　<a href="../docs/V10_PHASE_D_GROUND_EVIDENCE_BRIDGE.md">本轮结论</a></p></section>'
    p=ROOT/'references/viewer.html';html=p.read_text('utf8').replace('校园参考库 · V1.0 Phase C','校园参考库 · V1.0 Phase D')
    html=re.sub(r'<section id="ground-review">.*?</section>','',html,flags=re.S)
    html=html.replace('<nav>',panel+'<nav>',1)
    html=re.sub(r'(<script[^>]*id="data"[^>]*>).*?(</script>)',lambda m:m[1]+json.dumps(index['references'],ensure_ascii=False)+m[2],html,flags=re.S)
    p.write_text(html,encoding='utf8')
    print(json.dumps(coverage,ensure_ascii=False))


if __name__=='__main__':main()
