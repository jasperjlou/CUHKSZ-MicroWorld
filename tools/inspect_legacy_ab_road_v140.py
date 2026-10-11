"""Read-only vertical triangle probes in the normalized legacy GLB; no metre claim."""
import json, struct
from pathlib import Path
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
path = ROOT / 'references/legacy-gta-20261011/lower-campus-reference.glb'
with path.open('rb') as stream:
    stream.seek(12)
    length, _ = struct.unpack('<II', stream.read(8))
    document = json.loads(stream.read(length))
    stream.read(8)
    binary_offset = stream.tell()

def accessor(index):
    item = document['accessors'][index]
    view = document['bufferViews'][item['bufferView']]
    return np.memmap(path, mode='r', dtype={5126:'<f4',5125:'<u4',5123:'<u2'}[item['componentType']],
                     offset=binary_offset+view.get('byteOffset',0)+item.get('byteOffset',0),
                     shape=(item['count'],3) if item['type']=='VEC3' else (item['count'],))

primitive = document['meshes'][0]['primitives'][0]
vertices = accessor(primitive['attributes']['POSITION'])
indices = accessor(primitive['indices']).reshape(-1,3)
points = [(x,z) for z in [-320,-300,-280] for x in [-850,-810,-760,-710,-680,-650]] + [(x,-90) for x in [-850,-810,-760,-710]]
hits = {str(p):[] for p in points}
for start in range(0,len(indices),200000):
    triangles = vertices[indices[start:start+200000]]
    low = triangles[:,:,::2].min(axis=1)
    high = triangles[:,:,::2].max(axis=1)
    for x,z in points:
        q = triangles[(low[:,0]<=x)&(high[:,0]>=x)&(low[:,1]<=z)&(high[:,1]>=z)].astype(float)
        if not len(q): continue
        a = q[:,0]; b = q[:,1]-a; c = q[:,2]-a
        denominator = b[:,0]*c[:,2]-b[:,2]*c[:,0]
        valid = abs(denominator)>1e-6
        a,b,c,denominator = a[valid],b[valid],c[valid],denominator[valid]
        u = ((x-a[:,0])*c[:,2]-(z-a[:,2])*c[:,0])/denominator
        v = (b[:,0]*(z-a[:,2])-b[:,2]*(x-a[:,0]))/denominator
        inside = (u>=-1e-5)&(v>=-1e-5)&(u+v<=1.00001)
        heights = a[:,1]+u*b[:,1]+v*c[:,1]
        hits[str((x,z))] += heights[inside].round(3).tolist()
hits = {point:sorted(set(heights)) for point,heights in hits.items()}
output = {'coordinate_space':'normalized legacy GLB; not metres',
          'method':'vertical line intersections against all indexed triangles; no shadow or pixel inference',
          'points':hits,'limits':'Probe identities based on teaching-row topology; game XY registration and geographic north unresolved.'}
(ROOT/'references/legacy-gta-20261011/teaching-ab-road-height-probes-v140.json').write_text(json.dumps(output,indent=2)+'\n',encoding='utf-8')
for point, heights in hits.items(): print(point, heights)
