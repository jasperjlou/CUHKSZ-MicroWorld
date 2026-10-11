extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("woodland-entry-v86",Vector3(-29,4.15,-441),Vector3(-29,2.4,-474))
	await capture("woodland-downhill-v86",Vector3(-29,3.48,-457),Vector3(-30,2,-479))
	await capture("woodland-platform-v86",Vector3(-21,6,-475),Vector3(-34,3,-451))
	await capture("woodland-court-entry-v86",Vector3(-69,3.4,-484),Vector3(-88,4,-496))
	await capture("woodland-pavilion-connection-v86",Vector3(-22,15,-461),Vector3(-18,2,-491))
	await fixture(Vector3(-29,2.54,-438),[
		[Vector3(-29,2.24,-443),"under link at descent entry"],
		[Vector3(-29,2.10,-449),"upper descent"],
		[Vector3(-29,1.68,-459),"woodland slope"],
		[Vector3(-29,1.04,-477),"lower woodland fork"],
		[Vector3(-34,1.04,-482),"research bend"],
		[Vector3(-48,1.04,-484),"lower research approach"],
		[Vector3(-68,1.04,-487),"research frontage approach"],
		[Vector3(-76,1.04,-493),"longer court stair foot"],
		[Vector3(-88,2.89,-493),"court platform ascent"],
		[Vector3(-92,2.89,-494),"court platform connection"],
		[Vector3(-92,2.24,-505),"court interior grade retained"],
		[Vector3(-92,2.89,-493),"court return"],
		[Vector3(-76,1.04,-493),"court stair descent"],
		[Vector3(-68,1.04,-487),"research approach return"],
		[Vector3(-48,1.04,-484),"lower approach return"],
		[Vector3(-34,1.04,-482),"woodland bend return"],
		[Vector3(-29,1.04,-477),"woodland fork return"],
		[Vector3(-20,1.39,-484),"pavilion garden ascent"],
		[Vector3(-8,2.24,-490),"pavilion upper approach"],
		[Vector3(0,2.24,-491),"pavilion approach landing"],
		[Vector3(0,2.32,-503),"four arch pavilion retained"],
		[Vector3(0,2.24,-491),"pavilion return"],
		[Vector3(-8,2.24,-490),"upper fork return"],
		[Vector3(-20,1.39,-484),"garden descent return"],
		[Vector3(-29,1.04,-477),"woodland return junction"],
		[Vector3(-29,1.68,-459),"woodland ascent"],
		[Vector3(-29,2.24,-443),"return under transverse link"],
		[Vector3(-35,2.24,-442),"upper platform side approach"],
		[Vector3(-35,2.24,-472),"retained platform behind black rail"],
		[Vector3(-35,2.24,-442),"platform return"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"Woodland descent,lower research approach,revised court stair,pavilion branch and retained platform;fitted dimensions and gradients."}
	FileAccess.open("res://tests/artifacts/woodland_v86.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("WOODLAND_V86 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
