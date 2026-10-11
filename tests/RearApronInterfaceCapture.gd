extends "res://tests/LibraryRearRoadCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-asphalt-apron-v74",Vector3(131,5,-327),Vector3(99,10,-311))
	await capture("library-rear-road-mouth-v74",Vector3(139,7,-343),Vector3(115,5,-303))
	await capture("student-rear-connection-v74",Vector3(152,5,-409),Vector3(137,5,-397))
	await capture("library-student-rear-overview-v74",Vector3(190,64,-344),Vector3(120,4,-378))
	await fixture(site(137,-322)+Vector3.UP*.3,[
		[site(131,-322),"avenue opens onto asphalt apron"],[site(120,-322),"service apron cross aisle"],
		[site(111,-320),"asphalt reaches rear steps"],[Vector3(105,2.72,-320),"rear step ascent"],
		[Vector3(102,2.72,-320),"rear porch doorway"],[Vector3(97,2.24,-320),"porch connects lower interior"],
		[Vector3(105,2.72,-320),"lower interior returns to porch"],[site(111,-320),"rear step descent"],
		[site(120,-322),"back across apron"],[site(137,-322),"apron returns to avenue"],
		[site(127,-350),"library to student bend"],[site(151,-373),"extended student rear corner"],
		[site(151,-400),"student rear door road approach"],[site(145,-400),"open curb at rear door"],
		[Vector3(138,2.24,-400),"rear threshold enters student centre"],[site(145,-400),"rear threshold return"],
		[site(145,-433),"student rear paving follows building"],[site(151,-440),"student rear paving to road bend"],
		[site(120,-475),"rear avenue reaches Shaw interface"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"build_ms":world.built_ms,"scope":"single continuous library rear lower-entry/apron to student rear-door and Shaw-approach fixture;ground material and local interface only,not surveyed fidelity","no_teleport_within_fixture":true}
	FileAccess.open("res://tests/artifacts/rear_apron_interface_v74.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("REAR_APRON_INTERFACE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
