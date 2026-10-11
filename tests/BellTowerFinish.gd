extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("bell-final-v63",Vector3(1,45,-765),Vector3(35,32,-805))
	await capture("bell-plaza-final-v63",Vector3(35,10,-776),Vector3(35,5,-804))
	await fixture(Vector3(35,2.54,-792),[
		[Vector3(26,2.24,-792),"around front handrail"],[Vector3(26,2.24,-796),"left outside stair foot"],
		[Vector3(26,7.74,-813),"left outside ascent"],[Vector3(26,7.74,-815),"back landing west"],
		[Vector3(44,7.74,-815),"back landing across"],[Vector3(44,7.74,-813),"right outside stair head"],
		[Vector3(44,2.24,-796),"right outside descent"],[Vector3(49,2.24,-796),"outer right bypass"],
		[Vector3(49,2.24,-821),"right flank research gap"],[Vector3(19,2.24,-821),"behind tower platform"],
		[Vector3(19,2.24,-811),"corrected public route"],[Vector3(9,2.24,-805),"central avenue interface"],
		[Vector3(0,2.24,-787),"front road junction"],[Vector3(49,2.24,-787),"road in front of tower"],
		[Vector3(49,2.24,-831),"road beside tower"],[Vector3(44,2.24,-833),"research forecourt connection"],
		[Vector3(0,2.24,-833),"road return to main avenue"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"one continuous external stair/perimeter/redirected road route; four unchanged front entry legs retained from first batch; no vehicle steering simulation or full plaza registration"}
	FileAccess.open("res://tests/artifacts/bell_tower_finish_v63.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("BELL_TOWER_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
