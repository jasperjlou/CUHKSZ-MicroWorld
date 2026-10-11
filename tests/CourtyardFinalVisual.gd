extends "res://tests/CourtyardRefinementCapture.gd"
## Final roof patch is visual-only; do not repeat the already passed physical routes.
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-roof",Vector3(-5,63,-227),Vector3(81,13,-290))
	await capture("district-courtyard",Vector3(-25,38,-308),Vector3(40,5,-359))
	print("COURTYARD_FINAL_VISUAL ",JSON.stringify({"captures":captures,"failures":failures,"build_ms":world.built_ms}))
	quit(0 if failures.is_empty() else 1)
