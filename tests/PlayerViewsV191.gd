extends "res://tests/PlayerCameraV190.gd"
const Chapters = preload("res://world/product/ShowcaseChapters.gd")

func shot(label: String) -> void:
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/player-views-v191-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)

func fixture(start:Vector3,targets:Array,label:String)->void:
	var p:CharacterBody3D=product.world.player
	p.position=start+Vector3.UP*.12;p.velocity=Vector3.ZERO;p.orbit_pitch=0;p.orbit_zoom=1
	await frames(12)
	for i in targets.size():
		var target:Vector3=targets[i]
		var reached:=false
		for frame in 450:
			var offset:=target-p.position;offset.y=0
			if offset.length()<.3 and absf(p.position.y-target.y)<.6:reached=true;break
			p.orbit_yaw=atan2(-offset.x,-offset.z)
			# Input.get_vector applies the action deadzone (0.5); remain above it.
			Input.action_press("move_forward",clampf(offset.length()/3,.6,1))
			await physics_frame;audit_camera()
		Input.action_release("move_forward");await frames(12)
		legs.append({"fixture":label,"leg":i,"reached":reached,"position":str(p.position),"target":str(target)})
		check(label+" leg "+str(i),reached)
		if not reached:await shot(label+"-blocked");break
		if i==0 or i==targets.size()-1:await shot(label+"-"+str(i))

func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(15)
	product.start_player();await frames(15)
	var p:CharacterBody3D=product.world.player
	await player_controls()
	await key(KEY_V)
	check("V selects eye-height view",p.first_person and not p.model.visible and absf(p.camera.position.y-p.position.y-1.65)<.03)
	var before:float=p.orbit_zoom;p.zoom_camera(1)
	check("wheel preserves stored boom in first person",p.orbit_zoom==before)
	p.turn_camera(Vector2(80,-150));await frames(8)
	check("first person can inspect upper floors",(-p.camera.global_basis.z).y>.5)
	var direction:Vector3=-p.camera.global_basis.z;direction.y=0;direction=direction.normalized()
	Input.action_press("move_forward");await frames(20)
	var actual:Vector3=p.velocity;actual.y=0
	check("first person W follows view",actual.normalized().dot(direction)>.95)
	Input.action_release("move_forward");await frames(15)
	await key(KEY_F2);await key(KEY_V)
	check("overview ignores view toggle",p.first_person)
	await key(KEY_F2)
	check("overview returns to first person",p.first_person and p.camera.current)
	await key(KEY_R)
	check("R restores third person",not p.first_person)
	await key(KEY_V)
	await fixture(gp(11.1),[gp(6),gp(-1)],"first-library-stair")
	await fixture(lib(Vector3(-18,0,10)),[lib(Vector3(-18,0,3.1)),lib(Vector3(-28.13,0,3.1)),lib(Vector3(-28.13,0,1.5))],"first-library-rooms")
	var chapters:=Chapters.build(product.world)
	for id:String in ["student","zhang"]:
		for c:Dictionary in chapters:
			if c.id!=id:continue
			p.first_person=true
			await fixture(c.route[0],c.route.slice(1),"first-"+id)
			p.first_person=false
			var reverse:Array=c.route.duplicate();reverse.reverse()
			await fixture(reverse[0],reverse.slice(1),"third-"+id+"-return")
	check("all sampled camera volumes clear",overlap_frames==0)
	check("all sampled body to eye segments clear",blocked_frames==0)
	await key(KEY_V);await key(KEY_ESCAPE);product.start_player();await frames(10)
	check("menu reentry restores third person",not p.first_person and p.model.visible)
	await shot("compact-hud")
	FileAccess.open("res://tests/artifacts/player_views_v191.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":errors,"physical_legs":legs,"camera_samples":samples,"overlap_frames":overlap_frames,"blocked_frames":blocked_frames,"bad_samples":bad_samples,"captures":captures,"scope":"First-person interaction and four building fixtures; return paths use third person. Input throttles near endpoints; no teleport inside a fixture. Not full-campus acceptance."},"\t"))
	print("PLAYER_VIEWS_V191_DONE ",errors," samples=",samples," overlap=",overlap_frames," blocked=",blocked_frames)
	quit(0 if errors.is_empty() else 1)
