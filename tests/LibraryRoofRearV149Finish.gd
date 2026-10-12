extends "res://tests/LibraryCoreBoundaryV147Finish.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var old=JSON.parse_string(FileAccess.get_file_as_string("res://tests/artifacts/library_roof_rear_v149.json"))
	for leg in old.physical_legs:
		if leg.valid:continue
		var q:=PhysicsShapeQueryParameters3D.new();var sphere:=SphereShape3D.new();sphere.radius=.52;q.shape=sphere
		q.transform=Transform3D(Basis.IDENTITY,Vector3(leg.end[0],leg.end[1]+.7,leg.end[2]));q.exclude=[world.player.get_rid()]
		for hit in world.get_world_3d().direct_space_state.intersect_shape(q,8):print("OLD_CONTACT ",hit.collider.get_path())
	var checks:Array=[];var support:Array=[]
	for p in [[430,640],[600,640],[850,740],[690,936]]:
		var base:=Plan.point(p[0],p[1],8.8)
		probe(wp(base.x-.7,9,base.z),wp(base.x+.7,9,base.z),true,"existing column base side "+str(p),checks)
		# Start below the column to avoid a ray beginning inside its collider.
		var q:=PhysicsRayQueryParameters3D.create(wp(base.x,8.79,base.z),wp(base.x,-.3,base.z));q.exclude=[world.player.get_rid()]
		var hit:=world.get_world_3d().direct_space_state.intersect_ray(q)
		if not hit.is_empty():support.append({"column":p,"first_surface_y":hit.position.y-2.24,"collider":str(hit.collider.get_path())})
	var route:Array=[]
	for p in [[350,52],[395,52],[450,52],[510,52],[510,105],[510,155]]:route.append([pp(p[0],p[1],12.8),"left frame clear window strip "+str(p)])
	await fixture(pp(350,65,13.1),route)
	await capture("library-roof-v149-rear-left-final",pp(345,-310,19.5),pp(405,55,19.5))
	await capture("library-roof-v149-rear-right-final",pp(1480,45,21.5),pp(1240,255,19.5))
	await capture("library-roof-v149-column-foot",pp(820,780,10.8),pp(850,740,8.6))
	FileAccess.open("res://tests/artifacts/library_roof_rear_v149_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"support_observations":support,"captures":captures,"failures":failures,"fixtures":1},"\t"))
	print("LIBRARY_ROOF_REAR_FINISH ",JSON.stringify({"legs":legs.size(),"failures":failures,"supports":support}))
	quit(0 if failures.is_empty() else 1)
