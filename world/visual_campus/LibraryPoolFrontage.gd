extends RefCounted
## 2023 anniversary view + official Central Mall panorama: brick broadside, glazed end.
## Coordinates are fitted. The pavilion's unobserved interior is deliberately not furnished.
const K := preload("res://world/visual_campus/VisualCampusKit.gd")
const M := preload("res://world/visual_campus/PhotoMallGround.gd")

const Plan=preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd")
static func outline()->PackedVector2Array:
	# V120: follow the ENTIRE curved fin bay; do not put water under the G arcade.
	# The shared registered edge also leaves the recessed1F entrance reachable from the side.
	# This is a photo-informed contour, not a survey of the pond.
	var boundary:=PackedVector2Array([Vector2(19.5,-332),Vector2(34.5,-332),Vector2(34.5,-326),Vector2(56.0,-326)])
	var front:=preload("res://world/visual_campus/LibraryLowerFrontPlan.gd").front3()
	for i in range(4,11):
		var q:Vector2=front[i]
		boundary.append(Vector2(78-q.y-.42,-290+q.x))
	boundary.append_array(PackedVector2Array([Vector2(58.911,-273.210),Vector2(50.396,-266.516),Vector2(42.511,-260.318),Vector2(36.204,-255.360),Vector2(34.5,-254),Vector2(19.5,-254)]))
	return boundary
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

static func pavilion(parent: Node3D) -> void:
	preload("res://world/visual_campus/LibraryEntryPavilion.gd").build(parent)

static func pool(parent: Node3D) -> void:
	var n:=K.holder(parent,"LibraryReflectingPoolFrontage")
	var boundary:=outline()
	sheet(n,boundary,1.54,"485852",7,true)
	preload("res://world/visual_campus/ReflectingPoolWater.gd").build(n,Plan.floor_vertices([boundary],2.18))
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
	var promenade:Array[PackedVector2Array]=[PackedVector2Array([Vector2(34.7,-332),Vector2(66,-332),Vector2(66,-254),Vector2(34.7,-254)])]
	# V187: the library arcade now owns its stone finish in this shared world strip.
	var masks:=preload("res://world/visual_campus/LibraryArcadePlan.gd").world_areas()
	masks.append(boundary)
	for mask in masks:
		var remaining:Array[PackedVector2Array]=[]
		for part in promenade:remaining.append_array(Geometry2D.clip_polygons(part,mask))
		promenade=remaining
	for part in promenade:sheet(n,part,2.375,M.STONE,40)
	# Two perimeter connections replace the old bridge crossing the reflecting water.
	M.paving(n,9,46,-253.2,-249.8)
	M.paving(n,9,68,-336,-332.5)
	# Close the half-metre finish gap where the transverse path meets the dry promenade.
	# Clip against the arcade-owned finish and water rather than covering either one.
	var join_parts:Array[PackedVector2Array]=[PackedVector2Array([Vector2(34.7,-332.5),Vector2(66,-332.5),Vector2(66,-332),Vector2(34.7,-332)])]
	for mask in masks:
		var remaining:Array[PackedVector2Array]=[]
		for part in join_parts:remaining.append_array(Geometry2D.clip_polygons(part,mask))
		join_parts=remaining
	for part in join_parts:sheet(n,part,2.375,M.STONE,40)
	# Source-visible grey stone shore and slotted drainage, clear of both ramps.
	M.paving(n,9,18.7,-326.5,-253.2)
	# User photo222215 puts the longitudinal grate under the low-light row, pool-side.
	# The former grass-side line at X9.6 separated the photographed lights and grate.
	M.drain(n,Vector2(17.65,-326.5),Vector2(17.65,-253.2))
	M.drain(n,Vector2(-37,-252),Vector2(18.7,-252))
	for z in [-320,-311,-302,-293,-284,-266,-257]:
		K.box(n,Vector3(17.65,2.79,z),Vector3(.14,1.1,.14),"64716b",true,11)
		for x in [17.54,17.76]:K.box(n,Vector3(x,2.83,z),Vector3(.04,.83,.08),"e7dfbe",false,17)
	# The transverse path joins the existing teaching-C apron without closing its lawn panels.
	M.paving(n,-43.0,18.7,-283,-276)
	M.drain(n,Vector2(-37,-280.4),Vector2(16,-280.4))
	for z in [-308,-288,-268]:K.tree(n,Vector3(1.7,2.36,z),10.5,9000+absi(z),1.7)
	K.finish(n)
