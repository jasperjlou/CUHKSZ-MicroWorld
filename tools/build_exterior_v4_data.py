"""Deterministic V4 authoring records. Original V3 files remain immutable."""
import hashlib
import json
import math
import subprocess
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
DATA=ROOT/'systems/data'
def read(name):return json.loads((ROOT/name).read_text(encoding='utf-8'))
def write(name,value):
    p=ROOT/name;p.parent.mkdir(parents=True,exist_ok=True)
    p.write_text(json.dumps(value,ensure_ascii=False,indent=2)+'\n',encoding='utf-8',newline='\n')

def main():
    m=read('systems/data/campus_masterplan.json');e=read('systems/data/campus_environment_zones.json')
    p=read('systems/data/building_architecture_profiles.json')
    tracked=subprocess.check_output(['git','ls-tree','-r','--name-only','6cd48b0'],cwd=ROOT,text=True,encoding='utf-8').splitlines()
    protected=[f for f in tracked if f.startswith(('world/campus_master/','player/','agents/','benchmarks/','systems/')) or f=='project.godot']
    frozen=dict(baseline='6cd48b04fc669dfe92e33b82fe2b63feabfa8fea',masterplan=m,environment=e,
                paths=read('systems/data/campus_paths.json'),profiles=p,
                source_sha256={f:hashlib.sha256((ROOT/f).read_bytes().replace(b'\r\n',b'\n')).hexdigest() for f in protected})
    # Snapshot created only once. Never silently refresh an immutable baseline.
    if not (DATA/'campus_environment_v3_frozen.json').exists():write('systems/data/campus_environment_v3_frozen.json',frozen)
    refs={
        'V4_MUSIC_OPENING':dict(url='https://www.cuhk.edu.cn/zh-hans/article/15580',decision='Five music/teaching/service masses plus separately anchored two Eighth dormitory masses; petal performance forms, U courts and covered connections.',review='OFFICIAL_TEXT_REVIEWED',date='2026-10-07'),
        'V4_CAMPUS_CONTEXT':dict(url='https://admissions.cuhk.edu.cn/node/909',decision='Separate motor road and greenway vocabulary; upper residential, middle landscape/descent and lower academic platform; hill context.',review='OFFICIAL_TEXT_REVIEWED',date='2026-10-07'),
        'V4_MUSE_FACILITIES':dict(url='https://muse.cuhk.edu.cn/page/76',decision='Three dormitory masses, exact subdivision/spacing inferred.',review='OFFICIAL_TEXT_REVIEWED',date='2026-10-07'),
        'V4_DILIGENTIA_FACILITIES':dict(url='https://diligentia.cuhk.edu.cn/page/1051',decision='Three A/B/C dormitory masses; inferred roof rhythm.',review='OFFICIAL_TEXT_REVIEWED',date='2026-10-07'),
        'V4_SHAW_FACILITIES':dict(url='https://cuhk.edu.cn/zh-hans/campus-life',decision='Three interconnected blocks per East/West ensemble.',review='OFFICIAL_TEXT_REVIEWED',date='2026-10-07'),
        'V4_COLLEGE_NAMES':dict(url='https://admissions.cuhk.edu.cn/node/30',decision='Current physical names; retain legacy identifiers as stable internal IDs.',review='OFFICIAL_TEXT_REVIEWED',date='2026-10-07')}
    write('references/exterior_v4/source_decisions.json',refs)
    vr=read('references/vr/scene_catalog.json')['references']
    work=[]
    for o in m['objects']:
        if o['category']!='building':continue
        profile=next(x for x in p['buildings'] if x['id']==o['id'])
        candidates=[r['reference_id'] for r in vr if any(t in r['subject'].lower() for t in [o['id'].replace('_',' '),o['name_en'].lower()])][:6]
        work.append(dict(id=o['id'],tier=profile['tier'],reference_ids=profile['reference_ids'],panorama_candidates=candidates,
                         front='regional or building-specific source',side='conservative continuation unless recorded',rear='INFERRED_REAR_FACADE',roof='guide and family interpretation'))
    write('references/exterior_v4/building_coverage.json',work)
    corrections=[]
    buildings={o['id']:o for o in m['objects'] if o['category'] in ['building','track','court']}
    separated=0
    for road in e['routes']:
        if road['category']!='vehicle':continue
        old=road['geometry'];geometry=[]
        for a,b in zip(old,old[1:]):
            dx=b[0]-a[0];dz=b[2]-a[2];length=math.hypot(dx,dz)
            if length<.01:continue
            mid=[(a[0]+b[0])/2,(a[1]+b[1])/2,(a[2]+b[2])/2]
            shared=False
            for ped in e['routes']:
                if ped['category']!='pedestrian':continue
                for u,v in zip(ped['geometry'],ped['geometry'][1:]):
                    vx=v[0]-u[0];vz=v[2]-u[2];den=vx*vx+vz*vz
                    t=max(0,min(1,((mid[0]-u[0])*vx+(mid[2]-u[2])*vz)/den)) if den else 0
                    if math.hypot(mid[0]-u[0]-t*vx,mid[2]-u[2]-t*vz)<2:shared=True
            shift=0
            if shared and length>18:
                for side in [1,-1]:
                    candidate=[mid[0]+dz/length*side*10,mid[1],mid[2]-dx/length*side*10]
                    if not any(abs(a[0]+dx*t+dz/length*side*10*min(1,t/.22,(1-t)/.22)-o['center'][0])<o['footprint_width']/2+road['width']/2+1 and abs(a[2]+dz*t-dx/length*side*10*min(1,t/.22,(1-t)/.22)-o['center'][2])<o['footprint_depth']/2+road['width']/2+1 for o in buildings.values() for t in [i/40 for i in range(41)]):
                        shift=side*10;break
            geometry.append(a)
            if shift:
                for t in [.22,.78]:geometry.append([round(a[0]+dx*t+dz/length*shift,3),a[1]+(b[1]-a[1])*t,round(a[2]+dz*t-dx/length*shift,3)])
                separated+=1
        geometry.append(old[-1]);road['geometry']=geometry
        road['profile']='CAMPUS_MAIN_ROAD' if road['width']>=9 else 'COLLEGE_INTERNAL_ROAD' if 'upper' in road['id'] else 'SERVICE_ROAD'
        if geometry!=old:corrections.append(dict(event='V4_SPATIAL_CORRECTION',object=road['id'],before=old,after=geometry,reason='Conservative lateral motor lane at shared segment; pedestrian and junction anchors retained.',reference=['V4_CAMPUS_CONTEXT','CAMPUS_MAP'],confidence='inferred'))
    for route in e['routes']:
        if route['category']=='pedestrian':route['profile']='SCENIC_LAKE_PATH' if 'scenic' in route['id'] else 'PRIMARY_PEDESTRIAN' if route['width']>=5 else 'SECONDARY_PEDESTRIAN'
    for c in e['entrance_connections']:
        c['corridor_review']='INFERRED'
        c['covered']=c['building_id'] in ['ling','muse','diligentia','harmonia','shaw_west','shaw_east','teaching_a','teaching_b']
        c['inference_basis']+=' V4: only restrained college/teaching arrival canopies retained; no verified inter-building corridor claim.'
    e['version']='campus-exterior-v4';e['road_separated_segments']=separated
    write('systems/data/campus_exterior_environment_v4.json',e)
    corrections.append(dict(event='V4_SPATIAL_CORRECTION',object='relative_macro_terrain',before='12-unit abrupt platform blend',after='42-unit graded blend with unchanged platform datums; physical routes revalidated',reason='Slope/terrace vocabulary, removal of angular raw pad transitions',reference=['CAMPUS_MAP','V4_CAMPUS_CONTEXT'],confidence='inferred'))
    write('systems/data/campus_spatial_corrections_v4.json',corrections)
    records=[]
    def add(id,kind,region,refs,confidence,priority='P2',unknowns='Dimensions/relative grades inferred, not a measured survey.'):
        records.append(dict(id=id,component_type=kind,region=region,current_confidence=confidence,target_confidence='SUPPORTED',reference_ids=refs,
                            visible_from_main_route=True,correction_priority=priority,remaining_unknowns=unknowns,
                            appearance_status='REFERENCE_APPROXIMATION',placement_confidence='INFERRED',architecture_confidence=confidence if kind=='BUILDING' else 'INFERRED',
                            environment_confidence='INFERRED',terrain_confidence='INFERRED_RELATIVE',replaceable=True))
    for o in m['objects']:
        if o['category']=='building':add(o['id'],'BUILDING',o['region'],o['source_refs']+({'music':['V4_MUSIC_OPENING'],'eighth':['V4_MUSIC_OPENING'],'muse':['V4_MUSE_FACILITIES'],'diligentia':['V4_DILIGENTIA_FACILITIES'],'shaw_east':['V4_SHAW_FACILITIES'],'shaw_west':['V4_SHAW_FACILITIES']}.get(o['id'],[])),'SUPPORTED' if o['id'] in ['music','eighth','muse','diligentia','shaw_east','shaw_west'] else 'INFERRED','P0' if o['id']=='music' else 'P1' if next(x for x in p['buildings'] if x['id']==o['id'])['tier']=='A' else 'P2')
        elif o['category'] in ['gate','stop','pavilion','stone','sign','lake','plaza']:
            add(o['id'],{'gate':'GATE','stop':'SHUTTLE_STOP','lake':'LAKE','plaza':'PLAZA'}.get(o['category'],'LANDMARK'),o['region'],o['source_refs'],'PLACEHOLDER' if o['category']=='stop' else 'INFERRED','P1')
    for route in e['routes']:add(route['id'],'ROAD' if route['category']=='vehicle' else 'PATH','campus',route['reference_ids']+['V4_CAMPUS_CONTEXT'],'INFERRED','P0')
    for entry in e['entrance_connections']:
        if entry['covered']:add('corridor_'+entry['building_id'],'CORRIDOR',next(o['region'] for o in m['objects'] if o['id']==entry['building_id']),entry['reference_ids'],'INFERRED','P1')
    for zone in e['zones']:add('terrain_'+zone['id'],'TERRAIN',zone['region'],zone['reference_ids']+['V4_CAMPUS_CONTEXT'],'INFERRED','P0')
    write('systems/data/campus_accuracy_v4.json',dict(version='V4',sources=refs,records=records,visible_placeholder_target=0,
        appearance_policy='Appearance is separate from factual confidence; QA must inspect before asserting zero visible placeholders.',road_profiles=['CAMPUS_MAIN_ROAD','COLLEGE_INTERNAL_ROAD','SERVICE_ROAD','SHUTTLE_APPROACH','SHARED_SPACE'],
        walkway_profiles=['PRIMARY_PEDESTRIAN','SECONDARY_PEDESTRIAN','COVERED_CORRIDOR','SCENIC_LAKE_PATH','COURTYARD_PATH','STAIR_CONNECTION','RAMP_CONNECTION']))
    road_names=['CAMPUS_MAIN_ROAD','COLLEGE_INTERNAL_ROAD','SERVICE_ROAD','SHUTTLE_APPROACH','SHARED_SPACE']
    walk_names=['PRIMARY_PEDESTRIAN','SECONDARY_PEDESTRIAN','COVERED_CORRIDOR','SCENIC_LAKE_PATH','COURTYARD_PATH','STAIR_CONNECTION','RAMP_CONNECTION']
    write('systems/data/campus_surface_profiles_v4.json', dict(confidence='inferred',units='estimated game units',road_profiles={n:dict(width=w,curb_width=.36,shoulder_width=.8,lamp_spacing=25,material='Campus_Asphalt',collision='shared terrain') for n,w in zip(road_names,[10,8,6,8,7])},walkway_profiles={n:dict(width=w,curb_width=.3,material='Campus_LakePath' if n=='SCENIC_LAKE_PATH' else 'Campus_Concrete',collision='shared terrain',grade_limit=.5) for n,w in zip(walk_names,[6,4,5.8,4,4,4,5])}))
    print('V4 authoring:' ,len(records),'accuracy records,',separated,'separated lane sections')

if __name__=='__main__':main()
