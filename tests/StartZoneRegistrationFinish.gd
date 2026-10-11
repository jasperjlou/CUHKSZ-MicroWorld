extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("classroom-terrace-clear-v54",Vector3(-6,6,-703),Vector3(51,12,-698))
	# Main-square lobby has a column at world Z=-735. Use the actual door gap beside it.
	await fixture(Vector3(-44,2.54,-735),[
		[Vector3(-44,2.24,-733),"lobby door alignment"],[Vector3(-51,2.24,-733),"rear lobby through open door"],
		[Vector3(-44,2.24,-733),"rear lobby return"],[Vector3(-33,2.24,-733),"court side-door approach"],
		[Vector3(-33,2.24,-700),"north wing public lower"],[Vector3(-33,2.24,-733),"north wing return"],
		[Vector3(-33,2.24,-765),"south wing public lower"],[Vector3(-33,2.24,-733),"south wing return"],
		[Vector3(-8.1,2.24,-733),"courtyard back to street"]])
	# The west-facing arcade is reached around the solid rear classroom wall, not through it.
	await fixture(Vector3(82,4.94,-734),[
		[Vector3(82,4.64,-770),"Zhiren rear perimeter"],[Vector3(52,4.64,-770),"Zhiren end-wall perimeter"],
		[Vector3(52,4.64,-734),"Zhiren public arcade approach"],[Vector3(61,4.64,-734),"Zhiren open ground entrance"],
		[Vector3(52,4.64,-734),"Zhiren entrance return"],[Vector3(43,4.64,-734),"Zhiren terrace head"],
		[Vector3(24,2.24,-734),"Zhiren terrace descent"],[Vector3(9,2.24,-734),"lower square return"],
		[Vector3(-8.1,2.24,-735),"road crossing to library"]])
	var report: Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"Only failed V54 route continuations and final stair approach visual; retain the initial18 passed legs."}
	FileAccess.open("res://tests/artifacts/start_zone_registration_finish_v54.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("START_ZONE_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
