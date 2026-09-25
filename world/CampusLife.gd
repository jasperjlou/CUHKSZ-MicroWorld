extends Node3D
# Authored scenery in final world metres. No recovered third-party meshes.
const K := preload("res://world/MeshKit.gd")
const Extra := preload("res://npc/CampusExtra.gd")
const IVORY := Color("e7e1d3")
const FRAME := Color("526365")
const CLAY := Color("b77958")

func _ready() -> void:
	_courtyard()
	_colonnade()
	_hall()
	_landscape()
	_people()

func _sign(words: String, pos: Vector3, size: int = 30) -> Label3D:
	var label := K.label(self, words, pos, size)
	label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	label.no_depth_test = false
	label.pixel_size = 0.012
	label.visibility_range_end = 26
	return label

func _courtyard() -> void:
	# A U-shaped garden room frames the departure without enclosing the camera.
	for x: float in [-11, 11]:
		K.box(self, Vector3(x, 4, 47), Vector3(5, 8, 20), IVORY, true)
		for z: float in [41, 45, 49, 53]:
			for y: float in [3, 5.8]:
				K.box(self, Vector3(x - signf(x) * 2.53, y, z), Vector3(0.08, 1.8, 2.6), Color("6a8990"))
		for z: float in [39, 43, 47, 51, 55]:
			K.box(self, Vector3(x - signf(x) * 3, 2.2, z), Vector3(0.32, 4.4, 0.32), IVORY, true)
		K.box(self, Vector3(x - signf(x) * 3, 4.4, 47), Vector3(2.5, 0.25, 18), IVORY)
	K.box(self, Vector3(-4.9, 0.35, 48), Vector3(2.5, 0.7, 5), Color("aaad95"), true)
	K.box(self, Vector3(-4.9, 0.72, 48), Vector3(2.1, 0.06, 4.6), Color("4e7778"))
	for z: float in [46.7, 48.2, 49.4]:
		K.cylinder(self, Vector3(-4.9, 0.77, z), 0.22, 0.035, Color("91a175"))
	poster(Vector3(4.6, 0, 40), "今晚有约\n高桌晚宴\n沿连廊直行", CLAY)
	K.box(self, Vector3(-7.3, 0.7, 42), Vector3(0.65, 1.4, 0.65), FRAME, true)
	_sign("分类投放", Vector3(-7.3, 1.3, 42.34), 17)

func _colonnade() -> void:
	# Keep the existing traversable centre; side rooms and fins establish depth.
	for z: float in [29, 13, -3, -36]:
		K.box(self, Vector3(-9, 5.1, z), Vector3(7, 3, 12), IVORY)
		for zz: float in [-4, 0, 4]:
			K.box(self, Vector3(-5.47, 5.2, z + zz), Vector3(0.1, 1.9, 2.8), Color("779493"))
			K.box(self, Vector3(-5.35, 5.2, z + zz + 1.5), Vector3(0.3, 2.6, 0.14), CLAY)
		for zz: float in [-5, 5]:
			K.box(self, Vector3(-6, 1.9, z + zz), Vector3(0.4, 3.8, 0.4), IVORY, true)
		K.box(self, Vector3(-9, 3.7, z), Vector3(7.5, 0.25, 12.5), IVORY)
	# Fictional joke signage, clearly documented as authored for this prototype.
	K.box(self, Vector3(-3.9, 2.1, 18), Vector3(2.2, 1.3, 0.14), FRAME)
	_sign("走路不看手机", Vector3(-3.9, 2.35, 18.09), 28)
	_sign("抬头看路，也看看港中深。", Vector3(-3.9, 1.93, 18.09), 14)
	for z: float in [36, 20, 4, -12, -28, -42]:
		K.box(self, Vector3(-4.25, 0.11, z), Vector3(0.18, 0.06, 6), CLAY)
		K.box(self, Vector3(4.25, 0.11, z), Vector3(0.18, 0.06, 6), CLAY)
	poster(Vector3(-3.5, 0, -5), "赴宴之前\n整理衣领\n也整理好心情", FRAME)
	# Small planted corner; stairs are scenery outside the accessible spine.
	for i: int in range(4):
		K.box(self, Vector3(-12 - i * 0.55, 0.12 * (i + 1), -8), Vector3(0.55, 0.24 * (i + 1), 6), IVORY, true)
	K.tree(self, Vector3(-11, 0, -15), 5)
	poster(Vector3(14.5, 0, -22), "赴宴合影\n把今晚留在相册里", CLAY)

func poster(pos: Vector3, words: String, color: Color) -> void:
	K.box(self, pos + Vector3(0, 1.5, 0), Vector3(1.8, 2.7, 0.15), color, true)
	K.box(self, pos + Vector3(0, 0.08, 0), Vector3(2.2, 0.12, 0.9), FRAME)
	var label := _sign(words, pos + Vector3(0, 1.6, 0.09), 21)
	label.width = 135
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _glass(pos: Vector3, size: Vector3) -> void:
	var pane := K.box(self, pos, size, Color(0.5, 0.7, 0.73, 0.18))
	var mat: StandardMaterial3D = pane.material_override.duplicate()
	pane.material_override = mat
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.roughness = 0.22
	for dx: float in [-size.x / 2, size.x / 2]:
		K.box(self, pos + Vector3(dx, 0, 0), Vector3(0.09, size.y, 0.13), FRAME)
	K.box(self, pos + Vector3(0, size.y / 2, 0), Vector3(size.x, 0.08, 0.15), FRAME)

