extends RefCounted
const Text := preload("res://systems/ChineseText.gd")
const CHARACTER_SCALE := 1.5

static func material(color: Color, glow: bool = false) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = 0.88
	if glow:
		result.emission_enabled = true
		result.emission = color
		result.emission_energy_multiplier = 1.4
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

static func person(parent: Node3D, color: Color) -> Node3D:
	var model := Node3D.new()
	model.scale = Vector3.ONE * CHARACTER_SCALE
	parent.add_child(model)
	var body := CapsuleMesh.new()
	body.radius = 0.32
	body.height = 0.86
	body.radial_segments = 8
	body.rings = 4
	mesh(model, body, Vector3(0, 1.05, 0), color)
	var head := Node3D.new()
	head.name = "Head"
	head.position.y = 1.5
	model.add_child(head)
	cylinder(head, Vector3(0, 0.21, 0), 0.24, 0.43, Color("e9c5a0"))
	cylinder(head, Vector3(0, 0.45, -0.01), 0.255, 0.16, Color("3d3935"))
	for x: float in [-0.085, 0.085]:
		box(head, Vector3(x, 0.25, 0.227), Vector3(0.045, 0.06, 0.025), Color("3d3935"))
	box(model, Vector3(-0.17, 0.37, 0), Vector3(0.23, 0.72, 0.27), Color("344448"))
	box(model, Vector3(0.17, 0.37, 0), Vector3(0.23, 0.72, 0.27), Color("344448"))
	box(model, Vector3(-0.17, 0.08, 0.08), Vector3(0.26, 0.15, 0.43), Color("ece5cf"))
	box(model, Vector3(0.17, 0.08, 0.08), Vector3(0.26, 0.15, 0.43), Color("ece5cf"))
	for side: int in [-1, 1]:
		var arm := Node3D.new()
		arm.name = "LeftArm" if side < 0 else "RightArm"
		arm.position = Vector3(side * 0.43, 1.36, 0)
		model.add_child(arm)
		box(arm, Vector3(0, -0.3, 0), Vector3(0.2, 0.64, 0.22), color)
	return model
