extends "res://tests/ZhangDatumV137.gd"
var verify_lower:=true
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	if DisplayServer.get_name()!="headless":
		await capture("gate-ab-v140-step",Vector3(-12,3.5,-36),Vector3(-17.3,1.5,-48))
		await capture("gate-ab-v140-apron",Vector3(-20.5,2.8,-37.5),Vector3(-15,1.3,-44))
		await capture("gate-ab-v140-plan",Vector3(-170,52,-94),Vector3(-104,1,-140))
		await capture("gate-ab-v140-road",Vector3(-125,.0,-85),Vector3(-125,0,-148))
		await capture("gate-ab-v140-turn",Vector3(-135.12,-.5,-179),Vector3(-125,-.5,-156))
		await capture("gate-ab-v140-bridge",Vector3(-137,7,-148),Vector3(-129,1,-170))
		FileAccess.open("res://tests/artifacts/gate_ab_v140_views.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"failures":failures},"\t"))
		quit(0);return
	var points:Array[Vector3]=[Vector3(-17.3,0,-39.5),Vector3(-17.3,1.12,-45),Vector3(-17.3,1.12,-47),Vector3(-17.3,2.24,-55.5),Vector3(-35,2.24,-57),Vector3(-35,2.24,-73.5),Vector3(-54,2.24,-73.5),Vector3(-54,2.24,-74),Vector3(-121.8,-1.83,-74),Vector3(-125,-1.83,-74),Vector3(-125,-1.83,-148),Vector3(-125,-2.325,-167),Vector3(-135.12,-2.325,-167),Vector3(-135.12,-2.325,-181.5),Vector3(-135.12,-2.325,-207)]
	var route:Array=[]
	for p:Vector3 in points:route.append([p,"gate to A/B "+str(p)])
	points.reverse()
	for p:Vector3 in points.slice(1):route.append([p,"return "+str(p)])
	if verify_lower:await fixture(Vector3(-18,.3,-39.5),route)
	var upper:Array=[]
	for p:Vector3 in [Vector3(-135,2.32,-167),Vector3(-125,2.32,-167),Vector3(-119.5,2.32,-167),Vector3(-119.5,2.24,-160),Vector3(-119.5,2.24,-147),Vector3(-110,2.24,-147),Vector3(-119.5,2.24,-147),Vector3(-119.5,2.24,-160),Vector3(-119.5,2.32,-167),Vector3(-145,2.24,-167)]:upper.append([p,"upper crossing "+str(p)])
	await fixture(Vector3(-145,2.54,-167),upper)
	for item:Array in [[Vector3(-125,-1.3,-120),Vector3(-125,-2.2,-120),-1.83,"A lower road"],[Vector3(-135.12,-1.8,-177),Vector3(-135.12,-2.8,-177),-2.325,"B gate-side connection"],[Vector3(-17.3,1.6,-46),Vector3(-17.3,.9,-46),1.12,"stone mid landing"]]:
		var hit:=world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(item[0],item[1],1))
		var ok:bool=not hit.is_empty() and absf(hit.position.y-item[2])<.05
		checks.append({"label":item[3],"valid":ok});if not ok:failures.append(item[3])
	probe("A-B low throat open",Vector3(-135.12,-.8,-177),Vector3(-135.12,-.8,-183),false)
	probe("bridge supports upper walk",Vector3(-130,2.6,-167),Vector3(-130,1.9,-167),true)
	probe("lower turn headroom",Vector3(-135.12,-.8,-167),Vector3(-125,-.8,-167),false)
	FileAccess.open("res://tests/artifacts/gate_ab_v140_"+("physics" if verify_lower else "upper")+".json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"fixtures":2 if verify_lower else 1,"checks":checks,"failures":failures},"\t"))
	quit(0 if failures.is_empty() else 1)
