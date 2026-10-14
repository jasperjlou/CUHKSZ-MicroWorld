extends "res://tests/LibraryLowerLevelCapture.gd"
var building:Node3D
func sp(p:Vector3)->Vector3:return building.to_global(p)
func run()->void:
	root.disable_3d=true
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(20)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	building=world.builder.buildings.shaw_east
	await fixture(sp(Vector3(-39,.3,5.2)),[[sp(Vector3(-32,.45,5.2)),"removed generic post lane"],[sp(Vector3(-25,.45,5.2)),"lane to inner court edge"],[sp(Vector3(-25,.45,10.5)),"portal across"],[sp(Vector3(-32,.45,10.5)),"opposite jamb lane"],[sp(Vector3(-39,0,10.5)),"opposite lane exit"]])
	var checks:Array=[]
	for data:Array in [["front2F guard",Vector3(-20,5.55,28.8),Vector3(-20,5.55,29.8),true],["generic post removed",Vector3(-35,2,5.2),Vector3(-32,2,5.2),false],["street portal upper void",Vector3(-31,4.3,8),Vector3(-31,5.5,8),false]]:
		var q=PhysicsRayQueryParameters3D.create(sp(data[1]),sp(data[2]));q.exclude=[world.player.get_rid()]
		var hit=world.get_world_3d().direct_space_state.intersect_ray(q);var valid:bool=(not hit.is_empty())==data[3]
		checks.append({"case":data[0],"valid":valid})
		if not valid:failures.append(data[0])
	root.disable_3d=false;await frames(15)
	await capture("shaw-portal-v249-final-street",Vector3(57,4,-586),Vector3(77,5,-574))
	await capture("shaw-portal-v249-final-entry",sp(Vector3(-42,2.2,7.75)),sp(Vector3(-23,4,7.75)))
	await capture("shaw-portal-v249-final-front",Vector3(38,7,-571),Vector3(53,6,-554))
	FileAccess.open("res://tests/artifacts/shaw_street_finish_v249.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"checks":checks,"physical_legs":legs,"failures":failures,"scope":"5local lanes aftergeneric post removal,3changed boundary rays;retained first18legsnotrepeated;not full-campusorcamera acceptance"},"\t"))
	print("SHAW_STREET_FINISH_V249 ",JSON.stringify({"legs":legs.size(),"checks":checks,"failures":failures}));quit(0 if failures.is_empty() else 1)
