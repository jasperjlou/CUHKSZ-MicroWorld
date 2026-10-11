extends "res://tests/VisualCampusCapture.gd"
## One milestone for the new building shells, sunken terrain and affected access routes.
func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(12);await RenderingServer.frame_post_draw
	var filename:="courtyard-refined-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)

func walk(target: Vector3,label: String) -> bool:
	var player: CharacterBody3D=world.player;var count:=0;var lowest:=player.position.y
	while Vector2(target.x-player.position.x,target.z-player.position.z).length()>.8 and count<1800:
		player.navigation_direction=Vector2(target.x-player.position.x,target.z-player.position.z).normalized()
		await physics_frame;count+=1;lowest=minf(lowest,player.position.y)
	player.navigation_direction=Vector2.ZERO;await frames(12)
	var distance:=Vector2(target.x-player.position.x,target.z-player.position.z).length()
	var valid:=count<1800 and distance<1.5 and lowest>-2.15 and absf(player.position.y-target.y)<.6
	if not valid:failures.append("physical route "+label)
	legs.append({"goal":label,"valid":valid,"frames":count,"distance":distance,"lowest_y":lowest,"end":[player.position.x,player.position.y,player.position.z]})
	print("COURTYARD_LEG ",label," ",valid," ",player.position)
	return valid

func fixture(start: Vector3,route: Array) -> void:
	world.player.position=start;world.player.velocity=Vector3.ZERO
	world.player.set_physics_process(true);world.player.agent_controlled=true;await frames(20)
	for leg: Array in route:
		if not await walk(leg[0],leg[1]):break
	world.player.set_physics_process(false)

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("student-front",Vector3(-8,15,-366),Vector3(68,13,-400))
	await capture("student-courts",Vector3(4,66,-350),Vector3(72,12,-400))
	await capture("student-portal",Vector3(38,4.1,-395),Vector3(77,7,-400))
	await capture("library-front",Vector3(2,12,-237),Vector3(78,14,-290))
	await capture("library-roof",Vector3(-5,63,-227),Vector3(81,13,-290))
	await capture("district-courtyard",Vector3(-25,38,-308),Vector3(40,5,-359))
	await capture("sunken-court",Vector3(39,.1,-372),Vector3(27,2,-341))
	await fixture(Vector3(40,2.54,-392),[
		[Vector3(60,2.24,-392),"student portal"],[Vector3(76,2.24,-392),"student ground arcade"],
		[Vector3(59,2.24,-392),"student portal return"],[Vector3(58,2.24,-408),"student stair approach"],
		[Vector3(76,6.64,-408),"student upper gallery"],[Vector3(58,2.24,-408),"student descent"]])
	await fixture(Vector3(32,2.54,-333),[
		[Vector3(32,-1.76,-353),"sunken stair descent"],[Vector3(38,-1.76,-355),"sunken east aisle"],
		[Vector3(38,-1.76,-370),"sunken lower shopfront"],[Vector3(38,-1.76,-353),"sunken aisle return"],
		[Vector3(32,-1.76,-353),"sunken stair foot"],[Vector3(32,2.24,-334),"sunken stair ascent"]])
	await fixture(Vector3(15,2.54,-385),[[Vector3(15,-1.76,-350),"sunken ramp descent"],[Vector3(15,2.24,-383),"sunken ramp ascent"]])
	await fixture(Vector3(64,2.54,-272),[[Vector3(86,2.24,-272),"library G opening retained"],[Vector3(64,2.24,-272),"library G return"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":4,"no_teleport_within_each_fixture":true,"build_ms":world.built_ms,"scope":"student/library envelopes and sunken courtyard; remaining district refinement is still active"}
	FileAccess.open("res://tests/artifacts/courtyard_refinement_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("COURTYARD_REFINEMENT ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
