"""Record retained V118 evidence without widening the acceptance scope."""
import hashlib
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
def read(p):return json.loads((root/p).read_text(encoding='utf-8-sig'))
def write(p,v):(root/p).write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
def sha(p):return hashlib.sha256((root/p).read_bytes()).hexdigest()
paths=['tests/artifacts/library_shore_v118'+s+'.json' for s in ['', '_finish','_final','_details']]
a,b,c,d=[read(p) for p in paths]
assert all(x['valid'] for x in a['physical_legs'][:16])
assert all(x['valid'] for x in b['physical_legs'][:6])
assert len(c['physical_legs'])==7 and not c['failures'] and not d['failures']
assert all(x['valid'] for x in b['checks']) and len(b['checks'])==5
logs=['tests/artifacts/library-shore-v118'+s+'.log' for s in ['', '-finish','-final','-details']]
for p in logs:assert not any(line.startswith(('ERROR:','SCRIPT ERROR:')) for line in (root/p).read_text(encoding='utf-8').splitlines()),p
files=['world/visual_campus/'+x+'.gd' for x in ['LibraryPoolFrontage','LibraryEntryLawn','LibraryEntryApproach','LibraryLowerRightWing','LibraryRegisteredFloors','LibraryLowerFrontFacade','LibrarySpaces','VisualCampusBuilder','AnniversaryGround']]+['systems/data/campus_visual_build.json']
images=['tests/artifacts/courtyard-refined-library-shore-v118-details-'+x+'.png' for x in ['overview','lawn','soffit']]
limits='Photo-informed, fitted shoreline/lawn/levels, not surveying.116 small triangular bright patch persists after wall/roof thickness; visual sealing not accepted. G exterior whole circulation and support mass/remaining3F facade still unresolved. No true north claim.'
accepted={'version':d['version'],'status':'local_routes_passed_fidelity_partial_whole_goal_active',
 'accepted_legs':[{'file':paths[0],'indices':list(range(16))},{'file':paths[1],'indices':list(range(6))},{'file':paths[2],'indices':list(range(7))}],
 'valid_records':29,'fixture_starts':3,'not_single_continuous_tour':True,
 'accepted_checks':[{'file':paths[1],'indices':list(range(5))},{'file':paths[3],'indices':[0,1]}],'check_records':7,
 'retired':'Initial13 G-side approach legs superseded by extended water. Finish outerwalk failed at pavilion glass corner; all its outerwalk records retired and replaced by final7. Initial and finish captures contain obsolete paving; final captures predate visual border/grass triangulation finish. Original logs retained.',
 'retention_basis':'Initial16 south perimeter/main approach unchanged in collision. Finish6 G threshold legs unaffected by outerwalk correction. Final7 outerwalk legs unaffected by internal lawn tessellation, noncolliding border removal and closed116roof thickening. Details2 probes cover roof clearance.',
 'logs':logs,'engine_errors_in_retained_logs':0,'images_reviewed_final':images,'model_changed_after_detail_capture':False,
 'source_sha256':{p:sha(p) for p in files},'limits':limits}
write('tests/artifacts/library_shore_v118_accepted.json',accepted)
evidence={'version':d['version'],'photo':{'file':'references/anniversary-20261010/originals/mall-2023.jpg','sha256':sha('references/anniversary-20261010/originals/mall-2023.jpg'),'page':'https://10.cuhk.edu.cn/en/phase-i-campus','image_url':'https://10.cuhk.edu.cn/sites/default/files/2023-11/xiaoyuanhangpaisheyingchenming_2.jpg','date_basis':'Visible2023sign; exact capture date unknown; hosting directory not capture date','observed':'Water against lower finned facade,water alongside approach,lawn with narrow stone ties beside approach; no cross-water bridge shown'},'geometric_tie':'V115 publicly mapped3F fin line and V117 fitted approach. Outside bank retains earlier fitted world tie. G door kept dry locally; full exterior G loop not proven.','changes':files,'accepted':'tests/artifacts/library_shore_v118_accepted.json','limits':limits}
write('references/visual_build_20261008/library_shore_v118_evidence.json',evidence)
coverage=read('docs/lower_campus_refinement_coverage.json')
coverage.update(updated='2026-10-11',basis_version=d['version'],status='active',previous_turn_classification='progress')
coverage['next_action']='V118 pond now meets mapped fins and approach;terrain/alloldaprons clipped,unobserved bridge removed,dry perimeter/navigation relocated,lawn/stone ties/outer path built.29 valid movements/3starts and7 probes retained. Next prioritize actual G exterior access around new pond vs main-entry grade and central solid support/3F arcade face using official views; G local threshold6legs is NOT full exterior loop.116 small bright triangle persists despite wall/roof thickness; investigate material/edge/light locally rather than repeat broad tests. Pond outline/dimensions remain fitted. Then B/C/D andallA-G,legacy exterior threeanchors,fullrearroadtoShaw,backs/lowerlevels/corners. EastGate/north policy unchanged.'
coverage['v118_evidence']={'report':'docs/LIBRARY_SHORE_GROUND_V118.md','accepted':'tests/artifacts/library_shore_v118_accepted.json','valid_records':29,'fixture_starts':3,'checks':7,'final_images_viewed':3,'limits':limits}
for req in coverage['explicit_requirements']:
 if req['id']=='library_b1_identity_entry_and_space':
  req['note']+=' V118 changes reflecting shoreline and retains6 localGthreshold legs;former extendedGside-route superseded,full exteriorGaccess remains unverified.Small116brightseam persists.'
  req['evidence'].append('docs/LIBRARY_SHORE_GROUND_V118.md')
write('docs/lower_campus_refinement_coverage.json',coverage)
summary='V118：据可见2023标记的十周年照片，把池岸接到新竖片及入口缓坡侧边，重裁地形/馆前/十周年铺装，撤无依据跨水桥和旧木盆列，迁移导航到干地；入口侧补细石条草地、树和外步道。外步道初版擦展厅玻璃角，收边后7段通过；保留16主入口/池端及6G门槛，共29有效移动、3起点，7探针通过，有效日志无引擎错误，最终3图已看。116墙/底面加厚仍未消除小三角亮斑，未验收封闭视觉。新池岸使旧长G外侧路线退休，本批G6段仅门槛局部，下一批先核对真实G外接路线/支撑体/三楼架空，再B/C/D及全A–G；池岸尺度/标高仍拟合，真实北向不变，后车道至逸夫及全部下层背面角落保持。Goal active，详见 docs/LIBRARY_SHORE_GROUND_V118.md。'
p=root/'docs/LOWER_CAMPUS_ACTIVE_GOAL.md';s=p.read_text(encoding='utf-8-sig')
if '\nV118：' not in s:p.write_text(s+'\n\n'+summary+'\n',encoding='utf-8')
print(json.dumps({'version':d['version'],'accepted_legs':29,'fixtures':3,'checks':7,'goal':'active','visual_seam':'unresolved'},ensure_ascii=False))
