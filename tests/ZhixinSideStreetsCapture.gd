extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("zhixin-branch-v81",Vector3(3,5,-670),Vector3(-52,4,-683))
	await capture("zhixin-parking-v81",Vector3(-77,5,-689),Vector3(-78,4,-751))
	await capture("zhixin-side-layout-v81",Vector3(-101,57,-668),Vector3(-48,3,-723))
	await fixture(Vector3(-8.1,2.54,-700),[
		[Vector3(-8.1,2.24,-675),"main sidewalk crossing branch"],[Vector3(-69,2.24,-675.9),"branch north pedestrian strip"],
		[Vector3(-76,2.24,-682),"parking junction"],[Vector3(-76,2.24,-764),"rear parking aisle"],
		[Vector3(-82,2.24,-764),"parking bay access"],[Vector3(-82,2.24,-701),"parking bays clear of wheel stops"],
		[Vector3(-76,2.24,-701),"return to aisle"],[Vector3(-76,2.24,-682),"return to junction"],
		[Vector3(-169,2.24,-682),"branch to perimeter"],[Vector3(-174,2.24,-682),"perimeter road joined"],
		[Vector3(-76,2.24,-682),"branch return"],[Vector3(-76,2.24,-695),"parking entry return"],
		[Vector3(-68.7,2.24,-695),"building side pedestrian access"],[Vector3(-68.7,2.24,-751),"building side paved walk"],
		[Vector3(-64.5,2.24,-751),"existing rear walk connection"],[Vector3(-64.5,2.24,-686),"rear walk around north end"],
		[Vector3(-10,2.24,-688.1),"branch south pedestrian strip"],[Vector3(-8.1,2.24,-700),"return to Main Square frontage"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"V81 Zhixin Shaw-end branch and rear parking links;absolute site placement/date,DaoYuan-end connection and full campus remain unresolved"}
	FileAccess.open("res://tests/artifacts/zhixin_side_streets_v81.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ZHIXIN_SIDE_STREETS ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
