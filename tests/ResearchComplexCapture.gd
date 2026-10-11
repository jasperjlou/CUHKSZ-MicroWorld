extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("research-front-v56",Vector3(0,11,-808),Vector3(89,27,-842))
	await capture("research-overview-v56",Vector3(-15,93,-930),Vector3(93,23,-845))
	await capture("research-garden-v56",Vector3(82,17,-867),Vector3(93,30,-828))
	await fixture(Vector3(25,2.54,-845),[
		[Vector3(42,7.74,-845),"lower flight to middle landing"],[Vector3(56,13.74,-845),"upper flight to terrace"],
		[Vector3(68,13.74,-845),"front wing public doorway"],[Vector3(85,13.74,-845),"front wing to garden"],
		[Vector3(100,13.74,-845),"garden centre path"],[Vector3(85,13.74,-845),"garden path return"],
		[Vector3(68,13.74,-845),"front hall return"],[Vector3(56,13.74,-845),"upper stair landing return"],
		[Vector3(42,7.74,-845),"upper flight descent"],[Vector3(25,2.24,-845),"lower flight descent"]])
	await fixture(Vector3(43,2.54,-837),[
		[Vector3(51,2.24,-845),"under upper flight to ground door"],[Vector3(70,2.24,-845),"ground plinth doorway"],
		[Vector3(91,2.24,-845),"ground sheltered passage"],[Vector3(130,2.24,-845),"rear service exit"],
		[Vector3(91,2.24,-845),"rear service return"],[Vector3(51,2.24,-845),"ground passage return"],
		[Vector3(51,2.24,-854),"under stair side exit"],[Vector3(0,2.24,-854),"research to sports apron"],
		[Vector3(46,2.24,-854),"sports side approach"],[Vector3(46,2.24,-929),"sports side passage to rear"],
		[Vector3(-14,2.24,-940),"rear promenade to track"]])
	var report: Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"Research public podium/terrace stairs,courtyard,ground passage and Sports side route;upper laboratory floors and exact dimensions not verified."}
	FileAccess.open("res://tests/artifacts/research_complex_v56.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("RESEARCH_COMPLEX ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
