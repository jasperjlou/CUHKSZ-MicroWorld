extends "res://tests/StageCameraV218.gd"
var building:Node3D
func sp(x:float,y:float,z:float)->Vector3:return building.to_global(Vector3(x,y,z))
func shot(label:String)->void:
	if root.disable_3d:return
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/stage-player-v251-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func run()->void:
	root.disable_3d=true
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_player();await frames(15);building=product.world.builder.buildings.shaw_east
	var p:CharacterBody3D=product.world.player
	for mode:bool in [false,true]:
		p.first_person=mode;var label:String="first" if mode else "third"
		await fixture(sp(-39,0,29.3),[sp(-39,0,7.75),sp(-32,.45,7.75),sp(-25,.45,7.75),sp(-25,.45,10.7),sp(-22,.45,10.7),sp(-22,.45,23),sp(-20,.45,28),sp(-20,0,36),sp(-33,0,36),sp(-39,0,25),sp(-39,0,7.75)],label+"-street-front")
	check("camera volumes clear",overlap_frames==0);check("body-to-camera segments clear",blocked_frames==0)
	FileAccess.open("res://tests/artifacts/stage_player_finish_v251.json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"physical_legs":legs,"checks":checks,"failures":errors,"camera_samples":samples,"overlap_frames":overlap_frames,"blocked_frames":blocked_frames,"bad_samples":bad_samples,"per_fixture":per_fixture,"captures":captures,"scope":"Corrected central passage route only in two modes;side and upper fixtures retained from initial run;not fullcampus"},"\t"))
	print("STAGE_PLAYER_FINISH_V251 legs=",legs.size()," samples=",samples," errors=",errors);quit(0 if errors.is_empty() else 1)
