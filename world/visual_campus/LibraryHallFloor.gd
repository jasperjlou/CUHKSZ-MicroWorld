extends RefCounted
## V230: entry panorama pale stone with sparse dark insets;2025 service photo gray stone.
## Material boundary, modules and inset spacing are fitted, not a flooring survey.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const Map=preload("res://world/visual_campus/LibraryLowerFrontPlan.gd")
const Plan=preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd")

static func outline()->PackedVector2Array:
	var polygon:=PackedVector2Array()
	# Public circulation only;209 carpet,staff offices and outside galleries keep their finishes.
	for v in [[154,420],[747,420],[880,550],[1020,640],[1145,500],[1274,610],[1075,810],[916,1070],[850,993],[790,930],[725,886],[665,855],[606,843],[350,843],[350,685],[154,685]]:
		var p:=Map.point2(v[0],v[1]);polygon.append(Vector2(p.x,p.z))
	return polygon

static func add_over_slab(n:Node3D,slab:PackedVector2Array)->void:
	# Called after ALL physical floor cuts: the finish can never close a stair/core opening.
	for p in Geometry2D.intersect_polygons(slab,outline()):
		var mesh:=K.surface(n,Plan.floor_vertices([p],4.408),"d4cdb8",71)
		var material:ShaderMaterial=K.material("d4cdb8",71).duplicate()
		var origin:=Map.point2(1174.5,710)
		var axis:Vector3=(Map.point2(1274,610)-Map.point2(1075,810)).normalized()
		material.set_shader_parameter("floor_origin",Vector2(origin.x,origin.z))
		material.set_shader_parameter("floor_axis",Vector2(axis.x,axis.z))
		mesh.material_override=material

static func service_finish(n:Node3D)->void:
	# Thin flush finish replaces the old23mm-high rectangular slab over the service front.
	var p:=PackedVector2Array([Vector2(-3.3,-1.55),Vector2(3.9,-1.55),Vector2(3.9,1.75),Vector2(-3.3,1.75)])
	K.surface(n,Plan.floor_vertices([p],.010),"c4c3b8",72)
