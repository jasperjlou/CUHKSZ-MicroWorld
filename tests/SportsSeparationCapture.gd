extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("sports-separated-overview-v57",Vector3(-130,110,-1035),Vector3(-3,8,-936))
	await capture("sports-hall-portal-v57",Vector3(5,7,-828),Vector3(-5,11,-878))
	await capture("sports-complex-field-v57",Vector3(-36,8,-1008),Vector3(-10,11,-947))
	await capture("sports-between-halls-v57",Vector3(44,6,-925),Vector3(-32,9,-941))
	await capture("sports-complex-underpass-v57",Vector3(-10,4,-926),Vector3(-10,4,-961))
	await fixture(Vector3(0,2.54,-849),[
		[Vector3(0,3.08,-862),"University Hall entry stair"],[Vector3(0,3.08,-878),"University Hall reception retained"],
		[Vector3(0,3.08,-862),"reception return"],[Vector3(0,2.24,-850),"entry stair descent"]])
	await fixture(Vector3(46,2.54,-854),[
		[Vector3(46,2.24,-925),"Hall outer side to between-hall court"],[Vector3(-10,2.24,-925),"two separate halls court"],
		[Vector3(-10,2.24,-941),"Complex open ground entrance"],[Vector3(-10,2.24,-958),"Complex lower passage"],
		[Vector3(8,2.24,-958),"lower passage to stair side"],[Vector3(8,2.24,-972),"Complex passage to track edge"],
		[Vector3(62,2.24,-972),"field promenade to outer end"],[Vector3(62,2.24,-925),"Complex side bypass"],
		[Vector3(-81,2.24,-925),"between-hall court full width"],[Vector3(-81,2.24,-972),"opposite side bypass"],
		[Vector3(-35,2.24,-972),"opposite field promenade"]])
	await fixture(Vector3(3,2.54,-966),[
		[Vector3(-19,7.04,-966),"field stair ascent to landing"],[Vector3(-19,7.04,-960),"gallery landing to upper promenade"],
		[Vector3(-45,7.04,-960),"field gallery long wing"],[Vector3(-19,7.04,-960),"gallery return"],
		[Vector3(-19,7.04,-966),"field stair upper landing"],[Vector3(3,2.24,-966),"field stair descent"]])
	var report: Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"V57 independent University Sports Hall and Sports Complex; retained reception, between-hall court, open ground passage, both side bypasses, track promenade and external gallery stair. Survey placement, complete room plans and upper-floor cores remain unverified."}
	FileAccess.open("res://tests/artifacts/sports_separation_v57.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("SPORTS_SEPARATION ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
