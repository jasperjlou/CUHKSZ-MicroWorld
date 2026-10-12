"""Read-only height/plan evidence from the recovered lower-campus mesh.

The diagrams are analytical projections, not material renderings or geographic maps.
"""
import json, struct
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'references/legacy-gta-20261011'
path=OUT/'lower-campus-reference.glb'
with path.open('rb') as f:
    f.seek(12);size,_=struct.unpack('<II',f.read(8));doc=json.loads(f.read(size));f.read(8);offset=f.tell()
def accessor(i):
    a=doc['accessors'][i];v=doc['bufferViews'][a['bufferView']]
    return np.memmap(path,mode='r',dtype={5126:'<f4',5125:'<u4',5123:'<u2'}[a['componentType']],offset=offset+v.get('byteOffset',0)+a.get('byteOffset',0),shape=(a['count'],3) if a['type']=='VEC3' else (a['count'],))
p=doc['meshes'][0]['primitives'][0];vertices=accessor(p['attributes']['POSITION']);indices=accessor(p['indices']).reshape(-1,3)
parts=[]
for start in range(0,len(indices),200000):
    t=vertices[indices[start:start+200000]]
    mask=(t[:,:,0].max(1)>-620)&(t[:,:,0].min(1)<-60)&(t[:,:,2].max(1)>-50)&(t[:,:,2].min(1)<250)
    parts.append(t[mask])
t=np.concatenate(parts);del parts
horizontal=(np.ptp(t[:,:,1],axis=1)<.015)
q=t[horizontal];y=q[:,:,1].mean(1);order=np.argsort(y);q=q[order];y=y[order]
def pixel(p): return (60+(p[0]+620)*2,60+(p[1]+50)*2)
for name,cut in [('low',25),('middle',35),('upper',50),('roof',200)]:
    im=Image.new('RGB',(1240,720),'#eff1ed');d=ImageDraw.Draw(im)
    for tri,h in zip(q,y):
        if h>cut:break
        color='#c0c7c5' if h<20 else ('#a5b7a5' if h<28 else ('#789c96' if h<36 else ('#bcad87' if h<48 else '#d2b5a7')))
        d.polygon([pixel(v[[0,2]]) for v in tri],fill=color)
    for x in range(-620,-59,20):
        u=pixel((x,0))[0];d.line([(u,60),(u,660)],fill='#929c97');d.text((u-12,40),str(x),fill='#273831')
    for z in range(-50,251,20):
        v=pixel((0,z))[1];d.line([(60,v),(1180,v)],fill='#929c97');d.text((20,v-4),str(z),fill='#273831')
    d.text((60,12),f'Legacy XZ / horizontal triangles <= {cut} original units. Not metres or true north.',fill='#273831')
    im.save(OUT/f'central-datum-v152-{name}.png')
low=t[:,:,::2].min(1);high=t[:,:,::2].max(1)
points=[(x,z) for x in [-520,-480,-440,-400,-360,-320,-280,-240,-200,-160,-120] for z in [0,40,80,120,160,200,220]]
hits={}
for x,z in points:
    a=t[(low[:,0]<=x)&(high[:,0]>=x)&(low[:,1]<=z)&(high[:,1]>=z)].astype(float)
    if not len(a):hits[f'{x},{z}']=[];continue
    b=a[:,1]-a[:,0];c=a[:,2]-a[:,0];a=a[:,0];den=b[:,0]*c[:,2]-b[:,2]*c[:,0];ok=abs(den)>1e-7
    a,b,c,den=a[ok],b[ok],c[ok],den[ok]
    u=((x-a[:,0])*c[:,2]-(z-a[:,2])*c[:,0])/den;v=(b[:,0]*(z-a[:,2])-b[:,2]*(x-a[:,0]))/den
    inside=(u>=-1e-5)&(v>=-1e-5)&(u+v<=1.00001)
    hs=np.unique(np.round((a[:,1]+u*b[:,1]+v*c[:,1])[inside],3))
    hits[f'{x},{z}']=hs.tolist()
result={'source':str(path.relative_to(ROOT)),'model_date':'unknown','space':'normalized legacy units, not surveyed metres','bounds_xz':[-620,-50,-60,250],'selected_triangles':len(t),'vertical_intersections':hits,'limits':'Region identities are topology candidates; no library/student/game height registration yet. Clipping diagrams do not cap voids.'}
(OUT/'central-datum-v152.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print('Selected',len(t),'triangles;',len(points),'vertical probes and 4 diagrams written.')
for key in ['-440,200','-440,120','-440,40','-200,200','-200,120','-200,40']:print(key,hits[key])
# Separate exact-height faces: cumulative cuts otherwise hide which slab owns an outline.
for height in [26.78,30.04,33.04,43.04]:
    im=Image.new('RGB',(1040,1010),'#f5f5ee');d=ImageDraw.Draw(im)
    def px(p):return (50+(p[0]+520)*4,50+p[1]*4)
    selected=q[(abs(y-height)<.02)&(q[:,:,0].max(1)>-520)&(q[:,:,0].min(1)<-280)]
    for tri in selected:d.polygon([px(v[[0,2]]) for v in tri],fill='#71938b',outline='#4e7068')
    for x in range(-520,-279,20):
        u=px((x,0))[0];d.line([(u,50),(u,990)],fill='#a1a8a2');d.text((u-10,30),str(x),fill='#34443d')
    for z in range(0,236,20):
        v=px((0,z))[1];d.line([(50,v),(1010,v)],fill='#a1a8a2');d.text((15,v),str(z),fill='#34443d')
    d.text((50,10),f'Library exact horizontal faces at {height} legacy units / not metres',fill='#34443d')
    im.save(OUT/f'library-slab-v152-{height}.png')
