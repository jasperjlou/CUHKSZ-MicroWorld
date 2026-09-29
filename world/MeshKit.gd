extends RefCounted
const Text := preload("res://systems/ChineseText.gd")
const CHARACTER_SCALE := 1.5
static var materials: Dictionary = {}

static func material(color: Color, glow: bool = false) -> StandardMaterial3D:
	var key := color.to_html() + str(glow)
	if materials.has(key):
		return materials[key]
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = 0.88
	if glow:
		result.emission_enabled = true
		result.emission = color
		result.emission_energy_multiplier = 1.4
	materials[key] = result
	return result

static func mesh(parent: Node3D, geometry: Mesh, pos: Vector3, color: Color) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = geometry
	instance.position = pos
	instance.material_override = material(color)
	parent.add_child(instance)
	return instance

static func box(parent: Node3D, pos: Vector3, size: Vector3, color: Color, solid: bool = false) -> MeshInstance3D:
	var shape := BoxMesh.new()
	shape.size = size
	var instance := mesh(parent, shape, pos, color)
	if pos.y > 4.0 and size.y < 0.6 and maxf(size.x, size.z) > 2.0:
		instance.add_to_group("camera_overhead")
	if solid:
		var body := StaticBody3D.new()
		body.position = pos
		body.collision_layer = 1
		var collider := CollisionShape3D.new()
		var volume := BoxShape3D.new()
		volume.size = size
		collider.shape = volume
		body.add_child(collider)
		parent.add_child(body)
	return instance

static func cylinder(parent: Node3D, pos: Vector3, radius: float, height: float, color: Color) -> MeshInstance3D:
	var shape := CylinderMesh.new()
	shape.top_radius = radius
	shape.bottom_radius = radius
	shape.height = height
	shape.radial_segments = 8
	return mesh(parent, shape, pos, color)

static func tree(parent: Node3D, pos: Vector3, height: float = 5.0) -> void:
	cylinder(parent, pos + Vector3(0, height * 0.35, 0), 0.23, height * 0.7, Color("75624c"))
	var crown := SphereMesh.new()
	crown.radius = height * 0.37
	crown.height = height * 0.72
	crown.radial_segments = 8
	crown.rings = 4
	mesh(parent, crown, pos + Vector3(0, height * 0.85, 0), Color("637e62"))

static func label(parent: Node3D, words: String, pos: Vector3, size: int = 40) -> Label3D:
	var sign := Label3D.new()
	sign.text = words
	sign.font = Text.FONT
	sign.font_size = size
	sign.pixel_size = 0.023
	sign.position = pos
	sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sign.modulate = Color("fff4d8")
	sign.outline_modulate = Color("263f3b")
	sign.outline_size = 4
	sign.no_depth_test = true
	sign.visibility_range_end = 38.0
	parent.add_child(sign)
	return sign

static func person(parent: Node3D, color: Color, style: String = "casual") -> Node3D:
	var model := Node3D.new()
	model.scale = Vector3.ONE * CHARACTER_SCALE
	parent.add_child(model)
	# Tailored torso and articulated limbs replace the capsule silhouette.
	box(model, Vector3(0, 1.08, 0), Vector3(0.62, 0.68, 0.34), color)
	box(model, Vector3(0, 1.42, 0), Vector3(0.2, 0.16, 0.21), Color("e9c5a0"))
	if style != "casual":
		box(model, Vector3(0, 1.24, 0.182), Vector3(0.25, 0.44, 0.022), Color("f6edda"))
		box(model, Vector3(0, 1.22, 0.202), Vector3(0.065, 0.29, 0.024), Color("a87f55"))
		for side: int in [-1, 1]:
			var lapel := box(model, Vector3(side * 0.16, 1.25, 0.202), Vector3(0.09, 0.38, 0.03), color.lightened(0.13))
			lapel.rotation.z = side * -0.25
	if style == "gown":
		box(model, Vector3(0, 0.91, -0.2), Vector3(0.76, 0.91, 0.12), Color("343f49"))
		for side: int in [-1, 1]:
			box(model, Vector3(side * 0.28, 1.01, 0.21), Vector3(0.12, 0.84, 0.07), Color("343f49"))
	var head := Node3D.new()
	head.name = "Head"
	head.position.y = 1.5
	model.add_child(head)
	cylinder(head, Vector3(0, 0.21, 0), 0.24, 0.43, Color("e9c5a0"))
	cylinder(head, Vector3(0, 0.45, -0.01), 0.255, 0.16, Color("3d3935"))
	for x: float in [-0.085, 0.085]:
		box(head, Vector3(x, 0.25, 0.227), Vector3(0.045, 0.06, 0.025), Color("3d3935"))
	for side: int in [-1, 1]:
		var leg := Node3D.new()
		leg.name = "LeftLeg" if side < 0 else "RightLeg"
		leg.position = Vector3(side * 0.17, 0.74, 0)
		model.add_child(leg)
		box(leg, Vector3(0, -0.34, 0), Vector3(0.22, 0.69, 0.25), Color("344448"))
		box(leg, Vector3(0, -0.66, 0.08), Vector3(0.25, 0.15, 0.4), Color("ece5cf") if style == "casual" else Color("303539"))
	for side: int in [-1, 1]:
		var arm := Node3D.new()
		arm.name = "LeftArm" if side < 0 else "RightArm"
		arm.position = Vector3(side * 0.43, 1.36, 0)
		model.add_child(arm)
		box(arm, Vector3(0, -0.24, 0), Vector3(0.2, 0.49, 0.22), color)
		box(arm, Vector3(0, -0.53, 0), Vector3(0.17, 0.18, 0.18), Color("e9c5a0"))
	return model

static func pose_walk(model: Node3D, amount: float) -> void:
	model.get_node("LeftLeg").rotation.x = amount
	model.get_node("RightLeg").rotation.x = -amount
	model.get_node("LeftArm").rotation.x = -amount * 0.65
