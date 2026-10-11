extends "res://tests/TeachingRefinementCapture.gd"
## Decorative fixes and removal of duplicate columns only; retain the passed physical milestone.
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("b-lobby",Vector3(-43,4,-207),Vector3(-49,4,-207))
	await capture("c-arcade",Vector3(-46,4,-304),Vector3(-46,4,-348))
	await capture("c-entry",Vector3(-46,4,-325),Vector3(-59,4,-325))
	await capture("a-front",Vector3(-7,12,-85),Vector3(-65,13,-115))
	await capture("d-front",Vector3(-15,11,-390),Vector3(-66,11,-420))
	print("TEACHING_FINAL_VISUAL ",JSON.stringify({"captures":captures,"failures":failures,"build_ms":world.built_ms}))
	quit(0 if failures.is_empty() else 1)
