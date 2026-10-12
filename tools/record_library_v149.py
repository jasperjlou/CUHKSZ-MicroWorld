"""Record accepted V149 local checks, retaining superseded failures and source dates."""
from pathlib import Path
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[1]
def read(p): return json.loads((ROOT / p).read_text(encoding='utf-8-sig'))
def write(p, value): (ROOT / p).write_text(json.dumps(value, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')
def sha(p): return hashlib.sha256((ROOT / p).read_bytes()).hexdigest()

prefix = 'tests/artifacts/library_roof_rear_v149'
paths = [prefix+'.json', prefix+'_finish.json', prefix+'_pier.json']
a, b, c = [read(p) for p in paths]
assert not b['failures'] and not c['failures']
legs = [[i for i,v in enumerate(a['physical_legs']) if v['valid']], list(range(6)), list(range(4))]
assert len(legs[0]) == 9
checks = [
    [i for i,v in enumerate(a['checks']) if 'existing support foot' not in v['case'] and '[850, 740]' not in v['case']],
    [i for i,v in enumerate(b['checks']) if '[850, 740]' not in v['case']],
    list(range(10)),
]
assert [len(v) for v in checks] == [21,3,10]
for report, indices, ci in zip([a,b,c],legs,checks):
    assert all(report['physical_legs'][i]['valid'] for i in indices)
    assert all(report['checks'][i]['valid'] for i in ci)
logs = ['tests/artifacts/library-roof-v149-'+v+'.log' for v in ['initial','finish','pier']]
for p in logs:
    assert not any(v.startswith(('ERROR:','SCRIPT ERROR:')) for v in (ROOT/p).read_text(encoding='utf-8').splitlines()),p
source = ['world/visual_campus/'+v+'.gd' for v in ['LibraryUpperRegisteredPlan','LibraryAtrium','LibraryRegisteredUpper','LibraryEnvelope','LibraryRoofLantern','LibraryRearGlazing']]+['systems/data/campus_visual_build.json']
images = ['courtyard-refined-library-roof-v149-'+v+'.png' for v in ['overall','lantern','rear-left-final','rear-right-final','support','column-foot-final']]
receipt = {
    'version':c['version'], 'valid_records':19, 'fixtures':4, 'not_single_tour':True,
    'accepted_legs':[{'file':p,'indices':i} for p,i in zip(paths,legs)],
    'checks':34,'accepted_checks':[{'file':p,'indices':i} for p,i in zip(paths,checks)],
    'images_viewed':9,'effective_images':images,
    'image_scope':'Roof/lantern and unchanged column600,640 views retained;two endframes after visual head patch;corrected pier foot is final. Earlier wide facade views support facade only,not the subsequently moved interior pier.',
    'retired':'Initial blocked Cambridge shelf target;all initial foot probes and old850,740 roof probe;finish old850,740 base check and hanging-foot screenshot;initial rear heads with bright slit.',
    'validation_reuse':'Head patch visual only;retained glazing checks and aisle results.Only one pier moved after finish;checked its former space,new four-corner slab/roof/column and adjacent3F path.Whole campus not rerun.',
    'logs':logs,'engine_errors':0,'source_sha256':{p:sha(p) for p in source},
    'report_sha256':{p:sha(p) for p in paths+logs},
    'limits':'Visual fitting,not surveyed geometry or complete structural grid.Lower rear walls/doors remain on older estimate.Complete A-G goal active.Stablev2.0.0 unchanged.'}
write(prefix+'_accepted.json',receipt)

originals = 'references/visual_build_20261008/originals/library-roof-v149'
photos=[]
for name in ['003','006','008','009','017','019']:
    suffix={'009':'-960x582','017':'-960x640','019':'-960x640'}.get(name,'')
    p=originals+'/'+name+'.jpg'
    photos.append({'file':name+'.jpg','url':'https://oss.gooood.cn/uploads/2021/03/'+name+'-chinese-university-of-hong-kong-sz-library-by-wang-weijen-architecture'+suffix+'.jpg','bytes':(ROOT/p).stat().st_size,'sha256':sha(p),'published':'2021-03-16','capture_date':'unknown'})
write(originals+'/manifest.json',{'retrieved':'2026-10-12','article':'https://www.gooood.cn/chinese-university-of-hong-kong-sz-library-by-wang-weijen-architecture.htm','credit':'Wang Weijen Architecture supplied project material;photo credits per article','photos':photos,'limits':'Historic structural references;not evidence of current furnishing.009 repeats existing courtyard aerial,not an independent view.'})
evidence = {
    'date':'2026-10-12','photos_manifest':originals+'/manifest.json',
    'sources':[
        {'url':'https://campusvr-en.cuhk.edu.cn/?scene_id=70037189','capture_date':'unknown','local_directory':'references/visual_build_20261008/originals/rear-wall-20261010','key_images':['e19dae8d99aa6175.jpg','891ef9a55942fa16.jpg'],'supports':'Deep upper rear-tip frames/red reveals,centralpier andmullions;lower rear masonry still pending'},
        {'url':'https://wwjarch.com/Central-Courtyard-of-Chinese-University-of-Hong-Kong-SZ','project_dates':'2012-16','capture_date':'unknown','supports':'Folded raised lantern andlow roof perimeter'},
        {'url':'https://www.gooood.cn/chinese-university-of-hong-kong-sz-library-by-wang-weijen-architecture.htm','published':'2021-03-16','capture_date':'unknown','supports':'Architect-supplied roof/section/support relationship;not currentdated conditions'},
        {'url':'https://10.cuhk.edu.cn/en/phase-i-campus','capture_date':'exactdate unknown;2023 marker visible in localmallphoto','supports':'Newer overall massing,not hidden roof construction'}],
    'fitted_dimensions':{'rear_glass_recess':1.35,'rear_frame_side_width':.65,'roof_upstand_height':.32,'lantern_eave':28.3,'lantern_ridge':29.25},
    'pier_correction':{'old_public4F_point':[850,740],'new_fitted_point':[865,754],'reason':'Oldbase on2F-3F stairvoid. Shiftwholepier about1.3m onto3F slab;allfourfootcorners checked. Not surveyedgrid.'},
    'limits':receipt['limits']}
write('references/visual_build_20261008/library_roof_rear_v149.json',evidence)
coverage=read('docs/lower_campus_refinement_coverage.json')
coverage.update(updated='2026-10-12',basis_version=c['version'],previous_turn_classification='progress',status='active')
coverage['next_action']='V149 rear uppertips/roofcurb/lanternbase/4supporttops andonehangingpier corrected;19validrecords/34checks,6scope-specific finalviews. NEXT register library lowerrear masonry/narrowwindows/doors/pierbases againstindependentG-3Fplans andofficialrearroadphoto,thenstudentactual lowerentrance/service-door registration. Retainfullroof shape/currentinteriors/completecolumn grid,6Funnumberedroom identity andallA-Groad/grade/back/corner backlog. Do notredo V146lamp,V147core,V148commons orV149closedchecks. Stablev2.0.0 fixed,development2.0.1-dev;Goal active.'
coverage['v149_evidence']={'report':'docs/LIBRARY_ROOF_REAR_V149.md','evidence':'references/visual_build_20261008/library_roof_rear_v149.json','accepted':prefix+'_accepted.json','valid_records':19,'checks':34,'effective_views':6,'limits':receipt['limits']}
coverage['release_convergence']['development']['model_version']=c['version']
for zone in coverage['zones']:
    if zone['id']!='C':continue
    report='docs/LIBRARY_ROOF_REAR_V149.md'
    if report not in zone.setdefault('evidence',[]):zone['evidence'].append(report)
    for building in zone['buildings']:
        if building['id']=='library' and 'V149' not in building['coverage']['upper_public_levels']:
            building['coverage']['upper_public_levels']+=' V149 recessedrearupperframes/roofcurb/lanternbase/4roofsupporttops;onepier shiftedoffstairvoid onto3Fslab.Localchecks only;lowerrear andfullcolumn grid remainpartial.'
unfinished='V149:upperrear tips refined,butlowerrear masonry/narrowwindows/doors andindependentfloorregistration stillpending;completecolumn grid/roof pitch andequipment notsurveyed.1.3m piermove islocalgeometriccorrection,notconstructioncoordinates.'
if unfinished not in coverage['known_unfinished_features']:coverage['known_unfinished_features'].append(unfinished)
write('docs/lower_campus_refinement_coverage.json',coverage)
summary='V149：按官方后路全景补上层两端内退玻璃、浅灰厚框/中柱/红褐侧壁；屋顶加连续挡边，天窗基座随坡贴合，四柱顶接屋面。发现一柱脚悬在2F–3F梯洞，整根拟合移约1.3米至三楼实板，四角及各层碰撞通过。19有效分批移动、4起点、34检查、6分范围最终视图，无引擎错误；初书架阻挡/旧柱脚检查及窗顶亮缝图退休，仅续查受影响处。全景拍摄日未知，2021建筑师资料为历史结构参照。下一批下层后翼灰墙/窄窗/门及柱脚独立配准，再学生真实下层门位；全A–G/完整柱网/现状室内/原点北向边界保留。稳定v2.0.0不覆盖，开发2.0.1-dev；Goal active。详见docs/LIBRARY_ROOF_REAR_V149.md。'
for filename in ['docs/LOWER_CAMPUS_ACTIVE_GOAL.md','docs/NEXT_ITERATION_HANDOFF.md']:
    p=ROOT/filename;s=p.read_text(encoding='utf-8-sig')
    if '\nV149：' not in s:s+='\n\n'+summary+'\n'
    if filename.endswith('HANDOFF.md'):
        s=s.replace('`official-visual-build-148-library-sixth-commons`','`official-visual-build-149-library-roof-rear`',1)
        if 'V149 已补' not in s:s=s.replace('不能说这些改动已包含在稳定包。','V149 已补后翼端面、屋面和局部柱连接，19 分批记录、34 检查、6 分范围视图。不能说这些改动已包含在稳定包。',1)
        s=s.replace('图书馆后翼/屋顶/跨层支撑及学生真实下层门位；','图书馆下层后翼灰墙/窄窗/门与柱脚独立配准，再学生真实下层门位；',1)
    p.write_text(s,encoding='utf-8')
p=ROOT/'README.md';s=p.read_text(encoding='utf-8-sig').replace('`2.0.1-dev` / V148，[图书馆六层共墙与较新实景](docs/LIBRARY_SIXTH_COMMONS_V148.md)','`2.0.1-dev` / V149，[图书馆后翼端面与屋顶](docs/LIBRARY_ROOF_REAR_V149.md)');p.write_text(s,encoding='utf-8')
exports=re.findall(r'res://[^"\s,]+',(ROOT/'export_presets.cfg').read_text(encoding='utf-8-sig'))
assert all((ROOT/p[6:]).exists() for p in exports)
print(json.dumps({'records':19,'checks':34,'views':6,'export_resources':len(set(exports)),'stable':'unchanged','goal':'active'}))
