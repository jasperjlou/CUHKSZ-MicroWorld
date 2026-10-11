"""Record the focused V114 checks; no model changes or repeated whole-campus tests."""
from pathlib import Path
import json,hashlib
root=Path(__file__).resolve().parents[1]
def read(p):return json.loads((root/p).read_text(encoding='utf-8-sig'))
def write(p,d):(root/p).write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
main=read('tests/artifacts/library_pool_facade_v114.json')
views=read('tests/artifacts/library_pool_facade_v114_views.json')
assert not main['failures'] and not views['failures']
assert len(main['physical_legs'])==7 and all(x['valid'] for x in main['physical_legs'])
assert len(main['checks'])==6 and all(x['valid'] for x in main['checks'])
logs=['tests/artifacts/library-pool-facade-v114-final.log','tests/artifacts/library-pool-facade-v114-roof-final.log']
for p in logs:assert not any(x.startswith(('ERROR:','SCRIPT ERROR:')) for x in (root/p).read_text(encoding='utf-8').splitlines())
sources=['world/visual_campus/'+s+'.gd' for s in ['LibraryEnvelope','LibraryPoolFacade','LibraryRoofLantern','LibraryRegisteredUpper','LibraryRareReading']]+['systems/data/campus_visual_build.json']
accepted={'version':main['version'],'physical_report':'tests/artifacts/library_pool_facade_v114.json','roof_report':'tests/artifacts/library_pool_facade_v114_views.json','valid_records':7,'fixtures':1,'checks':6,'logs':logs,'engine_errors':0,'images_reviewed':['courtyard-refined-library-pool-facade-v114-'+n+'.png' for n in ['water','reveals','roof-final','lantern-final']],'image_scope':'water/reveals confirm unchanged facade after shelf/room fix, before later visual roof work; roof-final/lantern-final show final roof geometry. Initial corner camera sees other side; not entry facade evidence.','source_sha256':{p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in sources},'models_changed_after_final_validation':False,'limits':'Fitted window count/size and roof heights. Lower fins/pavilion/pool/stair registration andsupport correspondence not solved. Rare-core intrusion,6F andallA-G remain active.'}
write('tests/artifacts/library_pool_facade_v114_accepted.json',accepted)
evidence={'report':'docs/LIBRARY_POOL_FACADE_V114.md','anniversary_image':'references/anniversary-20261010/originals/mall-2023.jpg','dated_basis':'2023 visible sign; exact capture unknown','panorama':'https://campusvr-en.cuhk.edu.cn/?scene_id=116440792','panorama_capture':'unknown','roof_photo':'references/visual_build_20261008/originals/central-courtyard-20261010/wwj-courtyard-aerial.jpg','roof_photo_capture':'unknown historical structure reference','architect_drawings':'references/visual_build_20261008/originals/library-section-20261010/sources.json','front_edges':{'grouped':[22,23,24],'regular':[25,26,27,28,29]},'coordinate_change':False,'geographic_north':'unresolved','limits':accepted['limits']}
write('references/visual_build_20261008/library_pool_facade_v114_evidence.json',evidence)
p='docs/lower_campus_refinement_coverage.json';c=read(p)
c.update(updated='2026-10-11',status='active',previous_turn_classification='progress',basis_version=main['version'])
c['next_action']='V114 entry-side window families,through-wall racks andcontinuous folded roof lantern corrected. Priority: register lower1F/2F/3F supporting/finned wings,entrance pavilion/mainstair/pool edges against current upper footprint using public plans andarchitectsections/aerial;old lower generic silhouette remains visibly mismatched. Resolve leftservicecore intruding rare-room shared edge andindependent6F alignment. ResumeB/C/D spatial sequence thenallA-G;rearroadtoShaw,mainstair lowerinterior,ground/roads/backfaces/corners allremain. EastGateorigin retained,northunresolved.'
c['v114_evidence']={'report':'docs/LIBRARY_POOL_FACADE_V114.md','accepted':'tests/artifacts/library_pool_facade_v114_accepted.json','valid_records':7,'checks':6,'effective_views':4,'engine_errors':0,'models_changed_after_final_validation':False,'limits':accepted['limits']}
c['known_unfinished_features'].append('V114 exposes retained lowerfinned wings,pavilion/stair/pool versus registered upperfootprint mismatch;must correct commonedges/supports using1F-3F source alignment before more generic facade decoration. Other sides still use approximate repetitivewindows. Rarecore/6F/allA-G remain.')
write(p,c)
summary='V114：按十周年2023标志照片/官方全景区分入口侧窄窗与成组短窗、局部橙色和板缝；四组书架内退避免穿墙，撤珍藏室重复外侧实墙遮窗。按建筑师已建航拍/剖解图将两小天窗连为转折双坡天窗，沿屋面高度折线分片修长裂缝。7段单起点沿窗往返、6外窗碰撞探针通过；后续纯屋顶改动只复查对应画面，4有效视角、日志无错误。上下层金色竖片翼/入口亭/主梯/池岸仍未共同配准，左核心侵入珍藏室及6F残差未完；下一批先修这些共同边界和支撑，再B/C/D及全A–G，后车道至逸夫/主梯下馆内下层/真实地板/背面角落留项。窗数尺寸/天窗高仍拟合，原点方向未变，Goal active。详见 docs/LIBRARY_POOL_FACADE_V114.md。'
p=root/'docs/LOWER_CAMPUS_ACTIVE_GOAL.md';s=p.read_text(encoding='utf-8-sig')
if '\nV114：' not in s:p.write_text(s+'\n\n'+summary+'\n',encoding='utf-8')
print(json.dumps({'version':main['version'],'records':7,'checks':6,'views':4,'errors':0,'goal':'active'}))
