extends "res://tests/LibraryLowerLevelCapture.gd"
const Core := preload("res://world/visual_campus/LibraryServiceCores.gd")
func cp(index: int,x: float,y: float,z: float) -> Vector3:
	var p:=Core.local_point(index,Vector3(x,y,z));return wp(p.x,p.y,p.z)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-atrium-up-v46",wp(14.5,10.5,-4.8),wp(-9,16,5))
	await capture("library-atrium-gallery-v46",wp(12,18.5,14),wp(-13,13,0))
	await capture("library-atrium-skylight-v46",wp(-6,10.6,10),wp(-4,24.5,-1))
	await capture("library-fourth-reading-v46",wp(36,14.5,2),wp(23,14,-13))
	await capture("library-roof-open-v46",wp(-8,40,54),wp(0,18,2))
	# Arrival from the retained 2F public stair, then all the way to 5F and back without teleport.
	await fixture(wp(0,4.7,9),[
		[wp(11.2,8.8,-2.2),"retained public third floor arrival"],
		[wp(15.2,8.8,-3),"third floor right atrium aisle"],
		[wp(15.2,8.8,14),"third floor front balcony"],
		[wp(-12,8.8,14),"third floor public flight approach"],
		[wp(-12,8.8,12),"third to fourth foot"],
		[wp(-12,12.8,-5.4),"public fourth floor arrival"],
		[wp(9,12.8,-5.4),"fourth floor rear bridge"],
		[wp(9,12.8,-4),"fourth to fifth foot"],
		[wp(9,16.8,13.6),"public fifth floor arrival"],
		[wp(15.5,16.8,13.6),"fifth floor front gallery"],
		[wp(17,16.8,0),"fifth floor right wing"],
		[wp(22,16.8,-7),"fifth floor reading aisle"],
		[wp(17,16.8,0),"fifth wing return"],
		[wp(15.5,16.8,13.6),"fifth gallery return"],
		[wp(9,16.8,13.6),"public upper descent approach"],
		[wp(9,12.8,-5.4),"public fourth floor descent"],
		[wp(-12,12.8,-5.4),"fourth bridge return"],
		[wp(-12,8.8,14),"public third floor descent"]])
	for index in 2:
		var name: String="left" if index==0 else "diagonal"
		var route: Array=[]
		for level in [2,3]:
			var y: float=Core.LEVELS[level];var next: float=Core.LEVELS[level+1];var half: float=(y+next)/2
			route.append_array([[cp(index,0,y,-3.8),name+" level "+str(level+1)+" lobby"],[cp(index,-1.45,y,-3),name+" upper stair foot"],[cp(index,-1.45,half,3.8),name+" upper half landing"],[cp(index,1.45,half,3.8),name+" upper turn"],[cp(index,1.45,next,-3.8),name+" level "+str(level+2)+" arrival"],[cp(index,6,next,-3.8),name+" level "+str(level+2)+" side doorway"],[cp(index,1.45,next,-3.8),name+" return into core"]])
		route.append_array([[cp(index,1.45,14.8,3.8),name+" descending fifth flight"],[cp(index,-1.45,14.8,3.8),name+" descending turn"],[cp(index,-1.45,12.8,-3.8),name+" down to fourth"],[cp(index,6,12.8,-3.8),name+" fourth exit"]])
		await fixture(cp(index,6,9.1,-3.8),route)
	var report: Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":3,"no_teleport_within_each_fixture":true,"build_ms":world.built_ms,"scope":"4F/5F ring slabs, public atrium flights, both service cores 3F-5F. 6F height and reduced footprint remain pending; no complete-library fidelity claim."}
	FileAccess.open("res://tests/artifacts/library_atrium_v46.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_ATRIUM ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
