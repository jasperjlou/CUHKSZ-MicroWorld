extends Node3D
## Authored V0.6 geometry. Physical bilingual signs are intentional; HUD stays Chinese.
const K := preload("res://world/MeshKit.gd")
const REGIONS := preload("res://world/WorldRegion.gd")
const PAPER := Color("eeeade")
const INK := Color("254440")
const IVORY := Color("e3e3d9")
var roofs: Array[MeshInstance3D] = []

func _ready() -> void:
	_corridor()
	_wood_sign()
	_boards()
	_wayfinding()
	_terrace()
	_exit_road()

func lettering(parent: Node3D, words: String, pos: Vector3, size: int, color: Color = INK, width: float = 250) -> Label3D:
	var label := K.label(parent, words, pos, size)
	label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	label.no_depth_test = false
	label.outline_size = 0
	label.pixel_size = 0.008
	label.modulate = color
	label.width = width
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.visibility_range_end = 45
	return label

func _corridor() -> void:
	# Repeated shallow roof bays; open east edge overlooks planted courts.
	for z: float in [34, 25.2, 16.4, 7.6, -1.2, -10, -18.8, -27.6, -36.4]:
		for x: float in [-3.0, 3.0]:
			var panel := K.box(self, Vector3(x, 5.65, z), Vector3(3.5, 0.22, 8.6), IVORY)
			panel.remove_from_group("camera_overhead")
			var roof_mat: StandardMaterial3D = panel.material_override.duplicate()
			roof_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			panel.material_override = roof_mat
			roofs.append(panel)
		K.box(self, Vector3(0, 5.45, z + 4.2), Vector3(9.5, 0.3, 0.24), IVORY)
		for x: float in [-4.25, 4.25]:
			K.box(self, Vector3(x, 5.27, z), Vector3(0.12, 0.07, 2.3), Color("d7d7bb"))
		# Roof has a longitudinal sky slot. Lamps belong to the side beams.
		var light := OmniLight3D.new()
		light.position = Vector3(-3.5, 4.5, z)
		light.light_color = Color("eef1df")
		light.light_energy = 0.35
		light.omni_range = 7
		add_child(light)
	# Pale piers and glass link two distinct garden courts, rather than a tunnel.
	for z: float in [24, 6, -12]:
		K.box(self, Vector3(-7.2, 1.6, z), Vector3(0.18, 3.2, 6), Color("789798"))
		for dz: float in [-3, 0, 3]:
			K.box(self, Vector3(-7.05, 1.6, z + dz), Vector3(0.2, 3.3, 0.10), IVORY)
	for z: float in [27, 9, -9]:
		K.box(self, Vector3(10, 0.16, z), Vector3(8, 0.32, 8), Color("95a187"))
		K.tree(self, Vector3(12, 0.3, z), 5.2)
		K.box(self, Vector3(7.8, 0.56, z - 2), Vector3(3, 0.16, 0.7), Color("9a8063"), true)
		for x: float in [6.7, 8.9]:
			K.box(self, Vector3(x, 0.27, z - 2), Vector3(0.15, 0.54, 0.5), INK)

func _process(delta: float) -> void:
	# Simple architectural cutaway: roofs near the follow camera disappear,
	# distant bays retain their ceiling. No camera collision on cosmetic roofs.
	var world := get_tree().current_scene
	if world == null or not is_instance_valid(world.get("player")): return
	var z: float = world.player.global_position.z
	for roof in roofs:
		var opacity := smoothstep(12.0, 19.0, absf(roof.position.z - z))
		roof.material_override.albedo_color.a = lerpf(roof.material_override.albedo_color.a, opacity, 1.0 - exp(-10.0 * delta))

