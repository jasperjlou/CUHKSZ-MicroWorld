extends "res://tests/LibraryGroundStairV103Capture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(30)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var doors:Array[Vector3]=[]
	for island:Array in [[-27.5,-1.8,7.95],[-15.7,-1.8,6.2]]:
		for sign in [-1,1]:
			for side in [-1,1]:doors.append(Vector3(island[0]+side*.63,1.35,island[1]+sign*island[2]/2))
	for desc:Array in [[Vector3(-14.7,0,-10.4),0.0],[Vector3(-6.9,0,-.65),PI/2],[Vector3(-6.9,0,6.3),PI*.75]]:
		doors.append(desc[0]+Basis(Vector3.UP,desc[1])*Vector3(0,1.35,1.6))
	var studio=preload("res://world/visual_campus/LibraryLowerRightWing.gd")
	for side in [-1,1]:doors.append(studio.studio_point(Vector3(side*.64,1.35,1.6)))
	var sphere:=SphereShape3D.new();sphere.radius=.30;var checks:Array=[]
	for i in doors.size():
		var p:=doors[i];var q:=PhysicsShapeQueryParameters3D.new();q.shape=sphere;q.collision_mask=1;q.exclude=[world.player.get_rid()];q.transform=Transform3D(Basis.IDENTITY,wp(p.x,p.y,p.z))
		var hit=world.get_world_3d().direct_space_state.intersect_shape(q,4);var ok:bool=hit.is_empty()
		checks.append({"door":i,"position":str(p),"clear":ok})
		if not ok:failures.append("door volume "+str(i))
	await capture("library-pods-v242-corner",wp(-33.5,1.8,3.8),wp(-30,2.15,.8))
	await capture("library-pods-v242-doors",wp(-27.5,1.8,5.4),wp(-27.5,1.75,1.6))
	await capture("library-pods-v242-single",wp(-14.7,1.8,-6.8),wp(-14.7,1.7,-10.4))
	await capture("library-pods-v242-interior",wp(-28.2,1.8,.8),wp(-30.6,1.65,1.8))
	var e:Vector3=studio.studio_point(Vector3(0,1.8,5.3));var t:Vector3=studio.studio_point(Vector3(0,1.75,1))
	await capture("library-pods-v242-studios",wp(e.x,e.y,e.z),wp(t.x,t.y,t.z))
	FileAccess.open("res://tests/artifacts/library_study_pod_finish_v242.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"checks":checks,"failures":failures,"scope":"13door-centre .30mradius clearance samples and5visualfixtures only;no new walk route/camera sweep;unchanged collision geometry"},"\t"))
	print("LIBRARY_PODS_V242 doors=",checks.size()," failures=",failures);quit(0 if failures.is_empty() else 1)
