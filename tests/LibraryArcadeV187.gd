extends "res://tests/LibraryEntryApproachV117.gd"
const Arcade=preload("res://world/visual_campus/LibraryPoolArcade.gd")
var verify_walks:=true
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-arcade-v187-overview",wp(-23,10,41),wp(-19,4,21))
	await capture("library-arcade-v187-stone",wp(-25,2.0,20),wp(-20,.12,20))
	await capture("library-arcade-v187-corridor",wp(-36,1.8,18),wp(-17,1.8,18))
	var route:Array=[]
	for p in [Vector3(34,2.24,-334),Vector3(54,2.24,-334),Vector3(60,2.24,-334),Vector3(60,2.24,-330)]:route.append([p,"pond end to open side "+str(p)])
	for p in [Vector3(-35,0,18),Vector3(-31,0,18),Vector3(-24,0,18),Vector3(-17,0,20),Vector3(-12,0,20),Vector3(-12,0,17),Vector3(-12,0,13),Vector3(-12,0,10),Vector3(-12,0,13),Vector3(-12,0,17),Vector3(-12,0,20),Vector3(-17,0,20),Vector3(-24,0,18),Vector3(-31,0,18),Vector3(-35,0,18),Vector3(-40,0,18)]:route.append([wp(p.x,p.y,p.z),"G open side and recessed entry "+str(p)])
	for p in [Vector3(60,2.24,-334),Vector3(54,2.24,-334),Vector3(34,2.24,-334),Vector3(14,2.24,-334)]:route.append([p,"pond end return "+str(p)])
	if verify_walks:await fixture(Vector3(14,2.54,-334),route)
	var checks:Array=[]
	var areas:=Arcade.finish_areas();var overlap_area:float=0
	for i in areas.size():
		for j in range(i+1,areas.size()):
			for intersection in Geometry2D.intersect_polygons(areas[i],areas[j]):
				var twice:float=0
				for k in intersection.size():twice+=intersection[k].cross(intersection[(k+1)%intersection.size()])
				overlap_area+=absf(twice)*.5
	checks.append({"case":"finish polygons have no coplanar overlap","valid":overlap_area<.001,"overlap_m2":overlap_area,"polygons":areas.size()})
	if overlap_area>=.001:failures.append("overlapping finish polygons")
	var columns=world.find_children("*RoundArcadeColumn*","MeshInstance3D",true,false)
	checks.append({"case":"five round arcade supports built","valid":columns.size()==5,"count":columns.size()})
	if columns.size()!=5:failures.append("round arcade support count")
	for pair in [[wp(-24,.6,18),wp(-24,-.3,18),true,"dry outdoor arcade floor"],[wp(-12,.6,20),wp(-12,-.3,20),true,"curved entry forecourt floor"],[wp(-4,.7,29),wp(-4,-.3,29),true,"public1F outside core stays dry"],[wp(-5,.3,37),wp(-5,-.4,37),false,"water outside new fin line has no grass floor"],[wp(-34,2,18),wp(-32,2,18),false,"side return remains open below3F"]]:
		var q=PhysicsRayQueryParameters3D.create(pair[0],pair[1]);q.exclude=[world.player.get_rid()]
		var hit=world.get_world_3d().direct_space_state.intersect_ray(q);var ok:bool=not hit.is_empty() if pair[2] else hit.is_empty()
		checks.append({"case":pair[3],"valid":ok,"collider":str(hit.collider.get_path()) if not hit.is_empty() else "none"});if not ok:failures.append(pair[3])
	var report={"version":world.data.version,"physical_legs":legs,"captures":captures,"checks":checks,"failures":failures,"fixtures":1 if verify_walks else 0,"scope":"continuous pond-end/open-side/Gthreshold return after round support and unified stone finish;stairs and absolute grades unresolved"}
	FileAccess.open("res://tests/artifacts/library_arcade_v187.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_ARCADE_V187 ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