func _wood_sign() -> void:
	# USER_PLAQUE_001: visible proportions/materials only, no surveyed location.
	K.box(self, Vector3(-3.85, 2.2, 18), Vector3(1.42, 4.4, 0.5), IVORY, true)
	K.box(self, Vector3(-3.85, 2.24, 18.31), Vector3(1.0, 3.2, 0.13), Color("563b35"))
	var face := MeshInstance3D.new()
	var plane := QuadMesh.new()
	plane.size = Vector2(0.96, 3.14)
	face.mesh = plane
	face.position = Vector3(-3.85, 2.24, 18.39)
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = preload("res://assets/signs/walk_without_phone_reference.png")
	mat.roughness = 0.94
	face.material_override = mat
	face.set_meta("inscription", "走路不看手机")
	face.set_meta("reference_id", "USER_PLAQUE_001")
	face.set_meta("reconstruction_status", "STYLIZED_REFERENCE_BASED_NOT_FACSIMILE")
	add_child(face)
	# One evidenced bay: continuous grey soffit and tiled floor at the plaque.
	# Keep the rest of the prototype layout explicitly authored, not surveyed.
	var soffit := K.box(self, Vector3(0, 5.65, 16.4), Vector3(2.6, 0.22, 8.6), Color("b8b9b0"))
	soffit.remove_from_group("camera_overhead")
	var soffit_mat: StandardMaterial3D = soffit.material_override.duplicate()
	soffit_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	soffit.material_override = soffit_mat
	roofs.append(soffit)
	K.box(self, Vector3(0, 0.012, 18), Vector3(7.4, 0.018, 7.2), Color("aaa99e"))
	for z: float in [14.4, 15.6, 16.8, 18, 19.2, 20.4, 21.6]:
		K.box(self, Vector3(0, 0.024, z), Vector3(7.4, 0.006, 0.015), Color("93958e"))
	for x: float in [-3.6, -2.4, -1.2, 0, 1.2, 2.4, 3.6]:
		K.box(self, Vector3(x, 0.024, 18), Vector3(0.015, 0.006, 7.2), Color("93958e"))

func _paper(board: Node3D, pos: Vector3, size: Vector2, angle: float, title: String, body: String, color: Color = PAPER, accent: Color = INK) -> void:
	var paper := Node3D.new()
	board.add_child(paper)
	paper.position = pos
	paper.rotation.z = angle
	K.box(paper, Vector3.ZERO, Vector3(size.x, size.y, 0.025), color)
	K.box(paper, Vector3(0, size.y * 0.5 - 0.07, 0.019), Vector3(size.x - 0.1, 0.065, 0.008), accent)
	var pixels := (size.x - 0.14) / 0.008
	var widest := 1.0
	for line: String in title.split("\n"):
		var units := 0.0
		for i: int in line.length():
			units += 1.0 if line.unicode_at(i) > 255 else 0.58
		widest = maxf(widest, units)
	lettering(paper, title, Vector3(0, size.y * 0.25, 0.025), mini(33, int(pixels / widest)), accent, pixels)
	lettering(paper, body, Vector3(0, -size.y * 0.13, 0.026), 16, accent, pixels)
	# One lifted corner and two small pins; deliberately not a menu-card grid.
	var corner := K.box(paper, Vector3(size.x/2 - 0.10, -size.y/2 + 0.1, 0.04), Vector3(0.2, 0.2, 0.015), color.lightened(0.04))
	corner.rotation.x = -0.2
	for x: float in [-size.x/2 + 0.08, size.x/2 - 0.08]:
		K.box(paper, Vector3(x, size.y/2 - 0.07, 0.034), Vector3(0.04, 0.04, 0.02), Color("9c8765"))

func _qr(board: Node3D, pos: Vector3) -> void:
	# Decorative non-QR pattern: no encoded URL or registration destination.
	K.box(board, pos, Vector3(0.34, 0.34, 0.015), PAPER)
	for row: int in range(7):
		for col: int in range(7):
			if (row * 5 + col * 3 + row * col) % 4 < 2:
				K.box(board, pos + Vector3((col-3)*0.041, (row-3)*0.041, 0.015), Vector3(0.033,0.033,0.01), INK)

func _board(pos: Vector3) -> Node3D:
	var board := Node3D.new()
	add_child(board)
	board.position = pos
	K.box(board, Vector3(0, 2.8, 0), Vector3(6.4, 3.7, 0.16), Color("75877d"), true)
	for x: float in [-2.6, 2.6]:
		K.box(board, Vector3(x, 0.8, 0), Vector3(0.12, 1.6, 0.2), INK, true)
	K.box(board, Vector3(0, 4.72, 0), Vector3(6.6, 0.12, 0.6), IVORY)
	return board

