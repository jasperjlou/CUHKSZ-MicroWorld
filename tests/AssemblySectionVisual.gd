extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("hall-roof-final-v70",Vector3(153,54,58),Vector3(66,17,-1))
	await capture("hall-street-final-v70",Vector3(100,9,51),Vector3(66,14,0))
	await capture("hall-seating-final-v70",Vector3(92,12,-2),Vector3(55,15,-1))
	await capture("hall-lake-glass-final-v70",Vector3(122,13,29),Vector3(85,15,-1))
	await capture("hall-rear-final-v70",Vector3(49,16.2,8),Vector3(89,12,-1))
	var report:Dictionary={"version":world.data.version,"captures":captures,"scope":"final visual closure only;existing walkability retained,back lining outside tested route"}
	FileAccess.open("res://tests/artifacts/assembly_section_visual_v70.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ASSEMBLY_VISUAL ",JSON.stringify(report));quit(0)
