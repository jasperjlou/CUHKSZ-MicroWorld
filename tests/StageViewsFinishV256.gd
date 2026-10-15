extends "res://tests/StageViewsV256.gd"
func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_showcase();var d:Node=product.director
	for i in d.chapters.size():
		if d.chapters[i].id!="zhixin":continue
		d.begin_chapter(i)
		while d.phase!="intro":await physics_frame
		await frames(100);audit();await shot("final-intro")
	d.set_physics_process(false);d.set_process(false);product.world.player.set_physics_process(false)
	d.camera.position=Vector3(-6.2,4.14,-701.08);d.camera.look_at(Vector3(-12,4.24,-701.08))
	await frames(15);audit();await shot("final-street-glass-clear")
	check("final composed camera spheres clear",overlaps.is_empty())
	product.start_player();var p:CharacterBody3D=product.world.player
	for v:Array in [["player-street",Vector3(-48,2.24,-676.5),Vector3(-32,3.5,-688),false],["player-cozy",Vector3(-52.2,2.24,-707.5),Vector3(-56.7,3.2,-710),true]]:
		p.position=v[1]+Vector3.UP*.12;p.velocity=Vector3.ZERO;p.first_person=v[3];p.orbit_pitch=0;p.orbit_zoom=1
		var direction:Vector3=v[2]-v[1];p.orbit_yaw=atan2(-direction.x,-direction.z)
		await frames(25);await shot(v[0])
	FileAccess.open("res://tests/artifacts/stage_views_finish_v256.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":errors,"captures":captures,"overlaps":overlaps,"scope":"revised intro,explicit frozen street camera and two player stills;no repeated physical route"},"\t"))
	print("STAGE_VIEWS_FINISH_V256 ",captures.size()," failures=",errors);quit(0 if errors.is_empty() else 1)
