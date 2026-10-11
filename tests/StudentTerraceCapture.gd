extends "res://tests/CourtyardRefinementCapture.gd"
func wp(x: float,y: float,z: float) -> Vector3:
	return Vector3(91.5-z,2.24+y,-400+x)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("student-stepped-front-v49",wp(10,11,80),wp(0,11,5))
	await capture("student-stepped-section-v49",wp(1,7,39),wp(0,12,-26))
	await capture("student-plan-v49",wp(44,70,68),wp(0,5,0))
	await capture("student-middle-court-v49",wp(3,10,3),wp(-8,14,-29))
	await capture("student-rear-street-v49",Vector3(162,14,-350),Vector3(142,6,-417))
	await fixture(wp(-9,.3,45),[
		[wp(-9,0,38),"front stair foot"],[wp(-9,4.4,17),"first court ascent"],
		[wp(0,4.4,16),"first terrace cross aisle"],[wp(9,4.4,14),"middle stair approach"],
		[wp(9,8.8,-5),"middle court ascent"],[wp(0,8.8,-7),"middle terrace cross aisle"],
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
	await fixture(Vector3(127,2.54,-350),[
		[Vector3(151,2.24,-373),"road around student north rear corner"],[Vector3(151,2.24,-440),"road clear of extended student rear"],
		[Vector3(120,2.24,-475),"rear road returns toward Shaw"],[Vector3(151,2.24,-440),"Shaw approach reverse"],
		[Vector3(151,2.24,-373),"student rear reverse"],[Vector3(127,2.24,-350),"library rear road return"]])
	var report: Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"build_ms":world.built_ms,"scope":"Ascending courts, two upper promenade interfaces and displaced SC rear road. Proportions and site coordinates fitted; missing cores and complete rooms not claimed."}
	FileAccess.open("res://tests/artifacts/student_terraces_v49.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("STUDENT_TERRACES ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
