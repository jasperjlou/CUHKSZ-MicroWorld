"""Audit a completed mock batch against fixture expectations and information boundaries."""
import argparse
import json
from pathlib import Path
from run_benchmark import read, load_tasks

def verify(root):
    root=Path(root);manifest,tasks=load_tasks('journey-v1');checks=0;failures=[]
    def check(ok,label):
        nonlocal checks
        checks+=1
        if not ok: failures.append(label)
    batch=read(root/'batch.json')
    check(batch['completed_episodes']==batch['requested_episodes'],'complete batch')
    results=list(root.glob('*/result.json'))
    check(len(results)==batch['completed_episodes'],'result count')
    for path in results:
        r=read(path);name=r['run_id'];job=read(path.parent/'job.json')
        check(r['success']==manifest['fixture_expectations'][r['task_id']]['success'],name+' fixture verdict')
        check(r['invalid_actions']==0,name+' valid actions')
        check(r['environment_version']=='v1.0.0-rc1' and r['baseline_commit']=='71fe452',name+' version')
        check(all(r[k] is None for k in ['prompt_tokens','completion_tokens','total_tokens','latency_ms']),name+' mock usage null')
        records=[json.loads(s) for s in (path.parent/'trajectory.jsonl').read_text(encoding='utf8').splitlines()]
        check(records[-1]['kind']=='verdict',name+' terminal receipt')
        for step in [s for s in records if s['kind']=='step' and s['actor']=='agent']:
            context=step['provider_context']['payload'];o=context['observation']
            check(step['action'] in step['legal_actions'],name+' action membership')
            check(('history' in context)==(r['condition']!='Reactive'),name+' history boundary')
            check(('plan' in context)==(r['condition']=='PlanHistory'),name+' plan boundary')
            check(len(context.get('history',[]))<=job['history_steps'],name+' bounded history')
            check(not set(o)&{'verifier','setup_actions','correct_route','best_branch','shortest_path','task_result','visited_zones'},name+' leakage')
        if r['task_id'].startswith('recovery_'):
            check(r['wrong_branch_count']==1 and r['replanning_count']==1,name+' detour metrics')
        if r['task_id']=='transport_shuttle':
            check(r['shuttle_used'],name+' ride')
        if r['task_id'] in ('transport_abandon','transport_missed'):
            check(not r['shuttle_used'] and r['replanning_count']==1,name+' transport replan')
        if r['task_id']=='time_on_time':check(r['event_state']=='on_time',name+' on time')
        if r['task_id']=='time_late_allowed':check(r['event_state']=='late' and r['success'],name+' accepted late')
    summary=read(root/'summary.json')
    check(not summary['real_model_results'],'mock not real research')
    check('Pipeline validation only' in (root/'report.md').read_text(encoding='utf8'),'report caveat')
    receipt={'checks':checks,'failures':failures}
    print('RC1 BATCH AUDIT '+json.dumps(receipt))
    (root/'audit.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf8')
    return not failures

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('directory');args=p.parse_args();raise SystemExit(0 if verify(args.directory) else 1)
