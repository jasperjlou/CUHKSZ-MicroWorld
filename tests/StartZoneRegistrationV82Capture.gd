extends "res://tests/CourtyardRefinementCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("start-registration-v82",Vector3(-202,112,-800),Vector3(-65,5,-735))
	await capture("daoyuan-perimeter-v82",Vector3(-176,7,-749),Vector3(-122,14,-733))
	await capture("zhixin-clock-junction-v82",Vector3(-17,7,-807),Vector3(-95,5,-783))
	await capture("lower-courts-v82",Vector3(-146,26,-678),Vector3(-111,3,-647))
	await capture("court-ground-v82",Vector3(-121,4,-661),Vector3(-105,4,-635))
	await fixture(Vector3(-8.1,2.54,-775),[
		[Vector3(-8.1,2.24,-790),"Main Square to corrected clock-end junction"],
		[Vector3(-71,2.24,-790),"transverse lane along Zhixin end"],
		[Vector3(-71,2.24,-770),"rear service aisle junction"],
		[Vector3(-71,2.24,-700),"between Zhixin and relocated DaoYuan"],
		[Vector3(-76,2.24,-682),"Shaw-end street join"],
		[Vector3(-114,2.24,-675.9),"court footway approach"],
		[Vector3(-114,2.24,-650),"court entrance through fence opening"],
		[Vector3(-124,2.24,-650),"first court centre"],
		[Vector3(-124,2.24,-637),"first court playing area"],
		[Vector3(-104,2.24,-637),"cross to second court"],
		[Vector3(-104,2.24,-658),"second court playing area"],
		[Vector3(-114,2.24,-658),"central court aisle"],
		[Vector3(-114,2.24,-623),"far gate exit"],
		[Vector3(-89,2.24,-623),"parking-side perimeter footway"],
		[Vector3(-89,2.24,-648),"side gate approach"],
		[Vector3(-100,2.24,-648),"side gate entry"],
		[Vector3(-89,2.24,-648),"side gate exit"],
		[Vector3(-89,2.24,-675.9),"parking-side footway return"],
		[Vector3(-162.5,2.24,-675.9),"branch footway to perimeter"],
		[Vector3(-162.5,2.24,-711),"perimeter to DaoYuan stair"],
		[Vector3(-137,4.64,-711),"relocated DaoYuan first stair ascent"],
		[Vector3(-136,4.64,-733),"raised brick forecourt"],
		[Vector3(-130,5.12,-733),"short entry stair"],
		[Vector3(-124,5.12,-733),"relocated DaoYuan vestibule"],
		[Vector3(-136,4.64,-733),"entry return"],
		[Vector3(-136,4.64,-755),"second upper landing"],
		[Vector3(-162.5,2.24,-755),"second stair descent"],
		[Vector3(-162.5,2.24,-782.8),"Old Gate approach"],
		[Vector3(-184,2.24,-782.8),"Old Gate outward pedestrian crossing"],
		[Vector3(-162.5,2.24,-782.8),"Old Gate inward return"],
		[Vector3(-150,2.24,-790),"return to corrected transverse street"],
		[Vector3(-8.1,2.24,-790),"clock-end street return"],
		[Vector3(-8.1,2.24,-775),"Main Square return"]])
	var report:Dictionary={"version":world.data.version,"captures":captures,"physical_legs":legs,"failures":failures,"scope":"V82 corrected DaoYuan and OldGate registration,two outdoor courts and affected links;metric scale and full-campus fidelity remain partial"}
	FileAccess.open("res://tests/artifacts/start_zone_registration_v82.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("START_REGISTRATION ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
