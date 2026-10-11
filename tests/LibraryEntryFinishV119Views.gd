extends "res://tests/LibraryEntryApproachV117.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-entry-v119-final-carpet",wp(-20.4,1.8,3.6),wp(-20.4,.8,-12))
	await capture("library-entry-v119-final-lower",wp(-10,1.8,-6),wp(5,1.3,-10))
	var report={"version":world.data.version,"captures":captures,"scope":"carpet shader contrast/frequency adjustment only;physical geometry unchanged after13 valid legs"}
	FileAccess.open("res://tests/artifacts/library_entry_v119_views.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	quit()
