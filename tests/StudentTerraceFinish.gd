extends "res://tests/CourtyardRefinementCapture.gd"
func wp(x: float,y: float,z: float) -> Vector3:
	return Vector3(91.5-z,2.24+y,-400+x)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("student-stepped-front-final-v49",wp(10,11,80),wp(0,11,5))
	await capture("student-stepped-section-final-v49",wp(1,6.2,39),wp(0,10,-12))
	await capture("student-plan-final-v49",wp(44,70,68),wp(0,5,0))
	await capture("student-middle-court-final-v49",wp(3,10,3),wp(-8,14,-29))
	await capture("student-rear-street-final-v49",Vector3(162,14,-350),Vector3(142,6,-417))
	await fixture(wp(9,9.1,-5),[[wp(0,8.8,-7),"middle terrace cross aisle"],
		[wp(-9,8.8,-9),"upper stair approach"],[wp(-9,12.4,-28),"upper court ascent"],
		[wp(0,12.4,-30),"upper terrace"],[wp(-9,12.4,-28),"upper return approach"],
		[wp(-9,8.8,-9),"upper court descent"],[wp(0,8.8,-7),"middle reverse aisle"],
		[wp(9,8.8,-5),"middle stair return"],[wp(9,4.4,14),"middle descent"],
		[wp(0,4.4,16),"first court return"],[wp(-9,4.4,17),"first stair return"],
		[wp(-9,0,40),"first stair descent"]])
	await fixture(Vector3(56,6.94,-346),[
		[Vector3(56,6.64,-362),"library link approaching student wing"],
		[Vector3(56,6.64,-382),"library link enters student gallery"],
		[wp(10,4.4,35.5),"library gallery opens to first court"],
		[wp(1,4.4,35.5),"first court to front bridge"],[wp(0,4.4,48),"student front upper portal"],
		[Vector3(30,6.64,-400),"student to teaching promenade"],
		[wp(0,4.4,48),"upper portal return"],[wp(1,4.4,35.5),"first court return from bridge"],
		[wp(10,4.4,35.5),"library-side court return"],[Vector3(56,6.64,-382),"student gallery back to link"],
		[Vector3(56,6.64,-346),"library link reverse"]])

	var report: Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"build_ms":world.built_ms,"scope":"Final middle-to-upper court and return, upper promenade after stopping old canopy at facade and opening terrace guard. Initial unaffected lower ascent and rear-road legs retained. Exact rooms/cores unbuilt."}
	FileAccess.open("res://tests/artifacts/student_terraces_finish_v49.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("STUDENT_TERRACES_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
