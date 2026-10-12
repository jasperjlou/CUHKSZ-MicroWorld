"""Targeted geometric sections; legacy coordinates remain unregistered, not metres."""
import json
import struct
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'references/legacy-gta-20261011/local-only/library-sections-v186'
OUT.mkdir(parents=True, exist_ok=True)
path = ROOT / 'references/legacy-gta-20261011/lower-campus-reference.glb'
with path.open('rb') as f:
    f.seek(12)
    size, _ = struct.unpack('<II', f.read(8))
    doc = json.loads(f.read(size))
    f.read(8)
    offset = f.tell()
def accessor(i):
    a = doc['accessors'][i]
    v = doc['bufferViews'][a['bufferView']]
    return np.memmap(path, mode='r', dtype={5126:'<f4', 5125:'<u4', 5123:'<u2'}[a['componentType']],
                     offset=offset+v.get('byteOffset',0)+a.get('byteOffset',0),
                     shape=(a['count'],3) if a['type']=='VEC3' else (a['count'],))
p = doc['meshes'][0]['primitives'][0]
vertices = accessor(p['attributes']['POSITION'])
indices = accessor(p['indices']).reshape(-1,3)
planes = [(0,-440),(0,-400),(2,160)]
result = {str(v):[] for _,v in planes}
for start in range(0,len(indices),200000):
    t = vertices[indices[start:start+200000]]
    mask = (t[:,:,0].max(1)>-520)&(t[:,:,0].min(1)<-300)&(t[:,:,2].max(1)>-30)&(t[:,:,2].min(1)<220)&(t[:,:,1].min(1)<90)
    t = t[mask]
    for axis,cut in planes:
        tris = t[(t[:,:,axis].min(1)<cut)&(t[:,:,axis].max(1)>cut)]
        for tri in tris:
            intersections=[]
            for i,j in [(0,1),(1,2),(2,0)]:
                a,b=tri[i],tri[j]
                if (a[axis]-cut)*(b[axis]-cut)<0:
                    q=a+(b-a)*((cut-a[axis])/(b[axis]-a[axis]))
                    intersections.append([float(q[2-axis]),float(q[1])])
            if len(intersections)==2:
                result[str(cut)].append(intersections)
for axis,cut in planes:
    x0,x1=(-30,220) if axis==0 else (-520,-300)
    im=Image.new('RGB',(1500,640),'#f3f4ee');d=ImageDraw.Draw(im)
    def pt(q):return (70+(q[0]-x0)/(x1-x0)*1380,585-(q[1]-10)/80*530)
    for h in range(10,91,10):
        y=pt([x0,h])[1];d.line([(70,y),(1450,y)],fill='#d3d6cf');d.text((20,y-5),str(h),fill='#273530')
    for x in range(x0,x1+1,10):
        u=pt([x,10])[0];d.line([(u,55),(u,585)],fill='#e1e3de');d.text((u-8,598),str(x),fill='#273530')
    for a,b in result[str(cut)]:d.line([pt(a),pt(b)],fill='#344c53',width=1)
    d.text((70,20),f'Legacy plane {"X" if axis==0 else "Z"}={cut}. Horizontal={"Z" if axis==0 else "X"}; vertical=Y. No unit/floor registration.',fill='#273530')
    im.save(OUT/f'section-{cut}.png')
(OUT/'segments.json').write_text(json.dumps(result),encoding='utf-8')
print('New section lines:',{k:len(v) for k,v in result.items()})
