"""Actual same-runtime timeout/rejection probes; requires one completed mock run as a config template."""
import copy
import json
from pathlib import Path
import subprocess
import sys
import uuid
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'benchmark'))
from run_benchmark import read,write,find_godot

template=read(Path(sys.argv[1])/'job.json')
godot,_=find_godot()
output=ROOT/'tests/artifacts'/('rc1-failure-'+uuid.uuid4().hex[:8]);output.mkdir()
cases=[('step_limit',{'max_steps':1},None,'step_limit'),('simulation_timeout',{'max_simulated_duration':2},None,'simulation_timeout'),('unavailable_action',{},[{'type':'board','shuttle_id':'prototype_shuttle_01'}],'provider_action_failure'),('missing_visit',{'required_visits':['FairyLake_Viewpoint_01']},[{'type':'navigate','target':'LowerCampus_Event_Area'},{'type':'inspect','target':'LowerCampus_Event_Area'}],'required_visit_missing')]
checks=0
for name,change,actions,expected in cases:
    job=copy.deepcopy(template);job['task'].update(change)
    folder=output/name;folder.mkdir();job['output_dir']=str(folder);job['run_id']=name
    if actions is not None:
        job.update(provider='replay',replay_actions=actions,replay_plan=[])
        job['run_config']['evidence_kind']='replay'
    write(folder/'job.json',job)
    with (folder/'engine.log').open('w',encoding='utf8') as log:
        p=subprocess.run([godot,'--headless','--path',str(ROOT),'--fixed-fps','60','--','--journey-job='+str(folder/'job.json')],stdout=log,stderr=subprocess.STDOUT,timeout=120)
    assert p.returncode==0,name;checks+=1
    result=read(folder/'result.json')
    assert result['success'] is False and result['failure_reason']==expected,(name,result);checks+=1
    assert (folder/'trajectory.jsonl').stat().st_size>0;checks+=1
    assert result['timeout']==(name in ['step_limit','simulation_timeout']);checks+=1
print('RC1 FAILURE QA '+json.dumps({'checks':checks,'failures':[]}))
