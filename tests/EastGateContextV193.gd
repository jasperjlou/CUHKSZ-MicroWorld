extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("gate-context-v193-outward",Vector3(29,1.8,44),Vector3(29,8,176))
	await capture("gate-context-v193-sidewalk",Vector3(38,1.8,55),Vector3(-70,5,160))
	await capture("gate-context-v193-origin",Vector3(29,1.8,1),Vector3(29,8,176))
	var checks:Array=[]
	for z in [-900.0,-300.0,0.0,100.0,200.0]:
		var base:float=world.builder.height(245,clampf(z,-1150,100))
		var actual:float=world.builder.backdrop_height(400,z)-base
		var expected:float=18*sin(155.0/375*PI/2) if z<=0 else 0.0
		var valid:bool=absf(actual-expected)<.001
		checks.append({"z":z,"valid":valid,"extra_height":actual})
		if not valid:failures.append("backdrop interval "+str(z))
	FileAccess.open("res://tests/artifacts/east_gate_context_v193.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"captures":captures,"checks":checks,"failures":failures,"scope":"Off-campus visual context only;no physical routes changed or retested;venue identity and dimensions fitted"},"\t"))
	quit(0 if failures.is_empty() else 1)
