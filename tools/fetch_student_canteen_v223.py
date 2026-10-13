"""Fetch only selected public campus panorama reference tiles, retaining URLs/hashes."""
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
import hashlib,json,subprocess
from PIL import Image

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'references/visual_build_20261008/originals/student-canteen-v223'
OUT.mkdir(exist_ok=True)
BASE='https://campusvr-en.cuhk.edu.cn/assets/resource/prod/5e2i2024703/6cf25uzkcbv'
def fetch(task):
    pid,face,row,col=task
    name=f'{pid}-{face}-{row}-{col}.jpg'
    r=f'{row:02d}' if pid>=80000000 else str(row)
    c=f'{col:02d}' if pid>=80000000 else str(col)
    url=f'{BASE}/{pid}/imgs/{face}/l1/{r}/l1_{face}_{r}_{c}.jpg'
    target=OUT/name
    if not target.exists():
        subprocess.run(['C:/WINDOWS/system32/curl.exe','-sS','-fL','--max-time','25','-o',str(target),url],check=True,capture_output=True,creationflags=0x08000000)
    with Image.open(target) as im: size=list(im.size)
    return {'file':name,'url':url,'size':size,'sha256':hashlib.sha256(target.read_bytes()).hexdigest()}
tasks=[(pid,f,r,c) for pid in [86404084,86404085,70037187,83562024] for f in 'fblr' for r in (1,2) for c in (1,2)]
with ThreadPoolExecutor(max_workers=8) as pool: records=list(pool.map(fetch,tasks))
for pid in [86404084,86404085,70037187,83562024]:
    for face in 'fblr':
        tiles=[[Image.open(OUT/f'{pid}-{face}-{r}-{c}.jpg') for c in (1,2)] for r in (1,2)]
        output=Image.new('RGB',(sum(im.width for im in tiles[0]),sum(row[0].height for row in tiles)))
        y=0
        for row in tiles:
            x=0
            for im in row: output.paste(im,(x,y));x+=im.width
            y+=row[0].height
        output.save(OUT/f'{pid}-{face}.jpg',quality=95)
(OUT/'manifest.json').write_text(json.dumps({'retrieved':'2026-10-14','capture_dates':'unknown','assets':records},indent=2)+'\n',encoding='utf-8')
print(f'{len(records)} source tiles and 16 assembled reference faces saved')
