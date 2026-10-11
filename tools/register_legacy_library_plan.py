"""Recompute manual2D registration; never changes game geometry or source assets.

Input anchors were read from the1440x900 orthographic cutaway and official1F map.
Output errors use fitted game units, not surveyed metres. Y/height is not fitted.
"""
import json, math
from pathlib import Path
root=Path(__file__).resolve().parents[1]
path=root/'references/visual_build_20261008/library_registration_v105.json'
d=json.loads(path.read_text(encoding='utf-8'));anchors=d['anchors'];count=len(anchors)
x=[r['legacy_render_pixel'] for r in anchors];y=[r['local_xz'] for r in anchors]
mx=[sum(p[k] for p in x)/count for k in range(2)];my=[sum(p[k] for p in y)/count for k in range(2)]
u=[[p[k]-mx[k] for k in range(2)] for p in x];v=[[p[k]-my[k] for k in range(2)] for p in y]
den=sum(a*a+b*b for a,b in u)
a=sum(q[0]*r[0]+q[1]*r[1] for q,r in zip(u,v))/den
b=sum(q[0]*r[1]-q[1]*r[0] for q,r in zip(u,v))/den
t=[my[0]-a*mx[0]+b*mx[1],my[1]-b*mx[0]-a*mx[1]]
def convert(p):return [a*p[0]-b*p[1]+t[0],b*p[0]+a*p[1]+t[1]]
for r in anchors:r['residual']=math.dist(convert(r['legacy_render_pixel']),r['local_xz'])
d.update(matrix=[[a,-b],[b,a]],translation=t,registered_outline=[convert(p) for p in d['reference_outline_pixels']])
d['fit_audit']={'rotation_degrees':math.degrees(math.atan2(b,a)),'positive_determinant':a*a+b*b,'reflection':False,'rms_fitted_units':math.sqrt(sum(r['residual']**2 for r in anchors)/count),'max_fitted_units':max(r['residual'] for r in anchors),'raw_xz_scale_approx':math.hypot(a,b)/(105/900),'y_scale':'not registered;do not apply this ratio to storey heights','scope':'2D raster correspondence,not physical measurement or geographic orientation'}
d['holdouts']=[]
for name,p,target in [('117-118',[418,466],[24.35,-3.05]),('119',[460,643],[20.8,-13.3]),('116',[480,290],[19.5125,8.8875])]:
 q=convert(p);d['holdouts'].append({'id':name,'legacy_pixel':p,'mapped_xz':q,'current_reference_xz':target,'residual':math.dist(q,target),'note':'Approximate visual centre;not construction tolerance'})
path.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps(d['fit_audit'],ensure_ascii=False));print(json.dumps(d['holdouts'],ensure_ascii=False))
