"""Record the two bounded gap investigations; never turn hotspot links into paths."""
import copy
import hashlib
import html
import json
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[1]
VERSION = '1.0.0-phase-d2'
DATE = '2026-09-28'


def read(path):
    return json.loads((ROOT / path).read_text('utf8'))


def write(path, data):
    (ROOT / path).write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf8')


def main():
    previous = read('references/regions/fairy_lake/v10d_ground_evidence.json')
    baseline = read(previous['frozen_baseline'])
    for path, digest in baseline['geometry_sha256'].items():
        assert hashlib.sha256((ROOT / path).read_bytes()).hexdigest() == digest
    # These are observed views, not newly discovered or independent source families.
    reviews = {
        'VR_42078153': {
            'view': '湖口浅阶与树池之间，转向广场外沿',
            'visible': ['弧形浅阶和阶脚排水开口', '灰色通行带', '黑色细灯柱', '外沿树列'],
            'not_resolved': '远侧铺地与车道/侧步道的接缝未读清；没有唯一固定物可与环岛对应。'},
        'VR_116384446': {
            'view': '环岛向书院站、再反向湖口/北门热点',
            'visible': ['种植岛浅色路缘', '外侧红灰铺地', '过街标志', '矮柱', '草坡上的浅色横牌', '局部台阶'],
            'not_resolved': '标志附近有路面亮色条纹，但湖口对应的完整过街线及两端落脚接缝仍不清楚。局部台阶未匹配到湖口浅阶。'},
        'VR_130095287': {
            'view': '北门入口转向湖口/环岛热点的路侧',
            'visible': ['门岗与音乐学院竖牌', '矮柱', '沿车道的红色窄条铺地和灰色步行面', '树列与草坡', '弯曲车道边线'],
            'not_resolved': '可见路侧空间到弯道处被遮挡；没有在该画面读出湖口树池或环岛横牌的同一性。'},
        'VR_116384465': {
            'view': '书院站建筑夹道与反向环岛热点',
            'visible': ['多组白色斑马线', '过街标志', '浅色侧铺地', '道路导流斜线', '树荫弯道'],
            'not_resolved': '这里的斑马线局部存在已确认；它不是116384446同一拍摄点，不能移作湖口接入证明。'}
    }
    pairs = [
        ('PAIR_LAKE_RING', 'VR_42078153', 'VR_116384446', ['灰石通行带外沿与红灰侧铺地接缝', '黑色步道灯与道路灯的空间接续'], '没有读出共享的独特地面接缝；热点跳转跳过中间地面。'),
        ('PAIR_LAKE_GATE', 'VR_42078153', 'VR_130095287', ['树池/浅阶与门外道路边缘', '灰色步道的转折'], '北门路侧连续可见范围在弯道被遮挡，未与湖口对接。'),
        ('PAIR_GATE_RING', 'VR_130095287', 'VR_116384446', ['草坡、横牌/竖牌、树列与路缘', '侧铺地接缝与灯柱顺序'], '草坡和同类路灯不足以确认同一地点；横牌与竖牌不是同一固定物。'),
        ('PAIR_STATION_RING', 'VR_116384465', 'VR_116384446', ['斑马线落脚点', '树荫弯道与路缘'], '反向路口附近设施可见，弯道中间无重叠地面链；不能用邻站斑马线代替目标过街。')
    ]
    chains = [dict(id=i, from_reference=a, to_reference=b, compared_cues=cues,
                   matched_unique_ground_cues=[], continuity='unknown', reverse_views_reviewed=True,
                   reason=reason) for i, a, b, cues, reason in pairs]
    options = [
        ('A', '直接步道接入', '湖口灰石通行带可见。', '广场外沿到环岛侧铺地的实际开口未确认。'),
        ('B', '沿路侧人行道绕行', '环岛红灰侧铺地、北门灰色步行面各自在本地连续可见。', '尚无同一路缘/灯柱的跨视角连续匹配，不能选定整条绕行路线。'),
        ('C', '独立坡道', '未在已审阅范围内确认连接两端的独立坡道。', '缺入口、坡面及出口连续画面；不能据未看见判定不存在。'),
        ('D', '台阶接入', '湖口浅阶与环岛一侧局部台阶各自可见。', '两组台阶未确认同一性，也没有证明它们属于同一通行线。'),
        ('E', '另一侧步行连接', '书院站有斑马线与侧铺地。', '该位置不是湖口接点，替代连接及其回接仍未证明。'),
        ('F', '当前接点假设不成立', '尚不能确认候选环岛是湖口步行遇到的第一个岔路。', '缺少正向完整抵达和反向回接证据，保留此可能。')
    ]
    access_options = [dict(id=i, name_zh=name, observed=seen, missing=missing,
                          route_status='unknown', selected=False) for i, name, seen, missing in options]
    gaps = [
        dict(id='GAP_A', segment_id='GroundSegment_D03', name_zh='中间道路连续性', status='unknown', closed=False,
             reviewed_references=['VR_42078153', 'VR_130095287', 'VR_116384446'],
             evidence_count=3, source_family_count=1, matched_chain_links=0,
             missing_zh='广场外沿与路侧地面的重叠接缝',
             required_evidence='从灰石广场外沿走至实际车道/步道接点的重叠正反向画面，包含同一灯柱、路缘和铺地变化。'),
        dict(id='GAP_B', segment_id='GroundSegment_D04', name_zh='环岛人行接入', status='unknown', closed=False,
             reviewed_references=['VR_116384446', 'VR_116384465', 'VR_130095287'],
             evidence_count=3, source_family_count=1, matched_chain_links=0,
             missing_zh='湖口侧开口与过街两端落脚点',
             required_evidence='从湖口侧步道开口连续显示如何沿边、过街或上台阶抵达候选环岛，再回拍同一落脚点。')
    ]
    # Relevance check of the existing triangle inventory, not another whole-model audit.
    topology_path = 'references/legacy_models/ground_topology.json'
    topology = read(topology_path)
    candidates = []
    for f in topology['files']:
        for n in f['nodes']:
            if 'road' in n['name'].lower():
                candidates.append(dict(source_path=f['source_path'], source_sha256=f['sha256'],
                    node_id=n['source_node_id'], name=n['name'], triangles=n['triangles'],
                    low_slope_connectivity=n['low_slope_connectivity'],
                    gap_anchor=n['geographic_anchor'], eligible_for_targeted_triangle_reaudit=False,
                    reason='未匹配湖口、目标环岛或人行开口；名称/相邻包围盒不足以确定相关区域。'))
    assert len(candidates) == 13
    relevance = dict(version=VERSION, source_commit=topology['source_commit'],
        parent_audit=topology_path, parent_audit_sha256=hashlib.sha256((ROOT/topology_path).read_bytes()).hexdigest(),
        scope=['GAP_A', 'GAP_B'], method='Review existing road-node identities and triangle connectivity only; require a gap anchor before selecting a spatial subset.',
        candidates=candidates, matched_candidates=0, new_triangles_audited=0,
        decision='No relevant spatial subset can be defensibly selected. Prior mesh adjacency cannot raise either gap confidence.',
        conflict_status='not_comparable_without_registration', conflicts=[], used_for_geometry=False)
    write('references/legacy_models/gap_relevance.json', relevance)
    matrix = []
    for s in previous['segments']:
        g = next((g for g in gaps if g['segment_id'] == s['id']), None)
        matrix.append(dict(id=s['id'], name_zh=s['name_zh'], confidence=s['confidence'],
            previous_confidence=s['confidence'], geometry_source=s['geometry_source'], visual_source=s['visual_source'],
            reviewed_references=g['reviewed_references'] if g else ['VR_42078153'],
            remaining_gap=g['missing_zh'] if g else '局部连续性无新增缺口；真实位置仍未配准',
            geographic_registration='unknown', game_position=None, new_walkable=False))
    report = dict(version=VERSION, reviewed_at=DATE, previous_report='references/regions/fairy_lake/v10d_ground_evidence.json',
        frozen_baseline=previous['frozen_baseline'], scope=['GAP_A', 'GAP_B'], reviews=reviews,
        source_family='OFFICIAL_VR', source_capture_dates='unknown', reverse_view_checks=chains,
        gaps=gaps, roundabout_options=access_options, segment_reviews=matrix,
        coverage=dict(verified=2, strong_inferred=0, unknown=2, closed_gaps=0, game_registered_segments=0),
        unknown_gap_change=dict(previous_open=2, current_open=2, measurable_reduction=None,
            note='补充局部设施与替代解释；没有已证实的连续链进展，不能报告百分比或距离缩短。'),
        dae_analysis='references/legacy_models/gap_relevance.json',
        conflicts=[], conflict_note='资料不能配准，不伪造DAE与全景的几何冲突。',
        phase_e_ready=False, new_walkable_segments=0, new_semantic_objects=[], screenshots_saved=False,
        conclusion='两个缺口均未关闭；维持Phase D，不创建人行连接或真实岔路。')
    write('references/regions/fairy_lake/v10d2_gap_closure.json', report)
    runtime = read('systems/data/ground_survey.json')
    runtime.update(version=VERSION, gap_review=copy.deepcopy(gaps), phase_e_ready=False)
    write('systems/data/ground_survey.json', runtime)
    vr = read('references/vr/scene_catalog.json')
    for r in vr['references']:
        if r['reference_id'] in reviews:
            r['phase_d2_ground_review'] = reviews[r['reference_id']]
            r['reviewed_at'] = DATE
            r['review_status'] = 'PARTIALLY_VISUALLY_REVIEWED'
    write('references/vr/scene_catalog.json', vr)
    index = read('references/index.json')
    index['scope'] = 'V1.0 Phase D2: bounded middle-road and pedestrian-access gap review; both unresolved, no new path'
    for r in index['references']:
        if r['reference_id'] == 'OFFICIAL_VR':
            r['phase_d2_note'] = '仅重查湖口、环岛、北门与书院站的正反向地面；设施局部可见，不构成连续路线。'
        if r['reference_id'] == 'LEGACY_DAE':
            r['gap_relevance_analysis'] = 'references/legacy_models/gap_relevance.json'
    write('references/index.json', index)
    pack = read('references/regions/fairy_lake/pack.json')
    pack['phase_d2_gap_closure'] = 'references/regions/fairy_lake/v10d2_gap_closure.json'
    write('references/regions/fairy_lake/pack.json', pack)
    unresolved = read('references/unresolved/gaps.json')
    for item in unresolved['gaps']:
        for g in gaps:
            if item['gap_id'] == 'ground_d' + g['segment_id'][-2:]:
                item.update(request=g['required_evidence'], phase_d2_status='unknown',
                    phase_d2_reviewed_references=g['reviewed_references'])
    write('references/unresolved/gaps.json', unresolved)
    search = read('references/unresolved/search_log.json')
    search['phase_d2'] = dict(date=DATE, queries=['"香港中文大学" "神仙湖" "环岛" 人行', '"港中深" "神仙湖" "入口" 步道'],
        excluded_results=['Unrelated campus activity text', 'Polluted search-index URLs', 'General architectural descriptions without ground continuity'],
        reviewed_ground_scenes=[42078153,116384446,130095287,116384465],
        result='No new continuous ground chain or independent matched DAE source; both gaps remain open.')
    write('references/unresolved/search_log.json', search)
    catalog = read('assets/campus/environment_catalog.json')
    catalog.update(version=VERSION, phase_d2=dict(new_geometry_assets=0, ground_geometry_unchanged=True,
        ground_evidence='references/regions/fairy_lake/v10d2_gap_closure.json'))
    write('assets/campus/environment_catalog.json', catalog)
    assets = read('docs/asset_catalog.json')
    assets['phase_d2_note'] = '两缺口补证；无新资产或模型导入，旧DAE未能锁定相关空间子集。'
    write('docs/asset_catalog.json', assets)
    rows = ''.join('<tr><td>' + html.escape(o['name_zh']) + '</td><td>' + html.escape(o['observed']) + '</td><td>' + html.escape(o['missing']) + '</td></tr>' for o in access_options)
    panel = '<section id="gap-review"><h2>第二轮补证：两个缺口仍未关闭</h2><p>缺口甲：中间道路重叠接缝。缺口乙：湖口侧人行开口及过街落脚点。4个调查段仍为已核实2、强推断0、未知2；计数不是路线完成率。</p><p>本轮4个全景来自同一官方项目，正反向查看不自动成为独立证据。书院站斑马线不能移作湖口过街证明。</p><table><thead><tr><th>环岛接入假设（均未选定）</th><th>已观察</th><th>仍缺什么</th></tr></thead><tbody>' + rows + '</tbody></table><p><a href="regions/fairy_lake/v10d2_gap_closure.json">逐对视角核查</a>　<a href="legacy_models/gap_relevance.json">旧模型相关性核查</a>　<a href="../docs/V10_PHASE_D2_GAP_CLOSURE.md">第二轮结论</a></p></section>'
    p = ROOT / 'references/viewer.html'
    content = p.read_text('utf8')
    content = re.sub(r'<section id="gap-review">.*?</section>', '', content, flags=re.S)
    content = content.replace('<nav>', panel + '<nav>', 1)
    content = content.replace('校园参考库 · V1.0 Phase D</title>', '校园参考库 · V1.0 Phase D2</title>')
    content = re.sub(r'(<script[^>]*id="data"[^>]*>).*?(</script>)', lambda m:m[1]+json.dumps(index['references'],ensure_ascii=False)+m[2], content, flags=re.S)
    p.write_text(content, encoding='utf8')
    print(json.dumps(report['coverage']))


if __name__ == '__main__':
    main()
