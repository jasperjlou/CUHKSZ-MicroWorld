extends RefCounted
## V238: official1F 86404084/85 pale brushed rectangles and sparse darker modules.
## Registered building coordinates keep material continuous across floor sheets.
const K=preload("res://world/visual_campus/VisualCampusKit.gd")
const P=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
const Plan=preload("res://world/visual_campus/LibraryUpperRegisteredPlan.gd")

static func sheet(n:Node3D,r:Array,y:float,mat:ShaderMaterial)->void:
	var poly:=P.polygon([[r[0],r[1]],[r[2],r[1]],[r[2],r[3]],[r[0],r[3]]])
	var mesh:=K.surface(n,Plan.floor_vertices([poly],y),"b9b9ad",76,false)
	mesh.material_override=mat

static func build(parent:Node3D)->void:
	var n:=K.holder(parent,"StudentCanteenFloorV238")
	var mat:ShaderMaterial=K.material("b9b9ad",76).duplicate()
	var origin:=P.point(220,300)
	mat.set_shader_parameter("floor_origin",Vector2(origin.x,origin.z))
	mat.set_shader_parameter("floor_axis",Vector2(0,-1))
	# Existing ground slab remains the collision surface; all finish sheets are flush.
	# Window-side continuation formerly exposed generic squares below the2F west landing.
	for r:Array in [[310,85,704,242],[220,242,704,453],[220,453,704,603],[505,603,704,687]]:
		sheet(n,r,.09,mat)
	# Reuse the exact existing door openings/step; no extra raised curb is introduced.
	for r:Array in [[213.6,341.38,224.6,360.62],[213.6,372.38,224.6,385.62],[213.6,426.38,224.6,449.62]]:
		sheet(n,r,.15,mat)
	n.set_meta("material_origin_plan",Vector2(220,300))
	n.set_meta("fitted_module_metres",Vector2(.6,1.2))
