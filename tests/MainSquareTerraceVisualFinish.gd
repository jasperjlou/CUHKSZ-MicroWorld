extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("main-square-shaw-flight-v78",Vector3(22,4.1,-682),Vector3(28,6,-641))
	await capture("main-square-layout-v78",Vector3(-15,72,-759),Vector3(48,5,-700))
	# Local boundary check: the curved street and pavement must stay at the street level.
	for p:Vector2 in [Vector2(0,-636),Vector2(11.5,-636),Vector2(13,-634)]:
		if absf(world.builder.height(p.x,p.y)-2.24)>.03:failures.append("raised road boundary "+str(p))
	var report:Dictionary={"captures":captures,"failures":failures,"scope":"Only outside edge of Shaw-end terrace pulled clear of curved road;stair/upper walk/central lawn/retained garden routes unchanged,24 earlier legs retained"}
	FileAccess.open("res://tests/artifacts/main_square_terrace_visual_v78.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("MAIN_SQUARE_VISUAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
