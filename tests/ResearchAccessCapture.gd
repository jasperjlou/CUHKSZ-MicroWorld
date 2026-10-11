extends "res://tests/StartZoneBuildingsCapture.gd"
## Retest only the obstructed straight test segment, using the space between real columns.
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world)
	await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("zhi-ren",Vector3(15,12,-759),Vector3(57,10,-734))
	await capture("research",Vector3(25,7,-810),Vector3(91,13,-845))
	world.player.position=Vector3(9,2.54,-845);world.player.velocity=Vector3.ZERO
	world.player.set_physics_process(true);world.player.agent_controlled=true;await frames(20)
	for leg: Array in [[Vector3(9,2.24,-849),"research side approach"],[Vector3(91,2.24,-849),"research column bypass"],[Vector3(91,2.24,-845),"research sheltered base"],[Vector3(91,2.24,-849),"research exit"],[Vector3(9,2.24,-849),"research sidewalk return"]]:
		if not await walk(leg[0],leg[1]):break
	report_and_quit()

func report_and_quit() -> void:
	var report: Dictionary={"captures":captures,"failures":failures,"continuous_physical_legs":legs,"fixture_start":[9,2.54,-845],"no_teleport_during_route":true,"build_ms":world.built_ms,"scope":"research access only; preceding 21 start-zone legs retained in original report"}
	FileAccess.open("res://tests/artifacts/research_access_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("RESEARCH_ACCESS ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
