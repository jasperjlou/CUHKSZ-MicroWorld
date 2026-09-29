"""Inspect actual COLLADA triangles, not convex envelopes. No game asset export."""
import collections
import hashlib
import json
import math
import pathlib
import subprocess
import xml.etree.ElementTree as ET
from audit_legacy_spatial import N, I, COMMIT, mm, transform

ROOT = pathlib.Path(__file__).resolve().parents[1]
REPO = ROOT / '.tools/research/virtual-campus-v2'


def components(triangles):
    # Weld identical positions after exporter-precision rounding; no metric tolerance.
    edges = collections.defaultdict(list)
    parent = list(range(len(triangles)))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    for i, tri in enumerate(triangles):
        pts = [tuple(round(v,5) for v in p) for p in tri]
        for a,b in [(0,1),(1,2),(2,0)]:
            edges[tuple(sorted((pts[a],pts[b])))].append(i)
    for neighbors in edges.values():
        for i in neighbors[1:]:
            parent[find(i)] = find(neighbors[0])
    sizes = sorted(collections.Counter(find(i) for i in range(len(parent))).values(),reverse=True)
    return dict(components=len(sizes),largest_component_triangles=sizes[:8],boundary_edges=sum(len(v)==1 for v in edges.values()),nonmanifold_edges=sum(len(v)>2 for v in edges.values()))


def analyze(data, path):
    root = ET.fromstring(data)
    up = root.find('c:asset/c:up_axis',N)
    assert up is None or up.text == 'Y_UP'
    geometries = {}
    for geometry in root.findall('.//c:library_geometries/c:geometry',N):
        mesh = geometry.find('c:mesh',N)
        inp = mesh.find('c:vertices/c:input[@semantic="POSITION"]',N)
        source = mesh.find('c:source[@id="'+inp.attrib['source'][1:]+'"]',N)
        values = list(map(float,source.find('c:float_array',N).text.split()))
        accessor = source.find('c:technique_common/c:accessor',N)
        stride,offset,count = int(accessor.attrib.get('stride',3)),int(accessor.attrib.get('offset',0)),int(accessor.attrib['count'])
        points=[values[offset+i*stride:offset+i*stride+3] for i in range(count)]
        faces=[]
        unsupported=[]
        for primitive in mesh:
            kind=primitive.tag.rsplit('}',1)[-1]
            if kind in ['source','vertices']: continue
            if kind != 'triangles':
                unsupported.append(kind)
                continue
            inputs=primitive.findall('c:input',N)
            width=max(int(x.attrib.get('offset',0)) for x in inputs)+1
            vertex_offset=int(next(x for x in inputs if x.attrib['semantic']=='VERTEX').attrib.get('offset',0))
            indices=list(map(int,primitive.find('c:p',N).text.split()))
            assert len(indices)==int(primitive.attrib['count'])*3*width
            faces.extend(tuple(indices[start+j*width+vertex_offset] for j in range(3)) for start in range(0,len(indices),3*width))
        geometries[geometry.attrib['id']] = points,faces,unsupported
    output=[]
    def visit(node, parent):
        matrix=parent
        for el in node:
            if el.tag.rsplit('}',1)[-1] in ['matrix','translate','rotate','scale','lookat','skew']:
                matrix=mm(matrix,transform(el))
        assert node.find('c:instance_node',N) is None
        for instance in node.findall('c:instance_geometry',N):
            points,faces,unsupported=geometries[instance.attrib['url'][1:]]
            pts=[[sum(matrix[r*4+k]*p[k] for k in range(3))+matrix[r*4+3] for r in range(3)] for p in points]
            candidates=[]
            for face in faces:
                a,b,c=[pts[i] for i in face]
                ab=[b[i]-a[i] for i in range(3)];ac=[c[i]-a[i] for i in range(3)]
                normal=[ab[1]*ac[2]-ab[2]*ac[1],ab[2]*ac[0]-ab[0]*ac[2],ab[0]*ac[1]-ab[1]*ac[0]]
                magnitude=math.sqrt(sum(v*v for v in normal))
                if magnitude>1e-10 and abs(normal[1])/magnitude >= math.cos(math.radians(35)):
                    candidates.append([a,b,c])
            name=node.attrib.get('name',node.attrib.get('id','unknown'))
            named_ground=any(x in name.lower() for x in ['road','ground','terrain','border','around-','slope','parking'])
            low=[min(p[i] for p in pts) for i in range(3)];high=[max(p[i] for p in pts) for i in range(3)]
            output.append(dict(name=name,source_node_id=node.attrib.get('id'),named_ground_candidate=named_ground,triangles=len(faces),low_slope_candidate_triangles=len(candidates),unsupported_primitives=unsupported,low_slope_connectivity=components(candidates),aabb_min=low,aabb_max=high,geographic_anchor='unknown',walkability='unknown',lake_to_junction_match=False))
        for child in node.findall('c:node',N):visit(child,matrix)
    scene_id=root.find('c:scene/c:instance_visual_scene',N).attrib['url'][1:]
    for node in root.findall('.//c:visual_scene[@id="'+scene_id+'"]/c:node',N):visit(node,I)
    return dict(source_path=path,sha256=hashlib.sha256(data).hexdigest(),nodes=output)


def main():
    fixture=[[[0,0,0],[1,0,0],[1,0,1]],[[0,0,0],[1,0,1],[0,0,1]],[[3,0,0],[4,0,0],[3,0,1]]]
    assert components(fixture)['components']==2
    assert components(fixture)['largest_component_triangles']==[2,1]
    assert components(fixture)['boundary_edges']==7
    assert components([])['components']==0
    paths=subprocess.check_output(['git','-C',str(REPO),'ls-tree','-r','--name-only',COMMIT],text=True).splitlines()
    files=[analyze(subprocess.check_output(['git','-C',str(REPO),'show',COMMIT+':'+p]),p) for p in paths if p.endswith('.dae')]
    nodes=[n for f in files for n in f['nodes']]
    assert len(nodes)==123,'Missing instance coverage'
    summary=dict(files=len(files),instances=len(nodes),named_ground_candidates=sum(n['named_ground_candidate'] for n in nodes),triangles=sum(n['triangles'] for n in nodes),low_slope_candidate_triangles=sum(n['low_slope_candidate_triangles'] for n in nodes),geographically_matched_segments=0)
    report=dict(source_commit=COMMIT,summary=summary,files=files,units='uncalibrated_export_units_not_metres',method='Actual indexed triangles transformed through full scene hierarchy; abs(normal.y) slope filter <=35 degrees; shared full edges welded to 5 decimal exporter precision, per instance.',limitations=['Low-slope faces include roofs, undersides, platforms and merged objects; they are not certified pedestrian surfaces.','Shared triangle edges indicate mesh connectivity only, not walkability or road branching.','Per-instance components do not prove absence of cross-mesh contact; T-junctions and gaps smaller than export precision are not resolved.','Numeric names remain unidentified; no road mesh is anchored to the lake inscription or candidate roundabout.','Uncalibrated exporter geometry cannot establish measured road width, metres, travel time or geographic orientation.'],lake_to_junction_continuity='unknown',used_for_game_geometry=False)
    target=ROOT/'references/legacy_models/ground_topology.json'
    target.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
    print(json.dumps(summary))
    for f in files:
        for n in f['nodes']:
            if n['named_ground_candidate']:
                print(f["source_path"],n['name'],n['triangles'],n['low_slope_candidate_triangles'],n['low_slope_connectivity']['components'])


if __name__=='__main__':main()
