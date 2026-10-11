extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("main-square-lawn-v78",Vector3(-2,4.1,-703),Vector3(56,10,-703))
	await capture("main-square-shaw-flight-v78",Vector3(22,4.1,-682),Vector3(28,6,-641))
	await capture("main-square-layout-v78",Vector3(-15,72,-759),Vector3(48,5,-700))
	await capture("main-square-tower-interface-v78",Vector3(24,5,-724),Vector3(23,10,-792))
	await fixture(Vector3(9,2.54,-697),[
		[Vector3(9,2.24,-663),"street walk to Shaw-end stair"],[Vector3(27,2.24,-663),"align below stair rails"],
		[Vector3(27,4.64,-645),"Shaw-end stair ascent and landing"],[Vector3(42.8,4.64,-645),"landing to upper edge walk"],
		[Vector3(42.8,4.64,-666),"upper walk to Chengdao"],[Vector3(51,4.64,-666),"Chengdao real end doorway"],
		[Vector3(42.8,4.64,-666),"Chengdao return"],[Vector3(42.8,4.64,-697),"upper central lane connection"],
		[Vector3(75,4.64,-697),"LeTian lane remains open"],[Vector3(42.8,4.64,-697),"return to continuous upper walk"],
		[Vector3(42.8,4.64,-734),"upper walk to Zhiren"],[Vector3(51,4.64,-734),"Zhiren real end doorway"],
		[Vector3(42.8,4.64,-734),"Zhiren return"],[Vector3(42.8,4.64,-645),"upper edge walk full return"],
		[Vector3(27,4.64,-645),"landing beyond rail ends"],[Vector3(27,2.24,-663),"end stair descent"],
		[Vector3(27,2.24,-697),"unbroken central lawn"],[Vector3(35,2.24,-697),"former central stair now level lawn"],
		[Vector3(15,2.24,-697),"cross lower lawn without artificial rise"],[Vector3(15,2.24,-745),"lawn to existing tower garden"],
		[Vector3(15,2.24,-765),"retained garden side walk"],[Vector3(15,2.84,-770),"retained first short garden stair"],
		[Vector3(15,2.84,-776),"retained first raised lawn"],[Vector3(15,3.44,-781),"retained second garden stair"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"V78 continuous lawn,Shaw-end stair,upper classroom approach and existing tower-end garden interface;dimensions,current dates,whole campus fidelity remain incomplete"}
	FileAccess.open("res://tests/artifacts/main_square_terrace_v78.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("MAIN_SQUARE_TERRACE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
