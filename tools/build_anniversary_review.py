"""Local reference/model review; source photographs are not packaged game textures."""
from pathlib import Path
from html import escape
import json
root=Path(__file__).resolve().parents[1]
sources=json.loads((root/'references/anniversary-20261010/sources.json').read_text(encoding='utf-8'))
source_by_file={Path(s['file']).name:s for s in sources}
def photo(name,caption,reference=False):
    path='../references/anniversary-20261010/originals/'+name if reference else '../tests/artifacts/courtyard-refined-'+name+'.png'
    link=''
    if reference:
        s=source_by_file[name]
        link=f'<p class="source"><a href="{escape(s["url"])}">校方原图</a> · {escape(s["date_evidence"])}</p>'
    return f'<figure><img loading="lazy" src="{path}" alt="{escape(caption)}"><figcaption>{escape(caption)}</figcaption>{link}</figure>'
sections=[]
for title,description,ref,views in [
    ('中央大道与东门铺地','灰色石材为连续步行面，草地以明确边界嵌入。原图与游戏取景不完全相同；比例仍是照片拟合。','mall-2023.jpg',[('anniversary-mall','V32 · 中央区总览'),('anniversary-eastgate','V32 · 东门上层平台入校'),('anniversary-paving','V32 · 米制石材拼缝与树池'),('anniversary-student','V32 · 学生中心及下沉庭院绕行')]),
    ('知新楼与旧图书馆','补齐两翼及不同层数，前庭改为石材包围的分块草地。原图拍摄年未证实；不能称为最新测绘。','zhixin-built.jpg',[('anniversary-zhixin','V32 · 知新楼广场视角'),('anniversary-zhixin-overview','V32 · 两翼、后部横窗楼翼与前庭')]),
    ('道远楼','竖向入口格栅、顶部透空框架和弧形玻璃翼。台地高差尚待进一步校正；楼名牌为暂用标识。','daoyuan-built.jpg',[('anniversary-daoyuan','V32 · 入口'),('anniversary-daoyuan-corner','V32 · 弧形玻璃侧翼')]),
]:
    sections.append(f'<section><h2>{title}</h2><p>{description}</p><div class="grid">'+photo(ref,'校方十周年专题 · 参照',True)+''.join(photo(n,c) for n,c in views)+'</div></section>')
html='''<!doctype html><html lang="zh"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>下园十周年参照精修 V32</title>
<style>body{margin:0;background:#e8e8e0;color:#202b29;font:16px/1.65 system-ui,"Microsoft YaHei",sans-serif}main{max-width:1500px;margin:auto;padding:40px}h1{font-size:34px;margin:0}h2{font-size:25px;margin-bottom:8px}p{max-width:1000px}.meta{color:#53665e}.grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:20px}figure{margin:0;background:#f9faf6;padding:10px}img{display:block;width:100%;aspect-ratio:1.6;object-fit:contain;background:#d8ded8}figcaption{font-weight:600;margin:10px 4px}.source{font-size:12px;color:#52615a;margin:4px}section{padding:25px 0;border-top:1px solid #bdc8bf}a{color:#315e51}.status{background:#d2dfd0;padding:14px 20px;margin:25px 0}@media(max-width:850px){main{padding:20px}.grid{grid-template-columns:1fr}}</style>
<main><h1>下园 · 十周年参照精修</h1><p class="meta">V32 / 东门坐标原点保留 / 程序化模型 / 2026-10-10</p><div class="status">本轮：35 个地面分区、知新楼缺失翼、道远楼入口与弧形翼。两轮集中验证合计 22 段步行通过。校园精修 Goal 继续进行。</div><p>照片上传目录不是拍摄年份。中央区原图画面内有 2023 标识；启动区照片仅确认建成状态。模型的绝对尺寸、部分高差与不可见立面仍有待校正。</p>
'''+''.join(sections)+'''<p><a href="ANNIVERSARY_REFINEMENT_V32.md">实现与验证记录</a> · <a href="../references/anniversary-20261010/sources.json">7 张参考图来源与年代</a></p></main></html>'''
(root/'docs/ANNIVERSARY_REVIEW.html').write_text(html,encoding='utf-8')
print(root/'docs/ANNIVERSARY_REVIEW.html')
