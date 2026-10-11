"""Read-only library1F recovery with per-renderer static-batch submesh selection.

Combined Mesh(root:scene) coordinates are already world space; never transform
them again for each renderer. Material base colours are retained, textures pending.
"""
import json
import struct
import argparse
from collections import defaultdict
from inspect_legacy_tuanjie import UnityPy, SOURCE, OUT, np, read_mesh, transform_matrix, MeshHandler, EndianBinaryReader, read_typetree

parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--scene',default='level24')
parser.add_argument('--root',type=int,default=4071)
parser.add_argument('--prefix',default='library-1f')
args=parser.parse_args()
scene=json.loads((OUT/(args.scene+'-geometry-index.json')).read_text(encoding='utf-8'))
ts=scene['transforms'];go_to_t={t['m_GameObject']['m_PathID']:int(k) for k,t in ts.items()}
filters={f['m_GameObject']['m_PathID']:f['m_Mesh'] for f in scene['mesh_filters']}
cache={};envs={};objects={}

def under(tid):
    while tid:
        if tid==args.root:return True
        if str(tid) not in ts:return False
        tid=ts[str(tid)]['m_Father']['m_PathID']
    return False

def world(tid):
    if tid not in cache:
        t=ts[str(tid)];pid=t['m_Father']['m_PathID']
        cache[tid]=(world(pid) if pid else np.eye(4))@transform_matrix(t)
    return cache[tid]

def get_objects(file_id):
    if file_id not in objects:
        name=args.scene if file_id==0 else scene['externals'][file_id-1]
        envs[file_id]=UnityPy.load(str(SOURCE/name))
        objects[file_id]={o.path_id:o for o in envs[file_id].objects}
    return objects[file_id]

def renderer(obj):
    raw=obj.get_raw_data()
    # Tuanjie inserts a 4-byte renderer field after ray-tracing flags.
    adapted=raw[:24]+raw[28:]
    r=EndianBinaryReader(adapted,endian='<')
    d=read_typetree(obj._get_typetree_node(),r,as_dict=True,check_read=False,assetsfile=obj.assets_file)
    if r.Position!=len(adapted):raise ValueError('Unrecognized MeshRenderer layout')
    return d

selections={};material_refs=set();errors=[];selected_renderers=0;duplicate_submeshes=0
for obj in list(get_objects(0).values()):
    if obj.type.name!='MeshRenderer':continue
    try:
        r=renderer(obj);go=r['m_GameObject']['m_PathID'];tid=go_to_t.get(go,0)
        if not under(tid) or go not in filters:continue
        ref=filters[go];fid,mid=ref['m_FileID'],ref['m_PathID']
        batch=r['m_StaticBatchInfo'];count=batch['subMeshCount'];first=batch['firstSubMesh']
        if count and r['m_StaticBatchRoot']['m_PathID']!=0:raise ValueError('Non-scene static root needs registration')
        key=(fid,mid,0 if count else tid)
        s=selections.setdefault(key,{})
        for i,mat in enumerate(r['m_Materials']):
            if count and i>=count:break
            index=first+i if count else i
            mref=(mat['m_FileID'],mat['m_PathID']);material_refs.add(mref)
            if index in s:
                duplicate_submeshes+=1
                if s[index]!=mref:raise ValueError('Conflicting materials for a static submesh')
            s[index]=mref
        selected_renderers+=1
    except Exception as ex:errors.append({'renderer':obj.path_id,'error':str(ex)[:180]})

materials=[];material_index={};material_inventory=[]
for ref in sorted(material_refs):
    obj=get_objects(ref[0]).get(ref[1])
    if obj is None or obj.type.name!='Material':raise ValueError('Material reference does not resolve')
    mat=obj.read_typetree();props=mat['m_SavedProperties'];colors=dict(props['m_Colors']);floats=dict(props['m_Floats'])
    c=colors.get('_BaseColor',colors.get('_Color',{'r':.7,'g':.7,'b':.7,'a':1}))
    rgba=[max(0,min(1,c[a])) for a in 'rgba']
    # Retain declared transparent surfaces; texture-only alpha cannot be reconstructed here.
    alpha='BLEND' if floats.get('_Mode',0)>=2 or rgba[3]<.95 else 'OPAQUE'
    matspec={'name':mat['m_Name'],'doubleSided':True,'alphaMode':alpha,'pbrMetallicRoughness':{'baseColorFactor':rgba,'metallicFactor':min(1,max(0,floats.get('_Metallic',0))),'roughnessFactor':max(.2,1-floats.get('_Glossiness',.3))}}
    material_index[ref]=len(materials);materials.append(matspec)
    material_inventory.append({'reference':ref,'name':mat['m_Name'],'color':rgba,'alpha_mode':alpha,'texture_references':props['m_TexEnvs']})

