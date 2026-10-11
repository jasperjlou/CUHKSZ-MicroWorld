extends "res://tests/CourtyardRefinementCapture.gd"
const ORIGIN := Vector3(-10,2.24,-947)
func wp(x: float,y: float,z: float) -> Vector3:return ORIGIN+Vector3(x,y,z)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("sports-upper-badminton-v61",wp(-7,11,5.8),wp(-37,12,-4))
	await capture("sports-upper-multipurpose-v61",wp(28,11.0,6),wp(17,11.8,-7))
	await capture("sports-upper-services-v61",wp(-33,11.4,5),wp(-39,16,-3))
	await capture("sports-upper-entry-v61",wp(43,11.0,13),wp(16,11.0,10))
	await capture("sports-section-exterior-v61",wp(-2,7,-90),wp(-2,11,0))
	var clearances: Array=[]
	for x in [-58.0,-40.0,-22.0,11.0,20.0]:
		var q:=PhysicsRayQueryParameters3D.create(wp(x,11.2,0),wp(x,23,0))
		var hit:=world.get_world_3d().direct_space_state.intersect_ray(q)
		var h: float=float(hit.position.y)-ORIGIN.y-9.2 if not hit.is_empty() else -1
		var valid: bool=h>6 and h<13
		clearances.append({"local_x":x,"overhead_collision_clearance":h,"valid":valid})
		if not valid:failures.append("upper headroom at "+str(x))
	await fixture(wp(48,5.1,14.5),[
		[wp(48,7,2.5),"2F to3F stair half landing"],[wp(54,7,2.5),"upper stair turn"],
		[wp(54,9.2,14.5),"3F arrival"],[wp(43,9.2,14.5),"3F landing exit"],
		[wp(43,9.2,11.3),"upper public lobby"],[wp(17,9.2,11.3),"sports room approach"],
		[wp(17,9.2,5.8),"sports room doorway"],[wp(28.8,9.2,5.8),"sports room right run-off"],
		[wp(28.8,9.2,-10),"sports room outside net end"],[wp(10.1,9.2,-10),"sports room far run-off"],
		[wp(10.1,9.2,5.8),"sports room opposite net end"],[wp(17,9.2,5.8),"sports room front aisle"],
		[wp(17,9.2,11.3),"sports room exit"],[wp(-33,9.2,11.3),"badminton lobby approach"],
		[wp(-33,9.2,6),"badminton doorway"],[wp(-10,9.2,6),"badminton front aisle"],
		[wp(-10,9.2,3),"badminton playing half"],[wp(-10,9.2,6),"return beyond baseline"],
		[wp(-5.9,9.2,6),"badminton end run-off"],[wp(-5.9,9.2,-10),"badminton round net end"],
		[wp(-59,9.2,-10),"badminton far-side full run-off"],[wp(-59,9.2,6),"badminton other net end"],
		[wp(-33,9.2,6),"badminton front return"],[wp(-33,9.2,11.3),"badminton room exit"],
		[wp(43,9.2,11.3),"lobby to open end"],[wp(43,9.2,0),"open-end terrace approach"],
		[wp(47,9.2,0),"existing upper terrace retained"],[wp(59,9.2,0),"upper outer aisle"],
		[wp(59,9.2,14.5),"upper descent approach"],[wp(54,9.2,14.5),"descending upper stair"],
		[wp(54,7,2.5),"upper descent half landing"],[wp(48,7,2.5),"upper descent turn"],
		[wp(48,4.8,14.5),"return to2F"],[wp(43,4.8,14.5),"2F corridor retained"],
		[wp(43,4.8,11.3),"2F corridor centreline"],[wp(43,4.8,-13),"2F field-side connection retained"]])
	var report: Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"clearance_checks":clearances,"scope":"V61 continuous existing2F stair to3F two rooms and perimeter run-offs, terrace and2F return; local dimensions/roof/room sequence fitted, not sport certification. Roof/duct checks sampled only."}
	FileAccess.open("res://tests/artifacts/sports_upper_v61.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("SPORTS_UPPER ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
