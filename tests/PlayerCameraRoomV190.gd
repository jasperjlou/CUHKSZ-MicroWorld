extends "res://tests/PlayerCameraV190.gd"
func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(15)
	product.start_player();await frames(10)
	var p:CharacterBody3D=product.world.player
	p.position=lib(Vector3(-28.13,.12,1.5));p.velocity=Vector3.ZERO;p.orbit_yaw=-PI/2
	await frames(30);await shot("room-close-finish")
	check("close camera hides obstructing avatar",not p.model.visible)
	p.position=Vector3(0,.3,18);p.velocity=Vector3.ZERO;p.orbit_yaw=0
	await frames(30)
	check("open space restores avatar",p.model.visible)
	FileAccess.open("res://tests/artifacts/player_camera_room_v190.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":errors,"captures":captures,"scope":"Avatar visibility only after changing hide threshold; prior collision routes unchanged."},"\t"))
	print("PLAYER_CAMERA_ROOM_V190_DONE ",errors);quit(0 if errors.is_empty() else 1)
