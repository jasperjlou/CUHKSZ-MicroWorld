"""Build a lightweight study copy by per-instance spatial vertex clustering.

Original export/source remain untouched. This is a preview, not topology-preserving
production decimation: thin features below the chosen cell can disappear.
"""
import json
import struct
import sys
from pathlib import Path
from inspect_legacy_tuanjie import write_glb, np, OUT

prefix = sys.argv[1] if len(sys.argv) > 1 else 'teaching-a-hall'
path = OUT / (prefix+'-reference.glb')
report = json.loads((OUT/(prefix+'-extraction.json')).read_text(encoding='utf-8'))
with path.open('rb') as f:
    f.seek(12)
    length, _ = struct.unpack('<I4s', f.read(8))
    gltf = json.loads(f.read(length))
    binary_start = 20 + length + 8
views = gltf['bufferViews']
v = np.memmap(path, dtype='<f4', mode='r', offset=binary_start+views[0]['byteOffset'], shape=(report['vertices'],3))
n = np.memmap(path, dtype='<f4', mode='r', offset=binary_start+views[1]['byteOffset'], shape=(report['vertices'],3))
t = np.memmap(path, dtype='<u4', mode='r', offset=binary_start+views[2]['byteOffset'], shape=(report['triangles'],3))
vv,nn,tt=[],[],[]
vo=to=out_count=0
details=[]
for i, item in enumerate(report['instances']):
    count=item['vertices'];tc=item['triangles']
    local_v=np.asarray(v[vo:vo+count]);local_n=np.asarray(n[vo:vo+count]);local_t=np.asarray(t[to:to+tc])-vo
    cell=.025 if tc>50000 else .008
    grid=np.floor(local_v/cell).astype(np.int64)+16384
    if grid.min()<0 or grid.max()>=32768:
        raise ValueError('Preview key range exceeded')
    keys=(grid[:,0]*32768+grid[:,1])*32768+grid[:,2]
    _,inverse=np.unique(keys,return_inverse=True)
    weights=np.bincount(inverse)
    nv=np.column_stack([np.bincount(inverse,weights=local_v[:,a])/weights for a in range(3)]).astype(np.float32)
    normals=np.column_stack([np.bincount(inverse,weights=local_n[:,a]) for a in range(3)]).astype(np.float32)
    normals/=np.maximum(np.linalg.norm(normals,axis=1,keepdims=True),1e-12)
    nt=inverse[local_t]
    nt=nt[(nt[:,0]!=nt[:,1])&(nt[:,1]!=nt[:,2])&(nt[:,2]!=nt[:,0])]
    # Shared duplicate triangles disappear after fine tessellation vertices collapse.
    nt=np.unique(nt,axis=0).astype(np.uint32)
    vv.append(nv);nn.append(normals);tt.append(nt+out_count);out_count+=len(nv)
    details.append({'name':item['name'],'input_triangles':tc,'output_triangles':len(nt),'cell_source_units':cell})
    vo+=count;to+=tc
    if i%100==0:print('CLUSTERED',i,'/',len(report['instances']),flush=True)
vertices=np.concatenate(vv);normals=np.concatenate(nn);triangles=np.concatenate(tt)
metadata={'source_export':path.name,'method':'per-instance vertex cluster; cells .025 for >50k triangles else .008 source units','original_triangles':report['triangles'],'preview_triangles':len(triangles),'preview_vertices':len(vertices),'source_units_not_verified_metres':True,'warning':'thin details may disappear; study only','instances':details}
write_glb(OUT/(prefix+'-preview.glb'),vertices,normals,triangles,{'preview':'vertex clustered, dimensions not calibrated'})
(OUT/(prefix+'-preview.json')).write_text(json.dumps(metadata,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('PREVIEW',len(vertices),'vertices',len(triangles),'triangles',flush=True)
