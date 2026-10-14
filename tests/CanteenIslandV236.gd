extends "res://tests/StageCameraV218.gd"
const P236=preload("res://world/visual_campus/StudentRegisteredPlan.gd")
func pp(u:float,v:float,y:float=.09)->Vector3:return P236.world(u,v,y)
func shot(label:String)->void:
	if root.disable_3d:return
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/canteen-island-v236-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func run()->void:
	root.disable_3d=true
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_player();await frames(15)
	var player:CharacterBody3D=product.world.player
	for mode:bool in [false,true]:
		player.first_person=mode
		await fixture(pp(650,365),[pp(650,445),pp(650,480),pp(580,480),pp(530,480),pp(530,400),pp(565,385),pp(625,385),pp(625,430),pp(625,480),pp(650,480),pp(650,565),pp(645,565),pp(650,565),pp(650,365)],"counter-"+("first" if mode else "third"))
	check("camera volumes clear",overlap_frames==0);check("body to camera clear",blocked_frames==0)
	player.set_physics_process(false);player.hide();product.world.ui.hide();root.disable_3d=false
	var eye:=Camera3D.new();product.world.add_child(eye);eye.current=true;eye.fov=68
	for v:Array in [["curve",pp(630,475,1.8),pp(565,430,1.7)],["front",pp(565,493,1.7),pp(565,430,1.65)],["console",pp(648,582,1.7),pp(616,563,1.25)],["aisle",pp(650,405,1.75),pp(560,490,1.5)]]:
		eye.position=v[1];eye.look_at(v[2]);await frames(12);await shot(v[0])
	FileAccess.open("res://tests/artifacts/canteen_island_v236.json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"physical_legs":legs,"checks":checks,"failures":errors,"camera_samples":samples,"overlap_frames":overlap_frames,"blocked_frames":blocked_frames,"bad_samples":bad_samples,"captures":captures,"scope":"two player camera modes around fitted island and service aisle/consoles; no whole-building route or physical grade registration claim"},"\t"))
	print("CANTEEN_ISLAND_V236 legs=",legs.size()," samples=",samples," failures=",errors);quit(0 if errors.is_empty() else 1)
