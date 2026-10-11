extends "res://tests/CourtyardRefinementCapture.gd"
func capture(label: String,eye: Vector3,target: Vector3) -> void:
	world.overview.projection=Camera3D.PROJECTION_PERSPECTIVE;world.overview.fov=58
	world.overview.global_position=eye;world.overview.look_at(target)
	await frames(12);await RenderingServer.frame_post_draw
	var filename:="admin-hill-"+label+".png"
	if root.get_texture().get_image().save_png("res://tests/artifacts/"+filename)!=OK:failures.append("capture "+label)
	captures.append(filename)

func ground(x: float,z: float) -> Vector3:
	return Vector3(x,world.builder.height(x,z),z)

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("rear-terrace",Vector3(110,16.5,-180),Vector3(135,16,-182))
	await capture("back-to-building",Vector3(139,17,-171),Vector3(92,20,-183))
	await capture("service-grade",Vector3(145,15,-223),Vector3(132,16,-183))
	await capture("overall",Vector3(165,65,-126),Vector3(103,9,-186))
	await fixture(Vector3(95,11.34,-180),[
		[Vector3(112,14.64,-180),"existing last stair with terrain beneath"],[Vector3(121,14.64,-180),"open rear rail and flush hill threshold"],
		[ground(136,-180),"level back-slope walk"],[ground(137,-201),"service-road hill junction"],
		[ground(137,-217),"service-road mid descent"],[ground(137,-233),"service-road lower descent"],
		[ground(137,-248),"return to retained ground level"],[ground(137,-233),"service-road lower ascent"],
		[ground(137,-217),"service-road mid ascent"],[ground(137,-201),"service-road upper ascent"],
		[ground(137,-180),"hill walk return"],[Vector3(112,14.64,-180),"terrace return"],
		[Vector3(95,11.04,-180),"existing final stair descent"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"build_ms":world.built_ms,"no_teleport_within_each_fixture":true,"scope":"continuous admin rear ground, terrace opening and service-road grade; unchanged courtyard holes excluded from terrain adjustment"}
	FileAccess.open("res://tests/artifacts/administration_hill_milestone.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("ADMINISTRATION_HILL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
