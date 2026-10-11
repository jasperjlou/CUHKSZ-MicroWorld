extends "res://tests/LibraryRemoteV112.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await fixture(wp(-32.5,.3,-23.8),[[wp(-32.5,0,-24.325),"corrected female frontage"],[wp(-32.5,0,-22.4),"accessible frontage return"]])
	await capture("library-remote-v112-lower-final",wp(-31.1,1.7,-21.3),wp(-34.1,1.8,-23.6))
	FileAccess.open("res://tests/artifacts/library_remote_v112_facade.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"captures":captures,"failures":failures,"fixtures":1,"scope":"Only shortened female frontage at old rear-wall junction; no stair or aisle geometry changed"},"\t"))
	quit(0 if failures.is_empty() else 1)
