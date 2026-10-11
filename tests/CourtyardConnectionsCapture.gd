extends "res://tests/CourtyardRefinementCapture.gd"
## Follow-up milestone: new admin stair and the completed upper link; no repeat of the 16 passed legs.
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("administration",Vector3(5,9,-136),Vector3(73,12,-180))
	await capture("administration-stair",Vector3(42,4.2,-181),Vector3(95,12,-180))
	await capture("student-front",Vector3(-8,15,-366),Vector3(68,13,-400))
	await capture("student-courts",Vector3(4,66,-350),Vector3(72,12,-400))
	await capture("library-front",Vector3(2,12,-237),Vector3(78,14,-290))
	await capture("library-roof",Vector3(-5,63,-227),Vector3(81,13,-290))
	await capture("district-courtyard",Vector3(-25,38,-308),Vector3(40,5,-359))
	await capture("upper-link",Vector3(56,8.3,-350),Vector3(56,7.9,-329))
	await fixture(Vector3(51,2.54,-180),[
		[Vector3(75,6.64,-180),"administration intermediate landing"],
		[Vector3(95,11.04,-180),"administration upper landing"],
		[Vector3(75,6.64,-180),"administration landing descent"],
		[Vector3(55,2.24,-180),"administration ground return"]])
	await fixture(Vector3(78,6.94,-408),[
		[Vector3(78,6.64,-382),"student gallery transverse aisle"],
		[Vector3(56,6.64,-382),"student gallery return"],
		[Vector3(56,6.64,-360),"student side doorway and link"],
		[Vector3(56,6.64,-330),"covered upper walk"],
		[Vector3(61,6.64,-330),"library upper corner threshold"],
		[Vector3(66,6.64,-326.8),"library inset gallery transfer"],
		[Vector3(88,6.64,-326.8),"library upper side gallery"],
		[Vector3(88,6.64,-302),"library upper transverse gallery"],
		[Vector3(88,6.64,-290),"library main upper foyer"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":2,"no_teleport_within_each_fixture":true,"build_ms":world.built_ms,"draw_calls":RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),"scope":"admin staircase and student-library upper connection"}
	FileAccess.open("res://tests/artifacts/courtyard_connections_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("COURTYARD_CONNECTIONS ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
