extends "res://tests/ProductExperienceV185.gd"
func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(15);product.start_showcase()
	var d:Node=product.director;d.begin_chapter(5)
	while d.phase!="intro":await physics_frame
	await frames(65);d.set_physics_process(false);product.world.player.set_physics_process(false)
	await shot("study-closeout-intro")
	product.world.player.position=d.chapters[5].route[3]+Vector3.UP*.1;d.leg=4;d.phase="walk";d.camera_snap=true;await frames(12)
	await shot("study-closeout-room")
	FileAccess.open("res://tests/artifacts/study_camera_finish_v185.json",FileAccess.WRITE).store_string(JSON.stringify({"captures":captures,"scope":"Two camera fixtures replacing obstructed study views;physical path unchanged"},"\t"))
	print("STUDY_CAMERA_V185_DONE");quit()
