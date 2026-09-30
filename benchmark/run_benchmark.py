"""Standard-library launcher: one fresh Godot process per episode, no embedded credentials."""
from __future__ import annotations
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time
import uuid

ROOT = Path(__file__).resolve().parents[1]
CONDITIONS = ('Reactive', 'History', 'PlanHistory')

def read(path):
    return json.loads(Path(path).read_text(encoding='utf-8-sig'))

def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def write(path, value):
    Path(path).write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n', encoding='utf8')

def source_fingerprint():
    """Fingerprint relevant source independently of whether the worktree is committed."""
    names=[]
    for directory in ('world','player','systems','agents','autoload','ui','benchmark','tasks'):
        names.extend(p for p in (ROOT/directory).rglob('*') if p.is_file() and p.suffix in ('.gd','.tscn','.gdshader','.json','.py') and not set(p.relative_to(ROOT).parts)&{'results','artifacts','reports','__pycache__'})
    names.append(ROOT/'project.godot')
    h=hashlib.sha256()
    for p in sorted(names):
        h.update(p.relative_to(ROOT).as_posix().encode()+b'\0'+p.read_bytes().replace(b'\r\n',b'\n')+b'\0')
    return h.hexdigest()

def infrastructure_result(job, reason):
    """A killed episode has unknown live metrics; do not turn missing values into zero."""
    result={k:None for k in ('arrival_time','lateness_seconds','action_count','invalid_actions','wrong_branch_count','replanning_count','path_length','walking_time','waiting_time','shuttle_used','transport_mode','visited_zones','prompt_tokens','completion_tokens','total_tokens','latency_ms')}
    result.update({k:job[k] for k in ('run_id','condition','provider','model','seed','suite_version','source_commit','environment_sha256')})
    result.update(task_id=job['task']['task_id'],success=False,failure_reason=reason,event_state='unknown',timeout=True,metrics_complete=False,trajectory_path='trajectory.jsonl',environment_version='v1.0.0-rc1',baseline_commit='71fe452',schema_version='journey-result-v1',evidence_kind=job['run_config']['evidence_kind'])
    return result

def load_tasks(suite):
    if suite != 'journey-v1':
        raise ValueError('Unsupported suite')
    directory = ROOT / 'benchmark/tasks' / suite
    manifest = read(directory / 'suite.json')
    tasks = [read(directory / (name + '.json')) for name in manifest['task_ids']]
    for task in tasks:
        if task['task_id'] not in manifest['task_ids'] or task['suite_version'] != suite:
            raise ValueError('Task identity mismatch')
        if not 1 <= task['max_steps'] <= 40 or not 0 < task['max_simulated_duration'] <= 7200:
            raise ValueError('Task budget out of range')
        if task['event_end'] <= task['event_time'] or not set(task['allowed_transport']) <= {'walk', 'shuttle'}:
            raise ValueError('Invalid task timing or transport')
        if any(key in task for key in ('correct_route', 'best_branch', 'shortest_path')):
            raise ValueError('Hidden solution field in task')
    return manifest, tasks

def find_godot(explicit=None):
    candidate = explicit or os.environ.get('GODOT_BIN') or shutil.which('godot') or shutil.which('godot4')
    if not candidate:
        options = sorted((ROOT / '.tools/godot').glob('*4.5.1*console.exe'))
        candidate = str(options[0]) if options else None
    if not candidate:
        raise ValueError('Install Godot 4.5.1 and set GODOT_BIN or pass --godot')
    version = subprocess.check_output([candidate, '--version'], text=True).strip()
    if not version.startswith('4.5.1.stable'):
        raise ValueError('This suite requires Godot 4.5.1 stable')
    return str(Path(candidate).resolve()), version