func _boards() -> void:
	var a := _board(Vector3(-4.2, 0, 36.2))
	_paper(a, Vector3(-1.95, 2.8, 0.12), Vector2(2.0, 3.2), -0.024, "招募被试\n￥30", "决策与认知实验\n20–30 MIN · 20–30 分钟\n港中深在校学生均可报名\n下园实验室\n30 元 / 校园纪念品\n电脑任务 · 简短问卷\n扫码报名\n行为科学研究项目")
	_paper(a, Vector3(0.25, 3.05, 0.14), Vector2(2.0, 2.9), 0.02, "TIDE\n2026 秋季招新", "一起做点有意思的事\n策划 / 设计 / 媒体 / 活动\n面向全校同学\n扫码加入我们\nJOIN US", Color("d9dfb1"))
	_paper(a, Vector3(2.0, 3.35, 0.16), Vector2(1.45, 2.1), -0.045, "失物招领", "连廊拾得\n黑色水杯一个\n请凭特征认领\n2026.09")
	_paper(a, Vector3(1.75, 1.6, 0.18), Vector2(2.05, 1.1), 0.015, "今晚高桌晚宴", "19:00\n请着正装及学生袍入场", Color("e5d9bd"))
	_qr(a, Vector3(-2.65, 1.46, 0.18))
	_qr(a, Vector3(0.90, 1.87, 0.2))
	var b := _board(Vector3(-4.8, 0, -23.5))
	_paper(b, Vector3(-2.0, 2.85, 0.12), Vector2(2, 3.25), 0.02, "COMPUTING\n× PHILOSOPHY", "计算机与哲学\nAI / COGNITION\nLANGUAGE / REASONING\n跨学科研究分享\n周三 19:30\n校园活动空间\n主题分享 / 自由交流", Color("d5dfdf"))
	_paper(b, Vector3(0.15, 3.05, 0.13), Vector2(2, 2.95), -0.025, "你走路时\n会看手机吗？", "注意力与多任务实验招募\n视觉判断 / 行为任务\n简短问卷\n约 25 分钟 · 参与有报酬\n港中深在校学生均可报名\n扫码参加", Color("e8d4ae"))
	_paper(b, Vector3(2.05, 3.32, 0.15), Vector2(1.6, 2.2), 0.03, "从问题到研究", "本科生如何开始科研？\n研究兴趣 / 文献阅读\n找导师 / 开始第一个项目\n本周五 19:00\n学生中心 / 开放报名")
	_paper(b, Vector3(1.75, 1.5, 0.16), Vector2(2.05, 1.15), -0.04, "志愿者招募", "高桌晚宴：签到 / 引导 / 现场协助\n17:30–21:30 · 欢迎报名")
	_qr(b, Vector3(0.88, 1.8, 0.2))
	var c := Node3D.new()
	add_child(c)
	c.position = Vector3(5.8, 0, -46.5)
	_paper(c, Vector3(0, 2.1, 0), Vector2(2.3, 3.8), 0, "HIGH TABLE\nDINNER\n高桌晚宴\n19:00", "TONIGHT\n18:30 签到\n正装及学生袍\n请提前入场\n书院活动", Color("ede6cf"), Color("485566"))
	K.box(c, Vector3(0, 0.3, -0.15), Vector3(0.16, 0.6, 0.3), INK, true)
	K.box(c, Vector3(0, 0.06, 0), Vector3(2.4, 0.12, 0.8), INK, true)

func wayfinder(pos: Vector3, lines: Array) -> void:
	K.box(self, pos + Vector3(0, 1.65, 0), Vector3(2.8, 3.3, 0.18), INK, true)
	for i: int in range(lines.size()):
		lettering(self, lines[i], pos + Vector3(0, 2.8 - i * 0.79, 0.11), 23, PAPER, 320)

