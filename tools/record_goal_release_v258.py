import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def read(p):return json.loads((ROOT/p).read_text(encoding='utf-8-sig'))
def write(p,j):(ROOT/p).write_text(json.dumps(j,ensure_ascii=False,indent=2)+'\n',encoding='utf-8',newline='\n')
r=read('docs/releases/v2.1.11-published.json');assert r['local_switch']!='pending'
write('docs/releases/v2.1.11-published.json',r)
next_action='V259 resume clock-end crossroad to Research side grounds from V170-V173/V206. V258 goal-agent user request implemented and published; preserve contract and explicit unreachable failures. Continue full A-G, unknown C-D/grey/032/301; first new model edit becomes2.1.12-dev.'
j=read('releases/latest.json');assert j['version']=='2.1.10'
j.update(version='2.1.11',tag='v2.1.11',model='official-visual-build-257-daoyuan-connections',status='published_verified',local_executable='builds/releases/v2.1.11/Windows/runtime/CUHKSZ-MicroWorld.exe',entries=['player','goal-agent'],next_iteration=next_action,source_commit=r['source_commit'],url=r['url'],build_receipt='docs/releases/v2.1.11-build.json',publication_receipt='docs/releases/v2.1.11-published.json')
write('releases/latest.json',j)
c=read('docs/lower_campus_refinement_coverage.json')
c.update(updated='2026-10-16',previous_turn_classification='V258_user_priority_goal_agent_implemented_published',next_action=next_action)
c['active_stage_goal'].update(stable_release='v2.1.11',development='2.1.11 published;2.1.12-dev on first V259 model change',transition_kind='V258_selectable_physical_goal_agent_published')
review={'version':'V258','document':'docs/GOAL_AGENT_V258.md','evidence':'docs/releases/v2.1.11-validation.json','status':'stage_published_full_A_G_incomplete','source_checks':27,'export_checks':45,'selectable_goals':116,'all_goal_pairs_verified':False,'policy':'local_rule','npc_transport_migration':False,'publication_receipt':'docs/releases/v2.1.11-published.json'}
c['in_progress_review']=review;c['goal_agent_v258']=review.copy()
c['explicit_requirements'].append({'id':'selectable_goal_driven_agent','source':'user2026-10-16','scope':'User selects target; shared player physics and world interaction contract; no task teleport or false success','status':'implemented_local_rule_with_explicit_unavailable_actions','evidence':'docs/GOAL_AGENT_V258.md','remaining':'all origin-target combinations and unmigrated NPC/transport interactions remain outside verified scope'})
c['release_convergence']['previous_cycle_v2_1_10']={k:c['release_convergence'][k] for k in ['candidate','published_release']}
c['release_convergence'].update(status='v2.1.11_published_verified_full_goal_active',published_release=r)
c['release_convergence']['candidate']={'product_version':'2.1.11','model_version':j['model'],'doc':'docs/GOAL_AGENT_V258.md','published':True,'windows_export_verified':True,'windows_package':'builds/releases/v2.1.11/Windows/runtime','validation':'docs/releases/v2.1.11-validation.json','full_campus_route_accepted':False}
c['release_convergence']['development'].update(product_version='2.1.11',published=True,stable_release='v2.1.11',next_version='2.1.12-dev on first V259 model change')
c['release_pipeline'].update(current_stage='resume_deep_refinement_V259',stable_release='v2.1.11',development_version='2.1.11')
c['release_pipeline']['stage_status'].update(player_experience_and_agent_showcase='V258 selectable physical goal Agent;27source checks,optional30chapter tour retained',formal_packaging_github_local_sync='v2.1.11 passed45exportchecks2native2images257sources2remotedigests2localentries',resume_deep_refinement='V259 Research side grounds;fullA-G')
write('docs/lower_campus_refinement_coverage.json',c)
header='''## V258 用户优先项已发布：目标式 Agent / v2.1.11（2026-10-16）

第二入口改为目标选择：116个地点/公共空间，本地规则Agent依照观察、合法动作、物理执行及反馈工作。可到达并观察或继续探索附近两处，支持改目标/暂停/停止；遇阻重规划，失败不传送、不虚报成功。原30章编排导览保留为内部选项。未接入的NPC/交通不宣称可用。27项源码检查、45项导出检查、两次原生入口及两张导出图通过，257构建源码与tag和两个远端附件校验一致，本地双入口已切换。见 [行为边界](GOAL_AGENT_V258.md) 与 [发布收据](releases/v2.1.11-published.json)。v2.1.10及更早固定包保留。

用户新需求插入前，科研楼侧场地尚未改模。下一批V259接回钟楼端横路—科研楼侧场地，先读V170–V173/V206证据；首次模型修改转2.1.12-dev。保留V257模型和V258行为接口。全部目标对、未迁移事件、隐藏后翼、C–D/灰梯/032/301及整园A–G仍未全验收；东门原点/未知真北不变。Goal继续active，本轮无运行检查进程。

'''
for name in ['NEXT_STAGE_GOAL_V243.md','LOWER_CAMPUS_ACTIVE_GOAL.md','NEXT_ITERATION_HANDOFF.md','CURRENT_STAGE_GATE.md']:
 p=ROOT/'docs'/name;s=p.read_text(encoding='utf-8');first,rest=s.split('\n',1)
 p.write_text(first+'\n\n'+header+rest.lstrip('\n'),encoding='utf-8',newline='\n')
print('V258 publication and V259 continuation recorded.')
