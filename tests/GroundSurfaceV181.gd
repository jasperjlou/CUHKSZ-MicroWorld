extends "res://tests/LibraryRearAccessV180.gd"

func profile_error(x0:float,x1:float,z:float,strips:int)->float:
	var worst:float=0
	for i in strips:
		var a:float=lerpf(x0,x1,float(i)/strips)
		var b:float=lerpf(x0,x1,float(i+1)/strips)
		for t:float in [.25,.5,.75]:
			var actual:float=world.builder.height(lerpf(a,b,t),z)
			var chord:float=lerpf(world.builder.height(a,z),world.builder.height(b,z),t)
			worst=maxf(worst,absf(actual-chord))
	return worst

func run()->void:
	root.disable_3d=true
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var profiles:Array=[]
	for sample:Array in [[134.,140.,-280.],[103.4,111.2,-400.],[24.,31.5,-50.]]:
		var old:float=profile_error(sample[0],sample[1],sample[2],1)
		var refined:float=profile_error(sample[0],sample[1],sample[2],ceili(sample[1]-sample[0]))
		profiles.append({"xz_span":sample,"old_full_width_error":old,"new_lateral_error":refined})
		if refined>old+.001:failures.append("lateral fit worsened "+str(sample))
	# Changed ribbons remain visual-only; the existing terrain and all structural
	# collisions are retained. No new physical route claim is made here.
	root.disable_3d=false;await frames(15)
	await capture("ground-v181-rear-road",Vector3(145,8,-359),Vector3(134,5,-301))
	await capture("ground-v181-student-rear",Vector3(122,5,-426),Vector3(106,3.2,-382))
	await capture("ground-v181-gate",Vector3(25,6,-30),Vector3(27,3,-67))
	FileAccess.open("res://tests/artifacts/ground_surface_v181.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"profiles":profiles,"failures":failures,"captures":captures,"physical_changes":false,"scope":"Lateral road/paving mesh fit and library avenue aggregate finish; not full ground/environment acceptance"},"\t"))
	print("GROUND_V181 ",JSON.stringify({"profiles":profiles,"failures":failures}));quit(0 if failures.is_empty() else 1)
