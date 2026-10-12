extends "res://tests/LibraryEntryApproachV117.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-soffit-v146-after",ap(0,7,1.3),ap(0,2.5,2.8))
	await capture("library-soffit-v146-stairs",ap(-2,13,4),ap(0,0,6.3))
	await capture("library-soffit-v146-public",wp(8,1.8,12),wp(16,2.0,10))
	# Return to the original camera for the same pixel diagnostics.
	world.overview.position=ap(0,7,1.3);world.overview.look_at(ap(0,2.5,2.8));await frames(3)
	var checks:Array=[]
	for sample in [[ap(0,7,1.4),ap(0,7,2.65),true,"closed116 inclined soffit"],[ap(0,5.2,4.3),ap(0,5.2,3.65),false,"upper stair void not capped"],[ap(0,5.2,3.7),ap(0,5.2,2.9),true,"main stair support retained"],[ep(0,1,6),ep(0,-1,6),false,"upper public doorway stays open"]]:
		var q:=PhysicsRayQueryParameters3D.create(sample[0],sample[1]);q.exclude=[world.player.get_rid()]
		var hit=world.get_world_3d().direct_space_state.intersect_ray(q);var ok:bool=not hit.is_empty() if sample[2] else hit.is_empty()
		checks.append({"case":sample[3],"valid":ok});if not ok:failures.append(sample[3])
	var panel_count:int=0;var intruding_panel_found:bool=false
	for mesh:MultiMeshInstance3D in world.find_children("*","MultiMeshInstance3D",true,false):
		if not str(mesh.get_path()).contains("LibraryGroundRightRegisteredBoundary"):continue
		if not mesh.material_override is ShaderMaterial or mesh.material_override.get_shader_parameter("surface_kind")!=17:continue
		for i in mesh.multimesh.instance_count:
			panel_count+=1
			var centre:Vector3=(mesh.global_transform*mesh.multimesh.get_instance_transform(i)).origin
			if centre.distance_to(Vector3(78,6.26,-273))<.02:intruding_panel_found=true
	checks.append({"case":"public ceiling panels retained","valid":panel_count>0,"count":panel_count})
	checks.append({"case":"identified protruding light removed","valid":not intruding_panel_found})
	if panel_count==0 or intruding_panel_found:failures.append("public ceiling light boundary")
	FileAccess.open("res://tests/artifacts/library_soffit_v146_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"checks":checks,"failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
