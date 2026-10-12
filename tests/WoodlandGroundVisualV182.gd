extends "res://tests/WoodlandGroundV182.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var x:float=Bank182.toe(Bank182.STAIR_Z,world.builder.rear_route)
	var y:float=Bank182.road_height(Bank182.STAIR_Z)
	await capture("ground-v182-final-library-bank",Vector3(128,7,-356),Vector3(157,9,-296))
	await capture("ground-v182-final-student-road",Vector3(113,4.2,-421),Vector3(137,5.5,-375))
	await capture("ground-v182-final-bank-stair",Vector3(x-8,y+2.2,Bank182.STAIR_Z-5),Vector3(x+4,y+4,Bank182.STAIR_Z))
	await capture("ground-v182-final-central-overall",Vector3(-10,68,-465),Vector3(123,11,-330))
	FileAccess.open("res://tests/artifacts/woodland_ground_visual_v182.json",FileAccess.WRITE).store_string(JSON.stringify({"captures":captures,"planting":world.get_node("LibraryStudentWoodlandEdgeV182").get_meta("counts"),"scope":"Visual-only replacement of intermediate solid canopy lobes with branched leaves; unchanged terrain/collision"},"\t"))
	print("WOODLAND_V182_VISUAL_DONE");quit()
