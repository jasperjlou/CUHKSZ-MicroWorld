"""V2 coverage, immutable masterplan/RC1 checks and bounded rendering driver."""
import argparse
import hashlib
import json
from pathlib import Path
from check_campus_masterplan import audit, engine, ROOT


def architecture_audit():
    audit()
    master = json.loads((ROOT/'systems/data/campus_masterplan.json').read_text(encoding='utf-8'))
    frozen = json.loads((ROOT/'systems/data/campus_masterplan_v1_frozen.json').read_text(encoding='utf-8'))
    profiles = json.loads((ROOT/'systems/data/building_architecture_profiles.json').read_text(encoding='utf-8'))
    data = (ROOT/'systems/data/campus_masterplan.json').read_bytes().replace(b'\r\n',b'\n')
    assert hashlib.sha256(data).hexdigest() == frozen['masterplan_sha256'], 'V1 database changed'
    ids = {o['id'] for o in master['objects'] if o['category']=='building'}
    assert len(ids)==44 and {p['id'] for p in profiles['buildings']}==ids
    assert len(profiles['buildings'])==44
    for p in profiles['buildings']:
        assert p['current_stage'] in ('LANDMARK','ARCHITECTURAL_SHELL','PLACEHOLDER_UNRESOLVED')
        assert p['architecture_confidence'] in ('STRONG_REFERENCE','SUPPORTED','APPROXIMATED','PLACEHOLDER')
        assert p['replaceable'] and p['inference_basis'] and p['unresolved']
        assert all(r in profiles['sources'] for r in p['reference_ids'])
        if p['tier']=='A': assert (ROOT/'references/architecture'/(p['id']+'.json')).exists()
    print('ARCHITECTURE_DATA_QA: 44 profiles; frozen V1 and RC1 sources intact')


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--render',action='store_true');parser.add_argument('--rc1',action='store_true')
    opts=parser.parse_args();architecture_audit()
    engine(['--headless','--editor','--import','--quit'],'architecture_import',120)
    scene=['res://world/campus_master/CampusMaster.tscn','--','--architecture-capture']
    if opts.render:
        engine(scene+['--architecture-baseline'],'architecture_baseline',120)
        engine(['--fixed-fps','60']+scene+['--architecture-walk'],'architecture_acceptance',240)
        # Separate uncapped timing pass; fixed timestep traversal is NOT an FPS benchmark.
        engine(scene,'architecture_performance',120)
    if opts.rc1:engine(['--headless','--fixed-fps','60','--','--qa'],'architecture_rc1_core',180)
