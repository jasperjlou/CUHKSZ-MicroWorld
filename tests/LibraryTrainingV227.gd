extends "res://tests/StageCameraV218.gd"
const T=preload("res://world/visual_campus/LibraryTraining209.gd")
func room(x:float,z:float,y:float=0)->Vector3:return lib(T.local_point(x,y,z))
func shot(label:String)->void:
	if root.disable_3d or DisplayServer.get_name()=="headless":return
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/library-training-v227-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func run()->void:
	root.disable_3d=true
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_player();await frames(15)
	var p:CharacterBody3D=product.world.player;var d:=T.size();var door:float=(435.-326.)/137.*d.x
	check("60 modeled chairs",product.world.find_children("TrainingChair209*","Node3D",true,false).size()==60)
	var route:Array=[room(door,d.y+.30),room(door,d.y-.40),room(door,8.10),room(d.x/2,8.10),room(d.x/2,2.1),room(.45,2.1),room(.45,8.10),room(d.x/2,8.10),room(d.x-.45,8.10),room(d.x-.45,2.1),room(d.x/2,2.1),room(d.x/2,8.10),room(door,8.10),room(door,d.y-.40),room(door,d.y+.30),room(door,d.y+1.4)]
	for mode:bool in [false,true]:
		p.first_person=mode;await fixture(room(door,d.y+1.4),route,"209-"+("first" if mode else "third"))
	check("camera volumes clear",overlap_frames==0);check("body to camera clear",blocked_frames==0)
	p.set_physics_process(false);product.world.ui.hide();root.disable_3d=false
	var eye:=Camera3D.new();product.world.add_child(eye);eye.current=true;eye.fov=68
	for view:Array in [["rear",room(d.x-1.5,8.45,1.75),room(2.8,3.2,1.3)],["front",room(.65,1.05,1.7),room(4.8,6.7,1.5)],["door",room(door,8.15,1.7),room(door,d.y+1,1.5)],["ceiling",room(d.x/2,6,1.75),room(d.x/2,2.3,3.3)]]:
		eye.position=view[1];eye.look_at(view[2]);await frames(12);await shot(view[0])
	FileAccess.open("res://tests/artifacts/library_training_v227.json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"physical_legs":legs,"checks":checks,"failures":errors,"camera_samples":samples,"overlap_frames":overlap_frames,"blocked_frames":blocked_frames,"bad_samples":bad_samples,"captures":captures,"scope":"209 door,rear/front/central/side aisles; both player camera modes; other2Frooms unchanged"},"\t"))
	print("LIBRARY_TRAINING_V227 legs=",legs.size()," samples=",samples," failures=",errors);quit(0 if errors.is_empty() else 1)
