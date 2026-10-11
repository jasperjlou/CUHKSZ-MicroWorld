"""Record V117 retained local checks and current legacy-reference review."""
import hashlib
import json
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
def read(p):
    return json.loads((ROOT / p).read_text(encoding='utf-8-sig'))
def write(p, data):
    (ROOT / p).write_text(json.dumps(data, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
def sha(p):
    return hashlib.sha256((ROOT / p).read_bytes()).hexdigest()

a_path='tests/artifacts/library_entry_approach_v117_accepted_run.json'
f_path='tests/artifacts/library_entry_approach_v117_finish.json'
p_path='tests/artifacts/library_entry_approach_v117_side_probe.json'
a,f,p=read(a_path),read(f_path),read(p_path)
assert all(r['valid'] for r in a['physical_legs'][:28])
assert len(f['physical_legs'])==13 and all(r['valid'] for r in f['physical_legs'])
assert all(r['valid'] for r in a['checks']) and f['checks'][0]['valid'] and p['valid']
logs=['library-entry-approach-v117-accepted.log','library-entry-approach-v117-finish.log','library-entry-approach-v117-side-probe.log']
for name in logs:
    assert not any(line.startswith(('ERROR:','SCRIPT ERROR:')) for line in (ROOT/'tests/artifacts'/name).read_text(encoding='utf-8').splitlines())
files=['world/visual_campus/'+name+'.gd' for name in ['LibraryEntryApproach','LibraryEntryLevels','LibraryEntryPavilion','LibraryRegisteredFloors','LibraryLowerRightWing','LibraryLowerRightPlan']]+['systems/data/campus_visual_build.json']
accepted={
    'version':f['version'],'status':'local_routes_passed_visual_fidelity_partial_goal_active',
    'accepted_legs':[{'file':a_path,'indices':list(range(28))},{'file':f_path,'indices':list(range(13))}],
    'valid_records':41,'fixture_starts':3,'not_single_continuous_tour':True,
    'accepted_checks':[{'file':a_path,'indices':list(range(5))},{'file':f_path,'indices':[0]},{'file':p_path,'valid':True}],
    'check_records':7,'unique_cases':6,
    'excluded':'Initial engine parse-error run entirely excluded; final run pre-soffit-fix retired. accepted_run G target(-12,12) intersects kiosk; excluded failure. finish negative-side upstand probe is outside116 footprint; corrected positive-side-only probe passes. Original failed reports retained.',
    'logs':['tests/artifacts/'+x for x in logs],'engine_errors_in_retained_logs':0,
    'images_reviewed':['courtyard-refined-library-entry-approach-v117-finish-'+x+'.png' for x in ['front','steps','soffit']],
    'visual_limits':'Front and steps support revised approach/threshold relation. Soffit image still shows a small bright triangular seam; full closed-room visual sealing NOT accepted. Side probe verifies only the positive-side sampled point.',
    'source_sha256':{x:sha(x) for x in files},'model_changed_after_finish':False,
    'retained_main_route_note':'24 continuous outdoor/exhibition/return legs predate noncolliding pot details and localized116 side upstand. Remaining4 entry legs and final13 G legs are separate starts.',
    'fitted_not_measured':{'G':0,'2F':4.4,'approach_foot_height':2.0,'short_stair_run':8.0,'short_stair_rise':2.4,'long_approach_run':28.8},
    'unchanged':'East Gate origin, uncalibrated north, library global datum and player collider'}
write('tests/artifacts/library_entry_approach_v117_accepted.json',accepted)

source_dir='references/visual_build_20261008/originals/library-grade-v117/'
sources=[]
for filename,url in [
 ('architect-section-full.jpg','https://oss.gooood.cn/uploads/2021/03/051-chinese-university-of-hong-kong-sz-library-by-wang-weijen-architecture.jpg'),
 ('architect-plan-full.jpg','https://oss.gooood.cn/uploads/2021/03/052-chinese-university-of-hong-kong-sz-library-by-wang-weijen-architecture.jpg')]:
    sources.append({'file':source_dir+filename,'url':url,'sha256':sha(source_dir+filename),'publication_date':'2021-03-16','drawing_revision_date':'unknown','article':'https://www.gooood.cn/chinese-university-of-hong-kong-sz-library-by-wang-weijen-architecture.htm','use':'Historical grade/topology only; not current as-built or measured dimensions'})
sources.append({'file':'references/anniversary-20261010/originals/mall-2023.jpg','page':'https://10.cuhk.edu.cn/en/phase-i-campus','url':'https://10.cuhk.edu.cn/sites/default/files/2023-11/xiaoyuanhangpaisheyingchenming_2.jpg','sha256':sha('references/anniversary-20261010/originals/mall-2023.jpg'),'date_basis':'Visible2023sign; exact capture date unknown; upload directory not capture date','use':'Long rising gray approach, short broad stair, paired plants; no numeric survey'})
sources.append({'url':'https://library.cuhk.edu.cn/zh-hans/event/1246','publication_date':'2025-10-31','works_date':'2025-11-01','use':'Separate1F and2F entrance identities; no numeric height'})
write(source_dir+'sources.json',{'sources':sources})
write('references/visual_build_20261008/library_entry_approach_v117_evidence.json',{'sources':sources,'model_files':files,'accepted':'tests/artifacts/library_entry_approach_v117_accepted.json','limitations':accepted['visual_limits'],'fitted_not_measured':accepted['fitted_not_measured']})

coverage=read('docs/lower_campus_refinement_coverage.json')
coverage.update(updated='2026-10-11',basis_version=f['version'],status='active',previous_turn_classification='progress')
coverage['next_action']='V117 replaced wrongly directed full-rise outdoor stair with long rising stone approach + short broad stair aligned to2F door; fitted heights,not as-built.41 retained physical records/3starts and7 check records pass,not whole-tour proof. Next resolve small triangular116soffit visual seam,pond-to-fins contour and sideforecourt grass/hardscape transitions,registered facade supports/remaining3Fsides. Keep shared datum until measured evidence; legacy exterior three-anchor registration remains open. Then resume B/C/D andallA-G,fullrearroadtoShaw,backs/lowerlevels/corners. EastGate origin retained,north unresolved.'
coverage['v117_evidence']={'report':'docs/LIBRARY_ENTRY_APPROACH_V117.md','accepted':'tests/artifacts/library_entry_approach_v117_accepted.json','valid_records':41,'fixture_starts':3,'check_records':7,'visual_fidelity':'partial; small116soffit seam remains','goal':'active'}
write('docs/lower_campus_refinement_coverage.json',coverage)
summary='V117：按十周年照片/历史建筑师平面重做图书馆长缓升石路与短宽外梯，正对2F门口，撤旧斜梯/暂接平台；116屋顶随外梯下降，2F楼板切开对应范围。长坡/短梯分担高差为拟合，整馆基准未动。保留24主路线+4G入口+最终13G绕行共41移动记录、3起点；7检查记录（含1重复）通过，不能称一次全馆通行。初解析错误和旧屋顶失败不计，终批负侧探针在116外而作废，改正侧单点通过。终3图已看，116底面仍有小三角亮缝，视觉封闭未验收；下一批补缝/池岸至竖鳍/侧前庭真实铺地草地，再立面和B/C/D及全A–G。旧资产已可离线读取并有参考副本，外部三锚点配准仍待做。Goal active，详见 docs/LIBRARY_ENTRY_APPROACH_V117.md。'
goal=ROOT/'docs/LOWER_CAMPUS_ACTIVE_GOAL.md'
text=goal.read_text(encoding='utf-8-sig')
if '\nV117：' not in text:goal.write_text(text+'\n\n'+summary+'\n',encoding='utf-8')

# Cheap current readability check; do not decode multi-GB geometry again.
base=ROOT/'references/legacy-gta-20261011'
inventory=read('references/legacy-gta-20261011/scene-inventory.json')
out={'inspection':'2026-10-11','method':'Existing extraction metadata and GLB headers checked; no full re-extraction','source':'A:/项目/港中深GTA旧资产/My project (2)_Data','scenes':len(inventory['scenes']),'name_parse_errors':sum(s['parse_errors'] for s in inventory['scenes']),'source_scene_files_present':{x:(Path('A:/项目/港中深GTA旧资产/My project (2)_Data')/x).is_file() for x in ['level12','level17','level24','level25']},'glb':[]}
for name in ['lower-campus-reference.glb','teaching-a-hall-reference.glb','teaching-a-hall-preview.glb','library-1f-reference.glb','library-4f-reference.glb']:
    path=base/name
    with path.open('rb') as handle:magic,version,length=struct.unpack('<4sII',handle.read(12))
    assert magic==b'glTF' and version==2 and length==path.stat().st_size
    out['glb'].append({'file':name,'bytes':length,'header_version':version,'declared_length_matches':True})
out['previews_viewed_this_review']=['legacy-overview.png','legacy-library1f-plan-cutaway.png']
out['limits']='Header checks are not a new full geometry validation; extraction metrics come from saved reports. Original model date/metric units/north/materials not verified.'
write('references/legacy-gta-20261011/current-readability-review.json',out)
print(json.dumps({'V117_valid_records':41,'goal':'active','legacy_scenes':out['scenes'],'readable_glbs':len(out['glb'])},ensure_ascii=False))
