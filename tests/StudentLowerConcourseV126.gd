extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	if DisplayServer.get_name()!="headless":
		await capture("student-lower-v126-stair",Vector3(18,5.4,-412),Vector3(16,-.8,-435))
		await capture("student-lower-v126-gift",Vector3(-9,.10,-443),Vector3(-21,.0,-443))
		await capture("student-lower-v126-card",Vector3(-14,.10,-438),Vector3(-19,.25,-422))
		await capture("student-lower-v126-concourse",Vector3(-16,.1,-443),Vector3(29,.2,-442))
		await capture("student-lower-v126-upper",Vector3(-8,17,-480),Vector3(8,1,-425))
		FileAccess.open("res://tests/artifacts/student_lower_v126_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures},"\t"))
		quit(0 if failures.is_empty() else 1);return
	await fixture(Vector3(18,2.54,-411),[
		[Vector3(18,2.24,-414),"broad stair upper landing"],[Vector3(18,-1.76,-431),"broad stair descent"],
		[Vector3(8,-1.76,-431),"lightwell side aisle"],[Vector3(-12,-1.76,-431),"card concourse"],
		[Vector3(-17,-1.76,-425),"card doorway approach"],[Vector3(-23,-1.76,-425),"card public threshold"],
		[Vector3(-17,-1.76,-425),"card threshold return"],[Vector3(-12,-1.76,-425),"card gallery"],
		[Vector3(-12,-1.76,-443),"covered longitudinal gallery"],[Vector3(-17,-1.76,-443),"gift doorway approach"],
		[Vector3(-23,-1.76,-443),"gift public threshold"],[Vector3(-17,-1.76,-443),"gift doorway return"],
		[Vector3(29,-1.76,-443),"cross concourse toward student side"],[Vector3(29,-1.76,-431),"lightwell east aisle"],
		[Vector3(29,-1.76,-443),"east aisle return"],[Vector3(-17,-1.76,-443),"gift concourse return"],
		[Vector3(-17,-1.76,-450),"secondary stair foot"],[Vector3(-17,2.24,-466.5),"secondary ascent"],
		[Vector3(-17,2.24,-470),"southern mall connection"],[Vector3(-17,2.24,-466.5),"secondary return head"],
		[Vector3(-17,-1.76,-450),"secondary descent"],[Vector3(-12,-1.76,-443),"lower return gallery"],
		[Vector3(-12,-1.76,-431),"lower return north"],[Vector3(18,-1.76,-431),"broad stair foot return"],
		[Vector3(18,2.24,-413),"broad stair ascent"],[Vector3(30,2.24,-413),"student upper walkway join"],
		[Vector3(30,2.24,-451),"upper walkway past aperture"],[Vector3(0,2.24,-451),"upper mall crossing"],
		[Vector3(0,2.24,-409),"retained mall roof route"],[Vector3(18,2.24,-409),"loop closure"]])
	FileAccess.open("res://tests/artifacts/student_lower_v126_physics.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"failures":failures,"fixtures":1,"scope":"Service concourse/stairs/upper mall local loop, fitted placement; not whole D or full campus verification."},"\t"))
	quit(0 if failures.is_empty() else 1)
