extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("tower-axis-final-v64",Vector3(23,8,-721),Vector3(23,17,-802))
	await capture("tower-junction-final-v64",Vector3(-1,34,-822),Vector3(26,2.24,-842))
	await fixture(Vector3(27,2.54,-876),[
		[Vector3(30,2.24,-884),"canopy outside stair side"],[Vector3(30,2.24,-893.889),"Hall stair frontal approach"],[Vector3(24,3.08,-893.889),"Hall stair ascent"],[Vector3(30,2.24,-893.889),"Hall stair descent"],[Vector3(30,2.24,-876),"Hall forecourt return"],[Vector3(38,2.24,-876),"road footpath connection"],[Vector3(44,2.24,-865),"road below Research stair"],
		[Vector3(35,2.24,-861),"road curved lower leg"],[Vector3(28,2.24,-857),"road bend southwest"],
		[Vector3(24,2.24,-852),"road beside stair foot"],[Vector3(24,2.24,-839),"road before stair foot"],
		[Vector3(23,2.24,-834),"road corner return"],[Vector3(35,2.24,-831),"road upper curve"],
		[Vector3(43,2.24,-827),"road upper bend"],[Vector3(45,2.24,-823),"road eastern side"],
		[Vector3(45,2.24,-782),"road parallel to axial garden"],[Vector3(55,2.24,-778),"hill road junction"],
		[Vector3(78,2.24,-778),"hill road continuation"],[Vector3(105,2.24,-781),"hill-side connection"],
		[Vector3(130,2.24,-781),"existing service route junction"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"Hall frontal stair entry and continuous curved road/hill;10+2+3+4 preceding legs retained;no driving or surveyed grade certification"}
	FileAccess.open("res://tests/artifacts/tower_plaza_road_final_v64.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("TOWER_PLAZA_ROAD_FINAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
