extends "res://tests/ResearchDetailCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("tu-arcade",Vector3(-40.7,4.1,-508),Vector3(-41,4.3,-550))
	await capture("hall",Vector3(-61,4,-535),Vector3(-82,4,-535))
	await fixture(Vector3(-92,2.54,-535),[
		[Vector3(-75,2.24,-535),"B entry with clear column line"],[Vector3(-35,2.24,-535),"B road exit"],
		[Vector3(-75,2.24,-535),"B hall return"],[Vector3(-92,2.24,-535),"B passage return"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"build_ms":world.built_ms,"scope":"Only Tu entrances after moving an intrusive column out of the door opening; bronze screen braces added"}
	FileAccess.open("res://tests/artifacts/research_detail_finish.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("RESEARCH_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
