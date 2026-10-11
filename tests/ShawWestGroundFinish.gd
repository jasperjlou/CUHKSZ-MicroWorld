extends "res://tests/ShawWestPodiumCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("shaw-west-hill-clear-v53",Vector3(187,21,-674),Vector3(168,11,-652))
	await capture("shaw-west-front-paving-v53",wp(40,12,54),wp(20,5,23))
	await capture("shaw-west-roof-final-v53",wp(-53,75,66),wp(0,15,-1))
	await fixture(wp(24,.35,37),[
		[wp(32,0,37),"clear main stair foot"],[wp(32,.05,31),"front court side entry"],
		[wp(32,.05,0),"campus-facing court"],[wp(16,.05,0),"below podium link"],
		[wp(14.5,.05,-11),"rear public arcade"],[wp(14.5,.05,-21),"rear public room"],
		[wp(14.5,.05,-11),"rear room return"],[wp(35,.05,-11),"side passage out"],
		[Vector3(178.5,2.24,-605),"rear sidewalk north"],[Vector3(178.5,2.24,-658),"rear walk under bridge"],
		[Vector3(178.5,2.24,-680),"rear sidewalk south"],[Vector3(110,2.24,-680),"south return to street"],
		[Vector3(110,2.24,-652),"front street return"],[wp(-12,.05,31),"front canopy"],
		[wp(-12,.05,22),"front public room"],[wp(-12,.05,31),"front room return"],
		[Vector3(110,2.24,-652),"front arcade to street"]])
	var report: Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"build_ms":world.built_ms,"scope":"Targeted ground court/rooms/perimeter after replacing diagonal across stair-foot rail with exterior approach;upper18 legs and5 geometry checks retained. Visual paving/fascia only;no new upper collision."}
	FileAccess.open("res://tests/artifacts/shaw_west_ground_finish_v53.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("SHAW_WEST_GROUND_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
