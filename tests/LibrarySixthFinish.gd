extends "res://tests/LibraryLowerLevelCapture.gd"
const Core := preload("res://world/visual_campus/LibraryServiceCores.gd")
func cp(x: float,y: float,z: float) -> Vector3:
	var p:=Core.local_point(1,Vector3(x,y,z));return wp(p.x,p.y,p.z)
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-rare-envelope-final-v47",wp(-20.5,18.5,21.2),wp(-27,18,26))
	await capture("library-section-front-final-v47",wp(-8,38,72),wp(0,14,5))
	await capture("library-sixth-gallery-final-v47",wp(-12,22.5,-5),wp(16,22.5,3))
	await capture("library-third-rear-glazing-v47",wp(10,10.5,-4),wp(-10,10.5,-13))
	await capture("library-silence-final-v47",wp(24,18.5,-9),wp(26,18.2,-18))
	await fixture(wp(14.5,21.1,-9),[
		[wp(14.5,20.8,13.2),"sixth wing aisle before column"],
		[wp(5,20.8,13.2),"sixth gallery crosses behind column"],
		[cp(6,20.8,-3.8),"sixth diagonal approach"],
		[cp(1.45,20.8,-3.8),"sixth core doorway"],
		[cp(1.45,18.8,3.8),"sixth core descending flight"],
		[cp(-1.45,18.8,3.8),"sixth descending turn"],
		[cp(-1.45,16.8,-3.8),"sixth down to fifth"],
		[cp(6,16.8,-3.8),"fifth core exit"]])
	await fixture(cp(6,21.1,-3.8),[[wp(5,20.8,13.2),"sixth core front return"],[wp(14.5,20.8,13.2),"sixth bridge behind column return"],[wp(14.5,20.8,-9),"sixth wing reverse aisle"]])
	await fixture(wp(-18,.3,34),[[wp(-18,0,20),"sealed facade lower doorway"],[wp(-18,0,-8),"sealed facade lower hall"],[wp(-18,0,34),"sealed facade lower exit"]])
	await fixture(wp(5,.3,31),[[wp(17,4.4,18),"sealed facade external stair"],[wp(18,4.4,10),"sealed facade main 2F portal"],[wp(17,4.4,18),"sealed facade 2F return"],[wp(5,0,30),"sealed facade external descent"]])
	await fixture(wp(-10,9.1,-8),[[wp(-10,8.8,-16),"third rear glazing terrace doorway"],[wp(-10,8.8,-8),"third terrace return"]])
	var guards: Array=[]
	for pair: Array in [[wp(14.5,21.45,4),wp(11.5,21.45,4)],[wp(-16+1,21.45,18),wp(-16-1,21.45,18)],[wp(30,21.45,-18.8),wp(30,21.45,-21.2)]]:
		var hit:=not world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(pair[0],pair[1])).is_empty();guards.append(hit)
		if not hit:failures.append("sixth reduced-floor guard")
	var report: Dictionary={"version":world.data.version,"captures":captures,"failures":failures,"physical_legs":legs,"guard_samples":guards,"build_ms":world.built_ms,"scope":"Corrected 6F route goes behind the retained round column; final sealed facade and3F rear glazing interfaces. Earlier unaffected sixth ascent/rooms/core ascent/rare-book legs remain valid."}
	FileAccess.open("res://tests/artifacts/library_sixth_finish_v47.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_SIXTH_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
