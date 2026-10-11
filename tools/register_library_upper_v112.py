"""Independent hand-picked map correspondences; store residuals, not survey claims."""
import json, math
from pathlib import Path

root=Path(__file__).resolve().parents[1]
def fit(rows):
    n=len(rows); sx=sum(r[1][0] for r in rows)/n; sz=sum(r[1][1] for r in rows)/n
    tx=sum(r[2][0] for r in rows)/n; tz=sum(r[2][1] for r in rows)/n
    den=sum((r[1][0]-sx)**2+(r[1][1]-sz)**2 for r in rows)
    a=sum((r[1][0]-sx)*(r[2][0]-tx)+(r[1][1]-sz)*(r[2][1]-tz) for r in rows)/den
    b=sum((r[1][0]-sx)*(r[2][1]-tz)-(r[1][1]-sz)*(r[2][0]-tx) for r in rows)/den
    off=[tx-a*sx+b*sz,tz-b*sx-a*sz]
    anchors=[]
    for name,p,q in rows:
        out=[a*p[0]-b*p[1]+off[0],b*p[0]+a*p[1]+off[1]]
        anchors.append(dict(id=name,source=p,target=q,predicted=out,residual=math.dist(out,q)))
    return dict(matrix=[[a,-b],[b,a]],translation=off,scale=math.hypot(a,b),rotation_degrees=math.degrees(math.atan2(b,a)),reflection=False,rms=math.sqrt(sum(r['residual']**2 for r in anchors)/n),anchors=anchors)

five=[['right-tip',[1194,110],[1140,110]],['right-outer',[1515,425],[1406,370]],['front-tip',[887,1460],[889,1220]],['left-front',[4,1140],[156,960]],['left-reentrant',[103,210],[240,192]],['remote-stair-centre',[56,412],[204,361]],['left-stair-centre',[289,865],[393,739]],['diagonal-stair-centre',[783,1005],[801,849]]]
six=[['right-tip',[1015,127],[1140,110]],['right-outer',[1283,390],[1406,370]],['front-tip',[750,1268],[889,1220]],['left-front',[196,997],[156,960]],['left-L-top-inner',[318,741],[480,720]],['left-L-top-right',[415,741],[591,720]],['diagonal-stair-centre',[655,880],[801,849]]]
result=dict(date='2026-10-11',source='https://library.cuhk.edu.cn/zh-hans/floor-maps',frames={'fourth':[1920,1295],'fifth':[1728,1470],'sixth':[1820,1376]},fifth_to_fourth=fit(five),sixth_to_fourth=fit(six),limits='Manual schematic landmarks,not survey.6F left-front edge changes between levels: treat as diagnostic,not rigid anchor until matched. No heights,north or construction-date calibration.')
# The sixth-floor lower-left corner is a reduced floor edge, not the 4F facade corner.
result['sixth_stable_only']=fit([r for r in six if r[0]!='left-front'])
(root/'references/visual_build_20261008/library_upper_registration_v112.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
for k in ['fifth_to_fourth','sixth_to_fourth','sixth_stable_only']:
    r=result[k];print(k, 'rms',round(r['rms'],2),'scale',round(r['scale'],5),'yaw',round(r['rotation_degrees'],3),'translation',r['translation'])
    print([(a['id'],round(a['residual'],1)) for a in r['anchors']])
