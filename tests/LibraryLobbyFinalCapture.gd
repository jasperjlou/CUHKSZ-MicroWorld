extends "res://tests/LibraryLobbyDetailCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("upper-blades",Vector3(82,8.3,-297),Vector3(90,8,-280))
	await fixture(Vector3(88,6.94,-290),[
		[Vector3(95.6,6.64,-290),"2F aisle beside flight"],[Vector3(95.6,6.64,-282),"approach 3F flight from its foot"],
		[Vector3(79.8,11.04,-282),"3F ascent through ceiling opening"],[Vector3(95.6,6.64,-282),"3F descent"],
		[Vector3(95.6,6.64,-290),"foot return to side aisle"],[Vector3(80,6.64,-290),"2F normal stair landing"],
		[Vector3(66,2.24,-290),"normal stair descent"]])
	var report: Dictionary={"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":1,"build_ms":world.built_ms,"no_teleport_within_each_fixture":true,"scope":"Remaining 3F connection and stair return only. Reuses nine passed legs in initial report; initial failed leg attempted to cross the rising stair mid-flight."}
	FileAccess.open("res://tests/artifacts/library_lobby_final.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("LIBRARY_LOBBY_FINAL ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
