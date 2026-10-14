extends "res://tests/ProductReviewV218.gd"
const IDS=["library-study","library-rear-shaw"]
var sampled:int=0
var overlap:Array=[]
func shot(label:String)->void:
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/stage-views-v246-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func audit(camera:Camera3D)->void:
	var sphere:=SphereShape3D.new();sphere.radius=.18
	var q:=PhysicsShapeQueryParameters3D.new();q.shape=sphere;q.collision_mask=1;q.exclude=[product.world.player.get_rid()];q.transform=camera.global_transform
	var hits=product.world.get_world_3d().direct_space_state.intersect_shape(q,1);sampled+=1
	if not hits.is_empty():overlap.append(str(hits[0].collider.get_path()))
func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_showcase();var d:Node=product.director
	for i in d.chapters.size():
		var c:Dictionary=d.chapters[i]
		if c.id not in IDS:continue
		d.begin_chapter(i)
		while d.phase!="intro":await physics_frame
		await frames(100);audit(d.camera);await shot(c.id+"-intro")
		# Still fixtures inspect composition; StageAgentV246 records actual continuous walking.
		product.world.player.set_physics_process(false);d.set_physics_process(false)
		var legs:Array=[3,9] if c.id=="library-study" else [6,20]
		for leg:int in legs:
			product.world.player.position=c.route[leg-1];product.world.player.velocity=Vector3.ZERO
			product.world.player.navigation_direction=Vector2.ZERO
			d.phase="walk";d.leg=leg;d.camera_snap=true
			await frames(20);audit(d.camera);await shot(c.id+"-leg"+str(leg))
		product.world.player.position=c.route.back();d.phase="outro";d.camera_snap=true
		await frames(30);audit(d.camera);await shot(c.id+"-outro")
		d.set_physics_process(true)
	check("composed camera volumes clear",overlap.is_empty())
	FileAccess.open("res://tests/artifacts/stage_views_v246.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":errors,"captures":captures,"camera_samples":sampled,"overlaps":overlap,"scope":"normal-speed intro and independent walk/outro camera fixtures, not continuous route evidence"},"\t"))
	print("STAGE_VIEWS_V246 captures=",captures.size()," failures=",errors);quit(0 if errors.is_empty() else 1)
