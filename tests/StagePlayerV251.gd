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
		await fixture(sp(-39,0,29.3),[sp(-39,0,7.75),sp(-32,.45,7.75),sp(-25,.45,7.75),sp(-25,.45,10.7),sp(-21,.45,10.7),sp(-21,.45,23),sp(-20,.45,28),sp(-20,0,36),sp(-33,0,36),sp(-39,0,25),sp(-39,0,7.75)],label+"-street-front")
		await fixture(sp(-39,0,0),[sp(-32,.45,0),sp(-26,.45,0),sp(-32,.45,0),sp(-39,0,0)],label+"-side-door")
		await fixture(sp(-20,4.95,26),[sp(-20,4.95,28.5),sp(-12,4.95,28.5),sp(-5,4.95,28.5),sp(-5,4.95,23.3),sp(0,4.95,23.3),sp(0,4.95,14),sp(0,8.85,4),sp(0,4.95,14),sp(0,4.95,23.3)],label+"-upper-guard")
	check("camera volumes clear",overlap_frames==0);check("body-to-camera segments clear",blocked_frames==0)
	root.disable_3d=false
	for v:Array in [["portal",sp(-39,0,7.75),sp(-24,3.5,7.75),false],["upper",sp(-12,4.95,28),sp(-12,6,36),true]]:
		p.position=v[1]+Vector3.UP*.12;p.velocity=Vector3.ZERO;p.first_person=v[3];p.orbit_pitch=0;p.orbit_zoom=1
		var direction:Vector3=v[2]-v[1];p.orbit_yaw=atan2(-direction.x,-direction.z)
		await frames(25);await shot(v[0])
	FileAccess.open("res://tests/artifacts/stage_player_v251.json",FileAccess.WRITE).store_string(JSON.stringify({"version":product.world.data.version,"physical_legs":legs,"checks":checks,"failures":errors,"camera_samples":samples,"overlap_frames":overlap_frames,"blocked_frames":blocked_frames,"bad_samples":bad_samples,"per_fixture":per_fixture,"captures":captures,"scope":"V247-V250Shawstreet/core/front/side and upperguard/stairs in two modes plus stationary yaw/pitch;not full campus"},"\t"))
	print("STAGE_PLAYER_V251 legs=",legs.size()," samples=",samples," errors=",errors);quit(0 if errors.is_empty() else 1)