func _wayfinding() -> void:
	wayfinder(Vector3(4.6, 0, 40), ["↑ 高桌晚宴\nHigh Table", "上园 · Upper Campus", "← 学生中心\nStudent Centre", "支路暂未开放"])
	wayfinder(Vector3(-10, 0, -47.5), ["高桌晚宴\n签到处", "CHECK-IN", "18:30 – 18:55", "→"])
	lettering(self, "请提前准备\n学生袍", Vector3(-9.2, 2.4, -50.15), 24)
	wayfinder(Vector3(15, 0, -44), ["→ 中园 · Middle Campus", "神仙湖 · Fairy Lake", "下园 / 图书馆\nLower Campus / Library", "前方路段暂未开放"])

func _terrace() -> void:
	# An actually walkable raised court, with ramp from the main spine and steps.
	K.box(self, Vector3(11, 0.3, -3), Vector3(8, 0.6, 6), Color("cacabb"), true)
	var ramp := Node3D.new()
	add_child(ramp)
	ramp.position = Vector3(5.1, 0.22, -3)
	ramp.rotation.z = atan2(0.6, 4.4)
	K.box(ramp, Vector3.ZERO, Vector3(4.45, 0.14, 3.0), Color("cacabb"), true)
	for i: int in range(3):
		K.box(self, Vector3(11, 0.10*(i+1), 1.5-i*0.5), Vector3(5,0.2*(i+1),0.5), IVORY, true)
	K.box(self, Vector3(12, 1.16, -4.6), Vector3(3, 0.18, 0.7), Color("9a8063"), true)
	K.tree(self, Vector3(14.2, 0.6, -4), 4)

func _exit_road() -> void:
	# A finite authored road, behind an explicit closed connector. Visual only
	# beyond the planters; no enabled navigation target points into this area.
	K.box(self, Vector3(15.5, 0.03, -40), Vector3(17, 0.12, 5), Color("c5c8b8"))
	var road := Node3D.new()
	add_child(road)
	road.position = Vector3(33, -1.2, -40)
	road.rotation.z = -0.075
	K.box(road, Vector3.ZERO, Vector3(30, 0.2, 6.4), Color("687773"))
	K.box(road, Vector3(0, 0.12, 4.5), Vector3(30, 0.3, 2.3), Color("c5c8b8"))
	for x: int in range(-12, 15, 6):
		K.box(road, Vector3(x, 0.12, 0), Vector3(2.3, 0.02, 0.12), Color("d4cda9"))
		K.tree(road, Vector3(x, 0, -5), 4.2)
		K.cylinder(road, Vector3(x, 2.4, 6), 0.07, 4.8, INK)
		K.box(road, Vector3(x, 4.8, 5.7), Vector3(0.2, 0.12, 0.7), PAPER)
	# Staggered landscape closure, visible and coherent, before the world edge.
	for z: float in [-43, -40, -37]:
		K.box(self, Vector3(18.4, 0.65, z), Vector3(1.5, 1.3, 3.2), IVORY, true)
		K.box(self, Vector3(18.4, 1.5, z), Vector3(1.6, 0.8, 3.3), Color("52745b"))
	K.box(self, Vector3(30.7, 1.0, -40), Vector3(1.5, 2.0, 10), Color("52745b"), true)
	lettering(self, "步道养护中\n请沿原路返回", Vector3(17.5, 2.3, -36.9), 23)
	# Passive semantic landmark; no vehicle, timetable or boarding action.
	var stop := Node3D.new()
	stop.name = "FutureCampusShuttleStop"
	stop.position = Vector3(15, 0, -25)
	stop.set_meta("bus_stop", REGIONS.BUS_STOP.duplicate(true))
	add_child(stop)
	K.box(stop, Vector3(0, 1.6, 0), Vector3(0.10,3.2,0.10), INK)
	K.box(stop, Vector3(0, 2.8, 0), Vector3(1.75,1.2,0.12), INK)
	lettering(stop, "校园接驳候车点\n暂未启用", Vector3(0,2.8,0.08), 22, PAPER, 210)
	K.box(stop, Vector3(0,0.05,1.4), Vector3(3,0.10,2), IVORY)
	for anchor_name: String in ["WaitingArea", "BoardingPoint"]:
		var anchor := Marker3D.new()
		anchor.name = anchor_name
		anchor.position = Vector3(0,0.12,1.4) if anchor_name == "WaitingArea" else Vector3(2,0,-1)
		stop.add_child(anchor)
