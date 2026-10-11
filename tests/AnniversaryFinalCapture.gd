extends "res://tests/CourtyardRefinementCapture.gd"
## Targeted second milestone: only newly revised appearance and Dao Yuan access.
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("anniversary-mall",Vector3(27,38,-125),Vector3(0,4,-320))
	await capture("anniversary-eastgate",Vector3(0,5,-58),Vector3(0,4,-175))
	await capture("anniversary-paving",Vector3(-7,4,-220),Vector3(-19,3,-239))
	await capture("anniversary-student",Vector3(-15,30,-355),Vector3(30,3,-441))
	await capture("anniversary-zhixin",Vector3(-35,10,-721),Vector3(-113,12,-737))
	await capture("anniversary-zhixin-overview",Vector3(-36,62,-693),Vector3(-107,7,-739))
	await capture("anniversary-daoyuan",Vector3(-13,8,-786),Vector3(-62,12,-805))
	await capture("anniversary-daoyuan-corner",Vector3(-13,9,-837),Vector3(-59,11,-808))
	await fixture(Vector3(-18,2.54,-805),[
		[Vector3(-44,2.24,-805),"Dao Yuan front entrance"],
		[Vector3(-53,2.24,-805),"Dao Yuan under canopy"],
		[Vector3(-18,2.24,-805),"Dao Yuan exit"]])
	var report:={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"build_ms":world.built_ms,"scope":"Final material, tree crowns, Dao Yuan envelope; earlier 19-leg corridor result retained."}
	FileAccess.open("res://tests/artifacts/anniversary_final_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ANNIVERSARY_FINAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
