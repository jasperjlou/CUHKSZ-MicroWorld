"""Record a bounded entrance reference review without upgrading geographic certainty."""
import json
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[1]


def read(path):
    return json.loads((ROOT / path).read_text(encoding="utf-8"))


def write(path, value):
    (ROOT / path).write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main():
    note = "V1.0 Phase A 在官方入口全景同一拍摄点转向补看临湖及背湖多个画面：灰石铺地、方形高起树池、浅台阶与平直通行带，临湖题字石。未校准方位、尺寸、高程或真实上下园连续路线；全景热点不是道路通行证据。"
    vr = read("references/vr/scene_catalog.json")
    for row in vr["references"]:
        if row["reference_id"] == "VR_42078153":
            row.update(review_status="PARTIALLY_VISUALLY_REVIEWED", notes=note, reviewed_at="2026-09-26")
    write("references/vr/scene_catalog.json", vr)
    index = read("references/index.json")
    index["scope"] = "V1.0 Phase A: bounded Fairy Lake entrance extension; not a surveyed or connected campus twin"
    for row in index["references"]:
        if row["reference_id"] == "OFFICIAL_VR":
            row["notes"] = note + " 其他场景以各条 review_status 为准；拍摄日期未知。"
    write("references/index.json", index)
    pack = read("references/regions/fairy_lake/pack.json")
    for slot in pack["slots"]:
        if slot["slot"] == "entrance":
            slot.update(status="PARTIAL", reference_ids=["VR_42078153", "LAKE_09"], notes=note)
        elif slot["slot"] == "reverse_view":
            slot.update(status="PARTIAL", reference_ids=["VR_42078153"], notes="已补看同一入口拍摄点的相反朝向；并非沿路线连续采样，也没有方位角或上下园接点标定。")
    pack["notes"] = "V1.0 Phase A 开放游戏入口过渡区。外观类别有图像依据；坐标、拓扑、宽度为 inferred，高差及上下园接点为 placeholder。真实跨园连接仍关闭。"
    write("references/regions/fairy_lake/pack.json", pack)
    evidence = {
        "version": "1.0.0-phase-a", "reviewed_at": "2026-09-26",
        "selected_end": "existing Fairy Lake entry, towards tree-lined forecourt",
        "decision": "Entrance panorama provides direct local paving, planter and terrace evidence; exit has insufficient continuous-route evidence.",
        "sources": [
            {"reference_id": "VR_42078153", "url": "https://campusvr-en.cuhk.edu.cn/?scene_id=42078153", "method": "interactive browser, multiple directions from same point", "views": ["lakeward: paving and tree planters, shallow terraces, inscription stone", "landward: flat paved corridor among trees and raised terrace banks"], "compass_calibrated": False, "full_360_review": False, "capture_saved": False, "license": "UNCONFIRMED_REFERENCE_ONLY"},
            {"reference_id": "LAKE_09", "url": "https://mbm.cuhk.edu.cn/sites/default/files/inline-images/1659604623131607.jpg", "local_original": "references/official/originals/lake_09.jpg", "observation": "Tall vertical stone with vertical inscription 神仙湖; planting at base and lake behind", "license": "UNCONFIRMED_REFERENCE_ONLY"},
            {"reference_id": "LAKE_06", "url": "https://mbm.cuhk.edu.cn/sites/default/files/inline-images/1659604580739500.jpg", "local_original": "references/official/originals/lake_06.jpg", "observation": "Lakeward rail with dark cap, boardwalk, landward vegetation and pale domed pavilion", "license": "UNCONFIRMED_REFERENCE_ONLY"}
        ],
        "verified": ["visual presence of grey paving, square tree planters, trees, shallow terraces", "vertical inscription stone form and text", "lake, railing, boardwalk, vegetation and domed pavilion appearance"],
        "inferred": ["game route bend and order, local zone boundary", "asset counts, positions, dimensions, vegetation density", "38.5348 game-unit extension, NOT measured metres"],
        "placeholder": ["elevation profile", "upper and lower campus connections", "prototype shuttle location and schedule", "far-end bounded research boundary"],
        "legacy_models": {"review": "Re-extracted four DAE files and 123 instances", "source": "https://github.com/newbie-at-cuhksz/virtual-campus-v2/tree/87e2d897fb2264a6b659407522a525f28f7cf211", "report": "tests/artifacts/v10-legacy-audit.json", "used_for_geometry": False, "reason": "No named lake anchor and uncalibrated units; numeric node names do not establish real building identities."},
        "asset_reuse": "No downloaded photograph, panorama texture or legacy mesh imported into game assets.",
        "remaining_gaps": ["ground-level continuous connections at both ends", "measured slope, route width and distance", "dated current street-level views and station positions", "panorama hotspot adjacency is not verified pedestrian connectivity"]
    }
    write("references/regions/fairy_lake/v10_entrance_evidence.json", evidence)
    viewer = ROOT / "references/viewer.html"
    source = viewer.read_text(encoding="utf-8").replace("V0.7 参考", "V1.0 Phase A 参考").replace("校园参考库 · V0.7", "校园参考库 · V1.0 Phase A")
    source, count = re.subn(r'(<script[^>]*id="data"[^>]*>).*?(</script>)', lambda m: m[1] + json.dumps(index["references"], ensure_ascii=False) + m[2], source, flags=re.S)
    if count != 1:
        raise RuntimeError("Expected one embedded reference data block")
    viewer.write_text(source, encoding="utf-8")
    catalog = {"version": "1.0.0-phase-a", "categories": ["Architecture", "Road", "Path", "Terrain", "Vegetation", "StreetFurniture", "Signage", "Lake", "Shuttle", "Landmark", "Background"], "assets": []}
    rows = [
        ("square_tree_planter", "方形树池与乔木", "StreetFurniture", "assets/campus/SquareTreePlanter.tscn", ["VR_42078153"], True, "verified"),
        ("granite_terrace", "浅石阶与平台", "Path", "assets/campus/GraniteTerrace.tscn", ["VR_42078153"], True, "verified"),
        ("entrance_paving", "入口灰石铺地", "Path", "world/EntranceBuilder.gd", ["VR_42078153"], False, "verified"),
        ("lake_pavilion", "湖畔圆亭", "Architecture", "world/FairyLakeBuilder.gd", ["LAKE_06"], False, "verified"),
        ("reserved_lake_road", "湖侧预留道路", "Road", "world/FairyLakeBuilder.gd", ["VR_42078154"], False, "verified"),
        ("grass_shoulder", "入口草地边坡", "Terrain", "world/EntranceBuilder.gd", ["VR_42078153"], False, "verified"),
        ("stylized_tree", "低多边形树", "Vegetation", "world/MeshKit.gd", ["VR_42078153"], True, "verified"),
        ("direction_sign", "方向占位导视", "Signage", "world/FairyLakeBuilder.gd", [], False, "placeholder"),
        ("lake_surface", "神仙湖水面", "Lake", "world/FairyLakeBuilder.gd", ["LAKE_06"], False, "verified"),
        ("prototype_shuttle", "原型接驳车", "Shuttle", "systems/LakeTransport.gd", [], False, "placeholder"),
        ("inscription_stone", "神仙湖竖向题字石", "Landmark", "world/FairyLakeBuilder.gd", ["LAKE_09"], False, "verified"),
        ("hill_backdrop", "远山背景", "Background", "world/FairyLakeBuilder.gd", ["VR_42078154"], False, "verified")
    ]
    for asset_id, title, category, path, refs, reusable, presence in rows:
        catalog["assets"].append({"asset_id": asset_id, "name_zh": title, "category": category, "path": path, "implementation": "prefab" if path.endswith("tscn") else "procedural", "reusable": reusable, "version": "1.0.0-phase-a", "source_reference_ids": refs, "provenance": "Original procedural geometry; source used only for visual reference", "license": "Project-authored; no third-party texture or mesh embedded", "confidence": {"presence": presence, "position": "inferred" if refs else "placeholder", "dimensions": "inferred", "elevation": "placeholder"}})
    write("assets/campus/environment_catalog.json", catalog)
    legacy_catalog = read("docs/asset_catalog.json")
    legacy_catalog["environment_catalog"] = "assets/campus/environment_catalog.json"
    write("docs/asset_catalog.json", legacy_catalog)
    print("V1.0 entrance evidence, viewer, review notes and environment asset catalog updated.")


if __name__ == "__main__":
    main()
