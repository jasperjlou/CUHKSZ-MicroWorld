"""Save the completed batch evidence and next continuation without a release."""
import hashlib
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text(encoding='utf-8-sig'))
def write(p,j):(ROOT/p).write_text(json.dumps(j,ensure_ascii=False,indent=2)+'\n',encoding='utf-8',newline='\n')
def sha(p):return hashlib.sha256((ROOT/p).read_bytes()).hexdigest()
a=read('tests/artifacts/daoyuan_connections_v257.json')
b=read('tests/artifacts/daoyuan_finish_v257.json')
assert not a['failures'] and not b['failures']
assert len(a['physical_legs'])==14 and len(b['physical_legs'])==6
assert all(x['valid'] for x in a['physical_legs']+b['physical_legs'])
sources=read('references/visual_build_20261008/daoyuan_terrace_v55.json')['sources'][2:]
sources+=read('references/visual_build_20261008/rear_roof_v83.json')['sources'][:1]
sources+=[read('references/visual_build_20261008/rear_roof_v83.json')['sources'][-1]]
sources.append({'file':'references/visual_build_20261008/originals/zhixin-roads-v81/l-2-1.jpg','capture_date':'unknown','source':'official aerial92544949'})
for s in sources:s['sha256']=sha(s['file'])
images=a['captures']+b['captures']
before=['courtyard-refined-daoyuan-v257-final-rear-link-before-guard-join.png','courtyard-refined-daoyuan-v257-final-stair-mouth-before-guard-join.png']
files=['world/visual_campus/DaoYuanGrade.gd','world/visual_campus/ShawEastPodium.gd','world/visual_campus/ZhixinSideStreets.gd','world/visual_campus/CampusSurface.gdshader','systems/data/campus_visual_build.json','project.godot']
e=dict(version=a['version'],development='2.1.11-dev',stable='v2.1.10',sources=sources,
    observed=['open metal terrace and stair rails instead of glass','red brick paving and stone edging','drainage strip at forecourt edge'],
    implementation=['closed risers preserve original ramp','horizontal rails preserve full guard volume','join both original missing rail corners','brick joints/grain and coping joints','local drain stops before flights','close rear-aisle sidewalk grass seam'],
    capture_date='unknown; cannot certify 2026 condition',fitted=['metric grades and spacing','rail/brick/drain dimensions','concealed lower rear wing retained provisionally'],
    validation={'physical_records':20,'initial_legs':14,'affected_guard_recheck_legs':6,'fixtures':3,'images_viewed':8,'final_images':b['captures'],'reports':['tests/artifacts/daoyuan_connections_v257.json','tests/artifacts/daoyuan_finish_v257.json'],'engine_runs':3,'full_campus':False,'camera_sampling':False},
    retained_issues=['initial grass seam','initial drain segment across stair footprint removed','pre-join image exposes rail endpoint gaps; corrected'],
    source_sha256={p:sha(p) for p in files},image_sha256={p:sha('tests/artifacts/'+p) for p in images+before},
    next='V258 clock-end crossroad to Research side ground: review V170-V173/V206, refine source-visible interfaces; hidden DaoYuan lower plan and full A-G remain')
write('references/visual_build_20261008/daoyuan_connections_v257.json',e)
ledger=read('docs/lower_campus_refinement_coverage.json')
assert ledger['basis_version']!=a['version'],'Already recorded'
ledger.update(updated='2026-10-15',basis_version=a['version'],previous_turn_classification='V257_actual_model_and_targeted_validation',next_action=e['next'])
ledger['active_stage_goal'].update(development='2.1.11-dev/V257',transition_kind='post_v2.1.10_model_refinement')
review={'version':'V257','document':'docs/DAOYUAN_CONNECTIONS_V257.md','evidence':'references/visual_build_20261008/daoyuan_connections_v257.json','status':'local_batch_pass_full_A_G_incomplete','physical_records':20,'images_reviewed':8,'full_campus_complete':False,'published':False}
ledger['in_progress_review']=review
ledger['daoyuan_connections_v257']=review.copy()
for z in ledger['zones']:
    if z.get('id')=='F':z['v257_update']=review.copy()
ledger['release_pipeline'].update(current_stage='V257_post_release_refinement',development_version='2.1.11-dev')
ledger['release_convergence']['development'].update(product_version='2.1.11-dev',model_version=a['version'],published=False,next_version='continue 2.1.11-dev')
write('docs/lower_campus_refinement_coverage.json',ledger)
header='''## V257 接续：道远侧阶与旧馆后路（2026-10-15）

开发2.1.11-dev/V257；固定正式v2.1.10与双入口不变。按官方全景把道远玻璃栏板改为开放横向金属栏杆，封闭侧阶立面、细化红砖/石边排水，补旧馆后路步道草缝；近景再发现并接齐两处原有栏杆端头缺口。14初批通行记录+6受影响转角/楼梯复核通过，3次引擎成功，8图已看；没有全园重测或全程镜头采样。见 [V257](DAOYUAN_CONNECTIONS_V257.md)。

下一批V258沿钟楼端横路至科研楼侧场地，读V170–V173/V206资料核对可确认地面、坡脚与楼体接口；不重复已验部分。道远隐藏后翼底层/米制关系、C–D/灰梯/032/301及完整A–G仍保留。来源拍摄日未知，细节尺度拟合；东门原点/未知真北不变。Goal继续active，本批未提交发布，无运行检查进程。

'''
for name in ['NEXT_STAGE_GOAL_V243.md','LOWER_CAMPUS_ACTIVE_GOAL.md','NEXT_ITERATION_HANDOFF.md','CURRENT_STAGE_GATE.md']:
 p=ROOT/'docs'/name;text=p.read_text(encoding='utf-8');first,rest=text.split('\n',1)
 p.write_text(first+'\n\n'+header+rest.lstrip('\n'),encoding='utf-8',newline='\n')
print('V257 evidence and continuation recorded.')
