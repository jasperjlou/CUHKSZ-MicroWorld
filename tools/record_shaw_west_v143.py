"""Record the completed V143 batch; preserves older source and validation records."""
import hashlib
import json
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
VERSION = 'official-visual-build-143-shaw-west-plan'

def read(path):
    return json.loads((ROOT / path).read_text(encoding='utf-8-sig'))

def write(path, value):
    (ROOT / path).write_text(json.dumps(value, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')

def sha(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()

reports = ['tests/artifacts/shaw_west_v143_physics.json', 'tests/artifacts/shaw_west_v143_links.json']
accepted_routes = []
for path in reports:
    d = read(path)
    assert d['version'] == VERSION and not d['failures'], path
    assert all(x['valid'] for x in d['physical_legs'] + d['checks']), path
    accepted_routes.append({'report': path, 'legs': len(d['physical_legs']), 'checks': len(d['checks']), 'fixtures': d['fixtures']})
assert sum(x['legs'] for x in accepted_routes) == 69
views = ['plan', 'entry', 'return-stair', 'hall', 'courts-final', 'bridge-final']
images = ['tests/artifacts/courtyard-refined-shaw-west-v143-'+x+'.png' for x in views]
logs = ['tests/artifacts/'+x+'.log' for x in ['shaw_west_v143_main_final','shaw_west_v143_links_oriented_final','shaw_west_v143_gpu_oriented_final','shaw_west_v143_gpu_connections_final']]
for path in logs:
    lines = (ROOT/path).read_text(encoding='utf-8').splitlines()
    assert not any(s.startswith(('SCRIPT ERROR:', 'ERROR:')) for s in lines), path
code = ['world/visual_campus/'+x+'.gd' for x in ['ShawWestPlan','ShawEastPodium','ShawHillside','LandmarkBuildings','VisualCampusBuilder','MainSquareTerrace']]
code += ['systems/data/campus_visual_build.json'] + ['tests/'+x+'.gd' for x in ['ShawWestPlanV143','ShawWestLinksV143','ShawWestViewsV143']]
write('tests/artifacts/shaw_west_v143_accepted.json', {
    'model_version': VERSION, 'accepted_routes': accepted_routes, 'movement_records':69, 'fixtures':3, 'checks':11,
    'final_views': images, 'viewed':True, 'engine_errors_in_accepted_runs':0,
    'excluded':[
        'All before-orientation reports and screenshots: retired after relative 90-degree plan correction.',
        'terrain_failed, guard_failed, links_failed: preserved early failures; final source replaces old geometry.',
        'roof_approach_failed and roof_return_failed: test diagonal clipped real stair guard; final route uses clear corridor and clears stair foot before turning.',
        'The ordinary courts capture duplicates courts-final and is not counted as a seventh accepted view.'
    ],
    'limits':'69 overlapping/return records over3fixtures, not a full-campus continuous run or complete14chapter product acceptance. Public structural shells; fitted metric/site geometry; current fitout, dorm cores and roof details open.',
    'files':{p:sha(p) for p in code+reports+images+logs}
})

download_path = 'references/visual_build_20261008/originals/shaw-west-v143/downloads.json'
downloads = read(download_path)
if not any(x['id']=='west-plan4' for x in downloads):
    downloads.append({'id':'west-plan4','url':'https://mmbiz.qpic.cn/mmbiz_jpg/zf81ZjaKQteg3QFBsRFW9onFfUbrOolGe9k4l4VRAPibAujd0qWmB4X29KDRVySSRxuYKxkv4X4nrEZTm7EiaAQQ/0?wx_fmt=jpeg','file':'references/visual_build_20261008/originals/shaw-west-v143/west-plan4.jpg','exit_code':0})
for item in downloads:
    item['file'] = item['file'].replace('\\','/')
    p = ROOT/item['file']
    item.update(bytes=p.stat().st_size, sha256=sha(item['file']), dimensions=list(Image.open(p).size), viewed=True)
write(download_path, downloads)
write('references/visual_build_20261008/shaw_west_plan_v143.json', {
    'version':VERSION, 'doc':'docs/SHAW_WEST_PLAN_V143.md',
    'architect':{'url':'https://www.archiposition.com/items/20190905014221','published':'2019-09-10','capture_date':'unknown','scope':'historical structural drawings and axonometric, not current fitout','images':downloads},
    'official_panorama':{'scene':'116440787','resource':'70037192','capture_date':'unknown','observed':'thin metal picket rails, slender canopy and brown-gray rectangular paving','local_tiles':['references/visual_build_20261008/originals/landmark-instances/shaw-west/'+x+'.jpg' for x in ['30d64af40d89a68c','9297605c287b2efe','65b66f5977725068']]},
    'current_clues':[
        {'url':'https://shaw.cuhk.edu.cn/taxonomy/term/104?page=1','scope':'text only: West office E205, canteen B2; old gym numbers conflict with2026guide'},
        {'url':'https://shaw.cuhk.edu.cn/event/1407','published':'2025-09-19','scope':'text only: East plaza and A lobby; not full tower mapping'},
        {'local':'references/visual_build_20261008/originals/shaw-current-v142/guide-2026.pdf','scope':'2026guide edition; pp12/13 viewed inV142; rendering-like room illustrations not current as-built evidence'}
    ],
    'fit':{'origin_retained':[145,2.24,-640],'inner_yaw_degrees':90,'root_yaw_degrees':-90,'scale':'60/1214m per 1888px review coordinate; uniform manual fit, not surveyed','new_plan_extent_approx':[47.8,60],'public_levels':[0.05,4.4,8.8,12.1],'side_bridge_world_z':-665,'side_bridge_deck_y':14.34,'geographic_north':'unresolved'},
    'retired':'V52placeholder excluded; V53footprint, straight flights,3Frear bridge and old exact-coordinate walks replaced. Before-orientationV143 reports not current evidence.',
    'unresolved':['absolute placement/metric scale','tower letter mapping','present public room fitout','roof garden circular elements','dorm cores','precise facade/windows','old coarse minimap footprint'],
})

note = 'V143：重新取得西座1F至4F历史平面，重建三楼翼/两井/折返梯/三层厅廊及屋顶梯洞；内部相对旋转90度，山桥改四层侧接，锚点北向约束不变。切除穿入地形和旧广场面、入口硬铺雨棚/地标接路同步。69条分批往返记录、3起点、11检查、6终图通过；旧朝向/地形/栏杆失败保留排除，不是全区或14章验收。历史2019发布、全景拍摄未知，2026指南效果图不当现状，尺寸/桥长/装修仍拟合。下一批西座现状细节与展示，再完整主线/阶段发布；全A–G及既有下层背面边角缺项保留，发布整理后继续，Goal active。详见docs/SHAW_WEST_PLAN_V143.md。'
next_action = 'V143 Shaw West rebuilt from recovered historical1F-4F plans: three wings/two wells/switchbacks/3Fhall/4Fside hill bridge, relative orientation corrected,69records3fixtures11checks6views accepted. NEXT reconcile current public-space glazing/fitout and roof details, update precise minimap footprint and add West showcase chapter; then concentrated current whole-main-route/showcase acceptance and Windows/GitHub/local stage release. Exact site scale, tower letters and current room fitout remain partial. Preserve all A-G backlog; organize stable release baseline and continue existing active Goal/heartbeat. No account-quota-reset capability; persist checkpoints for interruption.'
evidence = {'doc':'docs/SHAW_WEST_PLAN_V143.md','source':'references/visual_build_20261008/shaw_west_plan_v143.json','accepted':'tests/artifacts/shaw_west_v143_accepted.json','movement_records':69,'fixtures':3,'checks':11,'views':6,'status':'local_structural_batch_accepted_fidelity_partial'}
ledger = read('docs/lower_campus_refinement_coverage.json')
ledger.update(updated='2026-10-12', status='active', basis_version=VERSION, previous_turn_classification='progress', previous_turn_progress_kind='model_and_evidence', next_action=next_action, v143_evidence=evidence)
e = next(x for x in ledger['zones'] if x['id']=='E')
e['v143_update'] = evidence
e['stages'].update({'1':'V142Eastcuts;V143Westpolygoncuts/removeoldplazaslab/entrancehardscape;actualsitegradefitted','2':'V143Westpairedswitchbacks1F-3Fand3F-4Froofstair;dormcoresopen','3':'V143Westmanualuniformplanfit_threewings_twocourts_relativeyawcorrected;absoluteplacementfitted','4':'V142East1Fshells;V143West1Ffoyer3Fhall_shells;currentfitoutopen','5':'V1434Fsidehillbridgeandgroundperimeteraccepted;old3Fbridgewalksretired','7':'V14369records3fixtures11checks6views;notwholezoneorproductacceptance'})
b = next(x for x in e['buildings'] if x['id']=='shaw_west')
b.update(status='V143_plan_registered_public_structure_and4Fsidebridge_partial',reference_status='Recovered1F2F3F4Farchitectplansreviewed;2019published_captureunknown;officialpanoramaobserved;currenttowerandroommappingpartial')
b['coverage'].update(front='V143forwardwing_switchbacks_slimcanopy_brownpaving',rear='V143registeredrearwing;old3Fbridge_retired',side_left='V143registeredmiddlewing_andtwo_wells',side_right='V1434Fsidebridge_androofstair;precise_fenestration_open',ground_or_pilotis='V143planpolygonfloor_foyer_terraincut;full1F2Froomlayoutopen',stairs_ramps='V143paired1F3Freturnflights_and3F4Froofstair_local_updown_pass;dimensionsfitted',connections='V143entryroad_roofbridge_groundperimeter_69batchedrecords_total',corners_drains_retaining_edges='V143oldraisedplazaslabtrimmed;fullsitehardscapeanddrainageopen')
b['superseded'] += ' V143 replaces V53 footprint, stair and3Frear bridge;V143beforeorientation reports retired. Root remains but plan-relativeyaw andheightconnection changed;historicalwalks are not current proof.'
b['evidence'] += [v for k,v in evidence.items() if k in ('doc','source','accepted') and v not in b['evidence']]
candidate=ledger['release_convergence']['candidate']
candidate['current_model_version']=VERSION
candidate['affected_shaw_west_route_check']='V14369localrecords3fixtures11checks;Westnotyetashowcasechapter;notcurrentfull14chapteracceptance'
write('docs/lower_campus_refinement_coverage.json',ledger)
for path in ['docs/LOWER_CAMPUS_ACTIVE_GOAL.md']:
    p=ROOT/path;s=p.read_text(encoding='utf-8-sig')
    if '\nV143：' not in s:p.write_text(s+'\n\n'+note+'\n',encoding='utf-8')
p=ROOT/'README.md';s=p.read_text(encoding='utf-8-sig').replace('模型 V142','模型 V143')
line='- [V143 逸夫西座平面、折返梯与屋顶山桥](docs/SHAW_WEST_PLAN_V143.md)\n'
if line not in s:s=s.replace('- [V142 ',line+'- [V142 ',1)
p.write_text(s,encoding='utf-8')
p=ROOT/'docs/NEXT_ITERATION_HANDOFF.md';s=p.read_text(encoding='utf-8-sig').replace('`official-visual-build-142-shaw-podium-plan`；','`'+VERSION+'`；[V143西座平面与山桥](SHAW_WEST_PLAN_V143.md)69分批记录、3起点、11检查、6终图；')
s=s.replace('下一批用2026官方指南和竣工/活动实景核对塔楼字母、房间层位及装修，随后补西座连接。','V143已重建西座三翼/两井/折返梯与四层侧桥；下一批核对现状公共空间、屋顶细节及塔楼对应，更新小地图轮廓并补西座展示章节。')
p.write_text(s,encoding='utf-8')
p=ROOT/'docs/FORMAL_RELEASE_CONVERGENCE.md';s=p.read_text(encoding='utf-8-sig').replace('模型已至V142','模型已至V143')
if 'V143 西座结构批次' not in s:s+='\nV143 西座结构批次：69条分批记录、3起点、11检查、6终图通过；西座尚未加入展示，局部验收不替代当前完整主线/14章。精确小地图轮廓、现状外墙/公共房间及屋顶细节继续待核。见SHAW_WEST_PLAN_V143.md。\n'
p.write_text(s,encoding='utf-8')
p=ROOT/'docs/PRODUCT_SHOWCASE_CANDIDATE.md';s=p.read_text(encoding='utf-8-sig')
if 'V143 西座' not in s:s+='\nV143 西座按平面重建，69条局部移动记录、3起点、11检查、6终图通过。西座暂未增加展示章节，当前仍14章；需新增该区镜头和真实步行后集中验收全展示，不能复用旧朝向坐标。见SHAW_WEST_PLAN_V143.md。\n'
p.write_text(s,encoding='utf-8')
print('V143 checkpoint written:69records/3fixtures/11checks/6reviewedviews;Goalactive;unpublished.')
