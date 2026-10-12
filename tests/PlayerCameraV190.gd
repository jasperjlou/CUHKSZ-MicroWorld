extends "res://tests/ProductExperienceV185.gd"
const Ground = preload("res://world/visual_campus/LibraryGroundStair.gd")
const Approach = preload("res://world/visual_campus/LibraryEntryApproach.gd")
var samples := 0
var overlap_frames := 0
var blocked_frames := 0
var legs: Array = []
var bad_samples: Array = []

func lib(p: Vector3) -> Vector3:return Vector3(78-p.z, 2.24+p.y, -290+p.x)
func gp(z: float) -> Vector3:return lib(Ground.point(Vector3(0, clampf(z/10.5,0,1)*4.4, z)))
func ap(z: float) -> Vector3:return lib(Approach.point(0,z,Approach.surface_y(z)))

func shot(label: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var path := "res://tests/artifacts/player-camera-v190-"+label+".png"
	root.get_texture().get_image().save_png(path)
	captures.append(path)

func audit_camera() -> void:
	var p:CharacterBody3D=product.world.player
	var space:=p.get_world_3d().direct_space_state
	var query:=PhysicsShapeQueryParameters3D.new()
	var sphere:=SphereShape3D.new();sphere.radius=.20
	query.shape=sphere;query.collision_mask=1
	query.transform=Transform3D(Basis.IDENTITY,p.camera.global_position)
	var overlap:bool=not space.intersect_shape(query,1).is_empty()
	var anchor:=p.global_position+Vector3.UP*1.5
	var blocked:bool=not space.intersect_ray(PhysicsRayQueryParameters3D.create(anchor,p.camera.global_position,1)).is_empty()
	samples+=1
	if overlap:overlap_frames+=1
	if blocked:blocked_frames+=1
	if (overlap or blocked) and bad_samples.size()<12:bad_samples.append({"player":str(p.position),"eye":str(p.camera.global_position),"overlap":overlap,"blocked":blocked})

func fixture(start:Vector3, targets:Array, label:String) -> void:
	var p:CharacterBody3D=product.world.player
	p.position=start+Vector3.UP*.12;p.velocity=Vector3.ZERO;p.orbit_pitch=0;p.orbit_zoom=1
	await frames(8)
	for i in targets.size():
		var target:Vector3=targets[i]
		var direction:=target-p.position;direction.y=0
		p.orbit_yaw=atan2(-direction.x,-direction.z)
		await frames(18)
		Input.action_press("move_forward")
		var reached:=false
		for frame in 250:
			await physics_frame
			audit_camera()
			if Vector2(p.position.x-target.x,p.position.z-target.z).length()<.65 and absf(p.position.y-target.y)<.65:
				reached=true;break
		Input.action_release("move_forward");await frames(12)
		legs.append({"fixture":label,"leg":i,"reached":reached,"position":str(p.position),"target":str(target)})
		check(label+" leg "+str(i),reached)
		if not reached:break
		if i==0 or i==targets.size()-1:await shot(label+"-"+str(i))
		# Look sideways under the stair slab/inside rooms, then restore heading.
		if i==0:
			var yaw:float=p.orbit_yaw
			for turn in [PI/2,PI,-PI/2,0.0]:
				p.orbit_yaw=yaw+turn
				for frame in 18:await physics_frame;audit_camera()
			p.orbit_yaw=yaw

func run() -> void:
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(15)
	product.start_player();await frames(15)
	await player_controls()
	await shot("east-gate")
	await fixture(gp(11.1),[gp(6),gp(-1)],"indoor-descent")
	await fixture(gp(-1),[gp(6),gp(11.1)],"indoor-ascent")
	await fixture(ap(0),[ap(7),ap(12),ap(24)],"main-stair-descent")
	await fixture(lib(Vector3(-18,0,10)),[lib(Vector3(-18,0,3.1)),lib(Vector3(-28.13,0,3.1)),lib(Vector3(-28.13,0,1.5))],"lower-rooms")
	check("camera volume never intersects solid geometry",overlap_frames==0)
	check("body to camera visibility remains clear",blocked_frames==0)
	check("human view uses closer lower boom",product.world.player.camera_offset==Vector3(0,2.5,5.2) and product.world.player.camera.fov==55)
	FileAccess.open("res://tests/artifacts/player_camera_v190.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":errors,"legs":legs,"camera_samples":samples,"overlap_frames":overlap_frames,"blocked_frames":blocked_frames,"bad_samples":bad_samples,"captures":captures,"scope":"Player input + four local physics fixtures with camera volume and visibility checks every moving frame; orbit checks at first landing. Not full-campus fidelity acceptance."},"\t"))
	print("PLAYER_CAMERA_V190_DONE ",errors," samples=",samples," overlap=",overlap_frames," blocked=",blocked_frames)
	quit(0 if errors.is_empty() else 1)
