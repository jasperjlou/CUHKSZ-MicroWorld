"""Read two named legacy column meshes; retain static-batch coordinates and V105 fit."""
import json
from inspect_legacy_tuanjie import SOURCE, OUT, UnityPy, np, read_mesh, MeshHandler, EndianBinaryReader, read_typetree, transform_matrix

d=json.loads((OUT/'level24-geometry-index.json').read_text(encoding='utf-8'))
reference=json.loads((OUT/'library-1f-extraction.json').read_text(encoding='utf-8'))
fit=json.loads((OUT.parent/'visual_build_20261008/library_registration_v105.json').read_text(encoding='utf-8'))
filters={f['m_GameObject']['m_PathID']:f['m_Mesh'] for f in d['mesh_filters']}
targets={1934:'5342',2225:'7087'}
envs={0:UnityPy.load(str(SOURCE/'level24'))}
objects={0:{o.path_id:o for o in envs[0].objects}}
def world(tid):
    t=d['transforms'][str(tid)];pid=t['m_Father']['m_PathID']
    return (world(pid) if pid else np.eye(4))@transform_matrix(t)
rows=[]
for obj in list(objects[0].values()):
    if obj.type.name!='MeshRenderer':continue
    raw=obj.get_raw_data();r=EndianBinaryReader(raw[:24]+raw[28:],endian='<')
    renderer=read_typetree(obj._get_typetree_node(),r,as_dict=True,check_read=False,assetsfile=obj.assets_file)
    go=renderer['m_GameObject']['m_PathID']
    if go not in targets:continue
    assert r.Position==len(raw)-4
    ref=filters[go];fid=ref['m_FileID']
    if fid not in objects:
        envs[fid]=UnityPy.load(str(SOURCE/d['externals'][fid-1]));objects[fid]={o.path_id:o for o in envs[fid].objects}
    mesh=read_mesh(objects[fid][ref['m_PathID']]);h=MeshHandler(mesh);h.process()
    vertices=np.asarray(h.m_Vertices,dtype=float);triangles=h.get_triangles();batch=renderer['m_StaticBatchInfo'];count=batch['subMeshCount']
    if count:
        assert renderer['m_StaticBatchRoot']['m_PathID']==0
        indices=np.concatenate([np.asarray(triangles[i]).reshape(-1) for i in range(batch['firstSubMesh'],batch['firstSubMesh']+count)])
    else:
        indices=np.concatenate([np.asarray(t).reshape(-1) for t in triangles]);m=world(int(targets[go]));vertices=vertices@m[:3,:3].T+m[:3,3]
    v=vertices[np.unique(indices)];v[:,2]*=-1;v-=np.array(reference['removed_origin_after_z_flip'])
    lo=v.min(axis=0);hi=v.max(axis=0);centre=(lo+hi)/2
    pixel=np.array([720+centre[0]*900/105,450+centre[2]*900/105])
    local=np.array(fit['matrix'])@pixel+np.array(fit['translation'])
    rows.append({'name':d['gameobjects'][str(go)],'transform':targets[go],'static_batch':bool(count),'legacy_center':centre.tolist(),'legacy_size':(hi-lo).tolist(),'legacy_render_pixel':pixel.tolist(),'fitted_library_xz':local.tolist(),'height_rule':'not registered; do not use raw Y as game floor height'})
result={'source_date':'unknown','reviewed':'2026-10-14','registration':'Existing V105 raster fit, camera1440x900/105high; absolute metres and north unverified','columns':rows}
(OUT/'library-columns-v203.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(result,ensure_ascii=False))
