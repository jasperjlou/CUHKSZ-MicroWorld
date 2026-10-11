extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("zhang-front-v85",Vector3(-20,6,-382),Vector3(-41,9,-427))
	await capture("zhang-arcade-v85",Vector3(-35,4,-404),Vector3(-43,5,-439))
	await capture("zhang-transverse-v85",Vector3(-14,5,-417),Vector3(14,9,-444))
	await capture("research-court-v85",Vector3(-92,4,-481),Vector3(-92,12,-538))
	await capture("research-platform-v85",Vector3(-74,5,-484),Vector3(-94,5,-507))
	await fixture(Vector3(-38.15,2.54,-435),[
		[Vector3(-38.15,2.32,-432),"Zhang exterior stair foot"],
		[Vector3(-38.15,7.165,-415),"Zhang first gallery stair head"],
		[Vector3(-41.4,7.165,-415),"gallery inner bypass"],
		[Vector3(-41.4,7.165,-443),"gallery to transverse link"],
		[Vector3(-30,6.89,-443),"transverse deck level transition"],
		[Vector3(12,6.89,-443),"transverse middle"],
		[Vector3(38,6.89,-443),"transverse stair approach"],
		[Vector3(38,6.89,-441.7),"transverse stair head"],
		[Vector3(38,2.24,-425),"transverse stair descent"],
		[Vector3(5,2.24,-426),"ground return towards Zhang"],
		[Vector3(-28,2.24,-437),"beneath transverse approach"],
		[Vector3(-28,2.24,-450),"beneath transverse clear passage"],
		[Vector3(-30,2.24,-482),"garden approach towards research court"],
		[Vector3(-78,2.24,-485),"research building end approach"],
		[Vector3(-81,2.32,-493),"court side stair foot"],
		[Vector3(-89,2.89,-493),"court raised arrival platform"],
		[Vector3(-92,2.89,-494),"court platform behind front rail"],
		[Vector3(-92,2.32,-505),"court gradual descent"],
		[Vector3(-92,2.24,-537),"under high canopy"],
		[Vector3(-92,2.24,-568),"under glazed links"],
		[Vector3(-92,2.32,-505),"research court return"],
		[Vector3(-92,2.89,-493),"court platform return"],
		[Vector3(-81,2.32,-493),"court side descent"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"Zhang exterior stair/gallery/transverse link and ground access through raised research court;dimensions fitted;upper research bridges not entered."}
	FileAccess.open("res://tests/artifacts/zhang_research_v85.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ZHANG_RESEARCH_V85 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
