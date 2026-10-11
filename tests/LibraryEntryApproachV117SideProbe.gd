extends "res://tests/LibraryEntryApproachV117.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.player.set_physics_process(false)
	# 116 occupies along approximately -5..10; only +6.8 intersects its roof here.
	var q=PhysicsRayQueryParameters3D.create(ap(6.6,6,3.4),ap(7.0,6,3.4));q.exclude=[world.player.get_rid()]
	var hit=world.get_world_3d().direct_space_state.intersect_ray(q)
	var report={"version":world.data.version,"case":"116 positive side upstand at actual footprint intersection","valid":not hit.is_empty(),"replaces":"finish negative-side probe outside116 footprint; no model edits"}
	FileAccess.open("res://tests/artifacts/library_entry_approach_v117_side_probe.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("V117_SIDE_PROBE ",JSON.stringify(report));quit(0 if report.valid else 1)
