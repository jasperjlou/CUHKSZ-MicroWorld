extends "res://tests/OldLibraryStudyV168.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("old-library-v168-study-final",ap(21,4.5,10.1),ap(21,-1,9.6))
	await capture("old-library-v168-desk-final",ap(19.1,2.6,10.0),ap(17.4,.6,9.2))
	await capture("old-library-v168-ceiling-final",ap(24,-4.5,10.0),ap(17,1,11.5))
	FileAccess.open("res://tests/artifacts/old_library_study_v168_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"captures":captures,"failures":failures,"scope":"Visual-only laminate/mesh scale and end-fixture shortening;17physical legs retained."},"\t"))
	quit(0 if failures.is_empty() else 1)
