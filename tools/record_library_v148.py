"""Accept the changed sixth-floor batch and retain its failed route/compile evidence."""
from pathlib import Path
import hashlib
import json

ROOT=Path(__file__).resolve().parents[1]
def read(p): return json.loads((ROOT/p).read_text(encoding='utf-8-sig'))
def write(p,v): (ROOT/p).write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
def sha(p): return hashlib.sha256((ROOT/p).read_bytes()).hexdigest()
a_path='tests/artifacts/library_sixth_commons_v148.json'
b_path='tests/artifacts/library_sixth_commons_v148_finish.json'
v_path='tests/artifacts/library_sixth_commons_v148_visual.json'
a,b,v=read(a_path),read(b_path),read(v_path)
assert len(a['physical_legs'])==22 and all(x['valid'] for x in a['physical_legs'][:21])
assert not b['failures'] and len(b['physical_legs'])==3 and not v['failures']
checks=[i for i in range(len(a['checks'])) if i not in [87,88,89]]
assert len(checks)==96 and all(a['checks'][i]['valid'] for i in checks)
assert len(b['checks'])==7 and all(x['valid'] for x in b['checks'])
logs=['tests/artifacts/library-commons-v148-'+n+'.log' for n in ['initial','final','visual']]
for p in logs:
    assert not any(s.startswith(('ERROR:','SCRIPT ERROR:')) for s in (ROOT/p).read_text(encoding='utf-8').splitlines()),p
src=['world/visual_campus/LibrarySixthCommons.gd','world/visual_campus/LibraryRegisteredUpper.gd','world/visual_campus/LibraryRareReading.gd','world/visual_campus/CampusSurface.gdshader','systems/data/campus_visual_build.json']
receipt={
    'version':b['version'],'accepted_legs':[{'file':a_path,'indices':list(range(21))},{'file':b_path,'indices':[0,1,2]}],
    'valid_records':24,'fixtures':3,'not_single_tour':True,
    'accepted_checks':[{'file':a_path,'indices':checks},{'file':b_path,'indices':list(range(7))}],'check_records':103,
    'images_viewed':8,'effective_final_images':['courtyard-refined-library-commons-v148-'+n+'.png' for n in ['glass-final','lounge-finish','front-final','special-sign']],
    'retired':'Initial isolated-door target/floor check superseded after door turned toward602;old isolated-door probes also retired. Initial dotted band and chair moire images superseded. Compile failure in finish.log excluded.',
    'logs':logs,'engine_errors':0,'source_sha256':{p:sha(p) for p in src},'report_sha256':{p:sha(p) for p in [a_path,b_path,v_path]+logs},
    'scope':'Public6F aisles;29 numbered closed room fronts andone unnumbered envelope;sharedwall andfloor probes;two representative furniture-centre probes;not interiors or a full furniture audit.',
    'validation_reuse':'Only isolated room changed orientation after main batch;other successful routes/probes retained. Last change is chair-only surface51;no physics change,one affected view rechecked.',
    'limits':'Schematic plan andphotograph-backed representative fitout,not surveyedpositions/heights/113-seat census;unidentified frontroom maplabel401 not silently changed to601.WholeA-G goal active;stablev2.0.0 untouched.'}
write('tests/artifacts/library_sixth_commons_v148_accepted.json',receipt)
evidence={'date':'2026-10-12','sources':[{'url':'https://library.cuhk.edu.cn/zh-hans/event/1235','published':'2025-09-17','capture_date':'unknown','supports':['Special Collections rename andtimber vertical plaque','6F glazed partitions,pale dottedheads,flatceiling/linear lights,roundtables,mesh swivelchairs,burgundysofas']},{'url':'https://library.cuhk.edu.cn/zh-hans/event/1219','published':'2025-08-29','effective':'2025-09-01','supports':'7groupstudy,1meeting,22staffresearch rooms;not a photo date'}],
    'photos_manifest':'references/visual_build_20261008/originals/library-upper-v148/manifest.json',
    'plan':'references/visual_build_20261008/originals/library-plan-20261010/official-library-floor-6.jpg','plan_date':'2025-08 hosting path;not capture date',
    'plan_frame':[1820,1376],'registration':'references/visual_build_20261008/library_upper_registration_v112.json',
    'fitted_group_dimensions':[5.4,5.2,3.2],'group_width_basis':'about88-90 normalizedpixels in firstaxis-aligned mapgroup;schematic doors/symbols not surveyedwalls',
    'numbering_correction':'Rotated616-620 array is now618,617,616,619,620 locally,so globalmap reads616,617,618 alongbottom and620,619 alongtop',
    'front_room':{'map_centre':[696,1141],'map_label':'401','model_number':None,'door':'toward602 end aisle;NW edge borders void'},
    'limits':receipt['limits']}
