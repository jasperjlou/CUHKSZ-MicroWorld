extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("gate-left-step-final-v92",Vector3(-10,3.2,-37),Vector3(-17.3,2.1,-49))
	await capture("gate-teaching-upper-final-v92",Vector3(-41,14,-58),Vector3(-18,2.4,-96))
	await capture("teaching-a-transverse-final-v92",Vector3(-26,4.05,-98),Vector3(-42,4,-110))
	await capture("icc-ground-stone-final-v92",Vector3(63.5,4.1,-64),Vector3(64.2,3.9,-36))
	await fixture(Vector3(-18,.3,-39.5),[
		[Vector3(-17.3,0,-39.5),"teaching side stair lower mouth"],
		[Vector3(-17.3,1.12,-46),"side stair intermediate landing"],
		[Vector3(-17.3,2.24,-55.5),"side stair upper landing"],
		[Vector3(-35,2.24,-57),"upper teaching side turn"],
		[Vector3(-35,2.24,-98),"teaching A transverse junction"],
		[Vector3(-40,2.24,-98),"teaching A arcade threshold"],
		[Vector3(0,2.24,-98),"upper crosswalk toward central mall"],
		[Vector3(0,2.24,-60),"upper main stair landing link"],
		[Vector3(29,2.24,-60),"conference walk approach"],
		[Vector3(35,2.24,-53),"conference walk bend"],
		[Vector3(43.2,2.24,-55.02),"ICC side apron entry"],
		[Vector3(64.26,2.24,-55.02),"ICC undercroft stone aisle"],
		[Vector3(64.26,2.24,-62.04),"ICC door bay exterior"],
		[Vector3(64.26,2.24,-55.02),"ICC aisle return"],
		[Vector3(43.2,2.24,-55.02),"ICC apron return"],
		[Vector3(29,2.24,-60),"gate landing return"],
		[Vector3(0,2.24,-60),"main upper landing return"],
		[Vector3(-17.3,2.24,-56),"side stair top rejoin"],
		[Vector3(-17.3,1.12,-46),"side stair landing descent"],
		[Vector3(-17.3,0,-39.5),"side stair lower descent"],
		[Vector3(-18,0,-39.5),"lower court rejoin"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"no_teleport_within_each_fixture":true,"scope":"V92 lower gate-left stair to teaching A,upper crossing and ICC ground apron;metric/date fidelity partial"}
	FileAccess.open("res://tests/artifacts/gate_teaching_final_v92.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("GATE_TEACHING_V92 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
