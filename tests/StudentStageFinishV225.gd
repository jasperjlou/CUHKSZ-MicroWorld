extends "res://tests/ProductReviewV218.gd"
const P=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
const R=preload("res://world/visual_campus/StudentThirdRooms.gd")
const L=preload("res://world/visual_campus/StudentInteriorLocation.gd")
func shot(label:String)->void:
	if DisplayServer.get_name()=="headless":return
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/student-stage-finish-v225-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_showcase();var d:Node=product.director;d.presentation_speed=12
	var sphere:=SphereShape3D.new();sphere.radius=.18
	var samples:int=0;var bad:Array=[];var first_frames:int=0
	# Shared cut initialization changed: inspect intros of all 26 chapters, not their unchanged walks.
	for i in d.chapters.size():
		d.begin_chapter(i)
		var seen:bool=false;var count:int=0
		while count<180 and d.phase!="walk":
			await physics_frame;count+=1
			if d.phase!="intro":continue
			if not seen:
				seen=true;first_frames+=1
				check(str(d.chapters[i].id)+" initialized before intro",d.camera.position.distance_to(d.chapters[i].eye)<.01)
			var q:=PhysicsShapeQueryParameters3D.new();q.shape=sphere;q.collision_mask=1;q.exclude=[product.world.player.get_rid()];q.transform=Transform3D(Basis.IDENTITY,d.camera.global_position)
			var hits=product.world.get_world_3d().direct_space_state.intersect_shape(q,1);samples+=1
			if not hits.is_empty():bad.append({"chapter":d.chapters[i].id,"eye":str(d.camera.position),"object":str(hits[0].collider.get_path())})
			if d.chapters[i].id=="student-serenity" and count==20:await shot("serenity-intro")
		check(str(d.chapters[i].id)+" intro completed",seen and d.phase=="walk")
	check("all intro camera volumes clear",bad.is_empty())
	product.start_player();var player:CharacterBody3D=product.world.player
	var places:Array=[
		[P.world(400,365,.075),"首层餐厅"],[P.world(480,315,4.4),"二层餐厅"],
		[R.world(650,550),"三层301多功能厅"],[R.world(484,78),"三层公共隔间"],
		[P.world(480,315,7.0),""],[P.world(180,438,0),""],[Vector3.ZERO,""]]
	for view:Array in places:
		var expected:String=view[1]
		check("floor label "+str(view[0]),L.label(view[0]).ends_with(expected) if not expected.is_empty() else L.label(view[0]).is_empty())
		if expected.is_empty():continue
		player.position=view[0]+Vector3.UP*.12;player.velocity=Vector3.ZERO;player.first_person=true;player.orbit_pitch=0;player.orbit_yaw=PI/2
		await frames(15)
		check("HUD "+expected,product.world.location_text.text.contains(expected))
		await shot("hud-"+str(places.find(view)))
	var suffix:String="headless" if DisplayServer.get_name()=="headless" else "visual"
	FileAccess.open("res://tests/artifacts/student_stage_finish_v225_"+suffix+".json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":errors,"intro_first_frames":first_frames,"intro_camera_samples":samples,"overlaps":bad,"captures":captures,"scope":"all26 authored intro transitions and four interior HUD labels; unchanged movement not rerun"},"\t"))
	print("STUDENT_STAGE_FINISH_V225 ",suffix," samples=",samples," failures=",errors);quit(0 if errors.is_empty() else 1)
