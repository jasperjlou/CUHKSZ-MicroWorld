"""V3 additive authoring data. Frozen V2 coordinates are never rewritten.

Connections are inferred, not surveyed. Exact entrance endpoints are retained.
The authoring A* below does not replace runtime Agent navigation.
"""
import hashlib
import json
import math
from pathlib import Path
from build_campus_masterplan import route_geometry, terrain_height

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT/'systems/data'


def connection_route(start,end,objects,shore):
    # The inherited five-unit planner needs free grid anchors as well as free
    # exact endpoints. Narrow inter-building gaps otherwise round into a wall.
    def free(p):
        x,z=p;inside=False
        for (ax,az),(bx,bz) in zip(shore,shore[1:]+shore[:1]):
            if (az>z)!=(bz>z) and x<(bx-ax)*(z-az)/(bz-az)+ax:inside=not inside
        return not inside and not any(abs(x-o['center'][0])<o['footprint_width']/2+6 and abs(z-o['center'][2])<o['footprint_depth']/2+6 for o in objects if o['category'] in ('building','track'))
    def clear(a,b):
        n=max(1,math.ceil(math.dist(a,b)))
        return all(free((a[0]+(b[0]-a[0])*i/n,a[1]+(b[1]-a[1])*i/n)) for i in range(n+1))
    def anchor(p):
        candidates=[(round(p[0]/5)*5+dx*5,round(p[1]/5)*5+dz*5) for dx in range(-3,4) for dz in range(-3,4)]
        return next(q for q in sorted(candidates,key=lambda q:math.dist(p,q)) if clear(p,q))
    try:a,b=anchor(start),anchor(end)
    except StopIteration:raise AssertionError('No free grid anchor')
    return [start]+route_geometry(a,b,objects,shore)+[end]


