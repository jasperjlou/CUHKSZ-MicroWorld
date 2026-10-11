"""Consolidate the accepted V112 batch and preserve rejected-route evidence."""
import json, hashlib
from pathlib import Path
root=Path(__file__).resolve().parents[1]
def read(p):return json.loads((root/p).read_text(encoding='utf-8-sig'))
def write(p,v):(root/p).write_text(json.dumps(v,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
paths=['tests/artifacts/library_remote_v112.json','tests/artifacts/library_remote_v112_finish.json','tests/artifacts/library_remote_v112_facade.json']
reports=[read(p) for p in paths]
assert len(reports[0]['physical_legs'])==68 and all(x['valid'] for x in reports[0]['physical_legs'][:67])
assert all(not r['failures'] for r in reports[1:])
logs=['library-remote-v112-final.log','library-remote-v112-finish.log','library-remote-v112-facade.log']
for log in logs:assert not any(l.startswith(('ERROR:','SCRIPT ERROR:')) for l in (root/'tests/artifacts'/log).read_text(encoding='utf-8').splitlines()),log
src=['world/visual_campus/LibraryRemoteCore.gd','world/visual_campus/LibraryServiceCores.gd','world/visual_campus/LibraryUpperRegisteredPlan.gd','systems/data/campus_visual_build.json']
accepted={'version':reports[-1]['version'],'accepted_legs':[{'file':paths[0],'indices':list(range(67))},{'file':paths[1],'indices':list(range(8))},{'file':paths[2],'indices':[0,1]}],'valid_records':77,'fixtures':3,'not_single_tour':True,'accepted_checks':{'file':paths[0],'indices':[0,1,2,3]},'retired':'Initial railing obstruction and final main-batch index67 diagonal shortcut not accepted; walk through real inner doorway instead. Initial lower facade screenshot superseded after trimming female room at rear wall.','images_viewed':5,'effective_final_images':['courtyard-refined-library-remote-v112-'+n+'.png' for n in ['stair','upper-entry','paired-wc','lower-final']],'logs':['tests/artifacts/'+n for n in logs],'engine_errors':0,'source_sha256':{p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in src},'validation_scope':'67 unchanged main-route legs +8 actual-door porch legs +2 affected facade legs. Female rear boundary/door centre changed after main checks; no stair, upper WC or public aisle geometry changed, so unrelated successful legs retained.','model_changed_after_last_verification':False,'limits':'Map-based fitted dimensions. Lower WC room boundaries/frontages not independently registered; no restroom interior survey. Independent5F fit not yet applied to rare room,6F edge correspondence still partial; wholecampus active.'}
write('tests/artifacts/library_remote_v112_accepted.json',accepted)
p='docs/lower_campus_refinement_coverage.json';c=read(p)
c.update(updated='2026-10-11',status='active',previous_turn_classification='progress',basis_version=accepted['version'])
c['next_action']='V112 remote stairG-5F,rotated shaft openings andpaired3F-5FWC frontages registered;77 accepted local records/4shaft checks. Use independently fitted5F transform to rebuild rare-book reading room polygon and public-stair doorway, then trace6F reduced left-front edge in its own map instead of copying4F facade. Resolve6F landmark residuals, upper/lower support/overhangs androof/windowtypes, then resume B/C/D andallA-G including lowerinterior,rear road toShaw,corners andrealpaving. Lower1/2FWC boundary/door directions remain fitted. EastGate origin retained;geographicnorth unresolved.'
c['v112_evidence']={'report':'docs/LIBRARY_REMOTE_REGISTRATION_V112.md','registration':'references/visual_build_20261008/library_upper_registration_v112.json','accepted':'tests/artifacts/library_remote_v112_accepted.json','valid_records':77,'checks':4,'images_viewed':5,'effective_final_images':4,'engine_errors':0,'model_changed_after_last_verification':False,'limits':accepted['limits']}
c['known_unfinished_features'].append('V112:5F rare-book room polygon/door conflicts with current shifted rectangle;6F reduced left-front corner is not4F facade anchor. Independent5F fit RMS2.92px;6F stable candidates RMS10.08px not exact. LowerWC boundaries/doors,upper-lower support,roof/windows remain partial.')
write(p,c)
summary='V112：远端梯按公开4F并用独立5F配准收为拟合4.5×5.9，中心(-37.440,-15.853)，重切各层旋转洞口，贯通G–5F；3–5F卫生间改并排不等深房间/后侧门，一二层前沿避梯井并收掉女厕与后墙重叠。斜扶手伸入平台已修；后门斜穿坡道边缘路线作废，改走实际内门。67保留主线+8后门+2门面=77分批有效记录，4梯井探针，5图已看/4最终图有效，无引擎错误。五层8点RMS2.92归一像素；六层错用缩减楼板角为外墙角已排除，其余仍有10.08像素RMS。下一批按5F变换修珍藏室多边形/梯口，按6F自身图修左前缘，再柱网悬挑屋顶窗型及B/C/D全A–G。下层WC边界仍拟合；入口梯下馆内下层、后车道至逸夫、真实铺地及边角全部留项，Goal active。详见 docs/LIBRARY_REMOTE_REGISTRATION_V112.md。'
p=root/'docs/LOWER_CAMPUS_ACTIVE_GOAL.md';s=p.read_text(encoding='utf-8-sig')
if '\nV112：' not in s:p.write_text(s+'\n\n'+summary+'\n',encoding='utf-8')
print(json.dumps({'records':77,'checks':4,'views':5,'final_views':4,'goal':'active'},ensure_ascii=False))
