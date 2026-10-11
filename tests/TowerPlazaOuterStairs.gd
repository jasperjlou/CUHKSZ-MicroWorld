extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("tower-green-axis-reviewed-v64",Vector3(23,8,-721),Vector3(23,17,-802))
	await capture("tower-Hall-connection-reviewed-v64",Vector3(44,13,-871),Vector3(25,6,-890))
	await fixture(Vector3(14,2.54,-796),[
		[Vector3(14,7.74,-813),"relocated left tower stair"],[Vector3(14,7.74,-815),"rear landing left"],
		[Vector3(32,7.74,-815),"rear landing across"],[Vector3(32,7.74,-813),"right stair head"],
		[Vector3(32,2.24,-796),"relocated right tower stair"],[Vector3(38,2.24,-796),"right stair to footpath"],
		[Vector3(38,2.24,-820),"tower right perimeter"],[Vector3(9.4,2.24,-820),"back perimeter to canopy"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"relocated tower external flights/guarded landing/right and back perimeter;new coordinates replace V63 tests"}
	FileAccess.open("res://tests/artifacts/tower_plaza_outer_stairs_v64.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("TOWER_PLAZA_OUTER ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
