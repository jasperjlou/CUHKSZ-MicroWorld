extends "res://tests/LibraryLowerLevelCapture.gd"
const Remote:=preload("res://world/visual_campus/LibraryRemoteCore.gd")
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-remote-entry-v73",wp(-29,1.8,-8.3),wp(-37,1.8,-8.3))
	await capture("library-remote-stair-v73",wp(-35.8,1.8,-8.3),wp(-38.7,3.0,-15.5))
	await capture("library-remote-toilets-v73",wp(-31.8,1.8,-15),wp(-34,1.8,-21.8))
	await capture("library-remote-upper-v73",wp(-31,18.6,-6),wp(-34,18.2,-16))
	await capture("library-rear-core-link-v73",wp(-30,1.8,-24),wp(-33,1.8,-17))
	var route:Array=[[wp(-32.5,0,-8.3),"lower study aisle to remote core"],[wp(-35.85,0,-8.3),"remote ground doorway"]]
	for i in 4:
		var y:float=Remote.LEVELS[i];var next:float=Remote.LEVELS[i+1];var half:float=(y+next)/2
		route.append_array([[wp(-38.75,y,-8.3),str(i+1)+"F first flight foot"],[wp(-38.75,half,-16.7),str(i+1)+"F half landing"],[wp(-35.85,half,-16.7),str(i+1)+"F landing turn"],[wp(-35.85,next,-8.3),str(i+2)+"F stair arrival"],[wp(-32.5,next,-8.3),str(i+2)+"F study-wing doorway"],[wp(-35.85,next,-8.3),str(i+2)+"F core return"]])
	route.append_array([[wp(-32.5,16.8,-8.3),"5F public aisle"],[wp(-32.5,16.8,-20.7),"5F restroom front"],[wp(-32.5,16.8,-8.3),"5F restroom return"],[wp(-35.85,16.8,-8.3),"5F descent approach"]])
	for i in range(3,-1,-1):
		var y:float=Remote.LEVELS[i];var next:float=Remote.LEVELS[i+1];var half:float=(y+next)/2
		route.append_array([[wp(-35.85,half,-16.7),str(i+2)+"F descending half flight"],[wp(-38.75,half,-16.7),str(i+2)+"F descending turn"],[wp(-38.75,y,-8.3),str(i+1)+"F descending arrival"],[wp(-35.85,y,-8.3),str(i+1)+"F landing traverse"]])
	route.append_array([[wp(-32.5,0,-8.3),"ground core exit"],[wp(-32.5,0,-19),"lower restroom corridor"],[wp(-32.5,0,-22.4),"lower accessible and female frontage"],[wp(-30,.36,-22.4),"rear entrance inner ramp"],[wp(-30,.48,-27),"rear entrance porch"],[wp(-30,0,-32),"rear paved path"],[wp(-30,.48,-27),"rear porch return"],[wp(-30,0,-19),"rear interior return"],[wp(-31,0,-8),"left study aisle return"]])
	await fixture(wp(-31,.3,-8),route)
	var checks:Array=[]
	# The centre between the two flights is genuinely clear through each floor slab.
	for y:float in [4.4,8.8,12.8,16.8]:
		var q:=PhysicsRayQueryParameters3D.create(wp(-37.3,y-.5,-12.5),wp(-37.3,y+.5,-12.5));q.exclude=[world.player.get_rid()]
		var hit:Dictionary=world.get_world_3d().direct_space_state.intersect_ray(q);var valid:bool=hit.is_empty()
		checks.append({"case":"remote shaft clear at "+str(y),"valid":valid,"collider":str(hit.collider.get_path()) if not hit.is_empty() else "none"})
		if not valid:failures.append("remote shaft blocked at "+str(y))
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"checks":checks,"failures":failures,"scope":"remote1F-5F stair with public landings,toilet frontage and rear porch;fitted core location and dimensions;no restroom interiors or6F connection claimed","no_teleport_within_fixture":true}
	FileAccess.open("res://tests/artifacts/library_remote_core_v73.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_REMOTE_CORE ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
