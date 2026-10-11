extends Control
## Lightweight schematic from the same public campus geometry; no second camera.
const G := preload("res://world/campus_exterior/ExteriorGeometry.gd")
const FONT := preload("res://systems/ChineseText.gd").FONT
const MAP_RECT := Rect2(12, 34, 216, 202)
var world: Node3D
var bounds := Rect2(-220, -290, 1360, 1350)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	position = Vector2(18, 18)
	size = Vector2(240, 260)
	var terrain: Dictionary = G.master.terrain
	bounds = Rect2(terrain.x_min, terrain.z_min, terrain.x_max - terrain.x_min, terrain.z_max - terrain.z_min)

func map_point(point: Vector3) -> Vector2:
	return MAP_RECT.position + (Vector2(point.x, point.z) - bounds.position) / bounds.size * MAP_RECT.size

func _process(_delta: float) -> void:
	visible = is_instance_valid(world.mode_panel) and not world.mode_panel.visible
	if visible: queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if not world.agent_environment.human_mode: return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and MAP_RECT.has_point(event.position):
		var closest := ""
		var distance := 18.0
		for building: Dictionary in G.master.objects:
			if building.category != "building" or not world.agent_environment.registry.locations.has(building.id): continue
			var gap := map_point(G.vec(building.center)).distance_to(event.position)
			if gap < distance: closest = building.id; distance = gap
		if not closest.is_empty(): world.explore_guide.set_destination(closest)
		accept_event()

func _draw() -> void:
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color("18342fe8")
	panel.corner_radius_top_left = 10
	panel.corner_radius_top_right = 10
	panel.corner_radius_bottom_left = 10
	panel.corner_radius_bottom_right = 10
	draw_style_box(panel, Rect2(Vector2.ZERO, size))
	draw_string(FONT, Vector2(12, 23), "校园地图", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("e9f1dd"))
	draw_string(FONT, Vector2(192, 23), "示意", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("c8d5c0"))
	draw_rect(MAP_RECT, Color("82967b"))
	var lake := PackedVector2Array()
	for point: Array in G.master.lake.shoreline:
		lake.append(map_point(Vector3(point[0], 0, point[1])))
	if lake.size() >= 3: draw_colored_polygon(lake, Color("5c9ca6"))
	for road: Dictionary in G.paths.paths:
		var line := PackedVector2Array()
		for point: Array in road.geometry: line.append(map_point(G.vec(point)))
		if line.size() > 1: draw_polyline(line, Color("e2d4aa"), 1.6, true)
	for building: Dictionary in G.master.objects:
		if building.category != "building": continue
		var center := map_point(G.vec(building.center))
		var footprint := Vector2(building.footprint_width, building.footprint_depth) / bounds.size * MAP_RECT.size
		draw_rect(Rect2(center - footprint / 2, footprint), Color("465d58"))
	for region: Dictionary in G.master.regions:
		draw_string(FONT, map_point(G.vec(region.center)) + Vector2(-14, -6), region.name_zh, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("f6f3df"))
	var player_point := map_point(world.player.global_position).clamp(MAP_RECT.position + Vector2(5, 5), MAP_RECT.end - Vector2(5, 5))
	if is_instance_valid(world.explore_guide) and not world.explore_guide.target_id.is_empty():
		var target := map_point(world.agent_environment.registry.anchor(world.explore_guide.target_id))
		draw_line(player_point, target, Color("ffe184aa"), 1.2, true)
		draw_arc(target, 6, 0, TAU, 24, Color("ffe184"), 2, true)
	var forward := Vector2(-world.player.camera.global_basis.z.x, -world.player.camera.global_basis.z.z).normalized()
	var side := Vector2(-forward.y, forward.x)
	draw_circle(player_point, 6, Color("16322d"))
	draw_colored_polygon(PackedVector2Array([player_point + forward * 9, player_point - forward * 4 + side * 5, player_point - forward * 4 - side * 5]), Color("ffe184"))
	draw_string(FONT, Vector2(12, 252), "▲ 你的位置 · 点击建筑设目标", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("e9f1dd"))
