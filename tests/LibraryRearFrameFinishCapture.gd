extends "res://tests/LibraryRearRoadCapture.gd"
const Bank := preload("res://world/visual_campus/RearRoadBank.gd")
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-rear-frame",Vector3(143,15,-337),Vector3(101,14,-313))
	await capture("library-rear-door",Vector3(115,5.0,-326),Vector3(102,4.3,-318))
	await capture("library-rear-bank-position",Vector3(176,65,-354),Vector3(109,9,-290))
	var toe:=Bank.toe(Bank.STAIR_Z,world.builder.rear_route);var y:=Bank.road_height(Bank.STAIR_Z)
	await capture("library-rear-bank-stair",Vector3(toe-7,y+2,Bank.STAIR_Z),Vector3(toe+5,y+2.7,Bank.STAIR_Z))
	await fixture(Vector3(112,2.54,-320),[
		[Vector3(109.2,2.24,-320),"rear step foot"],[Vector3(105.8,2.72,-320),"rear step platform"],
		[Vector3(102.4,2.72,-320),"rear door threshold"],[Vector3(98,2.24,-320),"rear door interior descent"],
		[Vector3(102.4,2.72,-320),"rear door interior return"],[Vector3(105.4,2.72,-320),"rear porch return"],
		[Vector3(105.4,2.72,-316.5),"rear porch side ramp head"],[Vector3(105.4,2.24,-307.5),"rear side ramp descent"],
		[Vector3(105.4,2.72,-316.5),"rear side ramp ascent"],[Vector3(105.4,2.72,-320),"rear porch stair return"],
		[Vector3(112,2.24,-320),"rear steps descent"],[site(121,-322),"rear spur ground transition"],
		[site(132,-322),"rear spur to avenue"]])
	await fixture(site(132,-330)+Vector3.UP*.3,[
		[site(137,Bank.STAIR_Z),"library road to relocated bank"],[site(toe-.3,Bank.STAIR_Z),"relocated stair foot"],
		[Vector3(toe+Bank.RUN+1,y+Bank.RISE+.025,Bank.STAIR_Z),"relocated bank top landing"],
		[site(toe-.3,Bank.STAIR_Z),"relocated bank descent"],[site(137,Bank.STAIR_Z),"relocated bank road return"],
		[site(132,-322),"local bank road return"]])
	var report:={"captures":captures,"failures":failures,"physical_legs":legs,"build_ms":world.built_ms,"scope":"library rear frame and lower entrance, relocated library bank; photo identity corrected, metric registration remains fitted"}
	FileAccess.open("res://tests/artifacts/library_rear_frame_finish.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_REAR_FRAME ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
