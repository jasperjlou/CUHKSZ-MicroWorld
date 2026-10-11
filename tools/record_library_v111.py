"""Record the completed V111 structural batch without changing game geometry."""
import hashlib
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1]
def read(path):
    return json.loads((root / path).read_text(encoding='utf-8-sig'))
def write(path, value):
    (root / path).write_text(json.dumps(value, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')

initial_path='tests/artifacts/library_curved_v111.json'
final_path='tests/artifacts/library_curved_v111_finish.json'
initial, final=read(initial_path),read(final_path)
kept=[i for i,r in enumerate(initial['physical_legs']) if not r['goal'].startswith('6F bent bridge')]
assert len(kept)==34 and all(initial['physical_legs'][i]['valid'] for i in kept)
assert len(final['physical_legs'])==14 and not final['failures']
logs=['library-curved-v111.log','library-curved-v111-finish.log','library-curved-v111-views.log','library-curved-v111-details.log']
for name in logs:
    assert not any(x.startswith(('ERROR:','SCRIPT ERROR:')) for x in (root/'tests/artifacts'/name).read_text(encoding='utf-8').splitlines()),name
files=['world/visual_campus/LibraryCurvedCirculation.gd','world/visual_campus/LibraryRegisteredUpper.gd','world/visual_campus/LibraryUpperRegisteredPlan.gd','systems/data/campus_visual_build.json']
accepted={
    'version':final['version'],'status':'local_batch_passed_whole_goal_active',
    'accepted_legs':[{'file':initial_path,'indices':kept},{'file':final_path,'indices':list(range(14))}],
    'valid_records':48,'fixtures':2,'not_single_continuous_tour':True,
    'accepted_checks':[{'file':initial_path,'indices':[0,1]},{'file':final_path,'indices':[0,1,2]}],
    'retired':'Initial15bridgelegs superseded by final14; initialfailedoutsidebendprobe fixed,not accepted',
    'logs':['tests/artifacts/'+n for n in logs],'engine_errors':0,
    'images_reviewed':['courtyard-refined-library-curved-v111-'+n+'.png' for n in ['stair','atrium','books','sixth','bridge','skylight']],
    'image_limits':'Atrium upward view partly occluded;skylight view too close and edge-on for full baffle fidelity. Stair/books/bridge/plan support local structure only.',
    'source_sha256':{f:hashlib.sha256((root/f).read_bytes()).hexdigest() for f in files},
    'model_changed_after_final_validation':False,
    'limits':'Fitted curve,width,tread count,levels,book display and simplified shading.5/6F independent registration,remote core,roof/windows andwholecampus remain.'}
write('tests/artifacts/library_curved_v111_accepted.json',accepted)

path='docs/lower_campus_refinement_coverage.json'
coverage=read(path)
coverage.update(updated='2026-10-11',basis_version=final['version'],status='active',previous_turn_classification='progress')
coverage['next_action']='V111 right curved public stairs4F-6F,bent6Fbridge and tall book grids built; outside-bend residual slab removed. Next independently register5/6F corners and remoteleftWC/stair; reconcile upper/lower columns,overhangs,roofsection andwindowtypes using dated references. Shading panels are simplified and need visual refinement. Then resume B/C/D and allA-G, including rear road toShaw, entrance-stair lower interior and corners. EastGate origin retained; geographicnorth unresolved.'
coverage['v111_evidence']={'report':'docs/LIBRARY_CURVED_CIRCULATION_V111.md','accepted':'tests/artifacts/library_curved_v111_accepted.json','valid_records':48,'checks':5,'images_viewed':6,'effective_structural_views':4,'engine_errors':0,'model_changed_after_final_validation':False,'limits':accepted['limits']}
write(path,coverage)

summary='V111：公开平面与建筑师历史实景交叉补右侧曲线公共梯4F–6F、休息平台/上下短桥/木扶手、六层转折连桥、高书墙及简化遮阳板。首批49移动通过但1探针发现旧楼板残片，已切除并只复查受影响桥面14段/3探针；保留34段未受影响记录，共48分批有效移动和5探针，不能称单次全馆巡游。6图已看，4图支持结构，仰视中庭遮挡与遮阳近图不作完整细节验收；有效日志无引擎错误，检查后未改模型。尺寸/曲线/板件孔纹/年份仍有限制，下一批独立5/6F配准、远端WC梯、柱网悬挑/屋顶窗型；全A–G、梯下馆内下层、后车道至逸夫及边角全部留项，Goal active。详见 docs/LIBRARY_CURVED_CIRCULATION_V111.md。'
p=root/'docs/LOWER_CAMPUS_ACTIVE_GOAL.md'
content=p.read_text(encoding='utf-8-sig')
if '\nV111：' not in content:p.write_text(content+'\n\n'+summary+'\n',encoding='utf-8')
p=root/'references/legacy-gta-20261011/README.md'
content=p.read_text(encoding='utf-8-sig').replace('游戏已独立推进到 V110','游戏已独立推进到 V111')
if '## V111：' not in content:content+='\n\n## V111：结构参考继续落实\n\n旧4F开口拓扑与公开楼层图、建筑师历史实景交叉用于曲线梯4F–6F和六层转折桥，并补高书墙。旧资产不用于证明当前装修或米制尺寸；原包未修改。48条分批有效移动、5结构探针与画面限制见 `docs/LIBRARY_CURVED_CIRCULATION_V111.md`。\n'
p.write_text(content,encoding='utf-8')
print(json.dumps({'valid_records':48,'checks':5,'images_reviewed':6,'engine_errors':0,'goal':'active'},ensure_ascii=False))
