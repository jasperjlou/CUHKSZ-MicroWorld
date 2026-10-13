extends "res://tests/LibraryGroundStairV103Capture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(40)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-lower-v202-tiers",gp(4,1.8,-3.5),gp(4,2.45,3))
	await capture("library-lower-v202-central",wp(-4.2,1.8,-7),wp(-12,2.8,-12))
	await capture("library-lower-v202-west",wp(-20.4,1.8,-7),wp(-32,2.7,-9))
	await capture("library-lower-v202-right",wp(28.9,1.8,-6.1),wp(23.8,2.8,-3.2))
	await capture("library-lower-v202-exhibit",wp(-16.5,1.8,10),wp(-21.8,2.1,8.9))
	FileAccess.open("res://tests/artifacts/library_lower_ceiling_v202.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":0,"scope":"Expanded-metal ceilings, framed diffusers and timber-tier panel carriers only; no collision or level changes. Exhibit smooth ceiling retained."},"\t"))
	print("LIBRARY_LOWER_CEILING_V202_DONE");quit(0 if failures.is_empty() else 1)
