"""Save scoped lower-rear evidence; retain failed early targets and grade uncertainty."""
from pathlib import Path
import hashlib
import json

ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text(encoding='utf-8-sig'))
def write(p,v):(ROOT/p).write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
def sha(p):return hashlib.sha256((ROOT/p).read_bytes()).hexdigest()
prefix='tests/artifacts/library_lower_rear_v150'
paths=[prefix+'.json',prefix+'_finish.json',prefix+'_floor.json']
a,b,c=[read(p) for p in paths]
assert len(a['physical_legs'])==15 and all(v['valid'] for v in a['physical_legs'][:14])
assert not b['failures'] and len(b['physical_legs'])==12
assert not c['failures'] and len(c['checks'])==3
ai=[0,1,2,4,5]
assert all(a['checks'][i]['valid'] for i in ai)
assert len(b['checks'])==4 and all(v['valid'] for v in b['checks'])
logs=['tests/artifacts/library-lower-rear-v150-'+v+'.log' for v in ['initial','finish','floor']]
for p in logs:assert not any(v.startswith(('ERROR:','SCRIPT ERROR:')) for v in (ROOT/p).read_text(encoding='utf-8').splitlines()),p
src=['world/visual_campus/'+v+'.gd' for v in ['LibraryLowerRearEnvelope','LibraryEnvelope','LibraryUpperLevels']]+['systems/data/campus_visual_build.json','export_presets.cfg']
images=['courtyard-refined-library-lower-rear-v150-'+v+'.png' for v in ['masonry','portal','overall','terrace-final','diagonal-door','vestibule-finish']]
receipt={
    'version':c['version'],'valid_records':26,'fixtures':4,'not_single_tour':True,
    'accepted_legs':[{'file':paths[0],'indices':list(range(14))},{'file':paths[1],'indices':list(range(12))}],
    'checks':12,'accepted_checks':[{'file':paths[0],'indices':ai},{'file':paths[1],'indices':list(range(4))},{'file':paths[2],'indices':list(range(3))}],
    'images_viewed':9,'effective_images':images,
    'retired':'Initial3Ftarget850,275cutsacrossglazing;initialx=-35probehitretainedWCwall,notretiredfacade.Initialterracetext mirrored;initial/intermediatevestibuleexposedasphalt.',
    'validation_reuse':'26movementrecords precede final0.106m innerfloor/shallower ramp joint.Only joint height/rays andoneGPU view checked after floorchange;not claimed as26new walks on finalfloor.Fullcampus untouched.',
    'scope':'Registered2F/3Frearenvelope,2terracedoors/3guards,Gfitted rearporch/vestibule/side ramp;not proof oftrueG/2Froadgrade orserviceareas.',
    'logs':logs,'engine_errors':0,'source_sha256':{p:sha(p) for p in src},'report_sha256':{p:sha(p) for p in paths+logs},
    'limits':'Officialplansschematic;photo datesunknown.Gdooridentity/0.48mporch andgrade/serviceenclosure remainhypothesis;fullA-Gandlibrarygrid/interiors incomplete.Stablev2.0.0 unchanged.'}
write(prefix+'_accepted.json',receipt)
evidence={
    'date':'2026-10-12','sources':[
        {'url':'https://library.cuhk.edu.cn/zh-hans/floor-maps','frames':{'1F':[1818,1344],'2F':[1862,1312],'3F':[1856,1339]},'dates':'1F202401 filename,2F/3F2021-11hosting paths;notphotodates','registration':'library_lower_front_v115_evidence.json'},
        {'url':'https://campusvr-en.cuhk.edu.cn/?scene_id=70037189','capture_date':'unknown','local_key_images':['originals/rear-wall-20261010/e19dae8d99aa6175.jpg','originals/rear-wall-20261010/3a51e1754adb4fa0.jpg'],'supports':'Greymasonry,verticalslits,glazedrearentrance andrecessedcourtyard;notleveldatum'},
        {'url':'https://www.gooood.cn/chinese-university-of-hong-kong-sz-library-by-wang-weijen-architecture.htm','published':'2021-03-16','capture_date':'unknown','drawing_revision':'unknown','supports':'Interlockingupper/lowerwings,sectionandterrace'},
        {'url':'https://10.cuhk.edu.cn/en/phase-i-campus','capture_date':'unknown exactday;2023marker visible inlocalmallphoto','supports':'Newer overallvolumecheck;hiddenGspacecannotbeinferred'}],
    'traced_second_rear':[[154,40],[698,40],[698,127],[878,277],[935,222],[1017,300],[1090,230],[1238,382]],
    'traced_third_rear':[[238,32],[608,32],[608,272],[887,272],[978,361],[1013,329],[1005,280],[1070,341],[1128,293],[1254,420]],
    'old_wall':{'local_z':-25.1,'new_second_line':[[-39.72,-32.73],[-9.19,-31.34]],'metric_status':'fitted'},
    'ground_hypothesis':'1F publicprogramme omits service/staffareas under2F;useclosedserviceenclosure andretainedGaccess identitypendingindependentroadgrade. Notmeasuredorconfirmednewroom.',
    'limits':receipt['limits']}
