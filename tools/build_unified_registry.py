"""Derive navigation from frozen V5 geometry; no map edits or route teleports."""
from pathlib import Path
import json, math, hashlib
ROOT=Path(__file__).resolve().parents[1]
def read(p): return json.loads((ROOT/p).read_text(encoding='utf-8'))
def write(p,v): (ROOT/p).write_text(json.dumps(v,ensure_ascii=False,indent=2),encoding='utf-8')
def main():
 master=read('systems/data/campus_masterplan.json'); defs=read('systems/data/campus_interiors.json')
 env=read('systems/data/campus_exterior_environment_v4.json'); paths=read('systems/data/campus_paths.json')
 objects={o['id']:o for o in master['objects']}; entries={d['building_id']:d for d in env['entrance_connections']}
 points=[]; edges=set(); lookup={}; locations=[]
 def node(p):
  k=tuple(round(float(x),3) for x in p)
  if k not in lookup: lookup[k]=len(points); points.append(list(k))
  return lookup[k]
 def edge(a,b):
  a,b=node(a),node(b)
  if a!=b: edges.add(tuple(sorted((a,b))))
 def loc(id,name,p,type='outdoor',region='',parent='campus',building='',floor='',accessible=True):
  locations.append(dict(id=id,display_name_zh=name,display_name_en=id.replace('_',' '),type=type,region=region,building_id=building,floor_id=floor,parent=parent,world_anchor=node(p),connections=[],human_accessible=accessible,agent_accessible=accessible,reference_confidence='inferred',navigation_confidence='physical_route_pending'))
 old=read('systems/data/campus_showcase_v4.json')
 anchors=[p for r in old for p in r['points']]+[n['position'] for n in paths['nodes']]+[r['geometry'][-1] for r in entries.values()]
 def project(p,a,b):
  dx,dz=b[0]-a[0],b[2]-a[2]; den=dx*dx+dz*dz
  t=max(0,min(1,((p[0]-a[0])*dx+(p[2]-a[2])*dz)/den)) if den else 0
  return t,[a[i]+(b[i]-a[i])*t for i in range(3)]
 for r in env['routes']:
  if r['category']!='pedestrian': continue
  for a,b in zip(r['geometry'],r['geometry'][1:]):
   split=[(0,a),(1,b)]
   for p in anchors:
    t,q=project(p,a,b)
    if math.hypot(p[0]-q[0],p[2]-q[2])<.02: split.append((t,q)); edge(p,q)
   split.sort(key=lambda x:x[0])
   for (_,x),(_,y) in zip(split,split[1:]): edge(x,y)
 for r in old+list(entries.values())+env['landmark_connections']:
  ps=r.get('points',r.get('geometry'))
  for a,b in zip(ps,ps[1:]): edge(a,b)
 for n in paths['nodes']:
  # Registry only exposes physically connected public anchors, not a shortcut map.
  if tuple(round(float(x),3) for x in n['position']) in lookup: loc(n['id'],{'upper_central':'上园中央步道','upper_west':'上园西侧步道','upper_east':'上园东侧步道','upper_north':'上园北侧步道','lake_east':'神仙湖东岸','lake_south':'神仙湖南岸','lake_junction':'湖口岔路'}.get(n['id'],'校园步行节点'),n['position'],region=('upper' if n['position'][2]<130 and n['position'][0]>220 else 'lower' if n['position'][2]>510 else 'fairy_lake' if n['position'][0]<220 and n['position'][2]<230 else 'middle'))
 for r in env['landmark_connections']:
  id=r['landmark_id']; loc(id,objects[id]['name_zh'],r['geometry'][0],region=objects[id]['region'])
 for d in defs:
  id=d['building_id']; o=objects[id]; cz=d['center_local'][2]; front=cz+d['depth']/2
  def world(p): return [o['center'][i]+p[i] for i in range(3)]
  approach=world(d['approach_local']); entrance=world([0,0,front]); lobby=world([0,0,cz]); deep=world([0,0,cz-10])
  chain=[entries[id]['geometry'][0],approach,world([0,0,front+2]),world([0,0,front-3]),lobby,deep]
  for a,b in zip(chain,chain[1:]): edge(a,b)
  loc(id,o['name_zh'],approach,'building',o['region'],o['region'],id)
  loc(id+'_main_entrance',o['name_zh']+'入口',entrance,'entrance',o['region'],id,id);edge(chain[2],entrance);edge(entrance,chain[3])
  loc(id+'_exit_main',o['name_zh']+'室外出口',approach,'exit',o['region'],id,id)
  loc(id+'_floor_0',o['name_zh']+'公共首层',lobby,'floor',o['region'],id,id,id+'_floor_0')
  loc(d['interior_id'],o['name_zh']+'公共区',lobby,'zone',o['region'],id+'_floor_0',id,id+'_floor_0')
  for j,room in enumerate(d['rooms']):
   p=lobby if j==0 else deep
   if room=='teaching_a_classroom_101':
    route=[world([0,0,cz+1]),world([-7,0,cz+1]),world([-7,0,cz-9])]
    edge(lobby,route[0])
    for a,b in zip(route,route[1:]):edge(a,b)
    p=route[-1]
   loc(room,{'library_reading':'图书馆阅览区','teaching_a_classroom_101':'教学楼A教室101','ling_high_table_prototype':'高桌晚宴演示区'}.get(room,o['name_zh']+('大厅' if j==0 else '公共活动区')),p,'room',o['region'],d['interior_id'],id,id+'_floor_0')
  if 'upper_slice' in d:
   x=d['width']/2-4; route=[lobby,world([0,0,cz+7]),world([x,0,cz+7]),world([x,5,cz-12]),world([0,5,cz-12])]
   for a,b in zip(route,route[1:]):edge(a,b)
   loc(id+'_stair_1',o['name_zh']+'公共楼梯',route[2],'stair',o['region'],id+'_floor_0',id,id+'_floor_0')
   loc(id+'_floor_1',o['name_zh']+'公共上层',route[-1],'floor',o['region'],id,id,id+'_floor_1')
   loc(id+'_upper_platform',o['name_zh']+'公共平台',route[-1],'room',o['region'],id+'_floor_1',id,id+'_floor_1')
 # Public photo and teacher interaction anchors use the actual V5 Ling actor coordinates.
 d=defs[0];o=objects['ling'];front=d['center_local'][2]+d['depth']/2
 for id,x,name in [('photo_student',7,'拍照同学'),('teacher_01',-5,'老师')]:
  p=[o['center'][0]+x,o['center'][1],o['center'][2]+front+7]
  edge([o['center'][0],o['center'][1],o['center'][2]+front+7],p)
  edge([o['center'][0],o['center'][1],o['center'][2]+front+7],entries['ling']['geometry'][0])
  loc(id,name,p,'interaction',o['region'],'ling','ling')
 for l in locations:
  l['connections']=[x['id'] for x in locations if x['id']!=l['id'] and (x['world_anchor']==l['world_anchor'] or tuple(sorted((x['world_anchor'],l['world_anchor']))) in edges)]
 hierarchy=[dict(id='campus',display_name_zh='港中深校园',type='campus',parent='')]+[dict(id=r['id'],display_name_zh=r.get('name_zh',r['id']),type='region',parent='campus') for r in master['regions']]
 for o in master['objects']:
  if o['category']=='building' and o['id'] not in {d['building_id'] for d in defs}:
   hierarchy.append(dict(id=o['id'],display_name_zh=o['name_zh'],type='building',parent=o['region'],human_accessible=False,agent_accessible=False,reference_confidence=o['confidence'],source_anchor=o['id']))
 write('systems/data/campus_locations_v6.json',dict(transport_stops=[dict(id=s['id'],region=s['region'],position=s['position'],confidence='placeholder',status='TRANSPORT_ABSTRACTION_UNAVAILABLE',boardable=False) for s in env['stops']],schema_version=6,hierarchy=hierarchy,locations=locations,points=points,edges=sorted(edges),coordinate_source='Frozen V5; game units, not surveyed',transport_status='UNAVAILABLE_IN_V6: visual placeholder stops only'))
 tasks=[]
 def task(id,name,start,goals,deadline=10000,event=''):
  tasks.append(dict(id=id,name=name,description=name,start=start,goals=goals,deadline_seconds=deadline,event=event))
 task('upper_lake','从上园走到神仙湖','upper_central',['lake_pavilion'])
 task('upper_library','从上园前往图书馆','upper_central',['library_lobby'])
 task('reading','前往图书馆阅览区','library',['library_reading'])
 task('library_student','离开图书馆前往学生中心','library_lobby',['library_exit_main','student_centre_lobby'])
 for id in ['ling','muse','music','sports_hall','administration','conference','shaw_east']:
  room=next(d for d in defs if d['building_id']==id)['rooms'][-1]
  task(id+'_visit',objects[id]['name_zh']+'参观并离开',id,[room,id+'_exit_main'])
 task('classroom','参观教室101并前往逸夫','teaching_a',['teaching_a_classroom_101','teaching_a_exit_main','shaw_east_lobby'])
 task('library_stairs','图书馆登楼并离开','library',['library_upper_platform','library_exit_main'])
 task('ordered_lower','依次参观下园公共空间','library',['library_lobby','library_exit_main','student_centre_lobby','student_centre_exit_main','administration_lobby'])
 task('photo_event','帮同学拍照后赴高桌晚宴','ling',['photo_student','ling_high_table_prototype'],300,'helped_student')
 tasks[-1]['required_flags']=['helped_student','high_table_signed_in']
 task('reverse','从下园经神仙湖返回上园','shaw_east',['library_lobby','library_exit_main','lake_pavilion','ling_lobby','ling_exit_main','upper_central'])
 write('systems/data/campus_tasks_v6.json',tasks)
 frozen={}
 for folder in ['world/campus_seamless','world/campus_exterior']:
  for f in (ROOT/folder).rglob('*'):
   if f.is_file() and f.suffix in ['.gd','.tscn','.scn','.json']: frozen[f.relative_to(ROOT).as_posix()]=hashlib.sha256(f.read_bytes().replace(b'\r\n',b'\n') if f.suffix!='.scn' else f.read_bytes()).hexdigest()
 write('systems/data/campus_v5_frozen_v6.json',dict(head='af907bcc3926fc1330a2e29a224e8547e9906682',files=frozen,geometry_fixes=[]))
 print(len(locations),'locations',len(points),'points',len(edges),'edges',len(tasks),'tasks')
if __name__=='__main__':main()
