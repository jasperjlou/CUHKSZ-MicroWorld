extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(40)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-water-v201-shore",Vector3(14,4,-321),Vector3(40,5,-288))
	await capture("library-water-v201-side",Vector3(43,4,-333),Vector3(50,2.5,-317))
	await capture("library-water-v201-high",Vector3(-8,27,-333),Vector3(42,2.3,-292))
	var b:Node3D=world.builder.buildings["library"]
	var points:Array[Vector3]=preload("res://world/visual_campus/LibraryOuterGallery.gd").route()
	await capture("library-water-v201-gallery-floor",b.to_global(points[4]+Vector3.UP*1.65),b.to_global(points[6]+Vector3.UP*.35))
	FileAccess.open("res://tests/artifacts/library_water_v201.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":0,"scope":"Library pool static-probe reflection and mild world-normal waves; direct gallery-floor material view. Waterline/basin/physics unchanged."},"\t"))
	print("LIBRARY_WATER_V201_DONE");quit(0 if failures.is_empty() else 1)
