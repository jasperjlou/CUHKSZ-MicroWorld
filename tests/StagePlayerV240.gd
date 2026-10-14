extends "res://tests/CanteenIslandV236.gd"
var ceiling_intrusions:Array=[]
func audit_camera()->void:
	super.audit_camera()
	var e:Vector3=product.world.player.camera.global_position
	var u:float=100+(e.x-44)*P236.PIXELS_PER_METRE
	var v:float=458-(e.z+400)*P236.PIXELS_PER_METRE
	if u>220 and u<325 and v>300 and v<599 and e.y-2.24>3.64:
		if ceiling_intrusions.size()<24:ceiling_intrusions.append({"fixture":current_fixture,"eye":str(e),"u":u,"v":v})
func shot(label:String)->void:
	if root.disable_3d:return
	await process_frame;await RenderingServer.frame_post_draw
	var path:="res://tests/artifacts/stage-player-v240-"+label+".png"
	root.get_texture().get_image().save_png(path);captures.append(path)
func run()->void:
	root.disable_3d=true
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_player();await frames(15)
	var player:CharacterBody3D=product.world.player
	for mode:bool in [false,true]:
		player.first_person=mode
		var label:String="first" if mode else "third"
		await fixture(pp(180,438),[pp(240,438),pp(270,438),pp(270,365),pp(350,365),pp(400,365),pp(650,365),pp(650,480),pp(530,480),pp(530,400),pp(565,385),pp(625,385),pp(650,385),pp(650,365),pp(400,365),pp(270,365),pp(270,438),pp(180,438)],label+"-loop")
		await fixture(pp(270,400),[pp(270,400)],label+"-window-orbit")
		await fixture(pp(350,365),[pp(350,365)],label+"-pendant-orbit")
	check("camera solids clear",overlap_frames==0);check("body to camera clear",blocked_frames==0)
	check("new window ceiling clearance",ceiling_intrusions.is_empty())
	root.disable_3d=false
	for mode:bool in [false,true]:
		player.first_person=mode;player.position=pp(270,400)+Vector3.UP*.12;player.velocity=Vector3.ZERO;player.orbit_yaw=atan2(-(pp(350,365)-player.position).x,-(pp(350,365)-player.position).z);player.orbit_pitch=0
		await frames(20);await shot("window-"+("first" if mode else "third"))
	FileAccess.open("res://tests/artifacts/stage_player_v240.json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"physical_legs":legs,"checks":checks,"failures":errors,"camera_samples":samples,"overlap_frames":overlap_frames,"blocked_frames":blocked_frames,"bad_samples":bad_samples,"ceiling_intrusions":ceiling_intrusions,"captures":captures,"scope":"first/third door-window-counter loop plus yaw/pitch probes under new window ceiling; no full-campus claim"},"\t"))
	print("STAGE_PLAYER_V240 legs=",legs.size()," samples=",samples," errors=",errors);quit(0 if errors.is_empty() else 1)
