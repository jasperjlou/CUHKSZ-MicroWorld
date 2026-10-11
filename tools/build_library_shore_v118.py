"""Apply the source-related shore/entry-lawn batch; backups retained separately."""
from pathlib import Path
import json
root=Path(__file__).resolve().parents[1]
p=root/'world/visual_campus/LibraryPoolFrontage.gd'
s=p.read_text(encoding='utf-8-sig')
start=s.index('static func cutout(')
end=s.index('static func pavilion(',start)
s=s[:start]+'''const Plan=preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd")
static func outline()->PackedVector2Array:
	# The outer bank retains its fitted site tie; the inner lobe follows V115 fins.
	# This is a photo-informed contour, not a survey of the pond.
	return PackedVector2Array([Vector2(19.5,-332),Vector2(34.5,-332),Vector2(34.5,-326),Vector2(64.7,-326),Vector2(64.7,-323.3),Vector2(56.3,-324.1),Vector2(56.5,-320.3),Vector2(56.1,-313.4),Vector2(54.6,-306.8),Vector2(34.5,-300),Vector2(34.5,-254),Vector2(19.5,-254)])
static func local_outline()->PackedVector2Array:
	var result:=PackedVector2Array()
	for p in outline():result.append(Vector2(p.y+290,78-p.x))
	return result
static func dry_parts(poly:PackedVector2Array)->Array[PackedVector2Array]:
	return Plan.subtract([poly],local_outline())
static func clipped_cell(builder,x:float,xx:float,z:float,zz:float)->PackedVector3Array:
	var result:=PackedVector3Array()
	for part in Geometry2D.clip_polygons(PackedVector2Array([Vector2(x,z),Vector2(xx,z),Vector2(xx,zz),Vector2(x,zz)]),outline()):
		var indices:=Geometry2D.triangulate_polygon(part)
		for i in range(0,indices.size(),3):
			var points:Array[Vector3]=[]
			for j in 3:
				var q:Vector2=part[indices[i+j]];points.append(Vector3(q.x,builder.height(q.x,q.y),q.y))
			result.append_array(K.quad(points[0],points[1],points[2],points[0]))
	return result
static func sheet(n:Node3D,poly:PackedVector2Array,y:float,color:String,kind:int,solid:bool=false)->void:
	K.surface(n,Plan.floor_vertices([poly],y),color,kind,solid)

''' +s[end:]
start=s.index('\t# V90 remove')
end=s.index('\t# Source-visible grey stone',start)
s=s[:start]+'''	var boundary:=outline()
	sheet(n,boundary,1.54,"485852",7,true)
	sheet(n,boundary,2.18,"405c63",10)
	for i in boundary.size():
		var a:Vector2=boundary[i];var b:Vector2=boundary[(i+1)%boundary.size()]
		var p:=Vector3(a.x,1.54,a.y);var q:=Vector3(b.x,1.54,b.y)
		var u:=Vector3(a.x,2.26,a.y);var v:=Vector3(b.x,2.26,b.y)
		K.surface(n,PackedVector3Array([p,q,v,p,v,u,p,v,q,p,u,v]),"697972",7,true)
		# Narrow coping only; the water reaches beneath the outer fin depth.
		var mid:=(a+b)/2;var yaw:float=-atan2(b.y-a.y,b.x-a.x)
		K.box(n,Vector3(mid.x,2.29,mid.y),Vector3(a.distance_to(b),.16,.32),"9da89a",false,26,yaw)
	# The former rectangular lobe, bridge and line of timber planters are retired.
	# A dry side promenade is clipped to the new water contour, not laid over it.
	for part in Plan.subtract([PackedVector2Array([Vector2(34.7,-332),Vector2(66,-332),Vector2(66,-254),Vector2(34.7,-254)])],boundary):
		sheet(n,part,2.375,"a5aba2",26)
	# Two perimeter connections replace the old bridge crossing the reflecting water.
	M.paving(n,9,46,-253.2,-249.8)
	M.paving(n,9,68,-336,-332.5)
''' +s[end:]
p.write_text(s,encoding='utf-8')
p=root/'world/visual_campus/VisualCampusBuilder.gd';s=p.read_text(encoding='utf-8-sig')
s=s.replace('if LibraryPool.cutout((x+next_x)/2,(z+next_z)/2):continue','if x<65 and next_x>19.5 and z< -254 and next_z> -332:\n\t\t\t\tvertices.append_array(LibraryPool.clipped_cell(self,x,next_x,z,next_z));continue')
p.write_text(s,encoding='utf-8')
p=root/'world/visual_campus/LibraryRegisteredFloors.gd';s=p.read_text(encoding='utf-8-sig')
old='\t\tK.surface(n,K.quad(Vector3(x0,.135,z0),Vector3(x1,.135,z1),Vector3(x1,.135,36),Vector3(x0,.135,36)),"a5a89f",26)'
new='\t\tvar apron:=PackedVector2Array([Vector2(x0,z0),Vector2(x1,z1),Vector2(x1,36),Vector2(x0,36)])\n\t\tfor dry:PackedVector2Array in preload("res://world/visual_campus/LibraryPoolFrontage.gd").dry_parts(apron):P.sheet(n,dry,.135,"a5a89f",26)'
assert old in s;s=s.replace(old,new);p.write_text(s,encoding='utf-8')
p=root/'world/visual_campus/LibraryLowerFrontFacade.gd';s=p.read_text(encoding='utf-8-sig')
old='\tK.surface(n,UpperVertices(apron,.12),"a7ada2",26)'
new='\tfor dry:PackedVector2Array in preload("res://world/visual_campus/LibraryPoolFrontage.gd").dry_parts(apron):K.surface(n,UpperVertices(dry,.12),"a7ada2",26)'
assert old in s;s=s.replace(old,new);p.write_text(s,encoding='utf-8')
p=root/'world/visual_campus/LibraryEntryApproach.gd';s=p.read_text(encoding='utf-8-sig')
old='\tK.finish(n)\n\nstatic func round_pot'
new='\tpreload("res://world/visual_campus/LibraryEntryLawn.gd").build(n)\n\tK.finish(n)\n\nstatic func round_pot'
# Lawn receives coordinate functions via a parameter to avoid reciprocal preload.
new=new.replace('.build(n)','.build(n,point, surface_y)')
assert old in s;s=s.replace(old,new);p.write_text(s,encoding='utf-8')
p=root/'systems/data/campus_visual_build.json';d=json.loads(p.read_text(encoding='utf-8-sig'));d['version']='official-visual-build-118-library-shore-ground';p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('V118 shore, terrain clipping, apron masks and lawn hook written')