write('references/visual_build_20261008/library_sixth_commons_v148.json',evidence)
c=read('docs/lower_campus_refinement_coverage.json')
c.update(updated='2026-10-12',basis_version=b['version'],previous_turn_classification='progress',status='active')
c['next_action']='V1486Fsharedclusters/frontrow/endroom built;2025-09officialphoto supportsrepresentative commonsfitout and5F SpecialCollectionsrename.24localrecords/103checks,4finalviews. NEXT library rearwing/roof/cross-floor supports thenstudentactual lowerentrance/service-door registration;retain sixthisolatedroom identity,currentinteriors/completefurniture andallA-G road/grade/back/corner backlog. Do not redo116lamp,V147coreintrusion orV148closeditems. Stablev2.0.0/V145 fixed,development2.0.1-dev only;Goal active.'
c['v148_evidence']={'report':'docs/LIBRARY_SIXTH_COMMONS_V148.md','evidence':'references/visual_build_20261008/library_sixth_commons_v148.json','accepted':'tests/artifacts/library_sixth_commons_v148_accepted.json','valid_records':24,'checks':103,'final_views':4,'limits':receipt['limits']}
c['release_convergence']['development']['model_version']=b['version']
for z in c['zones']:
    if z['id']!='C':continue
    z.setdefault('evidence',[]).append('docs/LIBRARY_SIXTH_COMMONS_V148.md')
    for building in z['buildings']:
        if building['id']=='library':building['coverage']['upper_public_levels']+=' V148 shared6Ffiveclusters/frontrow,616-620order andunnumberedendroom;2025-09photo commonsfitout/5F SpecialCollectionsname.Onlypublicaisles/closedroomfrontsverified;actualinteriors/completefurniture remainpartial.'
c['known_unfinished_features'].append('V148:front isolated6F room labelled401 inpublicmap remains unnumbered,not assumed601.6F fullinteriors/furniture positions/roof/rearwing/supports andcurrentdated fitout remainpartial;photo publication2025-09-17 notcapturedate.')
write('docs/lower_campus_refinement_coverage.json',c)
summary='V148：新读校方2025-09-17公告照片和2025-09-01空间调整，六层五组与602–605改共墙玻璃细框/浅色点状上沿，616–620排序修正；补无编号前端房间，门改朝602端部走道，原朝挑空错误退休。补圆桌/网背椅/酒红沙发/右翼平顶长条灯，五层改木质“特藏室”竖牌。24分批通行、3起点、103检查、4最终图通过，无有效日志引擎错误；初门口失败/脚本类型错误/粗点纹和网纹摩尔纹图排除，仅续查受影响处。尺寸及完整113座位/室内/前端401与601身份未定，照片发表不等于拍摄日期。下一批后翼屋顶/跨层支撑再学生真实下层门位，所有A–G和原点北向限制保留；开发2.0.1-dev，稳定v2.0.0不覆盖，Goal active。详见docs/LIBRARY_SIXTH_COMMONS_V148.md。'
for path in ['docs/LOWER_CAMPUS_ACTIVE_GOAL.md','docs/NEXT_ITERATION_HANDOFF.md']:
    p=ROOT/path;s=p.read_text(encoding='utf-8-sig')
    if '\nV148：' not in s:s+='\n\n'+summary+'\n'
    if path.endswith('HANDOFF.md'):
        s=s.replace('`official-visual-build-147-library-core-boundary`','`official-visual-build-148-library-sixth-commons`',1)
        s=s.replace('不能说这些改动已包含在稳定包。','V148 已补六层共墙组团与较新实景细节，24 分批通行、103 检查、4 终图。不能说这些改动已包含在稳定包。',1)
        s=s.replace('六层组团共墙、门向及前端独立房间身份，再后翼/屋顶/跨层支撑及学生真实下层门位。','图书馆后翼/屋顶/跨层支撑及学生真实下层门位；六层前端身份、完整室内和家具仍保留待核。',1)
    p.write_text(s,encoding='utf-8')
p=ROOT/'README.md';s=p.read_text(encoding='utf-8-sig').replace('`2.0.1-dev` / V147，[图书馆核心共墙与六层配准](docs/LIBRARY_CORE_BOUNDARY_V147.md)','`2.0.1-dev` / V148，[图书馆六层共墙与较新实景](docs/LIBRARY_SIXTH_COMMONS_V148.md)');p.write_text(s,encoding='utf-8')
print(json.dumps({'records':24,'checks':103,'final_views':4,'goal':'active'}))
