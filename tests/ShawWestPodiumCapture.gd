extends "res://tests/CourtyardRefinementCapture.gd"
var geometry_checks: Array=[]
func wp(x: float,y: float,z: float) -> Vector3:return Vector3(145-z,2.24+y,-640+x)
func check(label: String,a: Vector3,c: Vector3,expected: bool) -> void:
	var q:=PhysicsRayQueryParameters3D.create(a,c);q.exclude=[world.player.get_rid()]
	var r:=world.get_world_3d().direct_space_state.intersect_ray(q)
	var valid:=not r.is_empty() if expected else r.is_empty()
	geometry_checks.append({"label":label,"valid":valid,"expected_hit":expected,"hit":not r.is_empty()})
	if not valid:failures.append("geometry "+label)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("shaw-west-front-v53",wp(52,23,71),wp(2,16,0))
	await capture("shaw-west-roof-v53",wp(-53,75,66),wp(0,15,-1))
	await capture("shaw-west-stairs-v53",wp(32,7,43),wp(21,8,15))
	await capture("shaw-west-hill-v53",Vector3(207,25,-681),Vector3(168,12,-648))
	await fixture(wp(24,.35,37),[
		[wp(24,4.4,21),"first flight to2F"],[wp(24,8.8,5),"second flight to3F"],
		[wp(3,8.8,5),"3F cross-wing open arcade"],[wp(3,8.8,-25),"3F rear wing"],
		[wp(-18,8.8,-25),"3F hill court rear"],[wp(-18,8.8,-28.5),"hill bridge entry"],
		[Vector3(191,11.04,-658),"bridge over rear walk"],[Vector3(205,world.builder.height(205,-658)+.055,-658),"bridge reaches hillside"],
		[Vector3(191,11.04,-658),"hill bridge return"],[wp(-18,8.8,-28.5),"3F return from bridge"],
		[wp(-18,8.8,-25),"rear court return"],[wp(3,8.8,-25),"rear wing return"],
		[wp(3,8.8,5),"cross wing return"],[wp(24,8.8,5),"3F stair head"],
		[wp(24,4.4,21),"second flight descent"],[wp(4,4.4,21),"2F public branch"],
		[wp(24,4.4,21),"2F branch return"],[wp(24,.05,37),"first flight descent"]])
	await fixture(Vector3(110,2.54,-640),[
		[Vector3(110,2.24,-616),"street to main stair"],[wp(30,.05,31.5),"front open court edge"],
		[wp(30,.05,0),"campus-facing court"],[wp(16,.05,0),"court below podium connection"],
		[wp(16,.05,-14.5),"rear public room approach"],[wp(14.5,.05,-21),"rear public room"],
		[wp(14.5,.05,-14.5),"rear room return"],[wp(35,.05,-13),"side passage out"],
		[Vector3(178.5,2.24,-605),"rear sidewalk north"],[Vector3(178.5,2.24,-658),"rear walk below bridge"],
		[Vector3(178.5,2.24,-680),"rear sidewalk south"]])
	check("hill lightwell open",wp(-18.5,9,-6.5),wp(-18.5,46,-6.5),false)
	check("front court open sky",wp(17,1,17),wp(17,45,17),false)
	check("bridge above walk",Vector3(178.5,3.24,-658),Vector3(178.5,8.24,-658),false)
	check("3F lightwell guard",wp(-8.5,9.4,-7),wp(-11,9.4,-7),true)
	check("bridge side guard",Vector3(191,11.7,-658),Vector3(191,11.7,-662),true)
	var report: Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"geometry_checks":geometry_checks,"failures":failures,"build_ms":world.built_ms,"scope":"V53 West fitted dual courts,public1F3F stairs/2F branch,hill bridge and rear walk only;upper dorm cores and absolute geometry unverified"}
	FileAccess.open("res://tests/artifacts/shaw_west_podium_v53.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("SHAW_WEST_PODIUM ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
