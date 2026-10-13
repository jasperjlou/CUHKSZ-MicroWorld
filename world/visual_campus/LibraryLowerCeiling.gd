extends RefCounted
## Official G panoramas: expanded-metal panels and framed square diffusers.
## Module, colour and lamp positions are fitted; retained ceiling levels do not change.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const PLAN=preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd")
static func rectangle(x:float,z:float,width:float,depth:float)->PackedVector2Array:
	return PackedVector2Array([Vector2(x-width/2,z-depth/2),Vector2(x+width/2,z-depth/2),Vector2(x+width/2,z+depth/2),Vector2(x-width/2,z+depth/2)])
static func exclusions()->Array[PackedVector2Array]:
	# Match the separately authored smooth exhibition soffit and rotated low tier ceiling.
	# Keep constants here to avoid a ceiling <-> stair preload cycle.
	var tier:=PackedVector2Array()
	for q in rectangle(5,2.5,7.1,5.5):
		var p:=Vector3(.4,0,-1)+Basis(Vector3.UP,PI*.75)*Vector3(q.x,0,q.y)
		tier.append(Vector2(p.x,p.z))
	return [rectangle(-17.6,9,8.4,6.7),tier]
static func parts(polygon:PackedVector2Array)->Array[PackedVector2Array]:
	var out:Array[PackedVector2Array]=[polygon]
	for hole in exclusions():out=PLAN.subtract(out,hole)
	return out
static func panel(parent:Node3D,polygon:PackedVector2Array,y:float,color:String="b5b7ac",kind:int=62)->void:
	var vertices:=PLAN.floor_vertices(parts(polygon),y,true)
	if not vertices.is_empty():K.surface(parent,vertices,color,kind)
static func bar(parent:Node3D,p:Vector3,size:Vector2)->void:
	panel(parent,rectangle(p.x,p.z,size.x,size.y),p.y,"b5b8ac",11)
static func light(parent:Node3D,p:Vector3,width:float=1.2,depth:float=1.2,clip_regions:bool=true)->void:
	if clip_regions:
		for hole in exclusions():
			if not Geometry2D.intersect_polygons(rectangle(p.x,p.z,width+.12,depth+.12),hole).is_empty():return
	K.box(parent,p,Vector3(width+.12,.055,depth+.12),"7c8178",false,11)
	K.box(parent,p-Vector3.UP*.032,Vector3(width,.018,depth),"eee8d2",false,17)
	for side in [-1,1]:
		K.box(parent,p+Vector3(side*(width+.045)/2,-.035,0),Vector3(.045,.035,depth+.09),"bec0b5",false,11)
		K.box(parent,p+Vector3(0,-.035,side*(depth+.045)/2),Vector3(width+.09,.035,.045),"bec0b5",false,11)
