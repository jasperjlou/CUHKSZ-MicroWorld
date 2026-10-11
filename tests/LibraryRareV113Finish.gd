extends "res://tests/LibraryRareV113.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false)
	var route:Array=[]
	for p in [[470,710,18.8],[625,710,20.8],[625,674,20.8],[680,680,20.8],[725,696,20.8],[760,722,20.8],[797,754,20.8],[840,795,20.8],[870,825,20.8]]:route.append([pp(p[0],p[1],p[2]),"rare landing to6F "+str(p)])
	for p in [Vector3(6.5,20.8,3.4),Vector3(3,20.8,3.4),Vector3(3,20.8,-6.2),Vector3(-3,20.8,-6.2),Vector3(-3,18.8,2),Vector3(-5.7,18.8,2),Vector3(-5.7,16.8,-6.2),Vector3(3,16.8,-6.2),Vector3(6.5,16.8,3.4)]:route.append([cp(p.x,p.y,p.z),"6F edge via core to5F "+str(p)])
	for p in [[870,825],[865,715],[840,660],[625,660],[625,710]]:route.append([pp(p[0],p[1],16.8),"return to5F centre "+str(p)])
	await fixture(pp(470,780,17.1),route)
	if not failures.is_empty():
		var player=world.player;var target=route[legs.size()-1][0];var d:Vector3=target-player.global_position;d.y=0
		var collision:=KinematicCollision3D.new()
		if player.test_move(player.global_transform,d.normalized()*.1,collision):print("BLOCK ",collision.get_collider().get_path()," point ",collision.get_position()," normal ",collision.get_normal())
		for height in [.7,1.5,2.4]:
			var shape:=SphereShape3D.new();shape.radius=.7
			var q:=PhysicsShapeQueryParameters3D.new();q.shape=shape;q.transform=Transform3D(Basis.IDENTITY,player.global_position+Vector3.UP*height);q.exclude=[player.get_rid()]
			for c in world.get_world_3d().direct_space_state.intersect_shape(q,8):print("CONTACT ",height," ",c.collider.get_path())
	FileAccess.open("res://tests/artifacts/library_rare_v113_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"failures":failures,"fixtures":1},"\t"))
	quit(0 if failures.is_empty() else 1)
