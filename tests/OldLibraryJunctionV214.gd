extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var route:Array=[]
	for p in [[-9,-673],[-13,-675.3],[-20.5,-676.4],[-20.5,-688.1],[-14,-688.1],[-9,-691],[-8.1,-698],[-8.1,-705],[-8.1,-698],[-9,-691],[-14,-688.1],[-20.5,-688.1],[-20.5,-676.4],[-44,-676.4],[-65,-676.4],[-44,-676.4],[-20.5,-676.4],[-13,-675.3],[-9,-673],[-9,-665]]:
		route.append([Vector3(p[0],2.24,p[1]),"junction corner/crossing "+str(p)])
	await fixture(Vector3(-9,2.64,-665),route)
	world.player.hide()
	await capture("old-library-junction-v214-overview",Vector3(-30,17,-662),Vector3(-12,2.6,-683))
	await capture("old-library-junction-v214-court",Vector3(-25,3.8,-676.4),Vector3(-53,3.1,-682))
	await capture("old-library-junction-v214-corner",Vector3(-18,4.1,-689),Vector3(-7.8,3,-695))
	await capture("old-library-junction-v214-brick",Vector3(-33,3.4,-676.2),Vector3(-38,2.4,-676.4))
	FileAccess.open("res://tests/artifacts/old_library_junction_v214.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"captures":captures,"failures":failures,"fixtures":1,"scope":"modified corner rail and crossing/adjacent footway; fitted geometry and photo-led paving, not full route/fidelity acceptance"},"	"))
	print("OLD_LIBRARY_JUNCTION_V214 ",JSON.stringify({"legs":legs.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
