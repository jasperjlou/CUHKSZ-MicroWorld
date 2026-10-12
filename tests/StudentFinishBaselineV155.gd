extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
	var world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world)
	for i in 3:await physics_frame
	var result=preload("res://tests/StudentCollisionSignature.gd").capture(world)
	result["version"]=world.data.version
	FileAccess.open("res://tests/artifacts/student_finish_v155_collision_before.json",FileAccess.WRITE).store_string(JSON.stringify(result,"\t"))
	print("STUDENT_COLLISION_BEFORE ",JSON.stringify(result));quit()
