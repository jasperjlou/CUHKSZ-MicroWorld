extends "res://tests/CourtyardRefinementCapture.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var b:Node3D=world.builder.buildings.zhang_lingbin
	await capture("zhang-before-v133",b.to_global(Vector3(0,135,70)),b.to_global(Vector3(0,0,0)))
	var c:=Camera3D.new();root.add_child(c);c.projection=Camera3D.PROJECTION_ORTHOGONAL;c.size=240;c.position=Vector3(-305,1000,-130);c.look_at(Vector3(-305,0,-200))
	for p:Vector2 in [Vector2(500,440),Vector2(445,200),Vector2(720,200),Vector2(970,665),Vector2(1110,795),Vector2(445,795)]:
		var origin:=c.project_ray_origin(p);var ray:=c.project_ray_normal(p)
		print("REFERENCE_RAY ",p," atY26.59 ",origin+ray*((26.59-origin.y)/ray.y))
	quit(0)
