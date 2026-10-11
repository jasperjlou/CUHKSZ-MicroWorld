extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("start-zone-overview-v54",Vector3(-55,91,-622),Vector3(29,8,-712))
	await capture("zhixin-street-v54",Vector3(10,8,-691),Vector3(-38,11,-734))
	await capture("zhixin-court-v54",Vector3(-5,5,-733),Vector3(-49,11,-733))
	await capture("classroom-terrace-v54",Vector3(-6,6,-703),Vector3(51,12,-698))
	await capture("zhixin-north-garden-v54",Vector3(-76,8,-621),Vector3(-37,11,-703))
	await fixture(Vector3(-8.1,2.54,-620),[
		[Vector3(-8.1,2.24,-686),"Shaw approach to Zhixin front"],[Vector3(-8.1,2.24,-735),"street-side library frontage"],
		[Vector3(-20,2.24,-735),"old-library forecourt"],[Vector3(-44,2.24,-735),"flag courtyard passage"],
		[Vector3(-51,2.24,-735),"rear lobby entrance"],[Vector3(-44,2.24,-735),"rear lobby return"],
		[Vector3(-33,2.24,-735),"court side-door approach"],[Vector3(-33,2.24,-700),"north wing public lower"],
		[Vector3(-33,2.24,-735),"north wing return"],[Vector3(-33,2.24,-765),"south wing public lower"],
		[Vector3(-33,2.24,-735),"south wing return"],[Vector3(-8.1,2.24,-735),"courtyard back to street"]])
	await fixture(Vector3(9,2.54,-666),[
		[Vector3(24,2.24,-666),"Chengdao stair foot"],[Vector3(43,4.64,-666),"Chengdao terrace ascent"],
		[Vector3(48,4.64,-666),"Chengdao entrance"],[Vector3(43,4.64,-666),"Chengdao entrance return"],
		[Vector3(24,2.24,-666),"Chengdao terrace descent"],[Vector3(9,2.24,-666),"Chengdao street return"],
		[Vector3(9,2.24,-697),"Letian crossing approach"],[Vector3(24,2.24,-697),"middle stair foot"],
		[Vector3(43,4.64,-697),"middle terrace ascent"],[Vector3(82,4.64,-697),"upper transverse lane"],
		[Vector3(82,4.64,-713),"Letian garden"],[Vector3(109,4.64,-713),"Letian ground entry"],
		[Vector3(82,4.64,-713),"Letian return"],[Vector3(82,4.64,-734),"Zhiren side approach"],
		[Vector3(52,4.64,-734),"Zhiren public arcade"],[Vector3(43,4.64,-734),"Zhiren terrace head"],
		[Vector3(24,2.24,-734),"Zhiren terrace descent"],[Vector3(9,2.24,-734),"lower square return"],
		[Vector3(-8.1,2.24,-735),"road crossing to library"]])
	var report: Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"build_ms":world.built_ms,"scope":"F street/court relocation and raised classroom terrace paths only;absolute survey,full floors,2026 renovated interiors and garden position remain incomplete"}
	FileAccess.open("res://tests/artifacts/start_zone_registration_v54.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("START_ZONE_REGISTRATION ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
