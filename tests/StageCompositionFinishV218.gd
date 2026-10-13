extends "res://tests/StageCameraV218.gd"
func run()->void:
	product=load("res://world/product/CampusProduct.tscn").instantiate();root.add_child(product);await frames(25)
	product.start_showcase();await frames(5)
	var d:Node=product.director;var p:CharacterBody3D=product.world.player;d.set_physics_process(false);d.fade.color.a=0
	for id:String in ["library-grey-stair","library-rear-shaw"]:
		for i in d.chapters.size():
			var c:Dictionary=d.chapters[i]
			if c.id!=id:continue
			d.index=i;d.leg=1;d.phase="intro";d.title.text=c.title;d.detail.text=c.detail
			if id=="library-grey-stair":d.camera.position=c.eye_end;d.camera.look_at(c.look)
			else:
				d.leg=c.route.size()-1;d.phase="outro";d.camera_snap=true;p.position=c.route[-1]+Vector3.UP*.12;p.velocity=Vector3.ZERO;p.navigation_direction=Vector2.ZERO;p.set_physics_process(true)
			await frames(25);await shot("finish-"+id)
	print("V218_COMPOSITION_FINISH captures=",captures.size());quit()
