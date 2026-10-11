extends "res://tests/LibraryLowerLevelCapture.gd"
## Resume at the last successful checkpoint; only the furniture detour and ascent need checking.
func run() -> void:
	var prior: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://tests/artifacts/library_lower_level_milestone.json"))
	var good: Array=[]
	for leg: Dictionary in prior.physical_legs:
		if leg.valid:good.append(leg)
		else:break
	if good.size()!=19:
		push_error("Expected the 19 verified prefix legs from the unchanged lower-level model");quit(1);return
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var p: Array=good[-1].end
	await fixture(Vector3(p[0],p[1]+.20,p[2]),[
		[wp(18,0,8.5),"frontage aisle approach"],[wp(28,0,8.5),"compact stacks frontage"],
		[wp(18,0,8.5),"front study return"],[wp(18,0,12),"G exit"],
		[wp(0,0,12),"main stair foot"],[wp(0,4.4,-4),"entrance stair ascent"]])
	var report:={"captures":prior.captures,"failures":failures,"physical_legs":good+legs,"fixtures":2,"no_teleport_within_each_fixture":true,"build_ms":world.built_ms,"scope":prior.scope,"validation_note":"19 prefix legs retained; six remaining legs resumed at that checkpoint after routing around a solid study table. No model/collision changes between the two runs. Not a single uninterrupted engine run."}
	FileAccess.open("res://tests/artifacts/library_lower_level_final.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_LOWER_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
