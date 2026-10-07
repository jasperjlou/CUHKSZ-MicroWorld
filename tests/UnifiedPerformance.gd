extends Node
var world: Node3D
var reports: Array=[]
var agent_measure: Dictionary={}
var navigation_complete:=false
var navigation_result: Dictionary={}
func drive_navigation(api: Node) -> void:
	navigation_result=await api.step({"type":"navigate_to","target":"library_reading"})
	navigation_complete=true
func _ready() -> void:run.call_deferred()
func measure(label: String) -> void:
	for i in 30:await get_tree().process_frame
	var start:=Time.get_ticks_usec()
	for i in 120:await get_tree().process_frame
	reports.append({"mode":label,"frame_ms":(Time.get_ticks_usec()-start)/120000.0,"draw_calls":RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),"nodes":Performance.get_monitor(Performance.OBJECT_NODE_COUNT)})
func run() -> void:
	var baseline: bool="--v5-baseline" in OS.get_cmdline_user_args()
	if DisplayServer.get_name()!="headless":DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var start:=Time.get_ticks_msec()
	world=load("res://world/campus_seamless/CampusSeamless.tscn" if baseline else "res://world/unified/UnifiedCampus.tscn").instantiate();add_child(world)
	var startup:=Time.get_ticks_msec()-start
	if not baseline:
		world.select_mode(false);await world.agent_environment.frames(60)
	world.top_down=true;world.update_mode();world.frame(Vector3(450,0,385),1420)
	await measure("V5 Human overview" if baseline else "V6 Human overview")
	if not baseline:
		world.mode_panel.hide();world.event_demo.set_process(true);world.top_down=false;world.update_mode()
		var api: Node=world.agent_environment
		api.human_mode=false
		await api.reset({"id":"performance","start":"library","goals":["library_reading"]})
		var nav_start:=Time.get_ticks_usec()
		drive_navigation(api)
		await measure("V6 Agent physical navigation")
		while not navigation_complete:await get_tree().physics_frame
		agent_measure={"success":navigation_result.valid,"wall_ms":(Time.get_ticks_usec()-nav_start)/1000.0,"planning_ms":api.navigation_ms,"physics_samples":api.samples,"distance":api.distance,"rendering":DisplayServer.get_name()!="headless","unchanged_physics":true}
		await measure("V6 Agent library view")
	var report: Dictionary={"startup_ms":startup,"frames":120,"measurements":reports,"agent_navigation":agent_measure,"simulation_fixed_fps":60 if DisplayServer.get_name()=="headless" else 0,"machine_specific":true}
	var suffix: String="v5" if baseline else "headless" if DisplayServer.get_name()=="headless" else "v6"
	FileAccess.open("res://tests/artifacts/v6_performance_"+suffix+".json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("V6_PERF ",JSON.stringify(report));get_tree().quit()
