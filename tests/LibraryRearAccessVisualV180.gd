extends "res://tests/LibraryRearAccessV180.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await capture("library-rear-v180-final-overall",wp(-53,13,-60),wp(-21,5,-30))
	await capture("library-rear-v180-final-porch",dp(-8,3.2,-10),dp(3,1.5,-1))
	await capture("library-rear-v180-final-ramp",dp(13.5,1.5,-5.4),dp(3,1.2,-1.8))
	FileAccess.open("res://tests/artifacts/library_rear_access_visual_v180.json",FileAccess.WRITE).store_string(JSON.stringify({"captures":captures,"scope":"Only darker narrow-window pane/frame/sill materials after physical pass; collision unchanged."},"\t"))
	print("LIBRARY_REAR_V180_VISUAL_DONE");quit()
