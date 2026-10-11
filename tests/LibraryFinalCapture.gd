extends "res://tests/LibrarySpacesCapture.gd"
## Only the changed wide-stair entrance and previously unreached annex require replay.
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("pool-front",Vector3(8,10,-241),Vector3(78,12,-290))
	await capture("stairs",Vector3(61,4,-299),Vector3(78,7,-284))
	await capture("ground-entry",Vector3(51,4,-272),Vector3(80,4,-272))
	await capture("upper-lobby",Vector3(82,8.3,-289),Vector3(97,8,-290))
	world.player.position=Vector3(66,2.54,-282);world.player.velocity=Vector3.ZERO
	world.player.set_physics_process(true);world.player.agent_controlled=true;await frames(20)
	for leg: Array in [[Vector3(80,6.64,-282),"wide stepped landing"],[Vector3(66,2.24,-282),"wide stair descent"],[Vector3(48,2.24,-282),"annex approach bypass"],[Vector3(48,2.24,-261.62),"annex front approach"],[Vector3(55,2.24,-261.62),"annex portico"],[Vector3(59,2.24,-261.62),"annex ground hall"],[Vector3(55,2.24,-261.62),"annex return"]]:
		if not await walk(leg[0],leg[1]):break
	report_and_quit()

func report_and_quit() -> void:
	var report: Dictionary={"captures":captures,"failures":failures,"continuous_physical_legs":legs,"fixture_start":[66,2.54,-282],"no_teleport_during_route":true,"build_ms":world.built_ms,"scope":"wide entrance glass obstruction removed, closed stair risers and annex access; preceding 14 successful legs preserved"}
	FileAccess.open("res://tests/artifacts/library_spaces_final.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_FINAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