def safe_environment(provider):
    env = dict(os.environ)
    if provider == 'openai-compatible':
        from urllib.parse import urlsplit
        base = env.get('AGENT_BASE_URL') or env.get('LLM_BASE_URL', '')
        parsed = urlsplit(base)
        loopback = parsed.hostname in ('localhost', '127.0.0.1', '::1')
        if parsed.username or parsed.password or parsed.query or parsed.fragment or not parsed.hostname:
            raise ValueError('Endpoint must not contain credentials, query or fragment')
        if parsed.scheme != 'https' and not (parsed.scheme == 'http' and loopback):
            raise ValueError('HTTPS is required except for loopback fixtures')
        env['LLM_BASE_URL'] = base
        env['LLM_API_KEY'] = env.get('OPENAI_API_KEY') or env.get('LLM_API_KEY', '')
    return env

def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--provider', choices=['mock', 'openai-compatible'], default='mock')
    parser.add_argument('--config', default='benchmark/configs/rc1-mock.json')
    parser.add_argument('--suite', default='journey-v1')
    parser.add_argument('--tasks', help='Comma separated task ids')
    parser.add_argument('--conditions', help='Comma separated Reactive,History,PlanHistory')
    parser.add_argument('--repeats', type=int)
    parser.add_argument('--model')
    parser.add_argument('--godot')
    parser.add_argument('--rendered', action='store_true')
    parser.add_argument('--allow-network', action='store_true', help='Explicit real-provider opt-in')
    parser.add_argument('--dry-run', action='store_true')
    args = parser.parse_args(argv)
    config = read(ROOT / args.config)
    manifest, tasks = load_tasks(args.suite)
    ids = args.tasks.split(',') if args.tasks else config.get('tasks', manifest['task_ids'])
    if not ids or len(set(ids)) != len(ids) or set(ids) - set(manifest['task_ids']):
        raise ValueError('Unknown, empty or duplicate task selection')
    tasks = [t for t in tasks if t['task_id'] in ids]
    conditions = args.conditions.split(',') if args.conditions else config['conditions']
    repeats = args.repeats if args.repeats is not None else config['repeats']
    if not conditions or len(set(conditions)) != len(conditions) or set(conditions) - set(CONDITIONS) or not 1 <= repeats <= 10:
        raise ValueError('Invalid conditions or repeat count')
    if not (1 <= config['attempts'] <= 2 and 0 <= config['history_steps'] <= 8 and 64 <= config['max_tokens'] <= 1024 and 1 <= config['request_timeout'] <= 120 and 1 <= config['max_calls'] <= 1000):
        raise ValueError('Provider or history budget out of bounds')
    release_path = ROOT / 'systems/data/environment_release.json'
    release = read(release_path)
    for name, expected in release['frozen_files_sha256'].items():
        if hashlib.sha256((ROOT / name).read_bytes().replace(b'\r\n', b'\n')).hexdigest() != expected:
            raise ValueError('Frozen environment hash changed: ' + name)
    model = 'journey-mock-v1' if args.provider == 'mock' else args.model or os.environ.get('AGENT_MODEL') or os.environ.get('LLM_MODEL')
    if not model:
        raise ValueError('Set AGENT_MODEL or pass --model')
    call_ceiling = repeats * sum((t['max_steps'] + (c == 'PlanHistory')) * config['attempts'] for t in tasks for c in conditions)
    budget = min(call_ceiling, config['max_calls'])
    print(json.dumps({'episodes': len(tasks)*len(conditions)*repeats, 'provider':args.provider,'max_model_calls':budget,'max_output_tokens':budget*config['max_tokens'],'note':'Input tokens and monetary cost depend on the model; no price or usage estimate is fabricated.'}))
    if args.dry_run:
        return 0
    if args.provider != 'mock' and not args.allow_network:
        raise ValueError('Real provider requires --allow-network after reviewing --dry-run')
    env = safe_environment(args.provider)
    godot, version = find_godot(args.godot)
    commit = subprocess.check_output(['git','rev-parse','HEAD'], cwd=ROOT, text=True).strip()
    fingerprint = source_fingerprint()
    output = ROOT / 'benchmark/results' / (time.strftime('%Y%m%d-%H%M%S') + '-' + uuid.uuid4().hex[:8])
    output.mkdir(parents=True)
    # Import on fresh clones before booting the runtime; no private tool is required.
    with (output/'import.log').open('w',encoding='utf8') as log:
        proc = subprocess.run([godot,'--headless','--path',str(ROOT),'--editor','--import','--quit'],stdout=log,stderr=subprocess.STDOUT,timeout=120)
    if proc.returncode or 'SCRIPT ERROR' in (output/'import.log').read_text(encoding='utf8'):
        raise ValueError('Godot import failed; inspect local import.log')
    used = 0
    receipts = []
    for task in tasks:
        for condition in conditions:
            for repeat in range(repeats):
                # Reserve the worst-case episode before starting, never overshoot the global budget.
                maximum = (task['max_steps'] + (condition == 'PlanHistory')) * config['attempts']
                if args.provider != 'mock' and used + maximum > budget:
                    print('Call budget exhausted; remaining episodes were not run.')
                    break
                run_id = f"{task['task_id']}--{condition}--{repeat}"
                folder = output/run_id
                folder.mkdir()
                actual = {**config,'conditions':conditions,'repeats':repeats,'suite':args.suite,'provider':args.provider,'model':model,'rendered':args.rendered,'evidence_kind':'mock' if args.provider=='mock' else ('loopback_contract' if __import__('urllib.parse',fromlist=['urlsplit']).urlsplit(env.get('LLM_BASE_URL','')).hostname in ('localhost','127.0.0.1','::1') else 'real_model'),'godot_version':version,'fixed_fps':60}
                job = {**actual,'task':task,'condition':condition,'seed':config['seed']+repeat,'output_dir':str(folder),'run_id':run_id,'suite_version':args.suite,'task_sha256':digest(ROOT/'benchmark/tasks'/args.suite/(task['task_id']+'.json')),'environment_sha256':digest(release_path),'source_commit':commit,'run_config':actual}
                job['run_config']['source_tree_sha256'] = fingerprint
                write(folder/'job.json',job)
                command = [godot,'--path',str(ROOT),'--fixed-fps','60'] + ([] if args.rendered else ['--headless']) + ['--',f'--journey-job={folder / "job.json"}']
                with (folder/'engine.log').open('w',encoding='utf8') as log:
                    try:
                        episode = subprocess.run(command,stdout=log,stderr=subprocess.STDOUT,env=env,timeout=config['episode_wall_timeout'])
                    except subprocess.TimeoutExpired:
                        write(folder/'infrastructure_error.json',{'run_id':run_id,'reason':'wall_timeout','task_id':task['task_id']})
                        write(folder/'result.json',infrastructure_result(job,'wall_timeout'))
                        from report import aggregate
                        aggregate(output)
                        raise ValueError('Episode wall timeout; partial trajectory retained at '+run_id)
                log_text=(folder/'engine.log').read_text(encoding='utf8')
                if episode.returncode or 'JOURNEY BENCHMARK COMPLETE' not in log_text or 'SCRIPT ERROR' in log_text:
                    raise ValueError('Episode execution failed: '+run_id+'; inspect ignored engine.log')
                result=read(folder/'result.json')
                used += result['model_calls']
                receipts.append({'run_id':run_id,'success':result['success'],'failure_reason':result['failure_reason']})
                print(json.dumps(receipts[-1]),flush=True)
    write(output/'batch.json',{'provider':args.provider,'episodes':receipts,'completed_episodes':len(receipts),'requested_episodes':len(tasks)*len(conditions)*repeats,'model_calls':used,'environment_release':release,'source_commit':commit})
    from report import aggregate
    aggregate(output)
    print('BENCHMARK OUTPUT: '+str(output))
    return 0

if __name__ == '__main__':
    try:
        sys.exit(main())
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        # Never echo environment, raw response, or endpoint in the exception output.
        print(type(error).__name__+': '+str(error) if isinstance(error,ValueError) else 'Benchmark infrastructure failure; inspect local outputs.',file=sys.stderr)
        sys.exit(2)
