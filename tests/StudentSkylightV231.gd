extends "res://tests/StageCameraV218.gd"
const R=preload("res://world/visual_campus/StudentThirdRooms.gd")
func sp(u:float,v:float,y:float)->Vector3:return R.world(u,v,y)
func ray_check(a:Vector3,b:Vector3,expected:bool,label:String)->void:
	var q:=PhysicsRayQueryParameters3D.create(a,b,1,[product.world.player.get_rid()])
	check(label,not product.world.get_world_3d().direct_space_state.intersect_ray(q).is_empty()==expected)
func shot(label:String)->void:
	if root.disable_3d:return
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/student-skylight-v231-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func run()->void:
	root.disable_3d=true
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_player();await frames(15)
	var p:CharacterBody3D=product.world.player
	for q in [[635,570],[665,590],[690,615]]:
		ray_check(sp(q[0],q[1],24.6),sp(q[0],q[1],16.5),false,"open upper shaft "+str(q))
		ray_check(sp(q[0],q[1],16.5),sp(q[0],q[1],15.7),true,"glazed cap "+str(q))
	for y in [17.3,20.9]:
		for q in [[600,570,630,570],[722,570,690,570],[650,496,650,520],[650,650,650,620]]:
			ray_check(sp(q[0],q[1],y),sp(q[2],q[3],y),true,"upper well boundary "+str(y)+" "+str(q))
	for mode:bool in [false,true]:
		p.first_person=mode
		for y in [16.,19.6]:
			await fixture(sp(580,660,y),[sp(730,660,y),sp(730,480,y),sp(580,480,y),sp(580,660,y)],"well-perimeter-"+str(y)+("-first" if mode else "-third"))
		await fixture(sp(460,525,12.4),[sp(600,525,12.4),sp(750,525,12.4),sp(600,525,12.4),sp(460,525,12.4),sp(460,660,12.4),sp(460,525,12.4)],"gallery-"+("first" if mode else "third"))
	check("camera volumes clear",overlap_frames==0);check("body to camera clear",blocked_frames==0)
	p.set_physics_process(false);p.hide();product.world.ui.hide();root.disable_3d=false
	var eye:=Camera3D.new();product.world.add_child(eye);eye.current=true;eye.fov=68
	for v:Array in [["hall",sp(750,660,10.5),sp(560,545,15)],["upward",sp(670,630,10.5),sp(655,568,17.5)],["gallery",sp(480,630,14.1),sp(670,570,16.2)],["upper-perimeter",sp(730,660,17.7),sp(650,600,19.1)],["roof",sp(740,680,27),sp(655,570,22.8)]]:
		eye.position=v[1];eye.look_at(v[2]);await frames(12);await shot(v[0])
	FileAccess.open("res://tests/artifacts/student_skylight_v231.json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"physical_legs":legs,"checks":checks,"failures":errors,"camera_samples":samples,"overlap_frames":overlap_frames,"blocked_frames":blocked_frames,"bad_samples":bad_samples,"captures":captures,"scope":"shared301lightwell slab cuts,5F/6F boundaries,4F gallery;not fullbuilding;exactupperwell fit remains provisional"},"\t"))
	print("STUDENT_SKYLIGHT_V231 legs=",legs.size()," samples=",samples," failures=",errors);quit(0 if errors.is_empty() else 1)