def build():
    m=json.loads((DATA/'campus_masterplan.json').read_text(encoding='utf-8'))
    paths=json.loads((DATA/'campus_paths.json').read_text(encoding='utf-8'))
    profiles=json.loads((DATA/'building_architecture_profiles.json').read_text(encoding='utf-8'))
    specs=[
        ('UPPER_COLLEGE_CORE','upper','college','WarmPaving',[250,-100,520,195],32),
        ('UPPER_RESIDENTIAL_EDGE','upper','residential','Concrete',[315,-270,615,-190],42),
        ('UPPER_SERVICE_AREA','upper','service','Concrete',[310,-155,435,-85],38),
        ('UPPER_SPORTS','upper','sports','SportsSurface',[170,50,220,105],40),
        ('UPPER_TO_MIDDLE_TRANSITION','middle','slope','LakePath',[185,60,280,260],30),
        ('FAIRY_LAKE_NORTH','fairy_lake','scenic','LakePath',[-170,-160,160,-100],40),
        ('FAIRY_LAKE_WEST','fairy_lake','scenic','LakePath',[-185,-90,-125,180],34),
        ('FAIRY_LAKE_EAST','fairy_lake','scenic','LakePath',[130,-90,205,235],40),
        ('FAIRY_LAKE_SOUTH','fairy_lake','scenic','LakePath',[-130,145,145,235],48),
        ('MIDDLE_MUSIC_AREA','middle','music','LightStone',[-75,235,165,360],34),
        ('LOWER_SPORTS','lower','sports','Concrete',[30,420,340,630],42),
        ('LOWER_LIBRARY_STUDENT_CORE','lower','public','LightStone',[510,525,720,700],28),
        ('LOWER_ACADEMIC_CORE','lower','academic','CourtPaving',[340,650,840,940],40),
        ('LOWER_ADMIN_CONFERENCE','lower','formal','LightStone',[790,520,1060,725],42),
        ('LOWER_SHAW','lower','college','WarmPaving',[370,375,490,600],34),
        ('LOWER_GATE_EDGE','lower','gate','Concrete',[800,740,1090,1010],50),
    ]
    zones=[]
    for zid,region,kind,surface,bounds,spacing in specs:
        zones.append(dict(id=zid,region=region,environment_type=kind,primary_surface='Campus_'+surface,
            bounds=bounds,tree_spacing=spacing,vegetation_density='grouped_open_views' if kind=='scenic' else 'moderate',
            furniture_density='low' if kind in ('formal','residential','gate') else 'moderate',
            lighting_density='low' if kind=='scenic' else 'moderate',signage_density='junctions_and_entrances',
            confidence='inferred',reference_ids=['CAMPUS_MAP','UPPER_OVERALL' if region=='upper' else 'LAKE_01' if region in ('middle','fairy_lake') else 'LOWER_OVERALL'],
            inference_basis='Existing guide topology and regional field/photo vocabulary; illustrative fixture positions.',replaceable=True))
    def xyz(p):return [round(p[0],3),round(terrain_height(*p,m['objects'],m['lake']['shoreline']),3),round(p[1],3)]
    def closest(p,a,b):
        dx,dz=b[0]-a[0],b[1]-a[1]; t=max(0,min(1,((p[0]-a[0])*dx+(p[1]-a[1])*dz)/(dx*dx+dz*dz))) if dx*dx+dz*dz else 0
        return (a[0]+t*dx,a[1]+t*dz)
    ped=[r for r in paths['paths'] if r['category']=='pedestrian']
    connections=[]
    for o in m['objects']:
        if o['category']!='building':continue
        x,_,z=o['center']; d=o['footprint_depth']
        door=(x,z+d/2-(.5 if o['id']=='bell' else 2.5)); start=(x,z+d/2+6.5)
        candidates=[]
        for r in ped:
            for a,b in zip(r['geometry'],r['geometry'][1:]):
                q=closest(start,(a[0],a[2]),(b[0],b[2])); candidates.append((math.dist(start,q),r['id'],q))
        obstacles=m['objects']
        for _,route,q in sorted(candidates):
            try: geometry=connection_route(start,q,obstacles,m['lake']['shoreline']);break
            except AssertionError:continue
        else:raise RuntimeError('No entrance connection '+o['id'])
        points=[door,start]+geometry[1:]
        tier=next(p['tier'] for p in profiles['buildings'] if p['id']==o['id'])
        connections.append(dict(id='entry_'+o['id'],building_id=o['id'],route_id=route,tier=tier,width=4 if tier=='A' else 3,
            geometry=[xyz(p) for p in points],confidence='placeholder' if tier=='C' else 'inferred',replaceable=True,
            inference_basis='Frozen V2 entrance axis joined to nearest reachable authored pedestrian segment with building/water detours.',
            reference_ids=o['source_refs'],covered=tier=='A' and o['id'] not in ('music','sports_hall','conference','library'),
            grade_policy='Terrain-draped arrival; stair edge dressing only alongside the unobstructed approach.'))
    landmark_connections=[]
    for o in m['objects']:
        if o['id'] not in ('lake_pavilion','lake_stone','reservoir_sign'):continue
        start=(o['center'][0],o['center'][2]);candidates=[]
        for r in ped:
            for a,b in zip(r['geometry'],r['geometry'][1:]):
                q=closest(start,(a[0],a[2]),(b[0],b[2]));candidates.append((math.dist(start,q),r['id'],q))
        for _,route,q in sorted(candidates):
            try:geometry=connection_route(start,q,m['objects'],m['lake']['shoreline']);break
            except AssertionError:continue
        else:raise RuntimeError('No landmark approach '+o['id'])
        landmark_connections.append(dict(id='approach_'+o['id'],landmark_id=o['id'],route_id=route,width=3,geometry=[xyz(p) for p in geometry],confidence='inferred',replaceable=True,
            inference_basis='Existing landmark and shoreline path positions; conservative short walking approach, not surveyed pavilion/stone placement.',reference_ids=o['source_refs']))
    routes=[]
    for r in m['roads']+paths['paths']:
        hierarchy='MAIN' if r['width']>=5 else 'SCENIC' if 'scenic' in r['id'] else 'SECONDARY'
        routes.append(dict(id=r['id'],category=r['category'],hierarchy=hierarchy,width=r['width'],geometry=r['geometry'],
            confidence=r['confidence'],replaceable=True,inference_basis=r['basis'],reference_ids=r['source_refs']))
    stops=[];stop_connections=[]
    for o in m['objects']:
        if o['category']!='stop':continue
        pos=o['center'];start=(pos[0],pos[2]);candidates=[]
        for r in ped:
            for a,b in zip(r['geometry'],r['geometry'][1:]):
                q=closest(start,(a[0],a[2]),(b[0],b[2]));candidates.append((math.dist(start,q),r['id'],q))
        for _,route,q in sorted(candidates):
            try:geometry=connection_route(start,q,m['objects'],m['lake']['shoreline']);break
            except AssertionError:continue
        else:raise RuntimeError('No stop approach '+o['id'])
        stop_connections.append(dict(id='approach_'+o['id'],stop_id=o['id'],route_id=route,width=3,geometry=[xyz(p) for p in geometry],confidence='placeholder',replaceable=True,
            inference_basis='Short connection from frozen visual stop pad to existing pedestrian corridor; operational boarding location remains unverified.',reference_ids=o['source_refs']))
        stops.append(dict(id=o['id'],region=o['region'],position=pos,boarding_point=xyz(q),waiting_area=dict(center=pos,width=12,depth=6),
            active=False,transport_status='visual_prototype_no_schedule_change',confidence='placeholder',replaceable=True,
            inference_basis='Existing masterplan stop ID and location, not a surveyed fleet/operating timetable.',reference_ids=o['source_refs']))
    frozen_paths=['systems/data/campus_masterplan.json','systems/data/campus_paths.json','systems/data/building_architecture_profiles.json','world/campus_master/CampusGeometry.gd','world/campus_master/CampusMassing.gd']
    frozen_paths += [str(p.relative_to(ROOT)).replace('\\','/') for p in (ROOT/'world/campus_master/architecture').rglob('*.gd')]
    frozen={p:hashlib.sha256((ROOT/p).read_bytes().replace(b'\r\n',b'\n')).hexdigest() for p in frozen_paths}
    document=dict(version='campus-environment-v3',architecture_baseline='75ded2f3832092586a8c3932f181fe9cbe607882',zones=zones,
        sources=m['sources'],routes=routes,entrance_connections=connections,landmark_connections=landmark_connections,stop_connections=stop_connections,stops=stops,frozen_v2_sha256=frozen,
        navigation_policy='Additive authoring connections; existing RC1 AStar3D and transport state unchanged.',
        uncertainty_policy='verified / inferred / placeholder; no surveyed metric claim')
    (DATA/'campus_environment_zones.json').write_text(json.dumps(document,ensure_ascii=False,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(f'Environment: {len(zones)} zones, {len(routes)} routes, {len(connections)} entrances, {len(stops)} stops')


if __name__=='__main__':build()

