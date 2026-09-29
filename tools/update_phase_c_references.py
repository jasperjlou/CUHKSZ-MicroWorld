"""Cumulative, bounded Phase C review. No imported assets or invented connections."""
import json
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[1]


def read(path):
    return json.loads((ROOT / path).read_text(encoding="utf8"))


def write(path, data):
    (ROOT / path).write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf8")


def main():
    reviews = {
        "VR_116384465": "Phase C 同点多朝向审阅：书院站环岛路口有斑马线、浅色路缘；一向为两侧建筑夹道，一向为树荫弯道。建筑间视廊不能直接等同游戏林缘前沿。热点仅辅助定位拍摄点。",
        "VR_116384466": "Phase C 同点多朝向审阅：下沉草坪、灰白裙房、白色窗墙、宽台阶与扶手，台阶上方有连桥。可作为特征组合锚点；没有证实它与游戏端点之间的路线。",
        "VR_116440784": "Phase C 同点多朝向审阅：入口可读大学体育馆馆名，深色竖向格栅、门廊与白色横梁；转向可见树坡、浅色挡墙、另一侧深色塔楼与橙色立面。与游戏浅色双塔不能无依据认作同一建筑。"
    }
    vr = read("references/vr/scene_catalog.json")
    for row in vr["references"]:
        if row["reference_id"] in reviews:
            row.update(review_status="PARTIALLY_VISUALLY_REVIEWED", reviewed_at="2026-09-27", notes=reviews[row["reference_id"]])
    write("references/vr/scene_catalog.json", vr)
    matrix = []

    def row(element, sources, interpretation, confidence, conflict, missing, scope="frontier_geography"):
        matrix.append(dict(element=element, sources=sources, interpretation=interpretation, confidence=confidence,
                           conflict=conflict, missing_evidence=missing, scope=scope))

    row("冻结前沿", [], "游戏坐标(1,3.05,111)固定；真实校园拍摄点尚未配准。", "unknown", "游戏坐标已知不等于地理坐标已知。", "湖口题字石到第一个道路分岔的连续地面视图。")
    row("步道继续与左右岔路", ["VR_42078153","VR_116384446"], "实景存在路口；无法把游戏末端唯一绑定到其中一条支路。", "unknown", "热点跳转跨过未见路段。", "同一岔路来向、去向及左右侧连续画面。")
    row("坡度及台阶", ["VR_116384466","LEGACY_DAE"], "书院中庭台阶可见；前沿是否接入该台阶未知。", "unknown", "旧模型无已命名湖区锚点，不能与相片做高程配准。", "前沿锚点、高差参照和坡顶坡底照片。")
    row("书院站斑马线与建筑夹道", ["VR_116384465"], "同点多个朝向直接看到斑马线、路缘和建筑夹道，是可复查的局部路口锚点。", "verified", "不能把当前开阔林缘场景认作这个路口。", "通向湖口的中间路段；拍摄年代。", "reference_local_feature")
    row("书院中庭台阶与连桥", ["VR_116384466"], "下沉草坪、宽阶、扶手、跨空连桥组合可识别。", "verified", "单独台阶或白墙不具唯一性，应匹配整组特征。", "与道路路口的连续步行连接及无障碍绕行。", "reference_local_feature")
    row("书院站与中庭局部关联", ["VR_116384465","VR_116384466"], "白色窗墙及台阶口视线支持相邻候选，双向热点仅作辅助；局部关联推断。", "inferred", "两个全景属于同一制作来源，不算两个独立来源；没有标定距离。", "匹配台阶顶端与路口的人行铺地连续细节。", "reference_local_relation")
    row("体育馆有名入口", ["VR_116440784"], "现场馆名、深格栅门廊与白色梁架共同锁定大学体育馆入口外观。", "verified", "馆名证明身份，不证明从湖口到这里的路线。", "由音乐学院北门至该入口的连续步行路侧。", "reference_local_feature")
    row("体育馆侧挡墙与坡面", ["VR_116440784"], "转向可见浅色挡墙和树坡；存在性可靠。", "verified", "不能将它移植成前沿必经挡墙。", "墙脚与连续人行面的对应。", "reference_local_feature")
    row("游戏双塔的真实身份", ["VR_116384446","VR_116384465","VR_116440784"], "继续保留匿名浅色建筑远景；多画面中塔楼形态不同，尚无同一物体匹配。", "unknown", "体育馆侧深色塔楼/橙色立面与游戏浅色双塔明显不同，拒绝同名绑定。", "至少两个已知拍摄点对同一立面的共同可见特征。")
    row("前沿车行道与行人接点", ["VR_116384446","VR_130095287","VR_116384465"], "路缘、车道和部分路侧铺地有依据；游戏侧路的连接关系仍未知。", "unknown", "将多个有车道的拍摄点拼接不能证明一条连续人行路线。", "路口过街点、连续铺地、围栏缺口。")
    row("林缘结束与回看湖面", ["VR_42078153","VR_116384446"], "湖口可见湖面；无法标定游戏终点回看湖面的遮挡范围。", "unknown", "当前树密度和宽阔地形是布局近似。", "由路口回望题字石/湖面的地面照片。")
    row("路牌及接驳站", ["VR_116384465","SHUTTLE_SCHEDULE"], "书院站是官方全景名及班次表中的定位线索；不据此生成精确站牌。", "unknown", "路线站序不是当前站台位置。", "带站名、道路朝向和邻接建筑的现场照片。")
    row("真实上下园方向", ["OFFICIAL_MIDDLE_CONNECTION","LEGACY_DAE"], "中园有连接上下园的道路/绿道；冻结前沿应走哪一支仍无可靠配准。", "unknown", "DAE数字节点不提供可验证湖口对应点。", "至少一段直接连接冻结前沿锚点的可靠地面序列。")
    anchors = [
        dict(id="REF_COLLEGE_CROSSING", name_zh="书院站路口", reference_id="VR_116384465", features=["斑马线","浅色路缘","两侧建筑夹道"], confidence="verified"),
        dict(id="REF_ATRIUM_STAIR_BRIDGE", name_zh="书院中庭台阶与连桥", reference_id="VR_116384466", features=["下沉草坪","宽台阶与扶手","台阶上方连桥"], confidence="verified"),
        dict(id="REF_SPORTS_HALL_PORTAL", name_zh="大学体育馆入口", reference_id="VR_116440784", features=["现场馆名","深色竖向格栅","白色门前梁架"], confidence="verified")
    ]
    for anchor in anchors:
        anchor.update(game_position=None, game_registered=False, walkable=False, type="reference_landmark", zone="reference_only", obstacle=False, connector=False, landmark=True, geographic_relation_to_frontier="unknown")
    evidence = dict(version="1.0.0-phase-c", reviewed_at="2026-09-27", frontier_manifest="references/regions/fairy_lake/frontier_connector_b.json",
                    extension_enabled=False, added_path_game_units=0, source_independence="All reviewed VR scenes belong to one official tour; they are not independent sources.",
                    matrix=matrix, reference_landmarks=anchors, reviews=reviews, screenshots_saved=False, assets_imported=False,
                    build_gate=dict(two_independent_sources=False, directly_registered_official_panorama=False, calibrated_photo_dae_agreement=False, decision="NO_EXTENSION"),
                    resolutions=dict(reference_features_unknown_to_verified=4, local_relation_unknown_to_inferred=1, frontier_topology_resolved=0),
                    legacy=dict(files=4,instances=123,used_for_placement=False,reason="Uncalibrated export units and no lake anchor"),
                    next_phase="Resolve geographic registration before expansion; no predetermined upper/lower connector.")
    write("references/regions/fairy_lake/v10c_frontier_evidence.json", evidence)
    index = read("references/index.json")
    index["scope"] = "V1.0 Phase C: frozen frontier, three reference landmark anchors, no geographic registration or new path"
    for r in index["references"]:
        if r["reference_id"] == "OFFICIAL_VR":
            r["notes"] += " Phase C 新审阅书院站环岛116384465、中庭116384466、体育馆门前116440784。详见前沿证据矩阵；只锁定参考地标，未锁定游戏地理位置。" if "Phase C" not in r["notes"] else ""
    write("references/index.json", index)
    for region, source_ids in [("upper_campus",["VR_116384465","VR_116384466"]),("lower_campus",["VR_116440784"]),("fairy_lake",list(reviews))]:
        path = "references/regions/" + region + "/pack.json"
        pack = read(path)
        pack["phase_c_review"] = dict(reference_ids=source_ids, evidence_matrix="references/regions/fairy_lake/v10c_frontier_evidence.json", geographic_registration="unknown")
        for slot in pack["slots"]:
            if slot["slot"] == "landmark":
                slot["reference_ids"] = sorted(set(slot["reference_ids"]+source_ids))
                slot["status"] = "PARTIAL"
                slot["notes"] = "新增同点多方向参考地标审阅；与冻结游戏前沿的地理关系尚未确定。"
        write(path,pack)
    catalog = read("assets/campus/environment_catalog.json")
    catalog["version"] = "1.0.0-phase-c"
    catalog["phase_c"] = dict(new_geometry_assets=0, reference_landmarks_not_instantiated=[a["id"] for a in anchors], evidence_matrix="references/regions/fairy_lake/v10c_frontier_evidence.json")
    for asset in catalog["assets"]:
        if asset["asset_id"] in ["forest_roadside_path","connector_road_backdrop"]:
            asset["confidence"]["geographic_anchor"] = "unknown"
            if asset["asset_id"] == "connector_road_backdrop":
                asset["confidence"]["position"] = "placeholder"
                asset["confidence"]["identity"] = "unknown"
    write("assets/campus/environment_catalog.json",catalog)
    gaps=read("references/unresolved/gaps.json")
    gaps["updated_at"]="2026-09-28"
    gaps["gaps"]=[g for g in gaps["gaps"] if g["gap_id"]!="frontier_b_registration"]
    gaps["gaps"].append(dict(gap_id="frontier_b_registration",region="fairy_lake",status="NEEDS_REFERENCE",request="先绑定湖口题字石，再补广场边缘到第一岔路的连续地面正反向视图；附路缘与过街细节。",searched_reference_ids=list(reviews)+["VR_42078153","VR_116384446","VR_130095287","LEGACY_DAE"],reason="游戏终点是多个场景构成的局部布局，未地理配准；新审阅参考锚点不能自动生成连接。"))
    write("references/unresolved/gaps.json",gaps)
    viewer=ROOT/"references/viewer.html"
    s=viewer.read_text('utf8').replace("校园参考库 · V1.0 Phase B","校园参考库 · V1.0 Phase C").replace("31条主资料",f"{len(index['references'])}条主资料")
    s=re.sub(r'(<script[^>]*id="data"[^>]*>).*?(</script>)',lambda m:m[1]+json.dumps(index['references'],ensure_ascii=False)+m[2],s,flags=re.S)
    if 'id="frontier-review"' not in s:
        links=''.join(f'<li><a href="https://campusvr-en.cuhk.edu.cn/?scene_id={a["reference_id"][3:]}" target="_blank" rel="noopener noreferrer">{a["name_zh"]}</a>：'+"、".join(a['features'])+'</li>' for a in anchors)
        s=s.replace('<nav>', '<section id="frontier-review"><h2>前沿调查：先定位，再连路</h2><p>林缘端点已冻结；本轮新增路径为零。以下三组地标已在参考全景中核实，尚未配准进游戏。</p><ul>'+links+'</ul><p><a href="regions/fairy_lake/v10c_frontier_evidence.json">完整前沿证据矩阵</a>　<a href="../docs/V10_PHASE_C_CONNECTOR_RESOLUTION.md">调查结论与缺口</a></p></section><nav>')
    viewer.write_text(s,encoding='utf8')
    print("Phase C: 13 matrix rows, 3 reference anchors; no new path, no geographic registration.")


if __name__ == "__main__":
    main()
