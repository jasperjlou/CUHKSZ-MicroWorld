"""Exact XZ projection of horizontal legacy slabs, with original-unit grid.

Analytical plots only; not original materials, surveyed metres or geographic north.
"""
import json,struct
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw
ROOT=Path(__file__).resolve().parents[1]
path=ROOT/'references/legacy-gta-20261011/lower-campus-reference.glb'
with path.open('rb') as f:
    f.seek(12);size,_=struct.unpack('<II',f.read(8));doc=json.loads(f.read(size));f.read(8);offset=f.tell()
def get(i):
    a=doc['accessors'][i];v=doc['bufferViews'][a['bufferView']]
    return np.memmap(path,mode='r',dtype={5126:'<f4',5125:'<u4',5123:'<u2'}[a['componentType']],offset=offset+v.get('byteOffset',0)+a.get('byteOffset',0),shape=(a['count'],3) if a['type']=='VEC3' else (a['count'],))
p=doc['meshes'][0]['primitives'][0];vertices=get(p['attributes']['POSITION']);ix=get(p['indices']).reshape(-1,3)
selected=[]
for start in range(0,len(ix),200000):
    t=vertices[ix[start:start+200000]]
    mask=(np.ptp(t[:,:,1],axis=1)<.015)&(t[:,:,1].mean(axis=1)>0)&(t[:,:,1].mean(axis=1)<26.5)&(t[:,:,0].max(axis=1)>-390)&(t[:,:,0].min(axis=1)<-190)&(t[:,:,2].max(axis=1)>-290)&(t[:,:,2].min(axis=1)<-90)
    for tri in t[mask]:
        q=tri[:,[0,2]];u=q[1]-q[0];v=q[2]-q[0];area=abs(u[0]*v[1]-u[1]*v[0])
        if area>.01:selected.append((float(tri[:,1].mean()),q.tolist()))
selected.sort(key=lambda t:t[0])
def pixel(p):return (60+(p[0]+390)*5,60+(p[1]+290)*5)
for name,cut in [('ground18',18.75),('ground22',22.75),('ground26',26.5)]:
    im=Image.new('RGB',(1120,1120),'#edf0ef');draw=ImageDraw.Draw(im)
    for y,points in selected:
        if y>cut:continue
        color='#bbc8ca' if y<10 else ('#849b9b' if y<18 else ('#c8aa74' if y<19 else ('#b38f93' if y<23 else '#718ca8')))
        draw.polygon([pixel(p) for p in points],fill=color)
    for v in range(-390,-189,20):
        x=pixel((v,0))[0];draw.line([(x,60),(x,1060)],fill='#849393',width=1);draw.text((x-12,35),str(v),fill='black')
    for v in range(-290,-89,20):
        y=pixel((0,v))[1];draw.line([(60,y),(1060,y)],fill='#849393',width=1);draw.text((12,y),str(v),fill='black')
    draw.text((65,1080),f'Legacy horizontal slab projection, cut Y={cut}. Colors encode height. X right / Z down, NOT north.',fill='black')
    im.save(ROOT/f'references/legacy-gta-20261011/zhang-horizontal-slabs-{name}-v136.png')
out={'coordinate_space':'normalized legacy GLB; X right Z down, no geographic orientation','triangles':selected,'bounds':[-390,-290,-190,-90]}
(ROOT/'references/legacy-gta-20261011/zhang-ground-slabs-v136.json').write_text(json.dumps(out,separators=(',',':')),encoding='utf-8')
print('Projected',len(selected),'horizontal triangles into three original-unit diagrams.')
