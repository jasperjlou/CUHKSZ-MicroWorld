"""V4 source, confidence and evidence audit; does not mutate frozen worlds."""
from pathlib import Path
import hashlib
import json
import html
import argparse
try:
    from tools.check_campus_masterplan import engine
except ModuleNotFoundError:
    from check_campus_masterplan import engine

ROOT = Path(__file__).resolve().parents[1]

def read(name):
    return json.loads((ROOT / name).read_text(encoding="utf-8"))

def audit():
    frozen = read('systems/data/campus_environment_v3_frozen.json')
    count = 0
    def check(ok, message):
        nonlocal count
        count += 1
        if not ok: raise AssertionError(message)
    for name, digest in frozen['source_sha256'].items():
        check(hashlib.sha256((ROOT/name).read_bytes().replace(b'\r\n',b'\n')).hexdigest()==digest,
              'Frozen V3/RC1 file changed: '+name)
    accuracy = read('systems/data/campus_accuracy_v4.json')
    master = frozen['masterplan']
    records = {r['id']:r for r in accuracy['records']}
    sources = set(master['sources']) | set(accuracy['sources'])
    buildings = [o for o in master['objects'] if o['category']=='building']
    check(len(buildings)==44,'44-building coverage')
    for r in accuracy['records']:
        check(r['current_confidence'] in ['SUPPORTED','INFERRED','PLACEHOLDER'],'Confidence')
        check(r['replaceable'] and r['remaining_unknowns'],'Replaceability and unknowns')
        check(set(r['reference_ids']) <= sources,'Unresolved references: '+r['id'])
        for field in ['placement_confidence','architecture_confidence','environment_confidence','terrain_confidence']:
            check(field in r, 'Missing dimension '+field)
    routes=read('systems/data/campus_showcase_v4.json')
    check(len(routes)>=13 and all(r['continuous'] for r in routes),'Continuous showcase')
    for o in buildings:
        check(o['id'] in records,'Building omitted: '+o['id'])
    check(len(read('references/exterior_v4/building_coverage.json'))==44,'Reference coverage')
    check(len(read('systems/data/campus_surface_profiles_v4.json')['road_profiles'])==5,'Road profiles')
    check(len(read('systems/data/campus_surface_profiles_v4.json')['walkway_profiles'])==7,'Walk profiles')
    cache=ROOT/'world/campus_exterior/generated/CampusExteriorBaked.scn'
    manifest=read('world/campus_exterior/generated/manifest.json')
    check(cache.stat().st_size<10_000_000,'Cache size budget')
    check(hashlib.sha256(cache.read_bytes()).hexdigest()==manifest['scene_sha256'],'Cache integrity')
    # Source hashes normalize CRLF for Windows/Linux clone portability.
    paths=sorted(['res://world/campus_exterior/'+p.name for p in (ROOT/'world/campus_exterior').glob('*.gd')]+
                 ['res://systems/data/'+n for n in ['campus_masterplan.json','campus_paths.json','building_architecture_profiles.json','campus_exterior_environment_v4.json','campus_terrain_grid_v4.json']])
    fingerprint=''.join(p+hashlib.sha256((ROOT/p.removeprefix('res://')).read_bytes().replace(b'\r\n',b'\n')).hexdigest() for p in paths)
    check(hashlib.sha256(fingerprint.encode()).hexdigest()==manifest['fingerprint'],'Stale baked scene')
    # Metadata map is intentionally NOT a surveyed map or a screenshot of real campus.
    svg=['<svg xmlns="http://www.w3.org/2000/svg" viewBox="-230 -320 1600 1500">',
         '<rect x="-230" y="-320" width="1600" height="1500" fill="#f4f2e9"/>',
         '<text x="-180" y="-260" font-size="24">V4 置信概览：形态支持 / 推定 / 占位（非测绘图）</text>']
    for o in master['objects']:
        if o['id'] not in records: continue
        r=records[o['id']];color={'SUPPORTED':'#6cbb92','INFERRED':'#d2ad64','PLACEHOLDER':'#d47a69'}[r['current_confidence']]
        x,_,z=o['center'];w=o['footprint_width'];d=o['footprint_depth']
        svg.append(f'<rect x="{x-w/2}" y="{z-d/2}" width="{w}" height="{d}" fill="{color}" stroke="#666"><title>{html.escape(o["name_zh"]+": "+r["remaining_unknowns"])}</title></rect>')
    for road in read('systems/data/campus_exterior_environment_v4.json')['routes']:
        points=' '.join(f'{p[0]},{p[2]}' for p in road['geometry'])
        svg.append(f'<polyline points="{points}" fill="none" stroke="#987b41" stroke-width="{road["width"]}" opacity=".65"/>')
    svg.append('</svg>')
    (ROOT/'docs/CAMPUS_ACCURACY_V4.svg').write_text('\n'.join(svg),encoding='utf-8')
    report=dict(checks=count,failures=0,buildings=44,accuracy_records=len(records),cache_bytes=cache.stat().st_size,
                frozen_files=len(frozen['source_sha256']),evidence='data/source audit; appearance requires rendered review')
    (ROOT/'tests/artifacts/v4_data_qa.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
    print('V4_DATA_QA',report)
    return report

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--bake',action='store_true');parser.add_argument('--walk',action='store_true');args=parser.parse_args()
    if args.bake:engine(['res://world/campus_exterior/CampusExterior.tscn','--','--v4-authoring','--v4-bake'],'v4_bake_rendered',180)
    audit()
    if args.walk:engine(['--fixed-fps','60','res://world/campus_exterior/CampusExterior.tscn','--','--v4-capture','--v4-walk'],'v4_rendered_walk',600)