write('references/visual_build_20261008/library_lower_rear_v150.json',evidence)
coverage=read('docs/lower_campus_refinement_coverage.json')
coverage.update(updated='2026-10-12',basis_version=c['version'],previous_turn_classification='progress',status='active')
coverage['next_action']='V150 independent2F/3Flowerrear greywalls/slits/terraceglazing andtwo doors built;oldCnotchglass/fakecolumns removed;Gporch movedwithnewwall,vestibulejoined.26localmovementrecords/12checks/6scopedviews. NEXT jointlycalibrate rearroad-to-G/2Fgrade/dooridentity andstudentcentre actual lowerentrance/service-door/corridor interface usinglegacysections anddatedofficialrefs;do notfreeze fittedGrearidentity asfact. Continue D->F/G andallA-G ground/grade/back/corner/connection gaps;fullcolumn grid/interiors/6Funnumberedroom retained. Do notredo V146-150closedchecks. Stablev2.0.0 fixed,development2.0.1-dev;Goal active.'
coverage['v150_evidence']={'report':'docs/LIBRARY_LOWER_REAR_V150.md','evidence':'references/visual_build_20261008/library_lower_rear_v150.json','accepted':prefix+'_accepted.json','valid_records':26,'checks':12,'effective_views':6,'limits':receipt['limits']}
coverage['release_convergence']['development']['model_version']=c['version']
for zone in coverage['zones']:
    if zone['id']!='C':continue
    report='docs/LIBRARY_LOWER_REAR_V150.md'
    if report not in zone.setdefault('evidence',[]):zone['evidence'].append(report)
    for building in zone['buildings']:
        if building['id']=='library' and 'V150' not in building['coverage']['upper_public_levels']:
            building['coverage']['upper_public_levels']+=' V150 independent2F/3F rearoutline,greybrickslits/3Fterraceglass/2doors/guardclosure. Gporch/vestibule joinedbutdoorlevel/roadgrade stillhypothesis;localchecks notwholestructurecompletion.'
unfinished='V150:confirm rearroad datum vsG/2Fandactualrearentrylevel;Gserviceenclosurebelowstaffwingnotfullyshowninpublic1Fmap.2Fpublic/staffpartitions,3Ffitout,andfullstructuralgridstillpartial. NewGdoor/0.48mporch isfittedaccess,notcurrent-siteproof.'
if unfinished not in coverage['known_unfinished_features']:coverage['known_unfinished_features'].append(unfinished)
write('docs/lower_campus_refinement_coverage.json',coverage)
summary='V150：二/三楼独立后缘替换旧上层凹口玻璃；补灰砖窄窗、退台屋面、三楼两门及室外学习区护栏，撤占位柱廊。后门随新墙前移并接原G走道/短阶/侧坡，门厅石材收口修复。26分批移动、4起点、12检查、6分范围图；最后0.106米内坡接缝仅局部射线/GPU复核，未冒充重走26段。初斜穿玻璃目标、卫生间墙误探针及沥青/镜像文字图退休，无引擎错误。后路对G/2F标高及后门身份、未示服务区仍假设，不能按走通宣称实景成立。下一批联合后路标高与学生中心真实下层入口/服务门/连廊接口，再D至F/G及全A–G。稳定v2.0.0不覆盖；开发2.0.1-dev，Goal active。详见docs/LIBRARY_LOWER_REAR_V150.md。'
for filename in ['docs/LOWER_CAMPUS_ACTIVE_GOAL.md','docs/NEXT_ITERATION_HANDOFF.md']:
    p=ROOT/filename;s=p.read_text(encoding='utf-8-sig')
    if '\nV150：' not in s:s+='\n\n'+summary+'\n'
    if filename.endswith('HANDOFF.md'):
        s=s.replace('`official-visual-build-149-library-roof-rear`','`official-visual-build-150-library-lower-rear`',1)
        if 'V150 已改' not in s:s=s.replace('不能说这些改动已包含在稳定包。','V150 已改下层后翼与露台，26 分批记录、12 检查、6 分范围视图。不能说这些改动已包含在稳定包。',1)
        s=s.replace('图书馆下层后翼灰墙/窄窗/门与柱脚独立配准，再学生真实下层门位；','联合核准图书馆后路对 G/2F 标高、后门身份与学生中心真实下层入口/连廊接口；',1)
    p.write_text(s,encoding='utf-8')
p=ROOT/'README.md';s=p.read_text(encoding='utf-8-sig').replace('`2.0.1-dev` / V149，[图书馆后翼端面与屋顶](docs/LIBRARY_ROOF_REAR_V149.md)','`2.0.1-dev` / V150，[图书馆下层后翼与露台](docs/LIBRARY_LOWER_REAR_V150.md)');p.write_text(s,encoding='utf-8')
print(json.dumps({'records':26,'checks':12,'views':6,'goal':'active','stable':'unchanged'}))
