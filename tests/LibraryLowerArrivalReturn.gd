extends "res://tests/LibraryLowerLevelCapture.gd"
## Finish only the service-counter return through the actual lower door.
## The previous diagonal target crossed the curved exterior glazing outside its opening.
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await fixture(wp(-18,.3,31),[
		[wp(-18,0,27),"actual lower doorway approach"],[wp(-15.4,0,26.1),"ITSO reachable public face"],
		[wp(-18,0,27),"return along interior door corridor"],[wp(-18,0,31),"exit through opening not glazing"]])
	var report:Dictionary={"physical_legs":legs,"failures":failures,"scope":"service visit and return using existing lower door;no model change from finish run","no_teleport_within_fixture":true}
	FileAccess.open("res://tests/artifacts/library_lower_arrival_return_v72.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_ARRIVAL_RETURN ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
