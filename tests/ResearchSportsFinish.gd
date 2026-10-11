extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("research-front-finish-v56",Vector3(0,11,-808),Vector3(89,27,-842))
	await capture("research-overview-finish-v56",Vector3(-15,93,-930),Vector3(93,23,-845))
	await fixture(Vector3(51,2.54,-854),[
		[Vector3(20,2.24,-854),"sports portal side approach"],[Vector3(20,2.24,-850),"clear portal wall front corner"],
		[Vector3(0,2.24,-850),"sports entrance apron"],[Vector3(20,2.24,-854),"sports side return"],
		[Vector3(46,2.24,-854),"outside research plinth"],[Vector3(46,2.24,-929),"sports outer side passage"],
		[Vector3(-14,2.24,-940),"rear promenade approach"]])
	var report: Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"Seven local continuation legs around existing portal corner;retain17 research stairs/garden/ground passages. Sports building identity split remains required."}
	FileAccess.open("res://tests/artifacts/research_sports_finish_v56.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("RESEARCH_SPORTS_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
