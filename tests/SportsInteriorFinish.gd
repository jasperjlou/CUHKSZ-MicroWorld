extends "res://tests/CourtyardRefinementCapture.gd"
const ORIGIN := Vector3(-10,2.24,-947)
func wp(x: float,y: float,z: float) -> Vector3:return ORIGIN+Vector3(x,y,z)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("sports-service-finish-v60",wp(34,1.9,7),wp(29,1.5,-4))
	await capture("sports-corridor-finish-v60",wp(42,6.45,11),wp(7,6.5,12))
	await capture("sports-table-tennis-finish-v60",wp(37.5,6.5,6.8),wp(23,6,-2))
	await capture("sports-gymnastics-finish-v60",wp(-33,6.6,5),wp(-51,6,-3))
	await capture("sports-second-entry-finish-v60",wp(39,3.5,21),wp(31,1.8,4))
	# One continuous run through both ground entries, up the existing stairs and along new corridor.
	await fixture(wp(6.5,5.1,11.2),[
		[wp(6.5,4.8,0),"dance room entry"],
		[wp(6.5,4.8,11.2),"dance room return"],[wp(-16.5,4.8,11.2),"martial-arts doorway approach"],
		[wp(-16.5,4.8,0),"martial-arts room entry"],[wp(-16.5,4.8,11.2),"martial-arts room return"],
		[wp(-45,4.8,11.2),"gymnastics doorway approach"],[wp(-45,4.8,0),"gymnastics room entry"],
		[wp(-45,4.8,11.2),"gymnastics room return"],[wp(43,4.8,11.2),"full corridor return"],
		[wp(43,4.8,-13),"corridor to field gallery side aisle"],[wp(29,4.8,-13),"field gallery connection"],
		[wp(43,4.8,-13),"field gallery return"],[wp(43,4.8,14.5),"corridor to descent"],
		[wp(54,4.8,14.5),"descending stair arrival"],[wp(54,2.4,2.5),"descending half landing"],
		[wp(48,2.4,2.5),"descending turn"],[wp(48,0,14.5),"ground return"],
		[wp(59,0,14.5),"ground outside aisle"],[wp(59,0,0),"ground foyer return"],
		[wp(39,0,0),"service reentry"],[wp(35.2,0,0),"reception side return"],
		[wp(35.2,0,4),"open gates return"],[wp(31,0,7),"entrance foyer return"],
		[wp(31,0,19),"long-side exit return"]])
	var report: Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"V60 continuation after moving lockers off dance and martial-arts doorways; retain19 unaffected initial legs. Final material images also captured. Model positions remain fitted."}
	FileAccess.open("res://tests/artifacts/sports_interior_finish_v60.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("SPORTS_INTERIOR_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
