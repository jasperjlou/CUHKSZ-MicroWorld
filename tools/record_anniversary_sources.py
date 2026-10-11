"""Keep selected browser-exported official references and a capture-date evidence ledger."""
import json, shutil
from pathlib import Path
root=Path(__file__).resolve().parents[1]
dest=root/'references/anniversary-20261010'
(dest/'originals').mkdir(parents=True,exist_ok=True)
bundles=Path('C:/Users/12345/AppData/Local/Temp/browser-use/assets')
selected={
 '21d476d66723205a':('mall-2023.jpg','2023 marker visible in image; exact capture day unknown','primary hardscape', 'phase-i-campus'),
 '290993ea4e992cc4':('zhixin-built.jpg','Capture year unknown; 2023-11 is upload path only','built geometry only', 'start-zone'),
 '0047e3e089b70e60':('old-library-interior.jpg','Capture year unknown; 2023-11 is upload path only','interior supporting reference', 'start-zone'),
 'f032b800011222dc':('daoyuan-built.jpg','Capture year unknown; 2023-11 is upload path only','built geometry only', 'start-zone'),
 'c1173d5e2c00eff0':('zhiren-chengdao-built.jpg','Capture year unknown; construction visible behind building','geometry only; not current landscaping', 'start-zone'),
 '9bb8e1a98f8ae409':('teaching-built.jpg','Capture year unknown; 2023-11 is upload path only','supporting facade and water edge', 'phase-i-campus'),
 'dfed41bac2228665':('shaw-anniversary.jpg','Filename contains 20231206; not proof of capture day','supporting college facade', 'phase-i-campus'),
}
records=[]
for bid in ['d562ea37-2b62-45b4-ae9b-e331100e2346','3024a0fd-983e-40d6-b2ed-a0836b18e95d']:
    for a in json.loads((bundles/bid/'manifest.json').read_text(encoding='utf-8'))['assets']:
        if a['id'] not in selected:continue
        name,date,use,page=selected[a['id']]
        shutil.copy2(a['path'],dest/'originals'/name)
        records.append(dict(file='originals/'+name,url=a['url'],page='https://10.cuhk.edu.cn/en/'+page,date_evidence=date,use=use))
(dest/'sources.json').write_text(json.dumps(records,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(f'{len(records)} selected sources recorded at {dest}')
