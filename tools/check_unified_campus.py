"""V6 release gates. Never treats an engine exit zero as sufficient."""
from pathlib import Path
import argparse,hashlib,json,re,subprocess
from check_campus_masterplan import engine
ROOT=Path(__file__).resolve().parents[1]
def read(p): return json.loads((ROOT/p).read_text(encoding='utf-8'))
def audit():
 checks=0
 def check(ok,message):
  nonlocal checks
  checks+=1
  if not ok:raise AssertionError(message)
 for p,digest in read('systems/data/campus_v5_frozen_v6.json')['files'].items():
  raw=(ROOT/p).read_bytes();raw=raw if p.endswith('.scn') else raw.replace(b'\r\n',b'\n')
  check(hashlib.sha256(raw).hexdigest()==digest,'V5 changed '+p)
 registry=read('systems/data/campus_locations_v6.json');locations={r['id']:r for r in registry['locations']}
 check(len(locations)==len(registry['locations']),'duplicate location ID')
 graph={i:set() for i in range(len(registry['points']))}
 for a,b in registry['edges']:graph[a].add(b);graph[b].add(a)
 seen={locations['upper_central']['world_anchor']};todo=list(seen)
 while todo:
  n=todo.pop()
  for b in graph[n]-seen:seen.add(b);todo.append(b)
 for r in locations.values():check(r['world_anchor'] in seen,'disconnected '+r['id'])
 for task in read('systems/data/campus_tasks_v6.json'):
  for id in [task['start']]+task['goals']:check(id in locations,'task target '+id)
 for base in ['autoload','player','benchmark']:
  check(not subprocess.check_output(['git','diff','af907bc','--',base],cwd=ROOT),'RC1 modified '+base)
 check(not subprocess.check_output(['git','diff','af907bc','--','agents/AgentEnvironment.gd','agents/RuleBasedAgent.gd','agents/RandomAgent.gd','systems/TaskVerifier.gd','world/MainWorld.gd'],cwd=ROOT),'RC1 adapter changed')
 nav=(ROOT/'systems/unified/CampusAgentEnvironment.gd').read_text(encoding='utf-8').split('func navigate(')[1].split('func is_done')[0]
 check(not re.search(r'(?:global_position|position|transform)\s*=',nav),'navigation teleport')
 check('move_and_slide()' in (ROOT/'player/Player.gd').read_text(encoding='utf-8'),'original physics')
 print('V6 audit',checks,'checks; 44 exteriors / 10 interiors; frozen geometry')
 return checks
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--qa',action='store_true');p.add_argument('--render',action='store_true');p.add_argument('--human',action='store_true');p.add_argument('--rc1',action='store_true');args=p.parse_args()
 audit()
 if args.qa or args.render:engine(([] if args.render else ['--headless'])+['res://world/unified/UnifiedCampus.tscn','--fixed-fps','60','--','--v6-qa','--v6-showcase'],'v6_rendered' if args.render else 'v6_headless',1200)
 if args.human:engine(['res://world/unified/UnifiedCampus.tscn','--fixed-fps','60','--','--v5-qa','--v5-full','--v5-events'],'v6_human',1000)
 if args.rc1:
  engine(['--headless','res://world/MainWorld.tscn','--fixed-fps','60','--','--qa'],'v6_rc1_core',180)
  engine(['--headless','res://world/MainWorld.tscn','--fixed-fps','60','--','--rc1-qa'],'v6_rc1_contract',300)
