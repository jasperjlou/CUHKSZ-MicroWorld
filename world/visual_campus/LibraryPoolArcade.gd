extends RefCounted
## V187: unified dry stone apron and round supports under the retained V120 fin bay.
## Official Sept2026 photographs + historic built frontage; dimensions remain fitted.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/LibraryLowerFrontPlan.gd")
const U=preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd")
const Pool=preload("res://world/visual_campus/LibraryPoolFrontage.gd")
const Pods=preload("res://world/visual_campus/LibraryStudyPods.gd")

static func outer_strip()->PackedVector2Array:
	return preload("res://world/visual_campus/LibraryArcadePlan.gd").outer_strip()

static func finish_areas()->Array[PackedVector2Array]:
	var areas:=preload("res://world/visual_campus/LibraryArcadePlan.gd").areas()
	var result:Array[PackedVector2Array]=[]
	for area in areas:result.append_array(Geometry2D.clip_polygons(area,Pool.local_outline()))
	return result

static func outside_finish(polygon:PackedVector2Array)->Array[PackedVector2Array]:
	var result:Array[PackedVector2Array]=[polygon]
	for area in finish_areas():
		var next:Array[PackedVector2Array]=[]
		for part in result:next.append_array(Geometry2D.clip_polygons(part,area))
		result=next
	return result

static func round_support(n:Node3D,at:Vector2)->void:
	# DSC02471/DSC02494 and historic library018 show pale cylindrical supports.
	# Keep their existing fitted anchors, replacing only the incorrect square section.
	var mesh:=CylinderMesh.new();mesh.top_radius=.34;mesh.bottom_radius=.34
	mesh.height=8.44;mesh.radial_segments=24
	var column:=MeshInstance3D.new();column.name="RoundArcadeColumn"+str(n.get_child_count());column.mesh=mesh
	column.material_override=K.material("d4d2c6",22);column.position=Vector3(at.x,4.34,at.y);n.add_child(column)
	var body:=StaticBody3D.new();column.add_child(body)
	var shape:=CylinderShape3D.new();shape.height=8.44;shape.radius=.34
	var collision:=CollisionShape3D.new();collision.shape=shape;body.add_child(collision)

static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"LibraryPoolArcadeV120")
	# Keep the previously validated physical surface at G; no raised collision lip.
	for polygon in [outer_strip(),PackedVector2Array([Vector2(-43,12),Vector2(-32.2,12),Vector2(-32.2,24),Vector2(-43,24)])]:
		for dry:PackedVector2Array in Pool.dry_parts(polygon):
			K.surface(n,U.floor_vertices([dry],0),"a7ada2",26,true).visible=false
	var finish:=K.holder(n,"UnifiedGreyStoneV187")
	for dry in finish_areas():K.surface(finish,U.floor_vertices([dry],.12),"a7aaa5",58)
	var front:=P.front3()
	# White end pier beside the entry void, visible in2023 and architect photos.
	var a:Vector2=front[9];var end:Vector2=front[10];var axis:Vector2=(end-a).normalized()
	var inside:=Vector2(axis.y,-axis.x);var c:Vector2=end-axis*.55+inside*.65
	var yaw:float=-atan2(axis.y,axis.x)
	K.box(n,Vector3(c.x,6.33,c.y),Vector3(1.15,12.66,1.3),"ced0c4",true,22,yaw)
	# Shallow beam and sparse supports follow the same curved edge; no solid G infill.
	for i in range(4,10):
		var p:Vector2=front[i];var q:Vector2=front[i+1];var dir:Vector2=(q-p).normalized()
		var inset:=Vector2(dir.y,-dir.x)*.75
		Pods.strip(n,p+inset,q+inset,8.54,.28,.40,"c5cbbf",22)
		if i==9:continue
		var at:Vector2=p+inset+dir*.35
		round_support(n,at)
	# Low edge on the water side; route is behind it, not across the basin.
	for i in range(4,10):
		Pods.strip(n,front[i],front[i+1],.13,.18,.26,"9aa699",26)
	K.finish(n)
	preload("res://world/visual_campus/LibraryOuterGallery.gd").build(parent)
