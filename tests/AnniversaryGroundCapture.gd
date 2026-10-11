extends "res://tests/CourtyardRefinementCapture.gd"

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("anniversary-mall",Vector3(27,38,-125),Vector3(0,4,-320))
	await capture("anniversary-eastgate",Vector3(0,5,-58),Vector3(0,4,-175))
	await capture("anniversary-paving",Vector3(-7,4,-220),Vector3(-19,3,-239))
	await capture("anniversary-student",Vector3(-15,30,-355),Vector3(30,3,-441))
	await capture("anniversary-zhixin",Vector3(-35,10,-721),Vector3(-113,12,-737))
	await capture("anniversary-zhixin-overview",Vector3(-36,62,-693),Vector3(-107,7,-739))
	await fixture(Vector3(8,2.54,-64),[
		[Vector3(8,2.24,-125),"east gate upper landing"],[Vector3(8,2.24,-195),"central mall paving"],
		[Vector3(8,2.24,-253),"library stone approach"],[Vector3(8,2.24,-332),"pool west passage"],
		[Vector3(9,2.24,-386),"sunken court bypass"],[Vector3(30,2.24,-400),"student frontage"],
		[Vector3(30,2.24,-428),"link approach"],[Vector3(30,2.24,-476),"under student link"],
		[Vector3(42,2.24,-502),"Shaw avenue start"],[Vector3(42,2.24,-571),"Shaw turn"],
		[Vector3(24,2.24,-601),"square direction change"],[Vector3(9,2.24,-632),"old campus avenue"],
		[Vector3(9,2.24,-697),"old academic cluster"],[Vector3(9,2.24,-735),"main square crossing"],
		[Vector3(-50,2.24,-735),"square stone field"],[Vector3(-91,2.24,-735),"Zhi Xin open courtyard"],
		[Vector3(-121,2.24,-735),"old library rear entry"],
	])
	# One short second fixture verifies that the new surface did not cap the lower courtyard.
	await fixture(Vector3(32,2.54,-334),[
		[Vector3(32,-1.76,-353),"sunken stair remains open"],[Vector3(32,2.24,-334),"sunken stair return"]])
	var report:={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"build_ms":world.built_ms,"surface_regions":world.data.surface_regions.size()}
	FileAccess.open("res://tests/artifacts/anniversary_ground_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ANNIVERSARY_GROUND ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
