extends "res://tests/StudentWestLandingV233.gd"
func shot(label:String)->void:
	if root.disable_3d:return
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/student-west-v233-final-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func run()->void:
	root.disable_3d=true
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_player();await frames(15)
	var p:CharacterBody3D=product.world.player
	for mode:bool in [false,true]:
		p.first_person=mode
		# v365 is the wall between doors; go through the actual340..362 opening.
		# Preserve the original180365 destination, with an explicit doorway waypoint.
		await fixture(pp(180,438,.075),[pp(240,438,.075),pp(270,438,.075),pp(270,365,.075),pp(270,350,.075),pp(180,350,.075),pp(180,365,.075)],"ground-entries-"+("first" if mode else "third"))
	check("camera volumes clear",overlap_frames==0);check("body to camera clear",blocked_frames==0)
	p.set_physics_process(false);p.hide();product.world.ui.hide();root.disable_3d=false
	var eye:=Camera3D.new();product.world.add_child(eye);eye.current=true;eye.fov=68
	for v:Array in [["ground-door",pp(180,380,1.75),pp(260,350,1.7)],["front-upper",pp(360,330,6.1),pp(240,269,3.2)]]:
		eye.position=v[1];eye.look_at(v[2]);await frames(12);await shot(v[0])
	FileAccess.open("res://tests/artifacts/student_west_v233_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"physical_legs":legs,"checks":checks,"failures":errors,"camera_samples":samples,"overlap_frames":overlap_frames,"blocked_frames":blocked_frames,"bad_samples":bad_samples,"captures":captures,"scope":"Actual ground doors with preserved original endpoint; initial38front-west loop legs unchanged; initial failed direct path through wall retained"},"\t"))
	print("STUDENT_WEST_FINISH_V233 legs=",legs.size()," samples=",samples," failures=",errors);quit(0 if errors.is_empty() else 1)
