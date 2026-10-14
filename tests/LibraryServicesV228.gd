extends "res://tests/StageCameraV218.gd"
const Service=preload("res://world/visual_campus/LibrarySecondServices.gd")
const Map=preload("res://world/visual_campus/LibraryLowerFrontPlan.gd")
func svc(x:float,z:float,y:float=0)->Vector3:return lib(Service.point(x,y,z))
func plan(u:float,v:float,y:float=4.4)->Vector3:return lib(Map.point2(u,v,y))
func shot(label:String)->void:
	if root.disable_3d:return
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/library-services-v228-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func run()->void:
	root.disable_3d=true
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_player();await frames(15)
	var p:CharacterBody3D=product.world.player
	var route:Array=[svc(-2,1.5),svc(-1.1,1.5),svc(-1.1,-.25),svc(-1.1,1.5),svc(.7,1.5),svc(2.1,1.5),svc(3.7,1.5),svc(4.5,2.7),svc(0,2.7),svc(-3,2.7),svc(-3,1.5)]
	for mode:bool in [false,true]:
		p.first_person=mode;await fixture(svc(-3,1.5),route,"services-"+("first" if mode else "third"))
	# Same-level front corridor joins the new service-front apron.209 interior untouched.
	p.first_person=false
	await fixture(plan(500,445),[plan(575,445),plan(645,445),plan(715,445),plan(760,470),svc(-3,2.7),svc(0,2.7),svc(4.5,2.7)],"rooms-to-service")
	check("camera volumes clear",overlap_frames==0);check("body to camera clear",blocked_frames==0)
	p.set_physics_process(false);p.hide();product.world.ui.hide();root.disable_3d=false
	var eye:=Camera3D.new();product.world.add_child(eye);eye.current=true;eye.fov=68
	for v:Array in [["front",svc(3.8,5.0,1.65),svc(.8,.1,1.4)],["cabinet",svc(3.5,2.6,1.7),svc(2.1,.3,1.2)],["ask-us",svc(-1.1,2.5,1.65),svc(-1.3,-1.3,1.4)],["corridor",plan(730,455,6.1),svc(0,.5,1.5)]]:
		eye.position=v[1];eye.look_at(v[2]);await frames(12);await shot(v[0])
	FileAccess.open("res://tests/artifacts/library_services_v228.json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"physical_legs":legs,"checks":checks,"failures":errors,"camera_samples":samples,"overlap_frames":overlap_frames,"blocked_frames":blocked_frames,"bad_samples":bad_samples,"captures":captures,"scope":"new2025 servicecabinet/counter approach and210-213frontcorridor; not wholelibrary or209 repeat"},"\t"))
	print("LIBRARY_SERVICES_V228 legs=",legs.size()," samples=",samples," failures=",errors);quit(0 if errors.is_empty() else 1)
