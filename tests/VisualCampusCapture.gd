extends SceneTree
## Milestone only: rendered views and a single continuous physical route.
var world: Node3D
var failures: Array[String]=[]
var captures: Array[String]=[]
var legs: Array=[]

func _initialize() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	run.call_deferred()

func frames(count: int) -> void:
	for i in count:await physics_frame

func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(12);await RenderingServer.frame_post_draw
	var filename:="visual-campus-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)

func walk(target: Vector3,label: String) -> bool:
	var player: CharacterBody3D=world.player;var count:=0;var lowest:=player.position.y
	while Vector2(target.x-player.position.x,target.z-player.position.z).length()>.8 and count<3000:
		var direction:=Vector2(target.x-player.position.x,target.z-player.position.z).normalized()
		player.navigation_direction=direction
		await physics_frame;count+=1;lowest=minf(lowest,player.position.y)
	player.navigation_direction=Vector2.ZERO
	await frames(12)
	var distance:=Vector2(target.x-player.position.x,target.z-player.position.z).length()
	var valid:=distance<1.5 and lowest>-.3 and absf(player.position.y-target.y)<.6
	if not valid:failures.append("physical route "+label)
	legs.append({"goal":label,"valid":valid,"frames":count,"distance":distance,"lowest_y":lowest,"end":[player.position.x,player.position.y,player.position.z]})
	return valid

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://tests/artifacts")
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world)
	await frames(15)
	# Actual input events exercise the F1 and camera path once at this milestone.
	var event:=InputEventKey.new();event.keycode=KEY_F1;event.pressed=true;world._input(event)
	if not world.information.visible:failures.append("F1 information")
	world._input(event)
	var yaw: float=world.player.orbit_yaw
	world.dragging=true;var motion:=InputEventMouseMotion.new();motion.relative=Vector2(80,10);world._input(motion);world.dragging=false
	if is_equal_approx(yaw,world.player.orbit_yaw):failures.append("camera orbit")
	world.player.orbit_yaw=0;world.player.orbit_pitch=0
	if world.player.human_speed_multiplier!=2.5:failures.append("human speed multiplier")
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("gate",Vector3(0,5,42),Vector3(0,12,-20))
	await capture("entry-court",Vector3(0,5,-18),Vector3(0,6,-95))
	await capture("administration",Vector3(-6,10,-133),Vector3(72,13,-180))
	await capture("library",Vector3(-8,12,-247),Vector3(71,12,-290))
	await capture("promenade",Vector3(0,5,-113),Vector3(0,5,-270))
	await capture("teaching",Vector3(-4,8,-84),Vector3(-65,11,-115))
	await capture("teaching-court",Vector3(-8,42,-66),Vector3(-65,10,-115))
	await capture("student",Vector3(-5,9,-373),Vector3(65,11,-400))
	# One body walks from its normal gate spawn through all connected public paths.
	world.player.set_physics_process(true);world.player.agent_controlled=true
	var route: Array=[[Vector3(0,0,0),"gate origin"],[Vector3(0,0,-28),"gate square"],[Vector3(0,2.24,-82),"raised lawn via stairs"],[Vector3(0,2.24,-155),"central mall east"],[Vector3(0,2.24,-275),"library forecourt"],[Vector3(38,2.24,-275),"pool crossing"],[Vector3(66,2.24,-290),"library portico"],[Vector3(80,6.8,-290),"library second-floor landing"],[Vector3(66,2.24,-290),"library stair descent"],[Vector3(38,2.24,-275),"pool return"],[Vector3(0,2.24,-275),"promenade return"],[Vector3(0,2.24,-115),"teaching approach"],[Vector3(-65,2.24,-115),"teaching court entry"]]
	for leg: Array in route:
		if not await walk(leg[0],leg[1]):break
	world.player.agent_controlled=false;world.overview.current=false;world.player.camera.current=true;world.ui.show();world.player.update_camera(1,true)
	await frames(12);await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tests/artifacts/visual-campus-playable.png")
	report_and_quit()

func report_and_quit() -> void:
	var report: Dictionary={"captures":captures,"failures":failures,"continuous_physical_legs":legs,"no_teleport_during_route":true,"building_count":world.builder.buildings.size(),"route_count":world.data.routes.size(),"build_ms":world.built_ms,"draw_calls":RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),"manual_testing":false,"true_north_calibrated":false}
	FileAccess.open("res://tests/artifacts/visual_campus_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("VISUAL_CAMPUS ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
