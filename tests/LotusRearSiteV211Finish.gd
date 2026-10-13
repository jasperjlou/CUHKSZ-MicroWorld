extends "res://tests/LibraryLowerRearV150.gd"
func run()->void:
	root.disable_3d=true
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var route:Array=[]
	for p in [[122,-332.5],[120,-337],[120,-345],[120,-337],[122,-332.5],[124,-328]]:route.append([Vector3(p[0],world.builder.height(p[0],p[1])+.075,p[1]),"refitted ramp mouth "+str(p)])
	await fixture(Vector3(124,world.builder.height(124,-328)+.3,-328),route)
	root.disable_3d=false;await frames(12)
	await capture("pond-rear-v211-final-walk",Vector3(121,4,-361),Vector3(118,3,-340))
	await capture("pond-rear-v211-final-grade",Vector3(128,9,-355),Vector3(117,3,-332))
	await capture("pond-rear-v211-final-road",Vector3(133,8,-344),Vector3(116,3,-372))
	FileAccess.open("res://tests/artifacts/lotus_rear_site_v211_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"physical_legs":legs,"captures":captures,"failures":failures,"scope":"north ramp profile revised,terrain mesh density aligned and overlapping legacy stone strip retired"},"\t"))
	print("LOTUS_REAR_SITE_V211_FINISH ",JSON.stringify({"legs":legs.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
