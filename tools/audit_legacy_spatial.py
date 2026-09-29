"""Read recovered COLLADA sources only; export reference statistics, never game meshes."""
import argparse, hashlib, json, math, pathlib, subprocess, xml.etree.ElementTree as ET

N={'c':'http://www.collada.org/2005/11/COLLADASchema'}
I=[1.,0,0,0,0,1.,0,0,0,0,1.,0,0,0,0,1.]
COMMIT='87e2d897fb2264a6b659407522a525f28f7cf211'
def mm(a,b): return [sum(a[r*4+k]*b[k*4+c] for k in range(4)) for r in range(4) for c in range(4)]
def transform(e):
    t=e.tag.rsplit('}',1)[-1]; v=list(map(float,(e.text or '').split())); m=I.copy()
    if t=='matrix':
        assert len(v)==16 and all(abs(v[i])<1e-6 for i in [12,13,14]) and abs(v[15]-1)<1e-6, 'Unexpected matrix convention'
        return v
    if t=='translate': m[3],m[7],m[11]=v
    elif t=='scale': m[0],m[5],m[10]=v
    elif t=='rotate':
        x,y,z,ang=v; length=math.sqrt(x*x+y*y+z*z); x,y,z=x/length,y/length,z/length
        c=math.cos(math.radians(ang));s=math.sin(math.radians(ang));q=1-c
        m=[x*x*q+c,x*y*q-z*s,x*z*q+y*s,0,y*x*q+z*s,y*y*q+c,y*z*q-x*s,0,z*x*q-y*s,z*y*q+x*s,z*z*q+c,0,0,0,0,1]
    else: raise ValueError('Unsupported transform '+t)
    return m
def hull(points):
    p=sorted(set(points))
    if len(p)<3:return p
    def cross(o,a,b): return (a[0]-o[0])*(b[1]-o[1])-(a[1]-o[1])*(b[0]-o[0])
    lo=[];hi=[]
    for a in p:
        while len(lo)>1 and cross(lo[-2],lo[-1],a)<=0:lo.pop()
        lo.append(a)
    for a in reversed(p):
        while len(hi)>1 and cross(hi[-2],hi[-1],a)<=0:hi.pop()
        hi.append(a)
    return lo[:-1]+hi[:-1]
def audit(data,path):
    root=ET.fromstring(data); geoms={};nodes=[]
    for g in root.findall('.//c:library_geometries/c:geometry',N):
        mesh=g.find('c:mesh',N); inp=mesh.find('c:vertices/c:input[@semantic="POSITION"]',N)
        src=mesh.find('c:source[@id="'+inp.attrib['source'][1:]+'"]',N)
        vals=list(map(float,src.find('c:float_array',N).text.split()));acc=src.find('c:technique_common/c:accessor',N)
        stride=int(acc.attrib.get('stride','3'));offset=int(acc.attrib.get('offset','0'));count=int(acc.attrib['count'])
        geoms[g.attrib['id']]=[vals[offset+i*stride:offset+i*stride+3] for i in range(count)]
    def visit(node,parent):
        m=parent
        for e in node:
            if e.tag.rsplit('}',1)[-1] in ['matrix','translate','rotate','scale','lookat','skew']:m=mm(m,transform(e))
        if node.find('c:instance_node',N) is not None:raise ValueError('Unexpanded instance_node')
        for e in node.findall('c:instance_geometry',N):
            points=geoms[e.attrib['url'][1:]]
            transformed=[[sum(m[r*4+k]*p[k] for k in range(3))+m[r*4+3] for r in range(3)] for p in points]
            low=[min(p[i] for p in transformed) for i in range(3)];high=[max(p[i] for p in transformed) for i in range(3)]
            polygon=hull([(p[0],p[2]) for p in transformed])
            name=node.attrib.get('name',node.attrib.get('id','unknown'))
            kind='unidentified' if name.isdigit() else 'road' if 'road' in name.lower() else 'terrain_or_merged_surroundings' if any(w in name.lower() for w in ['ground','border','terrain','around-']) else 'building_or_object'
            nodes.append({'name':name,'kind':kind,'world_matrix':m,'vertex_count':len(points),'aabb_min':low,'aabb_max':high,'span':[round(high[i]-low[i],4) for i in range(3)],'center':[(a+b)/2 for a,b in zip(low,high)],'projected_convex_hull_xz':polygon,'footprint_type':'PROJECTED_ENVELOPE_NOT_GROUND_CONTACT','road_width':None,'real_height_m':None})
        for child in node.findall('c:node',N):visit(child,m)
    sceneid=root.find('c:scene/c:instance_visual_scene',N).attrib['url'][1:]
    scene=root.find('.//c:visual_scene[@id="'+sceneid+'"]',N)
    for n in scene.findall('c:node',N):visit(n,I)
    up=root.find('c:asset/c:up_axis',N);assert up is None or up.text=='Y_UP'
    return {'source_path':path,'source_commit':COMMIT,'sha256':hashlib.sha256(data).hexdigest(),'declared_unit_meter':root.find('c:asset/c:unit',N).attrib.get('meter'),'scale_status':'UNCALIBRATED_EXPORT_UNITS','nodes':nodes}
def main():
    parser=argparse.ArgumentParser();parser.add_argument('--repo',default='.tools/research/virtual-campus-v2');parser.add_argument('--out',default='references/legacy_models/spatial_skeleton.json');args=parser.parse_args()
    paths=subprocess.check_output(['git','-C',args.repo,'ls-tree','-r','--name-only',COMMIT],text=True).splitlines()
    files=[]
    for path in paths:
        if path.endswith('.dae'):
            data=subprocess.check_output(['git','-C',args.repo,'show',COMMIT+':'+path]);files.append(audit(data,path));print(path,len(files[-1]['nodes']),flush=True)
    distances=[]
    for f in files:
        buildings=[n for n in f['nodes'] if n['kind']=='building_or_object']
        for a,b in zip(buildings,buildings[1:]):
            distances.append({'source_path':f['source_path'],'a':a['name'],'b':b['name'],'center_distance_export_units':round(math.dist(a['center'],b['center']),3),'metric_distance_m':None})
    out={'name':'LEGACY_SPATIAL_SKELETON','status':'PARTIAL_LOWER_CAMPUS_ONLY','source_url':'https://github.com/newbie-at-cuhksz/virtual-campus-v2/tree/'+COMMIT,'files':files,'relative_distances':distances,'limits':['Projected convex envelope includes overhangs and fills courtyards; not surveyed footprint.','Height span includes merged base and decorations; not building height above local terrain.','Road mesh envelope is not drivable width; no lane-edge extraction.','Local elevations and relative distances use uncalibrated exporter coordinates, never metres.','Only four DAE exports audited. BLEND interiors, upper campus and lake geometry not decoded.','No lake-named mesh found in audited exports; this does not prove absence from the full archive.'],'asset_reuse_status':'ASSET_REUSE_UNKNOWN'}
    p=pathlib.Path(args.out);p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(out,ensure_ascii=False,indent=2),encoding='utf8')
    print('TOTAL',sum(len(f['nodes']) for f in files))
if __name__=='__main__':main()
