"""Preserve supplied files and produce a local reference-only contact gallery."""
import hashlib
import html
import json
import shutil
import argparse
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
REF = ROOT / 'references/regions/fairy_lake'
DEST = REF / 'originals/field_20260929'
DEST.mkdir(parents=True, exist_ok=True)
notes = {
    328: ('校园导览图', '图面标注2026年5月版；可辅助区域相邻关系，不是测量图，不能确认人行过街或高度。'),
    329: ('中式临水亭', '深色翘角瓦顶、木柱、白栏杆、架空台座；与当前圆顶亭身份未匹配，不替换。'),
    330: ('道扬书院门楼近景', '道揚書院与LING COLLEGE字样可读；灰门楼、竖联、后方白楼和右侧咖啡店。'),
    331: ('道扬书院入口', '门楼左侧宽台阶、上层平台与玻璃栏杆；与湖口的连续地面路线未知。'),
    332: ('湖岸夜景', '近侧铺路、矮墙扶手和临水花灌木；对岸有工地和亮灯亭。'),
    333: ('湖岸夜景相邻视角', '与332高度重复，不计作独立路线接缝证据。'),
    334: ('神仙湖题字石正面', '浅黄不规则石体、绿色竖字、碎石床、辅助景石和正面射灯。'),
    335: ('神仙湖题字石横景', '石后是水面；右侧树木与灌木，地面碎石和路缘可读。'),
    336: ('神仙湖题字石侧景', '碎石床沿曲线路缘，石右侧有树和后方亮灯步道；不等于完整地面接缝。'),
    337: ('神仙岭水库设施牌', '可读管养房、防汛仓库、大坝、溢洪道、输水涵管、大门；旁牌禁止游泳/钓鱼、小心落水、当心落物。'),
    338: ('草坡与排水构造', '草坡、弯曲混凝土排水带、树木与工地背景；不能仅凭设施牌认定具体坝体。'),
    339: ('沿水侧步道', '宽铺地、浅色矮墙、深色水平扶手、纤细下照路灯；左侧草坡和窄阶/排水构造。'),
    340: ('沿水侧步道相邻视角', '与339相近，路向前弯；工地是照片中的临时状态，时间未知。'),
    341: ('沿水侧步道广角', '延续339/340局部关系，没有建立到湖口候选环岛的连续链。'),
}
records = []
parser = argparse.ArgumentParser()
parser.add_argument('--source-dir', type=Path, default=Path.home() / 'Desktop')
parser.add_argument('--allow-missing', action='store_true')
args = parser.parse_args()
for number, (title, detail) in notes.items():
    matches = list(args.source_dir.glob(f'微信图片_*_{number}_33.*'))
    if not matches:
        matches = list(DEST.glob(f'微信图片_*_{number}_33.*'))
    if not matches and args.allow_missing:
        records.append({'id': f'FIELD_{number}', 'title_zh': title, 'visible_zh': detail,
                        'original': None, 'sha256': None, 'capture_date': None,
                        'received_at': '2026-09-29', 'source': 'user_message_image_attachment',
                        'local_original_status': 'missing_at_archive_attempt',
                        'usage': 'visual_reference_only', 'license': 'not_established',
                        'game_registered': False})
        continue
    if len(matches) != 1:
        raise RuntimeError(f'Expected exactly one supplied image {number}: {matches}')
    src = matches[0]
    dst = DEST / src.name
    sha = hashlib.sha256(src.read_bytes()).hexdigest()
    if dst.exists() and hashlib.sha256(dst.read_bytes()).hexdigest() != sha:
        raise RuntimeError(f'Refusing to overwrite changed original {dst}')
    if src.resolve() != dst.resolve():
        shutil.copy2(src, dst)
    assert hashlib.sha256(dst.read_bytes()).hexdigest() == sha
    with Image.open(src) as im:
        exif = im.getexif()
        dates = {str(k): str(exif[k]) for k in (306, 36867, 36868) if k in exif}
        dimensions = list(im.size)
    records.append({'id': f'FIELD_{number}', 'title_zh': title, 'visible_zh': detail,
                    'original': dst.relative_to(ROOT).as_posix(), 'source_path': str(src),
                    'sha256': sha, 'dimensions': dimensions, 'exif_dates': dates,
                    'capture_date': None, 'received_at': '2026-09-29',
                    'source': 'user_supplied_wechat_export', 'license': 'not_established',
                    'usage': 'local_reference_only', 'game_registered': False})
manifest = {'reviewed_at': '2026-09-29', 'records': records,
            'capture_sequence': 'unknown; file naming is not a verified field itinerary',
            'map_edition': 'May 2026, visible on FIELD_328',
            'gap_a_closed': False, 'gap_b_closed': False, 'new_paths': 0,
            'appearance_applied': ['Sign_01 visual treatment', 'existing lamp appearance'],
            'not_placed': ['traditional pavilion', 'reservoir facility sign', 'Ling College gate', 'construction site'],
            'identity_warning': 'FIELD_329 traditional pavilion is not proven identical to existing domed Pavilion_01'}
(REF / 'field_20260929.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2), 'utf8')
cards = []
for r in records:
    preview = '<p>已审阅聊天附件；本地原图待归档。</p>'
    if r['original']:
        rel = Path(r['original']).relative_to('references/regions/fairy_lake').as_posix()
        preview = f'<a href="{html.escape(rel)}"><img loading="lazy" src="{html.escape(rel)}" alt="{html.escape(r["title_zh"])}"></a>'
    cards.append(f'<article>{preview}<h2>{r["id"]} · {r["title_zh"]}</h2><p>{r["visible_zh"]}</p></article>')
archived = sum(bool(r['original']) for r in records)
(REF / 'field_20260929.html').write_text('''<!doctype html><html lang="zh-CN"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>神仙湖实景参考</title><style>body{background:#f2f0e8;color:#263d34;font:17px/1.7 system-ui;margin:32px}main{display:grid;grid-template-columns:repeat(auto-fit,minmax(330px,1fr));gap:24px}article{background:white;padding:18px;border-radius:10px}img{width:100%;height:290px;object-fit:contain;background:#e8e8e1}h2{font-size:20px}header{max-width:980px;margin-bottom:30px}</style><header><h1>神仙湖 · 新增实景参考</h1>''' + f'<p>已审阅14张聊天附件，当前已归档原文件{archived}张。拍摄日期与行走顺序未确认；微信文件名不是拍摄时间。图中2026年5月是导览图版本。</p>' + '''<p>本轮只校正已有题字石及路灯外观；中式亭、水库牌、道扬书院门楼尚未配准到游戏。湖口至候选环岛的两个地面缺口仍未关闭。</p></header><main>''' + ''.join(cards) + '</main></html>', 'utf8')
print(f'Preserved and hash-verified {archived} originals; {len(records)-archived} missing; wrote manifest and gallery.')
