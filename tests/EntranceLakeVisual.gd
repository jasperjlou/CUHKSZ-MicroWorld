extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("entrance-lake-final-v68",Vector3(177,54,51),Vector3(76,12,-20))
	await capture("entrance-spiral-final-v68",Vector3(111,6,-20),Vector3(104,4,-24))
	await capture("entrance-link-final-v68",Vector3(110,16,-26),Vector3(90,15,-23))
	var checks:Array=[]
	for sample:Array in [[Vector3(121,5,-20),Vector3(123,5,-20),"first raised lake terrace guard,below meeting box"],[Vector3(119,2,-17),Vector3(121,2,-17),"new gallery support column"],[Vector3(104,1.8,-22.7),Vector3(104,1.8,-21.5),"spiral inner parapet"]]:
		var q:=PhysicsRayQueryParameters3D.create(sample[0],sample[1]);q.exclude=[world.player.get_rid()]
		var hit:Dictionary=world.get_world_3d().direct_space_state.intersect_ray(q);var valid:bool=not hit.is_empty()
		checks.append({"case":sample[2],"valid":valid,"collider":str(hit.get("collider",""))})
		if not valid:failures.append(sample[2])
	var report:Dictionary={"version":world.data.version,"captures":captures,"checks":checks,"failures":failures,"scope":"final tread risers/supports/wood strip;guard sample replaces prior ray inside meeting box;no full route repeat"}
	FileAccess.open("res://tests/artifacts/entrance_lake_visual_v68.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ENTRANCE_LAKE_VISUAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
