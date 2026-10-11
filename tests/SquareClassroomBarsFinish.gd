extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("square-classroom-ends-v77",Vector3(-4,4.1,-700),Vector3(66,14,-700))
	await capture("square-classroom-layout-v77",Vector3(-12,73,-762),Vector3(74,10,-698))
	await capture("zhiren-garden-elevation-v77",Vector3(55,6.5,-761),Vector3(85,13,-734))
	await capture("classroom-upper-lane-v77",Vector3(44,6.5,-697),Vector3(111,8,-711))
	# Finish the public circuit through the actual inter-column gaps.
	await fixture(Vector3(83.4,4.94,-666),[
		[Vector3(81,4.64,-666),"align between retained columns"],
		[Vector3(81,4.64,-681),"Chengdao side exit"],[Vector3(81,4.64,-697),"shared upper lane"],
		[Vector3(94,4.64,-697),"Letian court approach"],[Vector3(94,4.64,-713),"Letian doorway alignment"],
		[Vector3(110,4.64,-713),"Letian existing open door"],[Vector3(94,4.64,-713),"Letian return"],
		[Vector3(81,4.64,-713),"Zhiren side approach"],[Vector3(81,4.64,-734),"Zhiren open lower aisle"],
		[Vector3(81,4.64,-751),"Zhiren garden colonnade exit"],[Vector3(62,4.64,-751),"Zhiren garden frontage"],
		[Vector3(62,4.64,-734),"Zhiren garden colonnade return"],[Vector3(47,4.64,-734),"Zhiren narrow-end opening"],
		[Vector3(43,4.64,-734),"Zhiren stair head"],[Vector3(24,2.24,-734),"Zhiren stair descent"],
		[Vector3(9,2.24,-734),"lower Main Square sidewalk"],[Vector3(9,2.24,-697),"central terrace approach"],
		[Vector3(24,2.24,-697),"central stair foot"],[Vector3(43,4.64,-697),"central stair ascent"],
		[Vector3(75,4.64,-697),"upper court free passage"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"retained_initial_legs":4,"scope":"V77 rebuilt Chengdao/Zhiren long bars,LeTian overlap removal and affected ground routes;exact footprint,junctions,private rooms and vertical cores incomplete"}
	FileAccess.open("res://tests/artifacts/square_classroom_bars_finish_v77.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("SQUARE_CLASSROOM_BARS_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
