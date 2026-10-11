extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("bell-axis-v63",Vector3(20,16,-713),Vector3(35,28,-805))
	await capture("bell-eaves-v63",Vector3(1,45,-765),Vector3(35,32,-805))
	await capture("bell-base-v63",Vector3(16,11,-784),Vector3(35,6,-805))
	await capture("bell-site-v63",Vector3(5,64,-784),Vector3(35,5,-817))
	await fixture(Vector3(35,2.54,-789),[
		[Vector3(35,2.24,-794),"front apron"],[Vector3(35,2.84,-798.5),"front four-step ascent"],
		[Vector3(35,2.84,-800),"base glazed entry threshold"],[Vector3(35,2.24,-794),"front descent"],
		[Vector3(26,2.24,-795),"left outside stair foot"],[Vector3(26,7.74,-813),"left outside ascent"],
		[Vector3(26,7.74,-815),"back landing west"],[Vector3(44,7.74,-815),"back landing across"],
		[Vector3(44,7.74,-813),"right outside stair head"],[Vector3(44,2.24,-796),"right outside descent"],
		[Vector3(49,2.24,-796),"outer right bypass"],[Vector3(49,2.24,-821),"right flank research gap"],
		[Vector3(19,2.24,-821),"behind tower platform"],[Vector3(19,2.24,-811),"corrected public route"],
		[Vector3(9,2.24,-805),"central avenue interface"],[Vector3(19,2.24,-811),"return route bend"],
		[Vector3(19,2.24,-820),"return platform bypass"],[Vector3(43,2.24,-833),"research forecourt north of stair"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"single continuous tower apron/external stairs/back landing/perimeter/Research forecourt fixture; no tower interior access or surveyed registration claimed"}
	FileAccess.open("res://tests/artifacts/bell_tower_v63.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("BELL_TOWER ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
