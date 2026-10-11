extends "res://tests/CourtyardRefinementCapture.gd"
## One continuous circuit from the upper entrance through the lower public wings and back.
func wp(x: float,y: float,z: float) -> Vector3:
	return Vector3(78-z,2.24+y,-290+x)

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("lower-stair-pocket",wp(-5,1.8,1),wp(1,2,-2.5))
	await capture("lower-left-corridor",wp(-17,1.8,-8),wp(-33,1.7,-10))
	await capture("lower-group-room",wp(-31,1.8,-10),wp(-31,1.8,-16))
	await capture("lower-right-corridor",wp(17,1.8,-8),wp(32,1.8,-12))
	await capture("lower-room119",wp(29,1.8,-12.5),wp(31,1.7,-19))
	await capture("lower-study-front",wp(-18,1.8,10),wp(-28,1.8,2))
	await fixture(wp(0,4.7,-7),[
		[wp(0,4.4,-2.2),"upper landing to entrance stair"],[wp(0,0,12),"entrance stair descent"],
		[wp(-18,0,12),"lower front approach"],[wp(-18,0,-8),"G entry into left aisle"],
		[wp(-31,0,-8),"group study cross aisle"],[wp(-31,0,-13.2),"room 101 doorway"],
		[wp(-31,0,-8),"room 101 return"],[wp(-36.5,0,-8),"window study aisle"],
		[wp(-31,0,-8),"left aisle return"],[wp(-18,0,-8),"left wing to centre"],
		[wp(0,0,-8),"central lower hall"],[wp(0,0,-.7),"high-end stair underside pocket"],
		[wp(0,0,-8),"stair pocket return"],[wp(18,0,-8),"central hall to right wing"],
		[wp(29,0,-8),"room 119 approach"],[wp(29,0,-12.6),"room 119 open doorway"],
		[wp(29,0,-8),"room 119 return"],[wp(18,0,-8),"right aisle return"],
		[wp(18,0,10),"right lower entrance return"],[wp(18,0,8.5),"frontage aisle approach"],
		[wp(28,0,8.5),"compact stacks frontage"],[wp(18,0,8.5),"front study return"],[wp(18,0,12),"G exit"],
		[wp(0,0,12),"main stair foot"],[wp(0,4.4,-4),"entrance stair ascent"]])
	var report:={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"no_teleport_within_each_fixture":true,"build_ms":world.built_ms,"scope":"User-confirmed interior below main entrance: ground public wings, four group rooms, 119, 116 frontage and hollow upper stair underside. Room dimensions and locations fitted, incomplete plan registration."}
	FileAccess.open("res://tests/artifacts/library_lower_level_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_LOWER_LEVEL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