verts=[];normals=[];faces=defaultdict(list);inventory=[];vo=0
for index,((fid,mid,tid),submeshes) in enumerate(selections.items()):
    obj=get_objects(fid)[mid];mesh=read_mesh(obj);h=MeshHandler(mesh);h.process()
    if tid==0 and not mesh.m_Name.startswith('Combined Mesh (root: scene)'):
        raise ValueError('Unexpected combined mesh coordinate space')
    if h.m_Vertices is None:
        if mesh.m_VertexData.m_VertexCount==0 and not mesh.m_IndexBuffer:
            inventory.append({'asset_file':fid,'mesh_id':mid,'transform':tid,'name':mesh.m_Name,'vertices':0,'triangles':0,'empty_mesh':True})
            continue
        raise ValueError(f'No decoded vertices: {mid} {mesh.m_Name}, count={mesh.m_VertexData.m_VertexCount}, stream={mesh.m_StreamData}')
    v=np.asarray(h.m_Vertices,dtype=np.float64)
    triangles=h.get_triangles()
    generated_normals=h.m_Normals is None or len(h.m_Normals)!=len(v)
    if generated_normals:
        n=np.zeros_like(v)
        for si in submeshes:
            tri=np.asarray(triangles[si],dtype=np.int64).reshape(-1,3)
            face=np.cross(v[tri[:,1]]-v[tri[:,0]],v[tri[:,2]]-v[tri[:,0]])
            for column in range(3):np.add.at(n,tri[:,column],face)
    else:n=np.asarray(h.m_Normals,dtype=np.float64)[:,:3]
    if tid:
        m=world(tid);v=v@m[:3,:3].T+m[:3,3];n=n@np.linalg.inv(m[:3,:3])
    n/=np.maximum(np.linalg.norm(n,axis=1,keepdims=True),1e-12)
    v[:,2]*=-1;n[:,2]*=-1
    tc=0
    for si,mref in submeshes.items():
        tri=np.asarray(triangles[si],dtype=np.uint32).reshape(-1,3)
        if tri.max()>=len(v):raise ValueError('Invalid index')
        # Reflection changes winding; retain affine reflection sign for ordinary meshes.
        flip=tid==0 or np.linalg.det(world(tid)[:3,:3])>0
        if flip:tri=tri[:,[0,2,1]]
        faces[material_index[mref]].append(tri+vo);tc+=len(tri)
    if not np.isfinite(v).all() or not np.isfinite(n).all():raise ValueError('Nonfinite geometry')
    verts.append(v.astype(np.float32));normals.append(n.astype(np.float32));vo+=len(v)
    inventory.append({'asset_file':fid,'mesh_id':mid,'transform':tid,'name':mesh.m_Name,'selected_submeshes':len(submeshes),'vertices':len(v),'triangles':tc,'normals_generated':generated_normals})
    if index%20==0:print('LIBRARY',index,'/',len(selections),flush=True)

v=np.concatenate(verts);n=np.concatenate(normals);lo=v.min(axis=0);hi=v.max(axis=0);origin=(lo+hi)/2;origin[1]=lo[1];v-=origin
chunks=[];views=[];accessors=[];offset=0
def append(a,target,kind,ctype,bounds=False):
    global offset
    raw=a.tobytes();view=len(views);views.append({'buffer':0,'byteOffset':offset,'byteLength':len(raw),'target':target});chunks.append(raw);offset+=len(raw)
    accessor={'bufferView':view,'componentType':ctype,'count':len(a) if kind=='VEC3' else a.size,'type':kind}
    if bounds:accessor.update({'min':a.min(axis=0).tolist(),'max':a.max(axis=0).tolist()})
    accessors.append(accessor);return len(accessors)-1
primitives=[];total_triangles=0;exported_vertices=0
for mi,arrays in faces.items():
    tri=np.concatenate(arrays).astype('<u4');total_triangles+=len(tri)
    # Each primitive gets only its referenced vertices. Some importers materialize
    # the entire POSITION buffer per surface, which is disastrous for 4F's materials.
    used,indices=np.unique(tri,return_inverse=True);exported_vertices+=len(used)
    p=append(v[used].astype('<f4'),34962,'VEC3',5126,True)
    normal=append(n[used].astype('<f4'),34962,'VEC3',5126)
    ix=append(indices.astype('<u4'),34963,'SCALAR',5125)
    primitives.append({'attributes':{'POSITION':p,'NORMAL':normal},'indices':ix,'material':mi})
meshes=[{'primitives':primitives[i:i+64]} for i in range(0,len(primitives),64)]
gltf={'asset':{'version':'2.0','generator':'Read-only Tuanjie library static-batch recovery'},'scene':0,'scenes':[{'nodes':list(range(len(meshes)))}],'nodes':[{'mesh':i} for i in range(len(meshes))],'meshes':meshes,'materials':materials,'bufferViews':views,'accessors':accessors,'buffers':[{'byteLength':offset}]}
header=json.dumps(gltf,separators=(',',':')).encode();header+=b' '*(-len(header)%4)
with (OUT/(args.prefix+'-reference.glb')).open('wb') as f:
    f.write(struct.pack('<4sII',b'glTF',2,12+8+len(header)+8+offset));f.write(struct.pack('<I4s',len(header),b'JSON'));f.write(header);f.write(struct.pack('<I4s',offset,b'BIN\0'))
    for chunk in chunks:f.write(chunk)
report={'scene':args.scene,'root':args.root,'source_date':'unknown','extraction_date':'2026-10-11','selected_renderers':selected_renderers,'selected_mesh_groups':len(selections),'vertices':len(v),'triangles':total_triangles,'materials':len(materials),'duplicate_submeshes_skipped':duplicate_submeshes,'renderer_errors':errors,'bounds_size_original_units':(hi-lo).tolist(),'removed_origin_after_z_flip':origin.tolist(),'coordinate_rule':'static scene batches are already world space;ordinary objects use affine transform;Z negated;metric site registration pending','material_limit':'base colours and declared alpha only;textures and UVs not yet restored','material_inventory':material_inventory,'mesh_inventory':inventory}
report['exported_vertices_after_primitive_compaction']=exported_vertices
(OUT/(args.prefix+'-extraction.json')).write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('EXPORTED LIBRARY',len(v),'vertices',total_triangles,'triangles',len(materials),'materials','errors',len(errors),flush=True)
if errors:raise SystemExit(1)
