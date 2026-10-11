extends Control
const FONT := preload("res://systems/ChineseText.gd").FONT
const AREA := Rect2(12,34,216,242)
var world: Node3D
var bounds: Rect2
var map_scale: float
var map_offset: Vector2

func _ready() -> void:
	position=Vector2(18,18);size=Vector2(240,302);mouse_filter=Control.MOUSE_FILTER_STOP
	var a: Array=world.data.terrain.bounds;bounds=Rect2(a[0],a[1],a[2]-a[0],a[3]-a[1])
	map_scale=minf(AREA.size.x/bounds.size.x,AREA.size.y/bounds.size.y)
	map_offset=AREA.position+(AREA.size-bounds.size*map_scale)/2

func project(p: Vector3) -> Vector2:
	return map_offset+(Vector2(p.x,p.z)-bounds.position)*map_scale

func _process(_delta: float) -> void:
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed:
		var closest: Dictionary={};var distance:=9.0
		for record: Dictionary in world.data.landmarks:
			var d:=project(world.builder.point(record.position)).distance_to(event.position)
			if d<distance:distance=d;closest=record
		if not closest.is_empty():world.destination=closest;accept_event()

func _draw() -> void:
	draw_style_box(panel_style(),Rect2(Vector2.ZERO,size))
	draw_string(FONT,Vector2(13,23),"东门入校 ↑",HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("edf0e5"))
	draw_rect(AREA,Color("647651"))
	for region: Dictionary in world.data.get("surface_regions",[]):
		var a: Array=region.bounds;var p0:=project(Vector3(a[0],0,a[1]));var p1:=project(Vector3(a[2],0,a[3]))
		draw_rect(Rect2(p0,p1-p0),Color("718458") if region.kind=="lawn" else Color("b1b4ac"))
	for space: Dictionary in world.data.get("public_spaces",[]):
		if not space.has("bounds"):continue
		var a: Array=space.bounds;var p0:=project(Vector3(a[0],0,a[1]));var p1:=project(Vector3(a[2],0,a[3]))
		draw_rect(Rect2(p0,p1-p0),Color("567c7a") if space.has("water_level") else Color("8d8e7a"))
		draw_rect(Rect2(p0,p1-p0),Color("465c53"),false,1)
	for r: Dictionary in world.data.routes:
		if not r.get("render_surface",true):continue
		for i in range(r.points.size()-1):
			draw_line(project(world.builder.point(r.points[i])),project(world.builder.point(r.points[i+1])),Color("526f49") if r.kind=="green" else Color("cad0bc"),maxf(1.0,float(r.width)*map_scale))
	for b: Dictionary in world.data.buildings:
		if b.id=="shaw_west":
			var plan:=preload("res://world/visual_campus/ShawWestPlan.gd")
			var frame:Node3D=world.builder.buildings.shaw_west.get_node("WestPlanFrameV143")
			# Same source rectangles and live transform as the model, not the old66x60 box.
			for r:Rect2 in plan.ground_parts():draw_plan_rect(r,frame,Color("acae9f"))
			for r:Rect2 in [plan.rect(699,247,346,292),plan.rect(1045,624,139,182)]:draw_plan_rect(r,frame,Color("56724d"))
			for r:Rect2 in [plan.rect(474,64,225,475),plan.rect(474,615,541,222),plan.rect(1217,737,224,541)]:draw_plan_rect(r,frame,Color("d6d4c0"))
			continue
		var centre: Vector3=world.builder.point(b.position)
		if b.has("footprint_offset"):centre+=Basis(Vector3.UP,deg_to_rad(float(b.yaw)))*world.builder.point(b.footprint_offset)
		var p:=project(centre)
		var yaw:=deg_to_rad(float(b.yaw));var s:=Vector2(absf(cos(yaw))*b.width+absf(sin(yaw))*b.depth,absf(sin(yaw))*b.width+absf(cos(yaw))*b.depth)*map_scale
		draw_rect(Rect2(p-s/2,s),Color("d6d4c0"));draw_rect(Rect2(p-s/2,s),Color("31443c"),false,1)
	for record: Dictionary in world.data.landmarks:
		var p:=project(world.builder.point(record.position));draw_circle(p,3,Color("e9dfaa"))
		if record.id in ["east_gate","library_entry","student_entry","main_square","sports_entry","track_entry"]:draw_string(FONT,p+Vector2(5,-4),record.name,HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("fff4d0"))
	var p:=project(world.player.global_position);draw_circle(p,4,Color("fff7dc"))
	var forward: Vector3=-world.player.camera.global_basis.z;var d:=Vector2(forward.x,forward.z).normalized()
	draw_line(p,p+d*10,Color("fff7dc"),2)
	if not world.destination.is_empty():
		var goal:=project(world.builder.point(world.destination.position));draw_line(p,goal,Color("e5bc73"),1);draw_circle(goal,6,Color("e5bc73"),false,2)
	draw_string(FONT,Vector2(13,292),"点击地点设目标 · 局部方位图",HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("c4cec0"))

func draw_plan_rect(r:Rect2,frame:Node3D,color:Color)->void:
	var poly:=PackedVector2Array()
	for p:Vector2 in [r.position,Vector2(r.end.x,r.position.y),r.end,Vector2(r.position.x,r.end.y)]:poly.append(project(frame.to_global(Vector3(p.x,0,p.y))))
	draw_colored_polygon(poly,color)

func panel_style() -> StyleBoxFlat:
	var style:=StyleBoxFlat.new();style.bg_color=Color(0.08,0.14,0.12,.94)
	style.corner_radius_top_left=8;style.corner_radius_top_right=8;style.corner_radius_bottom_left=8;style.corner_radius_bottom_right=8
	return style
