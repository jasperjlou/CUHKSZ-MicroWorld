extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("zhixin-branch-v81",Vector3(3,5,-670),Vector3(-52,4,-683))
	await capture("zhixin-parking-v81",Vector3(-77,5,-689),Vector3(-78,4,-751))
	await capture("zhixin-side-layout-v81",Vector3(-101,57,-668),Vector3(-48,3,-723))
	var report:Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"scope":"V81 noncollision curved-mouth paving and removal of obsolete verge planting;physical route unchanged"}
	FileAccess.open("res://tests/artifacts/zhixin_side_streets_visual_v81.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ZHIXIN_SIDE_STREETS_VISUAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
