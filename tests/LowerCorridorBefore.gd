extends "res://tests/LowerCampusScopeReview.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("corridor-before-garden",Vector3(30,4,-426),Vector3(39,4,-494))
	await capture("corridor-before-shaw",Vector3(34,5,-495),Vector3(66,7,-559))
	await capture("corridor-before-between",Vector3(110,6,-585),Vector3(116,7,-662))
	await capture("corridor-before-research",Vector3(112,5,-753),Vector3(82,8,-855))
	await capture("corridor-before-sports",Vector3(62,4,-843),Vector3(0,6,-853))
	await capture("corridor-before-overall",Vector3(-104,150,-453),Vector3(63,0,-688))
	print("CORRIDOR_BEFORE ",captures);quit()
