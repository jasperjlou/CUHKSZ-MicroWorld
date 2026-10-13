extends "res://tests/CourtyardRefinementCapture.gd"
const S196:=preload("res://world/visual_campus/SouthGateContext.gd")
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	for p:Vector2 in [Vector2(-174,-167),Vector2(-135,-179),Vector2(-125,-110),Vector2(-158,-167)]:
		var ok:bool=is_zero_approx(S196.rise(p.x,p.y));checks.append({"case":"existing road/building grade retained "+str(p),"valid":ok})
		if not ok:failures.append("grade altered at "+str(p))
	var seam:float=absf(world.builder.height(-220,-167)-world.builder.backdrop_height(-220.001,-167))
	checks.append({"case":"terrain/backdrop hill seam","delta":seam,"valid":seam<.01})
	if seam>=.01:failures.append("hill seam")
	await capture("south-context-v196-gate",Vector3(-179,3.94,-167),Vector3(-265,22,-167))
	await capture("south-context-v196-teaching-a",Vector3(-133,3.94,-110),Vector3(-245,14,-133))
	await capture("south-context-v196-teaching-b",Vector3(-148,3.94,-188),Vector3(-245,17,-212))
	await capture("south-context-v196-sidewalk",Vector3(-180,3.94,-222),Vector3(-180,3.94,-152))
	await fixture(Vector3(-180,2.6,-228),[
		[Vector3(-180,2.24,-190),"outer sidewalk approach"],
		[Vector3(-180,2.24,-178),"flush pedestrian opening"],
		[Vector3(-174,2.24,-178),"opening crosses retained street"],
		[Vector3(-174,2.24,-151),"new short street northward in local frame"],
		[Vector3(-174,2.24,-193),"return to retained vehicle street"]])
	await fixture(Vector3(-180,2.6,-151),[
		[Vector3(-180,2.24,-178),"sidewalk to gate opening"],
		[Vector3(-186,2.24,-178),"boundary rail opening"],
		[Vector3(-180,2.24,-178),"boundary opening return"]])
	FileAccess.open("res://tests/artifacts/south_gate_context_v196.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"checks":checks,"captures":captures,"failures":failures,"physical_legs":legs,"fixtures":2,"trees":world.get_node("SouthGateContextV196").get_meta("forest_tree_count"),"scope":"South Gate local street/sidewalk/opening and wooded hill; dimensions fitted,not all teaching exterior"},"\t"))
	quit(0 if failures.is_empty() else 1)
