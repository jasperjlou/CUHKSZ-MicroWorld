extends "res://tests/ProductReviewV218.gd"
const IDS=["library-training209","library-services","library-public-stairs","student-front-west301","student-hall301"]
const P=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
const L=preload("res://world/visual_campus/StudentInteriorLocation.gd")
var sampled:int=0
var overlap:Array=[]
func shot(label:String)->void:
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/stage-views-v235-"+label+".png"
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
		# Independent composed view fixtures. StageAgentV235 supplies continuous walking evidence.
		var leg:int={"library-training209":5,"library-services":12,"library-public-stairs":4,"student-front-west301":8,"student-hall301":9}[c.id]
		product.world.player.position=c.route[leg-1];product.world.player.velocity=Vector3.ZERO
		product.world.player.navigation_direction=Vector2.ZERO;product.world.player.set_physics_process(false)
		d.set_physics_process(false);d.phase="walk";d.leg=leg;d.camera_snap=true
		await frames(20);audit(d.camera);await shot(c.id+"-walk")
		d.phase="outro";await frames(30);audit(d.camera);await shot(c.id+"-detail")
		d.set_physics_process(true)
	for case:Array in [[P.world(235,269,2.2),"首层至二层前梯"],[P.world(260,520,6.6),"301 西侧宽梯"],[P.world(350,350,4.4),"二层院落"],[P.world(350,520,8.8),"301 西门平台"]]:
		check("location "+case[1],L.label(case[0]).ends_with(case[1]))
	check("composed camera volumes clear",overlap.is_empty())
	FileAccess.open("res://tests/artifacts/stage_views_v235.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":errors,"captures":captures,"camera_samples":sampled,"overlaps":overlap,"scope":"normal-speed intro and independent walk/detail camera fixtures, not continuous route evidence"},"\t"))
	print("STAGE_VIEWS_V235 captures=",captures.size()," failures=",errors);quit(0 if errors.is_empty() else 1)
