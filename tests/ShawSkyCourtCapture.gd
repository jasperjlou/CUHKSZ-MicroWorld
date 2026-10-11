extends "res://tests/CourtyardRefinementCapture.gd"
var geometry_checks: Array=[]
func wp(x: float,y: float,z: float) -> Vector3:return Vector3(84.3-z,2.24+y,-540+x)
func hit(a: Vector3,c: Vector3) -> Dictionary:
	var q:=PhysicsRayQueryParameters3D.create(a,c);q.exclude=[world.player.get_rid()]
	return world.get_world_3d().direct_space_state.intersect_ray(q)
func check(label: String,a: Vector3,c: Vector3,expected: bool) -> void:
	var r:=hit(a,c);var valid:=not r.is_empty() if expected else r.is_empty()
	geometry_checks.append({"label":label,"valid":valid,"expected_hit":expected,"hit":not r.is_empty()})
	if not valid:failures.append("geometry "+label)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("shaw-sky-front-v52",wp(-45,27,70),wp(0,21,0))
	await capture("shaw-sky-roof-v52",wp(-48,77,58),wp(0,15,-1))
	await capture("shaw-sky-side-v52",wp(-59,26,-18),wp(-29,25,-3))
	await capture("shaw-sky-rear-court-v52",wp(4,28,0),wp(1,26,-22))
	for p: Vector2 in [Vector2(1.66,-18.37),Vector2(-30.9,-3.05),Vector2(30.15,-22.3),Vector2(31.5,18.5),Vector2(31.5,27)]:
		check("sky clear "+str(p),wp(p.x,24.1,p.y),wp(p.x,42,p.y),false)
		check("garden floor "+str(p),wp(p.x,22.5,p.y),wp(p.x,21.5,p.y),true)
	check("rear court guard",wp(1.66,22.65,-17),wp(1.66,22.65,-14),true)
	check("side court guard",wp(-32,22.65,-3.05),wp(-35,22.65,-3.05),true)
	check("L court guard",wp(32,22.65,25.5),wp(35,22.65,25.5),true)
	await fixture(wp(1.66,22.35,-23.3),[[wp(1.66,22.05,-19.7),"rear sky door"],[wp(1.66,22.05,-17.7),"rear sky court"],[wp(1.66,22.05,-23.3),"rear sky return"]])
	await fixture(wp(-25.8,22.35,-3.05),[[wp(-29.2,22.05,-3.05),"side sky door"],[wp(-31.8,22.05,-3.05),"side sky court"],[wp(-25.8,22.05,-3.05),"side sky return"]])
	await fixture(wp(24,22.35,-22.3),[[wp(28,22.05,-22.3),"rear end door"],[wp(31.5,22.05,-22.3),"rear end terrace"],[wp(24,22.05,-22.3),"rear end return"]])
	await fixture(wp(24,22.35,18.5),[[wp(29,22.05,18.5),"L terrace door"],[wp(31.5,22.05,18.5),"L terrace north"],[wp(31.5,22.05,23),"L corner continuous join"],[wp(31.5,22.05,27),"L front return terrace"],[wp(31.5,22.05,18.5),"L corner reverse"],[wp(24,22.05,18.5),"L terrace door return"]])
	await fixture(wp(0,5.25,14),[[wp(0,8.85,4),"retained public terrace ascent"],[wp(10,8.85,4),"retained3F court"],[wp(10,8.85,-12),"rear return wing clearance"]])
	var report: Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"geometry_checks":geometry_checks,"build_ms":world.built_ms,"scope":"Upper courts initialized on their own floors: local access, real open sky, floors and guards only. Vertical cores/ground-to7F access unbuilt. Selected3F public connection retained."}
	FileAccess.open("res://tests/artifacts/shaw_sky_courts_v52.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("SHAW_SKY_COURTS ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
