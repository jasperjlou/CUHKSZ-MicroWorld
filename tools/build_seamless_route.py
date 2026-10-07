"""Build a continuous route on frozen V4 pedestrian lines, never across buildings."""
from pathlib import Path
import json,math,heapq
ROOT=Path(__file__).resolve().parents[1]
def read(path): return json.loads((ROOT/path).read_text(encoding="utf-8"))
def main():
 env=read("systems/data/campus_exterior_environment_v4.json")
 data=read("systems/data/campus_interiors.json")
 buildings={o["id"]:o for o in read("systems/data/campus_masterplan.json")["objects"]}
 entries={r["building_id"]:r for r in env["entrance_connections"]}
 nodes={};graph={}
 def key(p):return tuple(round(float(v),3) for v in p)
 def edge(a,b):
  a,b=key(a),key(b);nodes[a]=a;nodes[b]=b
  distance=math.dist(a,b);graph.setdefault(a,{})[b]=distance;graph.setdefault(b,{})[a]=distance
 def project(p,a,b):
  dx,dz=b[0]-a[0],b[2]-a[2];den=dx*dx+dz*dz
  t=max(0,min(1,((p[0]-a[0])*dx+(p[2]-a[2])*dz)/den)) if den else 0
  return t,[a[i]+(b[i]-a[i])*t for i in range(3)]
 anchors=[entries[d["building_id"]]["geometry"][-1] for d in data]
 # Existing V4 route vertices also supply established split anchors.
 old=read("systems/data/campus_showcase_v4.json")
 for r in old:anchors.extend(r["points"])
 start=next(n["position"] for n in read("systems/data/campus_paths.json")["nodes"] if n["id"]=="upper_central")
 anchors.append(start)
 for r in env["routes"]:
  if r["category"]!="pedestrian":continue
  for a,b in zip(r["geometry"],r["geometry"][1:]):
   points=[(0,a),(1,b)]
   for p in anchors:
    t,q=project(p,a,b)
    if math.dist([p[0],p[2]],[q[0],q[2]])<.02:points.append((t,q));edge(p,q)
   points.sort(key=lambda x:x[0])
   for (_,a1),(_,b1) in zip(points,points[1:]):edge(a1,b1)
 # Established V4 paths are already physically verified; retain exact authored waypoints.
 for r in old:
  for a,b in zip(r["points"],r["points"][1:]):edge(a,b)
 for r in entries.values():
  for a,b in zip(r["geometry"],r["geometry"][1:]):edge(a,b)
 def shortest(a,b):
  a,b=key(a),key(b);heap=[(0,a)];cost={a:0};parent={}
  while heap:
   distance,n=heapq.heappop(heap)
   if n==b:break
   if distance!=cost[n]:continue
   for nxt,w in graph.get(n,{}).items():
    c=distance+w
    if c<cost.get(nxt,float("inf")):cost[nxt]=c;parent[nxt]=n;heapq.heappush(heap,(c,nxt))
  assert b in cost,(a,b)
  result=[b]
  while result[-1]!=a:result.append(parent[result[-1]])
  return [list(p) for p in reversed(result)]
 sequence=["ling","muse","lake_pavilion","lake_stone","music","sports_hall","library","student_centre","administration","conference","teaching_a","shaw_east"]
 landmark={r["landmark_id"]:r for r in env["landmark_connections"]}
 current=start;result=[]
 for id in sequence:
  record=entries.get(id,landmark.get(id));target=record["geometry"][0]
  points=shortest(current,target)
  result.append({"destination":id,"points":points,"confidence":"inferred","continuous":True})
  # Interior side visit returns to its front; next route first retraces threshold/approach.
  if id in entries:
   d=next((d for d in data if d["building_id"]==id),None)
   current=target
   if d:
    o=buildings[id];out=[o["center"][0],o["center"][1],o["center"][2]+d["center_local"][2]+d["depth"]/2+4]
    edge(current,out);current=out
  else:current=target
 (ROOT/"systems/data/campus_showcase_v5.json").write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding="utf-8")
 print("V5 continuous destinations:",len(result),"waypoints:",sum(len(r["points"]) for r in result))
if __name__=="__main__":main()
