extends "res://tests/LibraryServicesFinishV228.gd"
const Pavilion=preload("res://world/visual_campus/LibraryEntryPavilion.gd")
func door(x:float,z:float,y:float=4.4)->Vector3:return lib(Pavilion.dp(x,z,y))
func shot(label:String)->void:
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/library-hall-floor-v230-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func run()->void:
	root.disable_3d=true
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_player();await frames(15)
	var p:CharacterBody3D=product.world.player
	for mode:bool in [false,true]:
		p.first_person=mode
		await fixture(door(-5.9,.7),[door(-3,.7),door(0,.7),door(0,-1.7),door(0,-3.5),door(0,.7),door(-5.9,.7)],"entry-return-"+("first" if mode else "third"))
	check("camera volumes clear",overlap_frames==0);check("body to camera clear",blocked_frames==0)
	p.set_physics_process(false);p.hide();product.world.ui.hide();root.disable_3d=false
	var eye:=Camera3D.new();product.world.add_child(eye);eye.current=true;eye.fov=68
	for v:Array in [["entrance-hall",door(0,-.8,6.15),plan(970,670,4.7)],["hall-floor",plan(1000,760,7.6),plan(920,720,4.41)],["service-join",svc(3.8,5,1.65),svc(.6,1,0.2)],["return-front",door(-5.9,2.2,6.05),door(-5.9,0,5.9)],["return-context",door(-2.7,4.0,6.2),door(-4.0,0,5.9)],["lower-opening",gp(8)+Vector3.UP*1.65,gp(11)+Vector3.UP*.7]]:
		eye.position=v[1];eye.look_at(v[2]);await frames(12);await shot(v[0])
	FileAccess.open("res://tests/artifacts/library_hall_floor_v230.json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"physical_legs":legs,"checks":checks,"failures":errors,"camera_samples":samples,"overlap_frames":overlap_frames,"blocked_frames":blocked_frames,"bad_samples":bad_samples,"captures":captures,"scope":"entry side-pier segmentation and main door; floor changes visual only,not wholelibrary"},"\t"))
	print("LIBRARY_HALL_FLOOR_V230 legs=",legs.size()," samples=",samples," failures=",errors);quit(0 if errors.is_empty() else 1)
