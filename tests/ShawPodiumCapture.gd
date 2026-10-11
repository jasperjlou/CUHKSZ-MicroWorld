extends "res://tests/CourtyardRefinementCapture.gd"
const Grade:=preload("res://world/visual_campus/ShawEastGrade.gd")
func wp(x: float,y: float,z: float) -> Vector3:return Vector3(84.3-z,2.24+y,-540+x)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("shaw-podium-front-v51",wp(-45,19,70),wp(0,12,0))
	await capture("shaw-podium-plan-v51",wp(-44,85,70),wp(0,0,0))
	await capture("shaw-podium-portal-v51",wp(-23,2.3,41),wp(-15,5,19))
	await capture("shaw-podium-terrace-v51",wp(0,10.5,23),wp(0,12,-19))
	await capture("shaw-podium-rear-v51",wp(20,20,-58),wp(2,6,-20))
	await fixture(wp(-20,.3,36),[
		[wp(-20,.45,28),"main entrance steps"],[wp(-10,.45,25),"lower entrance hall"],[wp(-6.1,.45,22.4),"lower stair approach"],
		[wp(-6.1,2.7,16),"lower stair first flight"],[wp(-3.2,2.7,16),"lower stair half landing"],[wp(-3.2,4.95,22.4),"second floor arrival"],
		[wp(0,4.95,22.4),"second floor hall"],[wp(0,4.95,14),"terrace stair approach"],[wp(0,8.85,5),"third floor terrace ascent"],
		[wp(10,8.85,5),"third floor open terrace"],[wp(10,8.85,-12),"rear terrace connection"],
		[wp(10,8.85,5),"terrace return"],[wp(0,8.85,5),"terrace stair return"],[wp(0,4.95,14),"terrace descent"],
		[wp(0,4.95,22.4),"second floor return hall"],[wp(-3.2,4.95,22.4),"lower stair return"],[wp(-3.2,2.7,16),"second flight descent"],
		[wp(-6.1,2.7,16),"half landing return"],[wp(-6.1,.45,22.4),"first flight descent"],[wp(-10,.45,25),"ground hall return"],[wp(-20,.45,28),"portal return"],[wp(-20,0,36),"street return"]])
	await fixture(wp(10,4.8,-36),[[wp(10,4.95,-28),"rear higher entry"],[wp(10,4.95,-17),"rear second-floor public passage"],[wp(10,4.95,-28),"rear passage return"],[wp(10,4.5,-36),"rear outdoor descent"]])
	await fixture(Vector3(120,2.54,-475),[[Vector3(122,6.74,-510),"rear road rises to Shaw"],[Vector3(130,6.74,-540),"rear road high frontage"],[Vector3(113,2.24,-575),"rear road descends to corner"],[Vector3(130,6.74,-540),"rear road reverse ascent"],[Vector3(122,6.74,-510),"rear road plateau return"],[Vector3(120,2.24,-475),"rear road descent towards student centre"]])
	var report: Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"build_ms":world.built_ms,"scope":"East public1F/2F/3F stairs and terraces;rear2F entry;changed rear-road grade. Fitted dimensions/registration, no complete dorm access claim."}
	FileAccess.open("res://tests/artifacts/shaw_podium_v51.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("SHAW_PODIUM ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
