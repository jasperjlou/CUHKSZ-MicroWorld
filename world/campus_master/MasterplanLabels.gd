extends Control
const G := preload("res://world/campus_master/CampusGeometry.gd")
const FONT := preload("res://systems/ChineseText.gd").FONT
var world: Node3D

func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE

func _process(_delta: float) -> void:
	visible=world.top_down and world.show_labels
	if visible: queue_redraw()

func _draw() -> void:
	var camera: Camera3D=world.overview
	var view := get_viewport_rect()
	var occupied: Array[Rect2]=[Rect2(0,0,256,320)]
	for r: Dictionary in G.master.regions:
		var p := camera.unproject_position(G.vec(r.center))+Vector2(0,-55)
		if view.has_point(p):
			var size := FONT.get_string_size(r.name_zh,HORIZONTAL_ALIGNMENT_LEFT,-1,19)
			occupied.append(Rect2(p-Vector2(0,20),size+Vector2(0,8)))
			draw_string(FONT,p,r.name_zh,HORIZONTAL_ALIGNMENT_LEFT,-1,19,Color("29463e"))
	for o: Dictionary in G.master.objects:
		if o.category not in ["building","lake","track","gate"]: continue
		var p := camera.unproject_position(G.vec(o.center)+Vector3.UP*float(o.estimated_height))
		if not view.grow(30).has_point(p): continue
		var marker := "[推]" if o.confidence=="inferred" else ("[实]" if o.confidence=="verified" else "[占]")
		var zh: String = marker+" "+o.name_zh
		var en: String = "空间："+("推定" if o.confidence=="inferred" else "已核实" if o.confidence=="verified" else "占位")
		if world.objects.has(o.id) and world.objects[o.id].has_meta("architecture_profile"):
			var profile: Dictionary=world.objects[o.id].get_meta("architecture_profile")
			en+=" · 建筑："+{"STRONG_REFERENCE":"明确参考","SUPPORTED":"参考支持","APPROXIMATED":"近似","PLACEHOLDER":"占位"}[profile.architecture_confidence]
		var width := maxf(FONT.get_string_size(zh,HORIZONTAL_ALIGNMENT_LEFT,-1,12).x,FONT.get_string_size(en,HORIZONTAL_ALIGNMENT_LEFT,-1,10).x)+10
		var chosen := Rect2(p+Vector2(6,-26),Vector2(width,35))
		var offsets: Array[Vector2]=[Vector2(6,-26),Vector2(-width-6,-26),Vector2(6,8),Vector2(-width-6,8)]
		for radius in range(40,481,40):
			for direction in range(16):
				offsets.append(Vector2(cos(direction*TAU/16),sin(direction*TAU/16))*radius-Vector2(width/2,17))
		var found := false
		for offset in offsets:
			var candidate := Rect2(p+offset,Vector2(width,35))
			var blocked := not view.grow(-8).encloses(candidate)
			for existing: Rect2 in occupied:
				if candidate.grow(2).intersects(existing): blocked=true;break
			if not blocked: chosen=candidate;found=true;break
		if not found:continue # Zooming into a region provides more label space.
		occupied.append(chosen)
		draw_line(p,chosen.get_center(),Color("526e61"),.7,true)
		draw_circle(p,2,Color("39594c"))
		draw_style_box(panel(),chosen)
		draw_string(FONT,chosen.position+Vector2(5,14),zh,HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("263d35"))
		draw_string(FONT,chosen.position+Vector2(5,28),en,HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("53645a"))

func panel() -> StyleBoxFlat:
	var style := StyleBoxFlat.new();style.bg_color=Color(.92,.94,.87,.88)
	style.corner_radius_top_left=3;style.corner_radius_bottom_right=3
	return style
