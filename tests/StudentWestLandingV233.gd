extends "res://tests/StudentSkylightV231.gd"
const P233=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
func pp(u:float,v:float,y:float)->Vector3:return P233.world(u,v,y)
func shot(label:String)->void:
	if root.disable_3d:return
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/student-west-v233-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func run()->void:
	root.disable_3d=true
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_player();await frames(15)
	var p:CharacterBody3D=product.world.player
	for mode:bool in [false,true]:
		p.first_person=mode
		await fixture(pp(150,269,.075),[pp(320,269,4.4),pp(350,350,4.4),pp(200,350,4.4),pp(200,520,4.4),pp(215,520,4.4),pp(330,520,8.8),sp(400,536,8.8),sp(450,536,8.8),sp(500,580,8.8),sp(450,536,8.8),sp(400,536,8.8),pp(400,480,8.8),pp(450,480,8.8),pp(580,480,8.8),pp(580,440,8.8),pp(400,440,4.4),pp(350,350,4.4),pp(320,269,4.4),pp(150,269,.075)],"front-west-loop-"+("first" if mode else "third"))
		await fixture(pp(180,438,.075),[pp(240,438,.075),pp(270,438,.075),pp(270,365,.075),pp(180,365,.075)],"ground-entries-"+("first" if mode else "third"))
	ray_check(sp(400,536,10.2),sp(450,536,10.2),false,"301 west doorway opens to upper landing")
	ray_check(pp(180,520,1.5),pp(250,520,1.5),true,"old false ground stair mouth closed")
	check("camera volumes clear",overlap_frames==0);check("body to camera clear",blocked_frames==0)
	p.set_physics_process(false);p.hide();product.world.ui.hide();root.disable_3d=false
	var eye:=Camera3D.new();product.world.add_child(eye);eye.current=true;eye.fov=68
	for v:Array in [["front-foot",pp(142,325,1.8),pp(285,269,3.4)],["west-foot",pp(185,390,6.1),pp(340,525,9.2)],["hall-door",sp(475,570,10.5),sp(350,536,9.7)],["landing",pp(385,500,10.5),pp(240,520,6.3)]]:
		eye.position=v[1];eye.look_at(v[2]);await frames(12);await shot(v[0])
	FileAccess.open("res://tests/artifacts/student_west_v233.json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"physical_legs":legs,"checks":checks,"failures":errors,"camera_samples":samples,"overlap_frames":overlap_frames,"blocked_frames":blocked_frames,"bad_samples":bad_samples,"captures":captures,"scope":"1F front stair to2F court to301 west3F,return by middle stair; ground facade entries; two viewpoints; levels and continuation of029 cut-line fitted"},"\t"))
	print("STUDENT_WEST_V233 legs=",legs.size()," samples=",samples," failures=",errors);quit(0 if errors.is_empty() else 1)
