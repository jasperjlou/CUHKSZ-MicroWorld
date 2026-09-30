"""Aggregate sanitized results; mock and real provider/model groups never mix."""
import argparse
from collections import defaultdict
import json
from pathlib import Path
from statistics import mean

def aggregate(root):
    root=Path(root)
    results=[json.loads(p.read_text(encoding='utf8')) for p in sorted(root.glob('*/result.json'))]
    groups=defaultdict(list)
    identities=set()
    for r in results:
        if r['run_id'] in identities:
            raise ValueError('Duplicate run identity')
        identities.add(r['run_id'])
        groups[(r['provider'],r['model'],r['condition'],r['suite_version'],r['environment_sha256'],r.get('evidence_kind','mock'))].append(r)
    rows=[]
    for (provider,model,condition,suite,environment,evidence),runs in sorted(groups.items()):
        row={'provider':provider,'model':model,'condition':condition,'suite':suite,'environment_sha256':environment,'runs':len(runs),'success_rate':mean(int(r['success']) for r in runs),'evidence_kind':evidence,'interpretation':'pipeline validation only' if evidence!='real_model' else 'model pilot; not generalizable'}
        for key in ['action_count','invalid_actions','wrong_branch_count','replanning_count','lateness_seconds','total_tokens','latency_ms']:
            values=[r[key] for r in runs if r[key] is not None]
            row['avg_'+key]=mean(values) if values else None
            row[key+'_reported_runs']=len(values)
        row['task_coverage']=sorted({r['task_id'] for r in runs})
        rows.append(row)
    summary={'schema_version':'journey-summary-v1','real_model_results':any(r.get('evidence_kind')=='real_model' for r in results),'groups':rows,'total_runs':len(results)}
    (root/'summary.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
    lines=['# Journey benchmark report','', 'Pipeline validation only — no real-model benchmark results.' if not summary['real_model_results'] else 'Real-provider pilot results; inspect task coverage and missing usage metrics before comparison.','', 'Mock successes validate plumbing, not model performance. The impossible missed-event task intentionally has success=false. Failed-task episodes remain in the denominator. Provider errors are not dropped.','', '| Provider / model | Condition | Runs | Success rate | Avg steps | Invalid | Wrong branches | Replans | Lateness (game s) | Tokens | Latency (ms) |','|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|']
    def fmt(v): return 'N/A' if v is None else f'{v:.2f}'
    for r in rows:
        values=[r['provider']+' / '+r['model'],r['condition'],str(r['runs']),fmt(100*r['success_rate'])+'%']+[fmt(r['avg_'+k]) for k in ['action_count','invalid_actions','wrong_branch_count','replanning_count','lateness_seconds','total_tokens','latency_ms']]
        lines.append('| '+' | '.join(values)+' |')
    lines+=['','Averages for tokens/latency use only reported runs; counts and task coverage are in summary.json. Incomplete batches must not be compared as a complete controlled study. Distance uses authored game units, not surveyed metres.']
    (root/'report.md').write_text('\n'.join(lines)+'\n',encoding='utf8')
    return summary

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('directory');args=parser.parse_args();aggregate(args.directory)
