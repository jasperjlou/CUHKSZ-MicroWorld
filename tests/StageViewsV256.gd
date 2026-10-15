extends "res://tests/ProductReviewV218.gd"
var overlaps:Array=[]
func shot(label:String)->void:
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/stage-views-v256-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func audit()->void:
	var q:=PhysicsShapeQueryParameters3D.new();var sphere:=SphereShape3D.new();sphere.radius=.18
	q.shape=sphere;q.collision_mask=1;q.exclude=[product.world.player.get_rid()];q.transform=product.director.camera.global_transform
	var hits=product.world.get_world_3d().direct_space_state.intersect_shape(q,1)
	if not hits.is_empty():overlaps.append(str(hits[0].collider.get_path()))
func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_showcase();var d:Node=product.director
	for i in d.chapters.size():
		var c:Dictionary=d.chapters[i]
		if c.id!="zhixin":continue
		d.begin_chapter(i)
		while d.phase!="intro":await physics_frame
		await frames(100);audit();await shot("intro")
		product.world.player.set_physics_process(false);d.set_physics_process(false)
		for leg:int in [1,9,10,15,16]:
			product.world.player.position=c.route[leg-1].lerp(c.route[leg],.5)+Vector3.UP*.05
			product.world.player.velocity=Vector3.ZERO;product.world.player.navigation_direction=Vector2.ZERO
			d.phase="walk";d.leg=leg;d.camera_snap=true;await frames(20);audit();await shot("leg"+str(leg))
		var prior:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://tests/artifacts/stage_agent_v256.json"))
		var e:Array=prior.physical_legs.back().end
		product.world.player.position=Vector3(e[0],e[1],e[2]);d.leg=c.route.size();d.phase="outro";d.camera_snap=true
		await frames(30);audit();await shot("outro")
	d.set_physics_process(false);product.world.player.set_physics_process(false)
	d.camera.position=Vector3(-6.2,4.14,-701.08);d.camera.look_at(Vector3(-12,4.24,-701.08))
	await frames(15);audit();await shot("street-glass-clear")
	check("composed camera spheres clear",overlaps.is_empty())
	FileAccess.open("res://tests/artifacts/stage_views_v256.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":errors,"captures":captures,"overlaps":overlaps,"scope":"normalintro,independentmidlegcompositions and recordedarrivaloutro;notcontinuousplaybackevidence"},"\t"))
	print("STAGE_VIEWS_V256 ",captures.size()," failures=",errors);quit(0 if errors.is_empty() else 1)
