"""Environment V3 invariants, actual controller routes and V2 comparison.

python tools/check_campus_environment.py --render --rc1
Artifacts remain local/ignored. Navigation authoring is not a physics backend.
"""
import argparse
import hashlib
import json
import math
from check_campus_architecture import architecture_audit
from check_campus_masterplan import ROOT, engine


def environment_audit():
    architecture_audit()
    d=json.loads((ROOT/'systems/data/campus_environment_zones.json').read_text(encoding='utf-8'))
    m=json.loads((ROOT/'systems/data/campus_masterplan.json').read_text(encoding='utf-8'))
    p=json.loads((ROOT/'systems/data/campus_paths.json').read_text(encoding='utf-8'))
    checks=0
    def check(ok,message):
        nonlocal checks
        checks+=1
        if not ok:raise AssertionError(message)
    for file,digest in d['frozen_v2_sha256'].items():
        check(hashlib.sha256((ROOT/file).read_bytes().replace(b'\r\n',b'\n')).hexdigest()==digest,'V2 frozen file '+file)
    seen=set()
    buildings={o['id']:o for o in m['objects'] if o['category']=='building'}
    route_ids={r['id'] for r in m['roads']+p['paths']}
    check(len(d['zones'])==16,'zone coverage')
    check({r['id'] for r in d['routes']}==route_ids,'road and pedestrian coverage')
    check(len(d['entrance_connections'])==44 and {r['building_id'] for r in d['entrance_connections']}==set(buildings),'all entrances')
    for record in d['zones']+d['routes']+d['entrance_connections']+d['stops']:
        check(record['id'] not in seen,'duplicate environment ID '+record['id']);seen.add(record['id'])
        check(record['confidence'] in ('verified','inferred','placeholder'),'confidence')
        check(record['replaceable'] and bool(record['inference_basis']),'provenance')
        check(bool(record['reference_ids']) and all(ref in d['sources'] for ref in record['reference_ids']),'reference resolution')
    def inside(x,z,polygon):
        value=False
        for (ax,az),(bx,bz) in zip(polygon,polygon[1:]+polygon[:1]):
            if (az>z)!=(bz>z) and x<(bx-ax)*(z-az)/(bz-az)+ax:value=not value
        return value
    for connection in d['entrance_connections']:
        check(connection['route_id'] in route_ids,'connected network endpoint')
        owner=buildings[connection['building_id']]
        a=connection['geometry'][0]
        check(abs(a[0]-owner['center'][0])<.01,'entrance axis')
        network=next(r for r in d['routes'] if r['id']==connection['route_id'])
        end=connection['geometry'][-1]
        def point_segment_distance(q,a,b):
            dx,dz=b[0]-a[0],b[2]-a[2];v=dx*dx+dz*dz
            t=max(0,min(1,((q[0]-a[0])*dx+(q[2]-a[2])*dz)/v)) if v else 0
            return math.hypot(q[0]-a[0]-t*dx,q[2]-a[2]-t*dz)
        check(min(point_segment_distance(end,a,b) for a,b in zip(network['geometry'],network['geometry'][1:]))<.01,'path joins exact existing segment')
        for segment,(a,b) in enumerate(zip(connection['geometry'],connection['geometry'][1:])):
            n=max(1,math.ceil(math.dist(a,b)))
            for i in range(n+1):
                x=a[0]+(b[0]-a[0])*i/n;z=a[2]+(b[2]-a[2])*i/n
                check(inside(x,z,m['bounds']),'connection outside world bounds')
                check(not inside(x,z,m['lake']['shoreline']),'connection in lake')
                for o in buildings.values():
                    if segment==0 and o['id']==owner['id']:continue
                    check(not(abs(x-o['center'][0])<o['footprint_width']/2 and abs(z-o['center'][2])<o['footprint_depth']/2),'connection through building '+o['id'])
    stop_ids={o['id'] for o in m['objects'] if o['category']=='stop'}
    check({s['id'] for s in d['stops']}==stop_ids,'stop IDs retained')
    for s in d['stops']:
        o=next(o for o in m['objects'] if o['id']==s['id'])
        check(s['position']==o['center'] and s['region']==o['region'],'stop placement')
        check(not s['active'] and bool(s['boarding_point']) and bool(s['waiting_area']),'prototype transport preserved')
    print(f'ENVIRONMENT_DATA_QA: {checks} checks, 0 failures; 16 zones / 15 routes / 44 entries / 2 stops')
    return checks


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--render',action='store_true');parser.add_argument('--rc1',action='store_true')
    opts=parser.parse_args();environment_audit()
    engine(['--headless','--editor','--import','--quit'],'environment_import',120)
    # Check the runtime script explicitly: editor import may not parse all scripts.
    engine(['--headless','--script','res://world/campus_master/environment/CampusEnvironment.gd','--check-only'],'environment_script_check',30)
    scene=['res://world/campus_master/CampusMaster.tscn','--','--environment-capture']
    if opts.render:
        engine(scene+['--environment-baseline'],'environment_v2_baseline',120)
        engine(['--fixed-fps','60']+scene+['--environment-walk'],'environment_v3_acceptance',300)
        engine(scene,'environment_v3_performance',120)
    else:
        engine(['--headless','--fixed-fps','60']+scene+['--environment-walk'],'environment_v3_headless',240)
    if opts.rc1:engine(['--headless','--fixed-fps','60','--','--qa'],'environment_rc1_core',180)
