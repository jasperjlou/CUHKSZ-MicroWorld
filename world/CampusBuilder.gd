extends Node3D
const Kit := preload("res://world/MeshKit.gd")
const STONE := Color("dfd5bc")
const CREAM := Color("eadfc7")
const TEAL := Color("3d6460")
const SPACE := Vector3(0.72, 1.0, 0.8)
const PHOTO_SPOT := Vector3(12, 0, -23)

static func to_world(pos: Vector3) -> Vector3:
	return pos * SPACE

func _ready() -> void:
	build()
	# Compress the existing campus, keeping people and Chinese lettering undistorted.
	for child in get_children():
		if child is Node3D:
			child.position *= SPACE
			if child is MeshInstance3D or child is StaticBody3D:
				child.scale *= SPACE

	var life := Node3D.new()
	life.set_script(preload("res://world/CampusLife.gd"))
	add_child(life)

func build() -> void:
	var environment := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("a2b7bd")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("d3dcd6")
	settings.ambient_light_energy = 0.42
	settings.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	environment.environment = settings
	add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-32, -38, 0)
	sun.light_color = Color("f3c49c")
	sun.light_energy = 0.46
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 100
	add_child(sun)
	Kit.box(self, Vector3(0, -0.35, 0), Vector3(95, 0.7, 165), Color("8b9b74"), true)
	# One continuous route with cross-paths; all buildings remain outside it.
	Kit.box(self, Vector3(0, 0.015, 0), Vector3(9.4, 0.06, 145), STONE)
	Kit.box(self, Vector3(0, 0.025, 60), Vector3(28, 0.08, 20), CREAM)
	Kit.box(self, Vector3(8, 0.025, -20), Vector3(20, 0.08, 7), STONE)
	Kit.box(self, Vector3(14, 0.04, -23), Vector3(14, 0.1, 16), CREAM)
	Kit.box(self, Vector3(-17, 0.02, 26), Vector3(5, 0.08, 60), STONE)
	for z: int in [51, 4]:
		Kit.box(self, Vector3(-10, 0.025, z), Vector3(22, 0.08, 5), STONE)
	for z: int in range(-63, 69, 6):
		Kit.box(self, Vector3(0, 0.06, z), Vector3(9.2, 0.02, 0.055), Color("c4baa4"))
	# Open colonnade: roof represented by side beams to keep the camera unobstructed.
	for z: int in range(-46, 43, 11):
		for x: float in [-6.5, 6.5]:
			# Leave the photo garden's cross-path open for the larger character capsule.
			if x > 0 and z == -24:
				continue
			Kit.box(self, Vector3(x, 2.45, z), Vector3(0.5, 4.9, 0.5), CREAM, true)
	for x: float in [-6.5, 6.5]:
		Kit.box(self, Vector3(x, 4.85, -3), Vector3(0.65, 0.35, 91), Color("cabb9e"))
	# Campus blocks, windows and terracotta fins.
	for z: int in [-40, -13, 26]:
		_building(Vector3(-32, 0, z), Vector3(17, 10, 20))
	_building(Vector3(32, 0, 37), Vector3(19, 8, 24))
	for z: int in range(-53, 63, 15):
		for x: int in [-12, 12]:
			if x == 12 and abs(z + 23) < 16:
				continue
			Kit.tree(self, Vector3(x, 0, z), 4.8)
			Kit.box(self, Vector3(x, 0.18, z), Vector3(3.5, 0.35, 3.5), Color("b8ad91"), true)
	for z: int in [41, 19, -3]:
		bench(Vector3(-20, 0, z))
	for x: int in [10, 21]:
		Kit.tree(self, Vector3(x, 0, -32), 5.4)
		bench(Vector3(x, 0, -30))
	# Photo backdrop and a noninteractive companion.
	Kit.box(self, Vector3(14, 1.1, -29), Vector3(10, 2.2, 0.35), TEAL, true)
	var photo_sign := Kit.label(self, "赴宴前，合影留念", Vector3(14, 2.1, -28.7), 28)
	photo_sign.name = "PhotoBackdropSign"
	var companion := Node3D.new()
	add_child(companion)
	companion.name = "PhotoCompanion"
	companion.position = Vector3(16, 0, -23)
	Kit.person(companion, Color("b7a4ca"), "gown")
	for z: int in [-59, -33, 18, 47]:
		lamp(Vector3(8.8, 0, z))
		lamp(Vector3(-8.8, 0, z))
	signpost(Vector3(4, 0, 55), "高桌晚宴 ↑\n沿连廊直行")
	signpost(Vector3(5, 0, -12), "合影花园 →\n高桌晚宴 ↑")
	signpost(Vector3(-12, 0, 47), "林荫小径")
	Kit.label(self, "入口广场", Vector3(0, 0.3, 66), 36)
	# Invisible outer boundaries prevent falling off the playable ground.
	for x: int in [-44, 44]:
		Kit.box(self, Vector3(x, 1.0, 0), Vector3(1, 2, 164), Color("6c7f60"), true)
	for z: int in [-81, 80]:
		Kit.box(self, Vector3(0, 1, z), Vector3(88, 2, 1), Color("6c7f60"), true)

func _building(pos: Vector3, size: Vector3) -> void:
	Kit.box(self, pos + Vector3(0, size.y / 2, 0), size, CREAM, true)
	for y: int in [3, 6]:
		for x: int in [-6, -2, 2, 6]:
			Kit.box(self, pos + Vector3(x, y, size.z / 2 + 0.02), Vector3(2.5, 1.7, 0.12), Color("718f8a"))
	Kit.box(self, pos + Vector3(0, size.y + 0.15, 0), Vector3(size.x + 0.5, 0.3, size.z + 0.5), Color("bf9876"))

func bench(pos: Vector3) -> void:
	Kit.box(self, pos + Vector3(0, 0.6, 0), Vector3(3.0, 0.2, 0.85), Color("a7825b"), true)
	Kit.box(self, pos + Vector3(0, 1, -0.32), Vector3(3, 0.75, 0.15), Color("a7825b"))
	for x: float in [-1.1, 1.1]:
		Kit.box(self, pos + Vector3(x, 0.25, 0), Vector3(0.16, 0.5, 0.6), TEAL)

func lamp(pos: Vector3) -> void:
	Kit.cylinder(self, pos + Vector3(0, 1.8, 0), 0.07, 3.6, TEAL)
	var globe := Kit.box(self, pos + Vector3(0, 3.6, 0), Vector3(0.5, 0.4, 0.5), Color("f7d995"))
	globe.material_override = Kit.material(Color("f7d995"), true)

func signpost(pos: Vector3, words: String) -> void:
	Kit.box(self, pos + Vector3(0, 0.9, 0), Vector3(0.12, 1.8, 0.12), TEAL)
	Kit.box(self, pos + Vector3(0, 2, 0), Vector3(3.4, 1.45, 0.2), TEAL)
	Kit.label(self, words, pos + Vector3(0, 2, 0.14), 25)
