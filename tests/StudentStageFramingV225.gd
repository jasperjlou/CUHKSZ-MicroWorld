extends "res://tests/StudentStageFinishV225.gd"
func shot(label:String)->void:
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/student-stage-framing-v225-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_showcase();var d:Node=product.director
	for i in d.chapters.size():
		if d.chapters[i].id=="student-serenity":d.begin_chapter(i);break
	var samples:int=0;var hits:int=0;var ticks:int=0
	var sphere:=SphereShape3D.new();sphere.radius=.18
	while d.phase!="walk" and ticks<400:
		await physics_frame;ticks+=1
		if d.phase!="intro":continue
		var q:=PhysicsShapeQueryParameters3D.new();q.shape=sphere;q.collision_mask=1;q.exclude=[product.world.player.get_rid()];q.transform=Transform3D(Basis.IDENTITY,d.camera.global_position)
		samples+=1
		if not product.world.get_world_3d().direct_space_state.intersect_shape(q,1).is_empty():hits+=1
		if samples==180:await shot("serenity-intro")
	check("final Serenity intro completed",d.phase=="walk")
	check("final Serenity camera volume clear",hits==0)
	for q in [[400,154],[400,365],[400,550],[600,650]]:check("1F finish label "+str(q),L.label(P.world(q[0],q[1],.075)).ends_with("首层餐厅"))
	for q in [[270,550],[450,650]]:check("1F stair/core excluded "+str(q),L.label(P.world(q[0],q[1],.075)).is_empty())
	product.start_player();var p:CharacterBody3D=product.world.player
	p.position=R.world(484,78)+Vector3.UP*.12;p.velocity=Vector3.ZERO;p.first_person=true;p.orbit_pitch=0;p.orbit_yaw=0
	await frames(20);check("3F HUD",product.world.location_text.text.contains("三层公共隔间"));await shot("rooms-hud")
	FileAccess.open("res://tests/artifacts/student_stage_framing_v225.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":errors,"intro_samples":samples,"overlaps":hits,"captures":captures,"scope":"final Serenity intro at normal speed and corrected1F label regions; rooms HUD facing door"},"\t"))
	print("STUDENT_STAGE_FRAMING_V225 samples=",samples," failures=",errors);quit(0 if errors.is_empty() else 1)
