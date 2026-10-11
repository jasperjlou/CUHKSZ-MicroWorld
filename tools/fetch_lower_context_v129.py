"""Retain public official commercial photos and one adjacent panorama, with provenance."""
import base64,hashlib,json,re,subprocess
from html import unescape
from html.parser import HTMLParser
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
from urllib.parse import urljoin
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'references/visual_build_20261008/originals/student-context-v129'
OUT.mkdir(exist_ok=True)
records=[]
def get(url,target):
    if not target.exists():subprocess.run(['C:/WINDOWS/system32/curl.exe','-fLsS','--max-time','30','-o',str(target),url],capture_output=True,check=True,creationflags=0x08000000)
class Images(HTMLParser):
    def __init__(self):super().__init__();self.text='';self.images=[]
    def handle_data(self,s):self.text+=s.strip()+' '
    def handle_starttag(self,t,attrs):
        if t=='img':self.images.append((dict(attrs),self.text[-230:]))
p=Images();p.feed((ROOT/'.tools/commercial-14377.html').read_text(encoding='utf-8'))
for i,(attrs,context) in enumerate(p.images):
    src=attrs.get('src','')
    if not any(s in context for s in ['三把椅子','全家便利店','内山书店','文印店','中兴眼镜']):continue
    ext='.png' if 'image/png' in src or '.png' in src else '.jpg'
    target=OUT/f'commercial-{i:02}{ext}'
    if src.startswith('data:'):target.write_bytes(base64.b64decode(src.split(',',1)[1]));url='embedded image in official page'
    else:url=urljoin('https://www.cuhk.edu.cn',unescape(src));get(url,target)
    with Image.open(target) as im:size=list(im.size)
    records.append({'file':target.name,'page':'https://www.cuhk.edu.cn/zh-hans/page/14377','url':url,'context':context,'size':size,'sha256':hashlib.sha256(target.read_bytes()).hexdigest(),'capture_date':'unknown'})
BASE='https://campusvr-en.cuhk.edu.cn/assets/resource/prod/5e2i2024703/6cf25uzkcbv/70040610/imgs'
def tile(task):
    face,r,c=task;url=f'{BASE}/{face}/l1/{r}/l1_{face}_{r}_{c}.jpg';target=OUT/f'70040610-{face}-{r}-{c}.jpg';get(url,target)
    return {'file':target.name,'url':url,'sha256':hashlib.sha256(target.read_bytes()).hexdigest(),'capture_date':'unknown'}
with ThreadPoolExecutor(max_workers=8) as pool:records+=list(pool.map(tile,[(f,r,c) for f in 'fblr' for r in [1,2] for c in [1,2]]))
for face in 'fblr':
    tiles=[[Image.open(OUT/f'70040610-{face}-{r}-{c}.jpg') for c in [1,2]] for r in [1,2]]
    output=Image.new('RGB',(sum(t.width for t in tiles[0]),sum(row[0].height for row in tiles)));y=0
    for row in tiles:
        x=0
        for im in row:output.paste(im,(x,y));x+=im.width
        y+=row[0].height
    output.save(OUT/f'70040610-{face}.jpg',quality=95)
(OUT/'manifest.json').write_text(json.dumps({'retrieved':'2026-10-11','page_date':'unknown; retrieval not capture date','assets':records},ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps([{'file':r['file'],'context':r.get('context','')} for r in records if 'context' in r],ensure_ascii=False))
