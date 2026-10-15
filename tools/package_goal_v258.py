import hashlib,json,zipfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
REL=ROOT/'builds/releases/v2.1.11';WIN=REL/'Windows';ART=ROOT/'tests/artifacts'
def read(p):return json.loads(p.read_text(encoding='utf-8'))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def write(p,j):p.write_text(json.dumps(j,ensure_ascii=False,indent=2)+'\n',encoding='utf-8',newline='\n')
manifest=read(WIN/'runtime/build-manifest.json')
assert manifest['product']=='2.1.11' and manifest['formal_release']
for name,item in manifest['files'].items():assert sha(WIN/'runtime'/name)==item['sha256']
reports={}
for name in ['goal_agent_v258','goal_agent_actions_v258','goal_agent_obstacle_v258','goal_agent_views_v258']:
 j=read(ART/(name+'.json'));assert not j['failures'] and all(c['valid'] for c in j['checks']);reports[name]=j
for mode in ['human','agent-demo']:
 name='release_v2_1_11_export_smoke_v258_'+mode
 j=read(ART/(name+'.json'));assert j['valid'];reports[name]=j
for title,mode in [('玩家游玩','human'),('Agent自动展示','agent-demo')]:
 (WIN/(title+'.cmd')).write_bytes(('@echo off\r\nstart "" "%~dp0runtime\\CUHKSZ-MicroWorld.exe" -- --'+mode+'\r\n').encode('ascii'))
(WIN/'使用说明.txt').write_text('港中深微型世界 v2.1.11\n完整解压，选择玩家游玩或Agent自动展示。Agent入口现在先选择目标，可到达并观察或连续探索附近两处；支持暂停、停止、改目标。原建筑导览在Agent面板内。\n本地规则Agent，真实物理行走；未接入的NPC/交通动作不提供。Esc回菜单。\n全园继续精修，几何尺寸拟合，真北未校准。\n',encoding='utf-8-sig')
archive=REL/'CUHKSZ-MicroWorld-v2.1.11-Windows-x86_64.zip'
assert not archive.exists()
with zipfile.ZipFile(archive,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for p in sorted(WIN.rglob('*')):
  if p.is_file() and 'clean-cwd' not in p.parts:z.write(p,p.relative_to(WIN).as_posix())
with zipfile.ZipFile(archive) as z:
 assert z.testzip() is None
 for name,item in manifest['files'].items():assert hashlib.sha256(z.read('runtime/'+name)).hexdigest()==item['sha256']
(REL/'SHA256SUMS.txt').write_text(sha(archive)+'  '+archive.name+'\n',encoding='ascii',newline='\n')
sources=read(ART/'export_resource_closure_v258.json')['files']+['project.godot','export_presets.cfg']
write(ROOT/'docs/releases/v2.1.11-validation.json',{'version':'2.1.11','reports':reports,'source_files':{p:sha(ROOT/p) for p in sources},'source_views_reviewed':True,'export_views_reviewed':True,'scope':'Selected physical goals, controls and packed two entries; not all goal pairs or full-campus acceptance.'})
write(ROOT/'docs/releases/v2.1.11-build.json',{'version':'2.1.11','model':manifest['model'],'artifact':archive.name,'bytes':archive.stat().st_size,'sha256':sha(archive),'runtime_manifest':manifest})
print('Package verified',archive.stat().st_size,'bytes',len(sources),'sources')
