extends "res://tests/ResearchSiteV172.gd"
func gp(x:float,z:float)->Vector3:return Vector3(x,world.builder.height(x,z)+.10,z)
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	world.player.position=Vector3(0,100,0)
	var profiles:Array=[]
	for x:float in [-106.5,-108.3]:
		for bounds:Vector2 in [Vector2(-1110,-1106),Vector2(-1130,-1126)]:
			var samples:Array=[];var largest:=0.0;var previous:=0.0;var valid:=true
			for i in 41:
				var z:float=lerpf(bounds.x,bounds.y,float(i)/40)
				var query:=PhysicsRayQueryParameters3D.create(Vector3(x,5,z),Vector3(x,-4,z))
				query.exclude=[world.player.get_rid()]
				var hit:=world.get_world_3d().direct_space_state.intersect_ray(query)
				if hit.is_empty():valid=false;continue
				var y:float=hit.position.y;samples.append([z,y])
				if i>0:largest=maxf(largest,absf(y-previous))
				previous=y
			valid=valid and largest<.025 and samples.size()==41
			profiles.append({"x":x,"z_bounds":[bounds.x,bounds.y],"samples":samples,"max_adjacent_rise":largest,"valid":valid})
			if not valid:failures.append("crossing profile "+str(x)+str(bounds))
	await capture("sports-crossing-v207-inside-accepted",Vector3(-107,.04,-1105),Vector3(-106.5,-1.1,-1111))
	await capture("sports-crossing-v207-outside-accepted",Vector3(-107,.05,-1131),Vector3(-106.5,-1.1,-1126))
	FileAccess.open("res://tests/artifacts/sports_crossing_v207_profile.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"profiles":profiles,"captures":captures,"failures":failures,"scope":"Final primitive joint backing and static ground profiles with player RID excluded; no repeated traversal. Retain12initial+8targeted walking records with their pre-final collision implementation scope explicit. Not wheelchair control simulation, accessibility certification, or surveyed geometry."},"\t"))
	print("SPORTS_CROSSING_V207_PROFILE ",JSON.stringify({"legs":legs.size(),"profiles":profiles.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
