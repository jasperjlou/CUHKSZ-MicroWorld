"""Package the verified2.1.5 runtime. Run only after reviewing both exported-mode images."""
import argparse
import hashlib
import json
import zipfile
from pathlib import Path

parser=argparse.ArgumentParser()
parser.add_argument('--export-images-reviewed',action='store_true',required=True)
parser.parse_args()
ROOT=Path(__file__).resolve().parents[1]
REL=ROOT/'builds/releases/v2.1.5';WIN=REL/'Windows';ART=ROOT/'tests/artifacts'
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def read(path):return json.loads(path.read_text(encoding='utf-8'))
def write(path,data):path.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8',newline='\n')
manifest=read(WIN/'runtime/build-manifest.json')
assert manifest['product']=='2.1.5' and manifest['formal_release']
for name,item in manifest['files'].items():assert sha(WIN/'runtime'/name)==item['sha256'],name
review=read(ROOT/'references/visual_build_20261008/stage_experience_v225.json')
assert review['valid_with_targeted_replacement'] and review['chapter_count']==26
assert review['effective_physical_legs']==260 and all(c['valid'] for c in review['physical_legs'])
for name,digest in review['source_sha256'].items():assert sha(ROOT/name)==digest,name
for name,digest in review['report_sha256'].items():assert sha(ART/name)==digest,name
assert len(review['image_sha256'])==21
for name,digest in review['image_sha256'].items():assert sha(ART/name)==digest,name
for name,mode in [('玩家游玩','human'),('Agent自动展示','agent-demo')]:
    (WIN/f'{name}.cmd').write_bytes(f'@echo off\r\nstart "" "%~dp0runtime\\CUHKSZ-MicroWorld.exe" -- --{mode}\r\n'.encode('ascii'))
(WIN/'使用说明.txt').write_text('''港中深微型世界 v2.1.5 / V219–V224学生中心层内 + V225体验复核
完整解压后选择：玩家游玩.cmd 或 Agent自动展示.cmd。无需安装 Godot。
保留 runtime 文件夹；程序未代码签名。
WASD移动，Shift跑步，右键拖动镜头，滚轮缩放，V切换第一/第三人称，小地图设目标。
F1查看信息，F2俯视，R回东门，Esc返回双入口菜单。
Agent为26章编排导览；空格暂停，左右键切章。章内真实物理行走，跨章有剪辑。
尺寸按资料拟合，真实北向未校准；本次是阶段版，完整校园继续精修，并非校方官方产品。
发布与源码：https://github.com/jasperjlou/CUHKSZ-MicroWorld/releases/tag/v2.1.5
''',encoding='utf-8-sig')
zip_path=REL/'CUHKSZ-MicroWorld-v2.1.5-Windows-x86_64.zip'
assert not zip_path.exists(),'Fixed archive exists; do not overwrite.'
with zipfile.ZipFile(zip_path,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
    for p in sorted(WIN.rglob('*')):
        if p.is_file():
            assert 'clean-cwd' not in p.parts
            z.write(p,p.relative_to(WIN).as_posix())
with zipfile.ZipFile(zip_path) as z:
    assert z.testzip() is None
    for name,item in manifest['files'].items():assert hashlib.sha256(z.read('runtime/'+name)).hexdigest()==item['sha256']
(REL/'SHA256SUMS.txt').write_text(sha(zip_path)+'  '+zip_path.name+'\n',encoding='ascii',newline='\n')
validation={'version':'2.1.5','model':manifest['model'],'showcase_chapters':26,'previous_baseline':'v2.1.4','source_experience':'docs/PRODUCT_REVIEW_V225.md','source_checks':review['source_checks'],'source_physical_legs':len(review['physical_legs']),'export_checks':{},'images':{},'source_files':{},'evidence_reports':{},'scope':'V219-V224 student interiors and V225 experience.26 chapters with260 effective legs:177 unchanged V218 plus83 affected legs. Original Agent intro failure retained and replaced by26-chapter intro audit plus final Serenity framing audit; no uninterrupted final replay claim. Player96legs5042camera samples. Not full-campus geometry or every free-roam route acceptance.','remaining_work':'Full A-G traceable backlog remains in docs/lower_campus_refinement_coverage.json; goal and hourly continuation remain active.'}
for mode in ['human','agent-demo']:
    name='release_v2_1_5_export_smoke_v225_'+mode
    report=read(ART/(name+'.json'));assert report['valid']
    validation['export_checks'][mode]=report['checks'];validation['images'][name+'.png']=sha(ART/(name+'.png'))
validation['export_images_reviewed']=True
validation['experience_receipt']=review
for name in ['student_stage_agent_v225.json','student_stage_finish_v225_visual.json','student_stage_camera_v225_physical.json','student_stage_framing_v225.json']:
    report=read(ART/name)
    if name!='student_stage_agent_v225.json':assert not report.get('failures',[])
    validation['evidence_reports'][name]={'sha256':sha(ART/name),'report':report}
closure=read(ART/'export_resource_closure_v225.json')['files']
for name in closure+['project.godot','export_presets.cfg']:validation['source_files'][name]=sha(ROOT/name)
write(ROOT/'docs/releases/v2.1.5-validation.json',validation)
write(ROOT/'docs/releases/v2.1.5-build.json',{'version':'2.1.5','model':manifest['model'],'artifact':zip_path.name,'bytes':zip_path.stat().st_size,'sha256':sha(zip_path),'runtime_manifest':manifest,'publication':'Verified local package; GitHub publication must be recorded separately.'})
print('Verified ZIP/runtime hashes; receipts saved;',zip_path.stat().st_size,'bytes.')
