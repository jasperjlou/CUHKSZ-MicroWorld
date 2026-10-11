"""Save V144's bounded evidence and current continuation state."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VERSION = 'official-visual-build-144-shaw-public-glazing'
def read(p): return json.loads((ROOT/p).read_text('utf-8-sig'))
def write(p,d): (ROOT/p).write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
def sha(p): return hashlib.sha256((ROOT/p).read_bytes()).hexdigest()

paths=['tests/artifacts/'+x+'.json' for x in ['shaw_public_v144_physics','shaw_west_showcase_v144','shaw_public_v144_finish']]
reports=[read(p) for p in paths]
for p,d in zip(paths,reports):
    assert d['version']==VERSION and not d['failures'],p
    assert all(x['valid'] for x in d.get('physical_legs',[])+d['checks']),p
images=[x.replace('res://','') if x.startswith('res://') else 'tests/artifacts/'+x for x in reports[-1]['captures']]
assert len(images)==7
logs=['tests/artifacts/'+x+'.log' for x in ['shaw_public_v144_physics_final','shaw_west_showcase_v144','shaw_public_v144_finish_seams']]
for p in logs:
    assert not any(x.startswith(('SCRIPT ERROR:','ERROR:')) for x in (ROOT/p).read_text('utf-8').splitlines()),p
files=['world/visual_campus/ShawWestPlan.gd','world/visual_campus/VisualCampusMap.gd','world/product/ShowcaseChapters.gd','systems/data/campus_visual_build.json']
files+=['tests/'+x+'.gd' for x in ['ShawPublicV144','ShawWestShowcaseV144','ShawPublicFinishV144']]
write('tests/artifacts/shaw_public_v144_accepted.json',{
    'model_version':VERSION,'accepted_reports':paths,'movement_records':sum(len(d.get('physical_legs',[])) for d in reports),'fixtures':3,
    'checks':sum(len(d['checks']) for d in reports),'final_views':images,'viewed':True,'engine_errors_in_accepted_runs':0,
    'scope':'14 room records and31 new-chapter records before redundant enclosed guard removal;13 final wall/landing probes after removal. No floor/window/door/route movement. Not full15chapter acceptance.',
    'excluded':['Initial type-inference parse failure;shaw_public_v144_parse_failed.json','Pre-finish images with duplicate enclosed deck rails;not final views','Original chapter end image taken before look-back settled;final end is a declared visual-only fixture'],
    'files':{p:sha(p) for p in files+paths+logs+images}})

folder='references/visual_build_20261008/originals/shaw-public-v144/'
urls=read(folder+'downloads.json')
source='references/visual_build_20261008/shaw_public_glazing_v144.json'
write(source,{'version':VERSION,'page':'https://www.archiposition.com/items/20190905014221','published':'2019-09-10','capture_date':'unknown',
    'images':[{'id':k,'url':v,'file':folder+k+'.jpg','bytes':(ROOT/(folder+k+'.jpg')).stat().st_size,'sha256':sha(folder+k+'.jpg'),'viewed':True} for k,v in urls.items()],
    'official_cross_reference':{'scene':'116440787','resource':'70037192','capture_date':'unknown','tiles':['30d64af40d89a68c','65b66f5977725068'],'observed':'public-layer glazing/vertical strips,gray endwall and entrance canopy;resource2024 is not capture date'},
    'plan':'V143 recovered3Fwindow runs;historical structure,not current interiors',
    'implemented':'public-layer glazing and yellow fins,middle perimeter shells,live plan minimap,31leg West showcase chapter',
    'limits':['window bays/sills/fin density fitted','middle interior partitions/furniture omitted','current fitout/tower letters unresolved','roof collectors observed but unbuilt','round roof objects unresolved','not surveyed dimensions or calibrated north']})

next_action='V144 public-layer glazing/yellow fins,middle shells,live West minimap and new West showcase chapter implemented;45movementrecords3fixtures22checks7finalviews. NEXT concentrated current15chapter product/control acceptance and cross-zone main-route review; fix actual release-level defects,prepare Windows export and GitHub/local stable build with only Player/Agent entries. Room fitout,roof landscape/collector arrays,current tower mapping and all A-G fidelity backlog remain;stage publication then organize and continue active Goal/heartbeat.'
ev={'doc':'docs/SHAW_PUBLIC_GLAZING_V144.md','source':source,'accepted':'tests/artifacts/shaw_public_v144_accepted.json','movement_records':45,'fixtures':3,'checks':22,'views':7,'status':'local_model_and_new_chapter_verified;whole15chapter_pending'}
d=read('docs/lower_campus_refinement_coverage.json')
d.update(updated='2026-10-12',basis_version=VERSION,status='active',previous_turn_classification='progress',previous_turn_progress_kind='model_and_showcase',next_action=next_action,v144_evidence=ev)
e=next(z for z in d['zones'] if z['id']=='E');e['v144_update']=ev
e['stages']['4']='V144Westmiddle_andforward_public_glazing_yellowfins_hallwindowruns;currentfitout_andinternalpartitions_open'
e['stages']['7']='V14445records3fixtures22checks7views;one_new_showcasechapter;full15chapters_pending'
b=next(x for x in e['buildings'] if x['id']=='shaw_west')
b['status']='V144_public_envelope_and_showcase_verified_fidelity_partial'
b['coverage']['front']='V144middle_forward_public_glazing_yellowfins;finspacing_fitted'
b['coverage']['ground_or_pilotis']='V143foyer;V144twolevelmiddle_perimeter_shells_and3Fhallglazing;actualroompartitions_fitout_open'
b['coverage']['connections']='V14431leg_showcase_entry_switchbacks_publicrooms_roofbridge;V143groundperimeter_retained'
for k in ['doc','source','accepted']:
    if ev[k] not in b['evidence']:b['evidence'].append(ev[k])
c=d['release_convergence']['candidate'];c.update(current_model_version=VERSION,chapters=15,full_campus_route_accepted=False)
c['west_chapter_evidence']=ev['doc'];c['affected_shaw_west_route_check']='V14431newchapterlegs+14roomlegs;13finalguardreplacementprobes;not full15chapter run'
c['normal_duration_estimate_seconds']=round(375+sum(x['seconds'] for x in reports[1]['physical_legs'])+7)
write('docs/lower_campus_refinement_coverage.json',d)
note='V144：西座公共层连续玻璃、灰窗裙/金属框/黄色竖向构件和中翼两层外围壳体落地，清重复窗后护栏，小地图改同源轮廓；新增西座31段展示，现15章。14房间+31展示=45分批记录、3起点，9初检+13最终边界=22检查，7终图已看，无最终引擎错误。初编译失败/旧栏杆图/过早结束截图排除；屋顶桥端最终机位仅视觉复核。2019发布图与未知年代全景交叉，不冒充当前装修。下一批当前15章/跨区主线集中验收、Windows/GitHub本地阶段发布；全部A–G/现状内部/屋顶/背面角落待办保持，发布整理后继续，Goal active。详见docs/SHAW_PUBLIC_GLAZING_V144.md。'
p=ROOT/'docs/LOWER_CAMPUS_ACTIVE_GOAL.md';s=p.read_text('utf-8-sig')
if '\nV144：' not in s:p.write_text(s+'\n\n'+note+'\n',encoding='utf-8')
p=ROOT/'README.md';s=p.read_text('utf-8-sig').replace('模型 V143','模型 V144')
if 'V144 逸夫' not in s:s=s.replace('- [V143 ','- [V144 逸夫西座公共层窗墙与展示](docs/SHAW_PUBLIC_GLAZING_V144.md)\n- [V143 ',1)
p.write_text(s,encoding='utf-8')
p=ROOT/'docs/NEXT_ITERATION_HANDOFF.md';s=p.read_text('utf-8-sig').replace('`official-visual-build-143-shaw-west-plan`；','`'+VERSION+'`；[V144公共窗墙与展示](SHAW_PUBLIC_GLAZING_V144.md)45分批记录、22检查、7终图；')
s=s.replace('现14章','V144再加西座一章，现15章').replace('下一批核对现状公共空间、屋顶细节及塔楼对应，更新小地图轮廓并补西座展示章节。','V144已补公共窗墙、小地图同源轮廓及西座展示；下一批集中核验当前15章及跨区主线，再准备阶段发行。现状房间、屋顶细节与塔楼对应继续保留。')
p.write_text(s,encoding='utf-8')
p=ROOT/'docs/FORMAL_RELEASE_CONVERGENCE.md';s=p.read_text('utf-8-sig').replace('模型已至V143','模型已至V144').replace('全主线和当前14章整段验收仍待完成','V144新增西座31段展示；全主线和当前15章整段验收仍待完成')
if '\nV144 ' not in s:s+='\nV144 公共层窗墙与西座展示完成局部批次：45条记录、22检查、7终图；西座已加入，当前15章。进入完整主线和整段展示的集中收束，不能以分批记录冒充全部通过。详见SHAW_PUBLIC_GLAZING_V144.md。\n'
p.write_text(s,encoding='utf-8')
p=ROOT/'docs/PRODUCT_SHOWCASE_CANDIDATE.md';s=p.read_text('utf-8-sig')
if '\nV144 ' not in s:s+='\nV144 新增第12章逸夫西座：从雨棚上折返梯、公共层窗墙及厅廊、屋顶梯至山桥，共31段实际身体移动通过。当前15章，仍未整段集中验证；本次45移动记录含另外两层房间14段，末尾删除重复窗后栏杆另13边界检查。最终7图含桥端回看视觉机位，不算另一次通行。见SHAW_PUBLIC_GLAZING_V144.md。\n'
p.write_text(s,encoding='utf-8')
print('V144 checkpoint:45records,22checks,7finalviews;15chapters with full run pending;active/unpublished.')

