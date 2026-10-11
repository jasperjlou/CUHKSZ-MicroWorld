"""Persist map fits and actual focused results; no model edits."""
from pathlib import Path
import json,math,hashlib
root=Path(__file__).resolve().parents[1]
def read(p):return json.loads((root/p).read_text(encoding='utf-8-sig'))
def write(p,d):(root/p).write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
def fit(points):
    target=[[393,750],[837,907],[204,361.5]]
    sx=sum(p[0] for p in points)/3;sz=sum(p[1] for p in points)/3
    tx=sum(p[0] for p in target)/3;tz=sum(p[1] for p in target)/3
    den=sum((x-sx)**2+(z-sz)**2 for x,z in points)
    a=sum((p[0]-sx)*(q[0]-tx)+(p[1]-sz)*(q[1]-tz) for p,q in zip(points,target))/den
    b=sum((p[0]-sx)*(q[1]-tz)-(p[1]-sz)*(q[0]-tx) for p,q in zip(points,target))/den
    off=[tx-a*sx+b*sz,tz-b*sx-a*sz]
    anchors=[]
    for name,p,q in zip(['left-core','diagonal-core','remote-stair'],points,target):
        predicted=[a*p[0]-b*p[1]+off[0],b*p[0]+a*p[1]+off[1]]
        anchors.append(dict(id=name,source=p,target=q,predicted=predicted,residual=math.dist(predicted,q)))
    return dict(matrix=[[a,-b],[b,a]],translation=off,anchors=anchors,rms=math.sqrt(sum(x['residual']**2 for x in anchors)/3),reflection=False)
paths=['tests/artifacts/library_lower_front_v115.json','tests/artifacts/library_lower_front_v115_second.json']
data=[read(p) for p in paths]
assert [len(d['physical_legs']) for d in data]==[25,9]
assert [len(d['checks']) for d in data]==[4,2]
assert all(not d['failures'] and all(x['valid'] for x in d['physical_legs']+d['checks']) for d in data)
logs=['tests/artifacts/library-lower-front-v115.log','tests/artifacts/library-lower-front-v115-second.log']
for p in logs:assert not any(l.startswith(('SCRIPT ERROR:','ERROR:')) for l in (root/p).read_text(encoding='utf-8').splitlines())
sources=['world/visual_campus/'+n+'.gd' for n in ['LibraryLowerFrontPlan','LibraryLowerFrontFacade','LibraryEnvelope','LibraryUpperLevels','LibraryRegisteredFloors','LibraryLowerArrival','LibrarySpaces','LibraryLowerLevel']]+['systems/data/campus_visual_build.json']
limits='Manual schematic registrations and fittedheights/fins;right2F/externalmainstair/pavilion/pool notaligned. Other3Fsides/terrace,rarecore/6F/wholeA-G remain.'
accepted={'version':data[-1]['version'],'reports':paths,'valid_records':34,'fixtures':3,'checks':6,'logs':logs,'engine_errors':0,'images_reviewed':['courtyard-refined-library-lower-front-v115-'+n+'.png' for n in ['entry','arrival','third','shell-final','second-final']],'image_scope':'First3 support G/3F unchanged by later2F correction;last2 show final2F. Initialshell retired. 6 images viewed,5 effective.','route_scope':'3 separate local fixtures,not a whole-building tour. Second report leg4 ends on public-stair approach about0.482m above2F within0.6m tolerance;not a flatfloor claim.','source_sha256':{p:hashlib.sha256((root/p).read_bytes()).hexdigest() for p in sources},'models_changed_after_final_validation':False,'limits':limits}
write('tests/artifacts/library_lower_front_v115_accepted.json',accepted)
evidence={'date':'2026-10-11','report':'docs/LIBRARY_LOWER_FRONT_V115.md','source':'https://library.cuhk.edu.cn/zh-hans/floor-maps','frames':{'1F':[1818,1344],'2F':[1862,1312],'3F':[1856,1339],'4F':[1920,1295]},'dates':{'1F':'202401filename;notcapturedate','2F/3F':'2021-11hosting;notcapturedates'},'second_to_fourth':fit([[415,763],[916,965],[206,346]]),'third_to_fourth':fit([[412,814],[914,1003],[192,387]]),'unchanged_world_origin_and_yaw':True,'limits':limits}
write('references/visual_build_20261008/library_lower_front_v115_evidence.json',evidence)
p='docs/lower_campus_refinement_coverage.json';c=read(p)
c.update(updated='2026-10-11',status='active',previous_turn_classification='progress',basis_version=data[-1]['version'])
c['next_action']='V115 independently traced3Ffront/slab/terrace andG entrance/arrival corrected;left2F floor/glass clipped. Next integrate RIGHT2F entrance line,external mainstair direction/landing,pavilion/exhibitionhall using2Fmap andofficialentrypanorama before accepting current right-hand compatibility deck. Outdoor stair should be checked independently of interior2F3Fstair. Then align water/shore to newleftfins andfinish remaining3Fsides/supports. Rarecore intrusion/6F remain;resumeB/C/D thenallA-G. RearroadtoShaw,mainstairlowerinterior,trueground/backfaces/corners andEastGateorigin/northconstraints retained.'
c['v115_evidence']={'report':'docs/LIBRARY_LOWER_FRONT_V115.md','reference':'references/visual_build_20261008/library_lower_front_v115_evidence.json','accepted':'tests/artifacts/library_lower_front_v115_accepted.json','valid_records':34,'checks':6,'fixtures':3,'effective_views':5,'engine_errors':0,'models_changed_after_final_validation':False,'limits':limits}
c['known_unfinished_features'].append('V115 right2F x>3 still usesoldfootprint for existingentry;externalstair/pavilion/ExhibitionHall axisandlanding need integratedregistration,thenreflectingpool extension againstnewfins. Other3F sides/terrace not fullyverified. No wholebuilding fidelity claim.')
write(p,c)
summary='V115：独立3F三核心配准RMS5.488归一像素，重画三楼前缘/楼板/后露台和灰米色竖片；G玻璃后退至公开1F边界，门厅/展区/安保/ITSO/终端重排并迁移入口定位。2F独立拟合RMS9.064，先修左侧楼板与玻璃，撤穿出立面的旧平台，右侧x>3兼容旧入口未验收精修。25段G/3F+9段最终2F=34局部记录、3起点，6探针、5有效视角，无引擎错误；2F末端一处位于原公共梯斜面而非平地，范围已注明。下一批右2F入口/室外主梯方向落点/入口亭展览厅整体配准，再池岸接新竖片、其余3F支撑侧面，恢复B/C/D及全A–G。左核心珍藏室/6F、后车道至逸夫、主梯下馆内下层/真实地板/角落保持，Goal active。详见 docs/LIBRARY_LOWER_FRONT_V115.md。'
p=root/'docs/LOWER_CAMPUS_ACTIVE_GOAL.md';s=p.read_text(encoding='utf-8-sig')
if '\nV115：' not in s:p.write_text(s+'\n\n'+summary+'\n',encoding='utf-8')
print(json.dumps({'version':accepted['version'],'records':34,'checks':6,'views':5,'engine_errors':0,'goal':'active','rms2':evidence['second_to_fourth']['rms'],'rms3':evidence['third_to_fourth']['rms']}))
