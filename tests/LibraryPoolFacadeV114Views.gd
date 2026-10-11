extends "res://tests/LibraryPoolFacadeV114.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-pool-facade-v114-roof-final",wp(-36,57,94),wp(-6,17,4))
	await capture("library-pool-facade-v114-lantern-final",pp(475,940,36),pp(655,770,27.5))
	var report={"version":world.data.version,"captures":captures,"failures":failures,"scope":"Final connected lantern only; changed roof is visual mesh,previous wall/aisle checks retained"}
	FileAccess.open("res://tests/artifacts/library_pool_facade_v114_views.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_FACADE_ROOF ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
