extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("old-library-junction-v87",Vector3(-12,6.8,-666),Vector3(-31,8,-698))
	await capture("court-bus-road-v87",Vector3(-19,4.0,-676.4),Vector3(-62,3.8,-682))
	await capture("old-library-glass-base-v87",Vector3(-48,3.9,-683),Vector3(-45,5.5,-693))
	await capture("old-library-road-layout-v87",Vector3(-5,57,-623),Vector3(-54,2.5,-685))
	await fixture(Vector3(-12,2.54,-688.1),[
		[Vector3(-20.5,2.24,-688.1),"library sidewalk crossing approach"],
		[Vector3(-20.5,2.24,-676.4),"crossing through white rail opening"],
		[Vector3(-44,2.24,-676.4),"court brick walk along painted wall"],
		[Vector3(-44,2.24,-668),"court road gate"],
		[Vector3(-44,2.24,-637),"court centre aisle"],
		[Vector3(-44,2.24,-631),"court eastgate end gate"],
		[Vector3(-18,2.24,-631),"outer end walk"],
		[Vector3(-18,2.24,-656),"outer side approach"],
		[Vector3(-27,2.24,-656),"side gate"],
		[Vector3(-44,2.24,-656),"court transverse aisle"],
		[Vector3(-70,2.24,-656),"parking side gate"],
		[Vector3(-76,2.24,-656),"parking aisle crossing"],
		[Vector3(-76,2.24,-672),"court service lane"],
		[Vector3(-86,2.24,-682),"branch junction"],
		[Vector3(-120,2.24,-682),"bus apron approach"],
		[Vector3(-154,2.24,-682),"waiting apron"],
		[Vector3(-100,2.24,-682),"branch return"],
		[Vector3(-87,2.24,-688.1),"library side walkway"],
		[Vector3(-64,2.24,-688.1),"recessed base approach"],
		[Vector3(-30,2.24,-688.1),"glass base roadside walk"],
		[Vector3(-20.5,2.24,-688.1),"crossing return approach"],
		[Vector3(-20.5,2.24,-676.4),"return crossing"],
		[Vector3(-12,2.24,-676.4),"curved rail footway"],
		[Vector3(-9,2.24,-670),"junction outer footway"],
		[Vector3(-9,2.24,-661),"main street eastgate direction connection"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"Repositioned court gates,brick walk,old library base crossing,branch,bus apron and main-street connection;coordinates fitted,not full campus fidelity acceptance."}
	FileAccess.open("res://tests/artifacts/old_library_road_v87.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("OLD_LIBRARY_ROAD_V87 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
