extends "res://tests/StageCameraV218.gd"
const T=preload("res://world/visual_campus/LibraryTraining209.gd")
func room(x:float,z:float,y:float=0)->Vector3:return lib(T.local_point(x,y,z))
func seating(x:float,z:float,y:float=0)->Vector3:return room(z,T.size().y-x,y)
func shot(label:String)->void:
	if root.disable_3d or DisplayServer.get_name()=="headless":return
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/library-training-v227-final-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func run()->void:
	root.disable_3d=true
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_player();await frames(15)
	var p:CharacterBody3D=product.world.player;var d:=T.size();var door:float=(435.-326.)/137.*d.x
	check("60 modeled chairs",get_nodes_in_group("library-training209-chairs").size()==60)
	var w:float=d.y;var rear:float=d.x-.75
	var route:Array=[room(door,d.y+.30),room(door,d.y-.65),seating(.70,rear),seating(w/2,rear),seating(w/2,1.40),seating(.70,1.40),seating(.70,rear),seating(w/2,rear),seating(w-.70,rear),seating(w-.70,1.40),seating(w/2,1.40),seating(w/2,rear),seating(.70,rear),room(door,d.y-.65),room(door,d.y+.30),room(door,d.y+1.4)]
	for mode:bool in [false,true]:
		p.first_person=mode;await fixture(room(door,d.y+1.4),route,"209-"+("first" if mode else "third"))
	check("camera volumes clear",overlap_frames==0);check("body to camera clear",blocked_frames==0)
	p.set_physics_process(false);p.hide();product.world.ui.hide();root.disable_3d=false
	var eye:=Camera3D.new();product.world.add_child(eye);eye.current=true;eye.fov=68
	for view:Array in [["rear",seating(w-.75,rear,1.75),seating(w*.40,2.5,1.3)],["front",seating(.70,.65,1.7),seating(w*.55,4.5,1.5)],["door",room(door,d.y-1.4,1.7),room(door,d.y+1,1.5)],["ceiling",seating(w/2,5.4,1.75),seating(w/2,2.3,3.3)]]:
		eye.position=view[1];eye.look_at(view[2]);await frames(12);await shot(view[0])
	FileAccess.open("res://tests/artifacts/library_training_v227_final.json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"physical_legs":legs,"checks":checks,"failures":errors,"camera_samples":samples,"overlap_frames":overlap_frames,"blocked_frames":blocked_frames,"bad_samples":bad_samples,"captures":captures,"scope":"209 door,rear/front/central/side aisles; both player camera modes; other2Frooms unchanged"},"\t"))
	print("LIBRARY_TRAINING_V227 legs=",legs.size()," samples=",samples," failures=",errors);quit(0 if errors.is_empty() else 1)
