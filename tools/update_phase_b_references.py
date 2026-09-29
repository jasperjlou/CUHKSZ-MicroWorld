"""Cumulative Phase B evidence update; does not import imagery or upgrade geography."""
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
        "VR_42078153": "Phase B 补看同一入口拍摄点的多方向：弧形浅阶、树池、灰石铺地和平直通行带。无指南针、连续高程或精确接点标定。",
        "VR_116384446": "Phase B 交互转向核看环岛多个画面：弯曲沥青路、浅色路缘、红灰色侧铺地、草坪灌木和树带；一侧可见浅色高层轮廓，另一侧可见道路分向。建筑身份未绑定，热点不等于可行走连接。",
        "VR_130095287": "Phase B 核看音乐学院及第八书院北门的门前及两侧道路：灰车道、窄人行铺地、路缘、单臂灯与道路另一侧绿化坡。仅画面可见范围；没有完成湖口至门口连续路线校准。"
    }
    vr = read("references/vr/scene_catalog.json")
    for row in vr["references"]:
        if row["reference_id"] in reviews:
            row.update(review_status="PARTIALLY_VISUALLY_REVIEWED", reviewed_at="2026-09-27", notes=reviews[row["reference_id"]])
    write("references/vr/scene_catalog.json", vr)
    index = read("references/index.json")
    ref_id = "OFFICIAL_MIDDLE_CONNECTION"
    record = {"reference_id": ref_id, "subject": "校方对中园机动车道及绿道连接上下园的说明", "region": "campus", "location": "中园；未给出精确连接坐标", "view_direction": "NOT_APPLICABLE", "source_type": "OFFICIAL", "source_url": "https://admissions.cuhk.edu.cn/node/909", "source_owner": "香港中文大学（深圳）招生办公室", "date_accessed": "2026-09-27", "license_status": "参考阅读；不包含游戏资产授权", "reuse_status": "ASSET_REUSE_UNKNOWN", "reference_status": "REFERENCE_ALLOWED", "confidence": "STRONG_REFERENCE", "review_status": "SOURCE_TEXT_REVIEWED", "notes": "正文说明中园为绿化及神仙湖区域，有机动车道与绿道连通上下园。只验证连接存在与交通类别，不给游戏林缘端点定位，不升级局部拓扑。另有神仙湖校区建设项目，不与本次湖边景观空间混淆。", "asset_imported": False}
    index["references"] = [r for r in index["references"] if r["reference_id"] != ref_id] + [record]
    index["scope"] = "V1.0 Phase B: reference-supported local forest-edge/roadside composition; inter-campus connector unknown"
    for row in index["references"]:
        if row["reference_id"] == "OFFICIAL_VR":
            row["notes"] = "Phase B 在原湖区审阅基础上，补看湖口42078153、环岛116384446、音乐学院北门130095287多方向。其余以各场景状态为准；拍摄时间未知，热点图不是道路连通图。"
    write("references/index.json", index)
    evidence = {
        "version": "1.0.0-phase-b", "reviewed_at": "2026-09-27", "sources": list(reviews) + [ref_id, "SHUTTLE_SCHEDULE", "LEGACY_DAE"],
        "review_notes": reviews,
        "verified": ["grey entrance paving, terraces and tree planters", "curved asphalt road, pale curbs, red-grey roadside paving, low planting", "single-arm lamp and green roadside slope in gate panorama", "anonymous pale tower silhouettes in roundabout view", "official text states vehicle road and greenway connect upper/lower campus"],
        "inferred": ["local composition sequence combining entrance and roadside references", "game bend, width, count, positions and vegetation density", "35.238 game-unit extension, NOT surveyed metres"],
        "unknown": ["geographic anchoring of Phase A end", "actual junction sequence and precise upper/lower endpoints", "continuous pedestrian route, crossing and accessibility", "surveyed elevation, slope and dimensions", "capture date and present-day match", "tower identity"],
        "placeholder": ["gentle elevation profile", "broad underlay landmass", "UNKNOWN_CONNECTOR bounded endpoint"],
        "candidate_connections": [
            {"from": "lake entrance", "via": "roundabout", "towards": "college station / upper campus", "status": "candidate_only", "basis": "official text plus panorama views and hotspot leads", "continuous_walk_verified": False},
            {"from": "lake entrance", "via": "MUS north gate", "towards": "sports hall / lower campus", "status": "candidate_only", "basis": "roadside views, official transport stop sequence and hotspot leads", "continuous_walk_verified": False}
        ],
        "legacy_models": {"existing_audit": "references/legacy_models/spatial_skeleton.json", "files": 4, "instances": 123, "used_for_placement": False, "reason": "No calibrated lake anchor; do not convert DAE units to metres."},
        "assets_imported": False, "panorama_capture_saved": False,
        "missing_evidence": ["ground views between lake plaza edge and adjacent vehicle-road junction", "both approach directions at each real fork", "slope bottom/top and route width calibration", "safe footway/crossing continuity", "current shuttle stop positions", "dated reference matching current campus"]
    }
    write("references/regions/fairy_lake/v10b_connector_evidence.json", evidence)
    pack = read("references/regions/fairy_lake/pack.json")
    for slot in pack["slots"]:
        if slot["slot"] == "road":
            slot.update(status="PARTIAL", reference_ids=["VR_116384446", "VR_130095287", ref_id], notes="补看环岛和北门路侧构成。局部道路可见；湖口至具体上下园接点的完整步行序列仍未知。")
    pack["notes"] = "Phase A + B 有限局部空间已开放；入口、路侧构成有视觉依据，组合与坐标推断，高程与真实接点占位。UNKNOWN_CONNECTOR 不代表已经接通上下园。"
    write("references/regions/fairy_lake/pack.json", pack)
    catalog = read("assets/campus/environment_catalog.json")
    catalog["version"] = "1.0.0-phase-b"
    additions = [
        ("pale_curb", "浅色路缘模块", "StreetFurniture", "assets/campus/PaleCurb.tscn", True, ["VR_116384446", "VR_130095287"]),
        ("single_arm_lamp", "单臂路灯", "StreetFurniture", "assets/campus/SingleArmLamp.tscn", True, ["VR_130095287"]),
        ("forest_roadside_path", "林缘路侧铺地", "Path", "world/ForestConnectorBuilder.gd", False, ["VR_42078153", "VR_116384446", "VR_130095287"]),
        ("connector_road_backdrop", "车道与未命名建筑远景", "Background", "world/ForestConnectorBuilder.gd", False, ["VR_116384446"])
    ]
    for aid, title, category, path, reusable, sources in additions:
        catalog["assets"] = [a for a in catalog["assets"] if a["asset_id"] != aid]
        catalog["assets"].append({"asset_id": aid, "name_zh": title, "category": category, "path": path, "implementation": "prefab" if path.endswith("tscn") else "procedural", "reusable": reusable, "version": "1.0.0-phase-b", "source_reference_ids": sources, "provenance": "Original procedural geometry based on visible material/shape categories; placement inferred", "license": "Project-authored, no third-party mesh or texture imported", "confidence": {"presence": "verified", "position": "inferred", "dimensions": "inferred", "elevation": "placeholder"}})
    write("assets/campus/environment_catalog.json", catalog)
    viewer = ROOT / "references/viewer.html"
    source = viewer.read_text(encoding="utf8").replace("校园参考库 · V1.0 Phase A", "校园参考库 · V1.0 Phase B")
    source, count = re.subn(r'(<script[^>]*id="data"[^>]*>).*?(</script>)', lambda m: m[1] + json.dumps(index["references"], ensure_ascii=False) + m[2], source, flags=re.S)
    if count != 1:
        raise RuntimeError("Expected one embedded reference data block")
    viewer.write_text(source, encoding="utf8")
    print("Phase B: 3 panorama review records, 1 official text source, evidence matrix, 4 asset entries and viewer updated.")


if __name__ == "__main__":
    main()
