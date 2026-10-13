extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	# Continue after the retained initial twelve legs. Existing gate booth occupies
	# the road centre at Z=-773; pedestrian access follows its outer side.
	var route:Array=[]
	for p in [[-177,-750],[-177,-782.8],[-181,-782.8],[-181,-835],[-181,-782.8]]:
		route.append([Vector3(p[0],2.24,p[1]),"gate booth outer-side continuation "+str(p)])
	await fixture(Vector3(-174,2.64,-748),route)
	FileAccess.open("res://tests/artifacts/start_zone_perimeter_v216_accepted.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"failures":failures,"scope":"five-leg continuation after initial12; previous straight-centre booth failure retained; no vehicle or gate-registration claim"},"\t"))
	print("START_PERIMETER_V216_ACCEPTED ",JSON.stringify({"legs":legs.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
