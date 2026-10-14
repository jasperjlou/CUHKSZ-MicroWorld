extends RefCounted
## V234: official70037187 grey fine-jointed squares and architect013 pale stairs/drain strip.
## Modules, drain positions and widths fitted; no alteration to walkable surfaces.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
const Plan=preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd")

static func finish(n:Node3D,poly:PackedVector2Array,y:float)->void:
	var mesh:=K.surface(n,Plan.floor_vertices([poly],y+.008),"bcbcb5",73,false)
	var mat:ShaderMaterial=K.material("bcbcb5",73).duplicate()
	var origin:=P.point(100,240)
	mat.set_shader_parameter("floor_origin",Vector2(origin.x,origin.z))
	mat.set_shader_parameter("floor_axis",Vector2(0,-1))
	mesh.material_override=mat

static func over_slab(n:Node3D,poly:PackedVector2Array,y:float)->void:
	var masks:Array=[]
	if is_equal_approx(y,4.4):masks=[[[100,240],[425,240],[425,560],[100,560]]]
	elif is_equal_approx(y,8.8):masks=[[[425,240],[710,240],[710,505],[425,505]],[[309.5312,454.3071],[425,454.3071],[425,557.3501],[309.5312,557.3501]]]
	elif is_equal_approx(y,12.4):masks=[[[710,240],[924,240],[924,505],[710,505]]]
	# Intersect only AFTER structural stair cuts. Never fill a courtyard stair hole.
	for mask in masks:
		for piece in Geometry2D.intersect_polygons(poly,P.polygon(mask)):finish(n,piece,y)

static func landing(n:Node3D,u0:float,v0:float,u1:float,v1:float,y:float)->void:
	finish(n,P.polygon([[u0,v0],[u1,v0],[u1,v1],[u0,v1]]),y)

static func nosings(n:Node3D,a:Vector3,b:Vector3,width:float,count:int)->void:
	var run:float=a.z-b.z
	for i in count:
		var y:float=lerpf(a.y,b.y,float(i+1)/count)
		var front:float=a.z-run*i/count
		# Restrained inset at the front of each real tread, no giant tiled riser grid.
		K.box(n,Vector3(a.x,y+.004,front-.038),Vector3(width-.08,.006,.022),"929991",false,22)

static func drain(n:Node3D,centre:Vector3,width:float)->void:
	# Thin flush visual grating; hydraulic network and exact installation not surveyed.
	K.box(n,centre+Vector3.UP*.011,Vector3(width,.008,.16),"49504b",false,22)
	var count:=maxi(1,roundi(width/.065))
	for i in count:
		K.box(n,centre+Vector3(-width/2+(i+.5)*width/count,.018,0),Vector3(.022,.006,.145),"9b9e92",false,11)
	for z in [-.085,.085]:K.box(n,centre+Vector3(0,.017,z),Vector3(width,.008,.016),"8c9288",false,11)

static func replace_stair_material(n:Node3D)->void:
	# Only the local stair holder's tread boxes use kind12. Collider nodes untouched.
	for child in n.get_children():
		if child is MultiMeshInstance3D and child.material_override is ShaderMaterial:
			if child.material_override.get_shader_parameter("surface_kind")==12:
				child.material_override=K.material("c2c4ba",74)
