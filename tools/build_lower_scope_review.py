"""Publish already-reviewed model frames; no extra engine runs or resemblance scores."""
import json
from html import escape as e
from pathlib import Path
root=Path(__file__).resolve().parents[1]
d=json.loads((root/'systems/data/campus_visual_build.json').read_text(encoding='utf-8'))
cards=[]
for r in d['buildings']:
    if r['id']=='gate_north':continue
    key='east-gate' if r['id']=='gate_south' else r['id']
    title='东门两翼与连桥' if key=='east-gate' else r['name']
    note=r.get('observed','体量、窗墙及场地关系见实景对照页。')
    if r['id']=='west_gate':note='仅保留方向点、铺地和灯；缺乏已核实门楼外观，不计入已建建筑。'
    if r['id']=='old_gate':note='独立双石柱、校名墙与门岗；13 m 柱高为拟合值。'
    scenes=r.get('scenes',[])
    scene=scenes[0] if scenes else r.get('evidence',{}).get('scene_id')
    url=f'https://campusvr-en.cuhk.edu.cn/?scene_id={scene}' if scene else 'https://www.cuhk.edu.cn/zh-hans/page/4908'
    cards.append((key,title,note,url))
for key,title in [('library-ground','大学图书馆 G 层'),('library-stair','图书馆入口楼梯与座席'),('administration-entry','行政楼公共入口'),('teaching-arcade','教学楼高廊'),('courtyard-lower','中庭下层玻璃休憩廊'),('central-enclosure','中庭三侧连廊与庭园'),('east-gate-entry','东门人行视角'),('east-gate-inside','东门内侧')]:
    cards.append((key,title,'局部通行及来源判断见验收记录；未见室内平面属于拟合。','LOWER_CAMPUS_COMPLETION_REVIEW.md'))
sections=[]
for key,title,note,url in cards:
    image=f'tests/artifacts/scope-review-{key}.png'
    if not (root/image).is_file():raise FileNotFoundError(image)
    sections.append(f'<section id="{key}"><h2>{e(title)}</h2><a href="../{image}"><img loading="lazy" src="../{image}" alt="{e(title)}实机"></a><p>{e(note)}</p><a href="{e(url)}">参考 / 范围说明</a></section>')
nav=''.join(f'<a href="#{key}">{e(title)}</a>' for key,title,_,_ in cards)
page='''<!doctype html><html lang="zh-CN"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>下园阶段建模巡查 · v30</title>
<style>*{box-sizing:border-box}body{margin:0;background:#1a2222;color:#edf0e6;font:15px/1.7 "Microsoft YaHei",sans-serif}main{max-width:1480px;margin:auto;padding:30px}h1{margin:0}h2{font-size:20px}a{color:#dcc28a}p{color:#c3ccc5}nav{display:flex;gap:10px 20px;flex-wrap:wrap;margin:22px 0}.grid{display:grid;grid-template-columns:1fr 1fr;gap:25px}section{border-top:1px solid #627269;padding-top:12px;scroll-margin-top:12px}img{width:100%;display:block}section p{min-height:3em}@media(max-width:850px){.grid{grid-template-columns:1fr}main{padding:18px}}</style>
<main><h1>下园阶段建模巡查 · v30</h1><p>21 组建筑模型、旧南门、运动场及 1 个未核实出口方向点，共 24 条数据记录。东门两翼合并展示；本页 31 个有效实机视角。东门为 v30，其余截图为 v29。后续 v31 已改动旧楼群排列、道路与部分建筑；本页保留历史截图，最新区间见 <a href="LOWER_CORRIDOR_REVIEW.html">v31 对照</a>。</p>
<p>建筑与公共空间已按官方全景、校方图片和建筑师平面细化。具体尺寸、等高线、未见背面和部分室内连接仍是建模估计，真北未标定。<a href="LOWER_CAMPUS_VISUAL_COMPARE.html">实景与模型对照（含 v31）</a> · <a href="LOWER_CAMPUS_COMPLETION_REVIEW.md">验收范围、证据和边界</a></p><nav>'''+nav+'</nav><div class="grid">'+''.join(sections)+'</div></main></html>'
(root/'docs/LOWER_CAMPUS_SCOPE_REVIEW.html').write_text(page,encoding='utf-8')
print(len(cards),'reviewed view paths verified; no image transformations')