func _hall() -> void:
	K.box(self, Vector3(0, 0.06, -55.5), Vector3(25, 0.12, 18), IVORY)
	# Real depth, open entrance, glazed side bays; the friend remains at z=-51.2.
	K.box(self, Vector3(0, 3.5, -64), Vector3(25, 7, 0.5), Color("c2a781"), true)
	for x: float in [-12, 12]:
		K.box(self, Vector3(x, 3.4, -58), Vector3(0.4, 6.8, 12), IVORY, true)
	for x: float in [-9, -5, 5, 9]:
		_glass(Vector3(x, 2.7, -53.5), Vector3(3.8, 5.2, 0.06))
		K.box(self, Vector3(x, 5.7, -53.5), Vector3(4, 1.0, 0.5), IVORY)
	K.box(self, Vector3(0, 6.1, -54), Vector3(26, 0.35, 2.4), IVORY)
	_sign("高桌晚宴", Vector3(0, 6.05, -52.73), 58)
	_sign("相聚 · 交流 · 成长", Vector3(0, 5.05, -53), 22)
	# Cutaway ceiling preserves the top-down follow camera and interior sightline.
	K.box(self, Vector3(0, 6.7, -62.8), Vector3(25, 0.25, 3), IVORY)
	K.box(self, Vector3(0, 0.16, -57), Vector3(3, 0.02, 10), Color("95655c"))
	K.box(self, Vector3(-7.2, 1.05, -50.8), Vector3(3.2, 0.2, 1.0), Color("7e5e4b"), true)
	K.box(self, Vector3(-7.2, 0.5, -50.8), Vector3(2.6, 1, 0.8), IVORY, true)
	_sign("签到处", Vector3(-7.2, 1.65, -50.4), 25)
	for x: float in [-8, -7.2, -6.4]:
		K.box(self, Vector3(x, 1.18, -50.7), Vector3(0.4, 0.02, 0.55), Color("fff9e7"))
	poster(Vector3(5.6, 0, -47.7), "今晚19:00\n高桌晚宴\n请着正装及\n学生袍入场", FRAME)
	for x: float in [-7, 7]:
		K.box(self, Vector3(x, 1.1, -59), Vector3(3, 0.16, 6), Color("fff4dc"), true)
		for z: float in [-57, -59, -61]:
			for side: int in [-1, 1]:
				K.cylinder(self, Vector3(x + side * 1.03, 1.2, z), 0.32, 0.035, Color("faf9eb"))
				K.cylinder(self, Vector3(x + side * 0.85, 1.35, z - 0.4), 0.09, 0.28, Color("e1ca9b"))
				K.box(self, Vector3(x + side * 1.85, 0.65, z), Vector3(0.65, 0.12, 0.7), FRAME)
				K.box(self, Vector3(x + side * 2.13, 1.1, z), Vector3(0.1, 0.85, 0.7), FRAME)
			K.cylinder(self, Vector3(x, 1.38, z), 0.18, 0.38, Color("d5c6a2"))
			for flower: int in range(3):
				K.cylinder(self, Vector3(x + (flower-1)*0.16, 1.67, z), 0.13, 0.16, Color("e5b5b1"))
		var light := OmniLight3D.new()
		light.position = Vector3(x, 4, -58)
		light.light_color = Color("ffd396")
		light.light_energy = 2.1
		light.omni_range = 12
		add_child(light)
		var fixture := K.box(self, Vector3(x, 4.5, -58), Vector3(3, 0.2, 0.6), Color("ffdca4"))
		fixture.material_override = K.material(Color("ffdca4"), true)
	K.box(self, Vector3(0, 0.25, -62.5), Vector3(5, 0.5, 2.4), Color("8c7562"), true)
	_sign("今晚，在这里相聚", Vector3(0, 3.5, -63.6), 37)

func _landscape() -> void:
	for i: int in range(9):
		var hill := SphereMesh.new()
		hill.radial_segments = 9
		hill.rings = 4
		hill.radius = 1
		hill.height = 2
		var mesh := K.mesh(self, hill, Vector3(-42 - (i%3)*7, -3, -90 + i*22), Color("637f78"))
		mesh.scale = Vector3(20, 10 + i%4*4, 23)
	for z: float in [-43, -31, 6, 32]:
		K.box(self, Vector3(6.4, 0.45, z), Vector3(1.6, 0.9, 2.5), IVORY, true)
		K.box(self, Vector3(6.4, 0.97, z), Vector3(1.4, 0.3, 2.3), Color("647f59"))

func _people() -> void:
	var spots := [Vector3(-5,0,36),Vector3(-6,0,35),Vector3(-7,0,-8),Vector3(5.8,0,-34),Vector3(6.6,0,-36),Vector3(-4,0,-43),Vector3(-5,0,-44),Vector3(8,0,-49),Vector3(-7,0,-52),Vector3(3.8,0,-57),Vector3(-3.6,0,-58),Vector3(4,0,-60)]
	for i: int in range(spots.size()):
		var extra := Node3D.new()
		extra.set_script(Extra)
		extra.position = spots[i]
		extra.variant = i
		add_child(extra)
