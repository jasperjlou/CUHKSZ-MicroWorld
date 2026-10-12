extends "res://tests/StudentLowerEntriesV151.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for s in [[12.,0.,8.8,9.],[-13.,4.4,12.4,-9.],[-40.,8.8,16.,0.]]:
		for x in [-11.8,-7.4,-3.2,1.,5.2,12.8]:
			if absf(x-s[3])<2.65:continue
			probe(wp(x,s[1]+1.5,s[0]+1),wp(x,s[1]+1.5,s[0]-1),true,"court solid strips "+str([x,s[0]]),checks)
	for x in [-4.8,3.6]:probe(wp(x,1.6,14),wp(x,1.6,10),false,"lower court door final "+str(x),checks)
	await fixture(wp(-4.8,.3,16),[[wp(-4.8,0,9),"refined lower door enter"],[wp(3.6,0,9),"hall cross"],[wp(3.6,0,16),"refined second door exit"]])
	await fixture(wp(0,4.7,18),[
		[wp(-5,4.4,20),"table side approach"],[wp(-5,4.4,28),"pass table on left"],[wp(-5,4.4,30.5),"before tree planter"],[wp(0,4.4,30.5),"cross behind table"],[wp(0,4.4,48),"upper promenade joint"],
		[wp(0,4.4,35.5),"library branch approach"],[wp(10,4.4,35.5),"library branch enters wing"],[Vector3(56,6.64,-382),"retained library link"]])
	await fixture(wp(0,4.7,16),[
		[wp(9,4.4,14),"middle stair approach"],[wp(9,8.8,-5),"middle stair through refined yellow wall"],[wp(0,8.8,-7),"middle aisle"],[wp(-9,8.8,-9),"upper stair approach"],[wp(-9,12.4,-28),"upper stair through refined yellow wall"],[wp(0,12.4,-30),"upper terrace"],[wp(0,12.4,-42),"upper rear opening"],[wp(0,12.4,-30),"upper opening return"]])
	await capture("student-lower-v151-court-final",wp(0,2,20),wp(-1,3,11))
	await capture("student-lower-v151-threshold-final",wp(-4.8,1.75,9),wp(-4.8,1.75,17))
	await capture("student-lower-v151-section-final",wp(2,8,43),wp(-1,10,-13))
	FileAccess.open("res://tests/artifacts/student_lower_entries_v151_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":3,"scope":"Changed yellow facade closure, stairs and table bypass; rear geometry not changed since initial batch"},"\t"))
	print("STUDENT_LOWER_V151_FINISH ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
