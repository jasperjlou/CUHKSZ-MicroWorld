"""Review v31 with fixed-camera before/after images and unmodified primary references."""
from html import escape
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
report=json.loads((root/'tests/artifacts/lower_corridor_milestone.json').read_text(encoding='utf-8'))
names={'garden':'学生中心连廊至逸夫步道','shaw':'逸夫东座临街端墙与铺装','between':'逸夫东、西座之间','research':'科研楼方向','sports':'科研楼至体育馆连接','overall':'整体排列'}
cards=[]
for key,title in names.items():
    cards.append(f'<section><h2>{title}</h2><div class="pair"><figure><img src="../tests/artifacts/scope-review-corridor-before-{key}.png"><figcaption>修改前 v30</figcaption></figure><figure><img src="../tests/artifacts/courtyard-refined-corridor-{key}.png"><figcaption>修改后 v31 · 相同相机</figcaption></figure></div></section>')
for key,title,source,href in [
    ('square-cluster','诚道、知仁在前，乐天在后','official-campus-map-20260512.jpg','https://www.cuhk.edu.cn/zh-hans/page/4908'),
    ('research-canopy','科研楼圆柱与悬挑下层','landmark-instances/research/3f66bff99ec6e7e8.jpg','https://campusvr-en.cuhk.edu.cn/?scene_id=116443791')]:
    cards.append(f'<section><h2>{title}</h2><div class="pair"><figure><a href="{href}"><img src="../references/visual_build_20261008/originals/{source}"></a><figcaption>官方参考；不是配准相机</figcaption></figure><figure><img src="../tests/artifacts/courtyard-refined-corridor-{key}.png"><figcaption>本轮建模</figcaption></figure></div></section>')
valid=sum(x['valid'] for x in report['physical_legs'])
status=f"连续步行 {valid}/{len(report['physical_legs'])} 段通过；场景建立 {report['build_ms']} ms。"
if report['failures']:status+=' 未通过：'+', '.join(report['failures'])
page='''<!doctype html><html lang="zh-CN"><meta charset="utf-8"><title>下园道路与排列修正 v31</title><style>
body{margin:0;background:#e9ece6;color:#273b32;font:16px/1.7 system-ui}main{max-width:1500px;margin:auto;padding:30px}h1{font-size:30px}section{background:#fff;padding:22px;margin:26px 0;border-radius:8px}.pair{display:grid;grid-template-columns:1fr 1fr;gap:16px}figure{margin:0}img{width:100%;height:auto}figcaption{color:#536759}a{color:#2a6350}@media(max-width:700px){.pair{grid-template-columns:1fr}}
</style><main><h1>图书馆 → 逸夫 → 主广场 → 科研楼 / 体育馆</h1><p>v31 修正道路走线和楼群排列：诚道楼移到主广场山侧，与知仁楼形成前排；乐天楼退到后侧。逸夫临街端墙、连续铺装和科研楼悬挑下层同步更新。</p>'''
page+=f'<p><strong>{escape(status)}</strong> <a href="../tests/artifacts/lower_corridor_milestone.json">完整验证记录</a></p>'
page+='<p>参照官方 2026 年校园导览图、全景 Lower Campus View 2 及逸夫—主广场路口。建筑相邻关系有来源，具体米数、隐蔽立面、塔楼高度仍为拟合；东门原点与坐标轴不变。旧 v30 全区截图仅保留作历史记录。</p>'
page+=''.join(cards)+'</main></html>'
(root/'docs/LOWER_CORRIDOR_REVIEW.html').write_text(page,encoding='utf-8')
print(status)
