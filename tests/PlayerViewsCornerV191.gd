extends "res://tests/PlayerViewsV191.gd"
func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(15)
	product.start_player();await frames(10)
	var b:Node3D=product.world.builder.buildings.zhang_lingbin
	var route:Array=[]
	for p:Vector3 in [Vector3(-21.5,.125,-26.6),Vector3(-21.5,.125,-20),Vector3(-24.4,.125,-20),Vector3(-24.4,.125,12)]:route.append(b.to_global(p))
	await fixture(route[0],route.slice(1),"third-zhang-corner")
	product.world.player.first_person=true;route.reverse()
	await fixture(route[0],route.slice(1),"first-zhang-corner")
	check("corner camera volumes clear",overlap_frames==0)
	check("corner body to eye clear",blocked_frames==0)
	await key(KEY_ESCAPE);product.start_player();await frames(10);await shot("compact-hud-final")
	FileAccess.open("res://tests/artifacts/player_views_corner_v191.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":errors,"physical_legs":legs,"camera_samples":samples,"overlap_frames":overlap_frames,"blocked_frames":blocked_frames,"bad_samples":bad_samples,"captures":captures,"scope":"Replaces diagonal upper corridor turn with orthogonal waypoint;two local fixtures,unchanged stairs retained from previous report."},"\t"))
	print("PLAYER_VIEWS_CORNER_V191_DONE ",errors);quit(0 if errors.is_empty() else 1)
