extends "res://tests/TeachingACadCompleteV96Capture.gd"

func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var n:Node3D=world.builder.buildings.teaching_a.get_node("TeachingACad")
	if DisplayServer.get_name()!="headless":
		await capture("ta-v96-plan",n.to_global(Vector3(-35,70,125)),n.to_global(Vector3(10,5,55)))
		await capture("ta-v96-court",n.to_global(Vector3(25,2,68)),n.to_global(Vector3(2,4,48)))
		await capture("ta-v96-lower",n.to_global(Vector3(12,-3.3,39)),n.to_global(Vector3(3,-1.5,49)))
		await capture("ta-v96-mall",n.to_global(Vector3(31,4,110)),n.to_global(Vector3(18,9,82)))
		await capture("ta-v96-gate-link",Vector3(-120,19,-67),Vector3(-70,2.24,-74))
		FileAccess.open("res://tests/artifacts/teaching_a_cad_views_v96.json",FileAccess.WRITE).store_string(JSON.stringify({"captures":captures,"failures":failures},"\t"))
		quit(0 if failures.is_empty() else 1);return
	var probes:Array=[]
	for q:Array in [["lower court open",Vector3(2,20,40),Vector3(2,-6,40),-5.15,.08],["inner court open",Vector3(6,20,60),Vector3(6,-1,60),-.15,.08],["tall arcade clearance",Vector3(25,1.8,54),Vector3(25,12,54),8.5,.3]]:
		var hit:Dictionary=world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(n.to_global(q[1]),n.to_global(q[2]),1))
		var y:float=n.to_local(hit.position).y if hit else -999.0
		var valid:bool=absf(y-float(q[3]))<float(q[4])
		probes.append({"label":q[0],"local_y":y,"valid":valid})
		if not valid:failures.append(q[0])
	await fixture(Vector3(-54,2.54,-71.5),[
		[Vector3(-54,2.24,-73.5),"gate rear threshold"],[Vector3(-122,2.24,-73.5),"gate to A outer path"],
		[Vector3(-122,2.24,-148),"A rear perimeter"],[Vector3(-122,2.24,-167),"A to B rear junction"],
		[Vector3(-135.12,2.24,-167),"B rear bend"],[Vector3(-135.12,2.24,-181.5),"B rear arrival"],
		[Vector3(-135.12,2.24,-167),"B return"],[Vector3(-36,2.24,-167),"A B cross path"],
		[Vector3(-36,2.24,-132.75),"A front promenade"],[n.to_global(Vector3(28.5,0,93)),"A entrance approach"],
		[n.to_global(Vector3(28.5,0,89.5)),"A front portal entry"]])
	await fixture(n.to_global(Vector3(20,.3,54)),[[n.to_global(Vector3(6,-.15,60)),"court bevel entry"],[n.to_global(Vector3(20,0,54)),"court bevel return"]])
	var report:Dictionary={"version":world.data.version,"failures":failures,"probes":probes,"physical_legs":legs,"fixtures":2,"headless":true,"scope":"New TA perimeter, East Gate rear landing, B rear connection and court edge"}
	FileAccess.open("res://tests/artifacts/teaching_a_cad_site_v96.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("TA_CAD_SITE_V96 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
