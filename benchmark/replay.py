"""Replay recorded legal actions through the same physics API, offline, without a model."""
import argparse
import json
from pathlib import Path
import subprocess
import uuid
from run_benchmark import ROOT, read, write, find_godot, digest, source_fingerprint

def replay(folder, godot=None):
    folder=Path(folder).resolve()
    original=read(folder/'result.json')
    job=read(folder/'job.json')
    if original['environment_sha256'] != digest(ROOT/'systems/data/environment_release.json'):
        raise ValueError('Environment declaration differs; refusing comparison replay')
    if job['run_config'].get('source_tree_sha256') not in (None,source_fingerprint()):
        raise ValueError('Runtime source differs from recorded run; use its exact checkout')
    rows=[json.loads(line) for line in (folder/'trajectory.jsonl').read_text(encoding='utf8').splitlines()]
    actions=[r['action'] for r in rows if r['kind']=='step' and r['actor']=='agent' and r['action']]
    plan=next((r['plan'] for r in rows if r['kind']=='plan'),[])
    target=ROOT/'benchmark/results'/('replay-'+uuid.uuid4().hex[:10])/job['run_id']
    target.mkdir(parents=True)
    job.update(provider='replay',model='recorded-actions',output_dir=str(target),replay_actions=actions,replay_plan=plan)
    job['run_config'].update(provider='replay',model='recorded-actions',evidence_kind='replay')
    write(target/'job.json',job)
    executable,_=find_godot(godot)
    with (target/'engine.log').open('w',encoding='utf8') as log:
        p=subprocess.run([executable,'--headless','--path',str(ROOT),'--fixed-fps','60','--','--journey-job='+str(target/'job.json')],stdout=log,stderr=subprocess.STDOUT,timeout=job['episode_wall_timeout'])
    if p.returncode or not (target/'result.json').exists():
        raise ValueError('Replay failed; inspect local engine.log')
    result=read(target/'result.json')
    fields=['success','failure_reason','event_state','wrong_branch_count','replanning_count','shuttle_used','action_count']
    differences={k:[original[k],result[k]] for k in fields if original[k]!=result[k]}
    if abs(original['path_length']-result['path_length'])>0.1:
        differences['path_length']=[original['path_length'],result['path_length']]
    receipt={'mode':'action replay, not saved-frame playback','compared_fields':fields+['path_length'],'differences':differences,'output':str(target)}
    write(target/'replay-comparison.json',receipt)
    print(json.dumps(receipt,ensure_ascii=False))
    return not differences

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('run_directory');parser.add_argument('--godot');a=parser.parse_args()
    raise SystemExit(0 if replay(a.run_directory,a.godot) else 1)
