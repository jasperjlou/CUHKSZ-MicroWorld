"""Apply the two reviewed V0.7 panorama annotations without replacing the library."""
import json
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[1]

def read(path):
    return json.loads((ROOT / path).read_text(encoding="utf-8"))

def write(path, value):
    (ROOT / path).write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

def main():
    catalog = read("references/vr/scene_catalog.json")
    notes = {
        "VR_42078153": "V0.7已查看入口地面全景的默认画面：题字石、灰色铺地、树荫和延伸道路。没有核定到上下园的实际连接、方位、路宽或高程。",
        "VR_42078154": "V0.7已查看湖畔地面全景的默认画面：画面左侧湖面与金属栏杆、深色扶手和木栈道；右侧树带后有平行灰路；前方白色圆顶亭，对岸树山。左右仅是该视角，不是指南针方向。未进行全周扫描或连续测量。",
    }
    for row in catalog["references"]:
        if row["reference_id"] in notes:
            row["review_status"] = "PARTIALLY_VISUALLY_REVIEWED"
            row["notes"] = notes[row["reference_id"]]
            row["reviewed_at"] = "2026-09-26"
    write("references/vr/scene_catalog.json", catalog)
    index = read("references/index.json")
    index["scope"] = "V0.7 reference-supported lake slice; not a surveyed digital twin"
    for row in index["references"]:
        if row["reference_id"] == "OFFICIAL_VR":
            row["notes"] = "已抽看神仙湖空中场景，并在V0.7补审入口42078153及湖畔42078154的默认地面画面。其它场景仍以各条review_status为准；全景链接不等于可走道路，拍摄日期未知。"
    write("references/index.json", index)
    pack = read("references/regions/fairy_lake/pack.json")
    for slot in pack["slots"]:
        key = slot["slot"]
        if key == "entrance":
            slot.update(status="PARTIAL", reference_ids=["VR_42078153", "LAKE_09"], notes=notes["VR_42078153"])
        elif key in {"main_path", "left_side", "right_side", "forward_view", "road", "landmark"}:
            slot.update(status="PARTIAL", reference_ids=["VR_42078154", "LAKE_06"], notes=notes["VR_42078154"])
        elif key == "elevation":
            slot.update(status="NEEDS_REFERENCE", reference_ids=[], notes="实际高差、坡度及连续高程暂无可靠证据。V0.7缓坡明确为placeholder；不从单张照片推导实测数值。")
    pack["notes"] = "V0.7已建独立有限短段。外观verified不等于位置verified；具体坐标与宽度inferred，高差和上下园接点placeholder。反向视角和连续地面路线仍缺。"
    write("references/regions/fairy_lake/pack.json", pack)
    viewer = ROOT / "references/viewer.html"
    text = viewer.read_text(encoding="utf-8").replace("V0.6.5", "V0.7")
    text, count = re.subn(r'(<script[^>]*id="data"[^>]*>).*?(</script>)', lambda m: m[1] + json.dumps(index["references"], ensure_ascii=False) + m[2], text, flags=re.S)
    if count != 1:
        raise RuntimeError("Expected exactly one embedded reference data block")
    viewer.write_text(text, encoding="utf-8")
    print("Updated 2 panorama reviews, main summary, lake pack and embedded viewer records.")

if __name__ == "__main__":
    main()
