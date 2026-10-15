"""Record verified remote publication and local entry switch without rebuilding."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
def read(name):
    return json.loads((ROOT / name).read_text(encoding='utf-8-sig'))
def write(name, data):
    (ROOT / name).write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8', newline='\n')

receipt = read('docs/releases/v2.1.10-published.json')
assert receipt['local_switch'] != 'pending' and len(receipt['local_entries']) == 2
write('docs/releases/v2.1.10-published.json', receipt)
next_action = ('V257: inspect adjacent old-library rear/DaoYuan connection evidence and refine confirmed ground, '
               'edge and building interfaces. Start 2.1.11-dev only with next model edit. Preserve fixed v2.1.10, '
               'v2.1.9 and v2.1.7. Full A-G and C-D/grey-stair/032/301 remain incomplete; do not repeat accepted V252-V256.')
latest = read('releases/latest.json')
assert latest['version'] == '2.1.9', 'Publication already recorded or baseline changed; do not duplicate history.'
latest.update(version='2.1.10', tag='v2.1.10', model='official-visual-build-256-old-library-experience',
              local_executable='builds/releases/v2.1.10/Windows/runtime/CUHKSZ-MicroWorld.exe',
              next_iteration=next_action, source_commit=receipt['source_commit'], url=receipt['url'],
              build_receipt='docs/releases/v2.1.10-build.json', publication_receipt='docs/releases/v2.1.10-published.json')
write('releases/latest.json', latest)
ledger = read('docs/lower_campus_refinement_coverage.json')
ledger.update(updated='2026-10-15', status='active', previous_turn_classification='V256_stage_release_verified_full_goal_active', next_action=next_action)
ledger['in_progress_review'].update(status='stage_published_verified_full_campus_incomplete', publication_receipt='docs/releases/v2.1.10-published.json')
ledger['stage_experience_v256'].update(status='stage_published_verified_full_campus_incomplete')
ledger['active_stage_goal'].update(stable_release='v2.1.10', development='2.1.10/V256 published; V257 next model edit becomes 2.1.11-dev', transition_kind='V256_stage_published_resume_refinement')
pipeline = ledger['release_pipeline']
pipeline.update(current_stage='resume_deep_refinement_V257', stable_release='v2.1.10', development_version='2.1.10')
pipeline['stage_status'].update(ground_and_surroundings='V252-V254 old-library brick footway, planted edge and grey court paving',
    player_experience_and_agent_showcase='V256:48 player legs/3358 samples,17 changed Agent legs/2184 samples;29 chapters retained;10 accepted source views',
    formal_packaging_github_local_sync='passed_v2.1.10_44checks_2native_2exportimages_255sources_remote2digests_two_local_entries',
    resume_deep_refinement='V257 adjacent old-library rear/DaoYuan connections, then full A-G')
conv = ledger['release_convergence']
conv['previous_cycle_v2_1_9'] = {k:conv[k] for k in ['candidate', 'published_release']}
conv.update(status='v2.1.10_published_verified_full_goal_active', published_release=receipt, product_entries=['玩家游玩', 'Agent自动展示'])
conv['candidate'] = dict(product_version='2.1.10',model_version=latest['model'],doc='docs/PRODUCT_REVIEW_V256.md',chapters=30,
    effective_agent_legs=358,current_agent_legs=17,current_camera_samples=2184,published=True,windows_export_verified=True,
    windows_package='builds/releases/v2.1.10/Windows/runtime',windows_manifest='builds/releases/v2.1.10/Windows/runtime/build-manifest.json',
    validation='docs/releases/v2.1.10-validation.json',full_campus_route_accepted=False)
conv['development'] = dict(product_version='2.1.10',model_version=latest['model'],stable_not_overwritten=True,published=True,stable_release='v2.1.10',next_version='2.1.11-dev on first V257 model edit')
write('docs/lower_campus_refinement_coverage.json', ledger)
header = '''## V256 阶段已发布：v2.1.10（2026-10-15）

V252–V256旧馆砖路、树带、灰石院落、2026悠悦角及玩家/Agent体验已合入正式v2.1.10。独立导出两模式44检查、两次原生入口启动、两张导出图通过；255个构建源码与tag一致，远端两附件大小/SHA256一致。源码提交 `70bbdaff86b55df490c0006c35c893dce253d89d`。两本地快捷方式已读回新版路径及参数，旧链接备份于 `builds/releases/v2.1.9/entry-backup-before-v2.1.10`，固定v2.1.9/v2.1.7及其他旧包保留。见 [发布收据](releases/v2.1.10-published.json) 与 [体验记录](PRODUCT_REVIEW_V256.md)。

下一批V257从相邻旧馆后侧—道远连接继续，先核对可确认地面、收边和墙体接口，再落模型；首次新模型修改才升2.1.11-dev。复用V252–V256未改证据。旧馆尺度/完整柱网/侧门身份/圆台与展厅、C–D/灰梯/032/301及全A–G仍未完成。东门原点、未知真北与照片年代边界不变，Goal继续active，现有小时续做保留；阶段发布不等于整园验收。下面为保留的历史过程记录。

'''
for name in ['NEXT_STAGE_GOAL_V243.md','LOWER_CAMPUS_ACTIVE_GOAL.md','NEXT_ITERATION_HANDOFF.md','CURRENT_STAGE_GATE.md']:
    p=ROOT/'docs'/name
    text=p.read_text(encoding='utf-8')
    first,rest=text.split('\n',1)
    p.write_text(first+'\n\n'+header+rest.lstrip('\n'),encoding='utf-8',newline='\n')
p=ROOT/'docs/PRODUCT_REVIEW_V256.md'
p.write_text(p.read_text(encoding='utf-8')+'\n发布完成：独立两模式44检查、两次原生启动、两张导出图；255源码/tag及两个远端附件校验通过，本地双入口已切换。见 `docs/releases/v2.1.10-published.json`。后续V257继续相邻旧馆后侧/道远连接，Goal保持active。\n',encoding='utf-8',newline='\n')
print('Publication, latest pointer and four handoffs recorded; full Goal remains active.')
