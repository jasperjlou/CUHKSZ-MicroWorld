extends "res://tests/ShawSkyCourtCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	await fixture(wp(-6.1,.75,23.3),[[wp(-6.1,2.7,15.4),"lower flight up"],[wp(-3.2,2.7,15.4),"half landing"],[wp(-3.2,4.95,23.3),"second flight up"],[wp(0,4.95,23.3),"2F landing turn"],[wp(0,4.95,14),"public stair approach"],[wp(0,8.85,4),"3F stair up"],[wp(10,8.85,4),"3F platform"],[wp(0,8.85,4),"3F return"],[wp(0,4.95,14),"3F stair down"],[wp(0,4.95,23.3),"2F full landing"],[wp(-3.2,4.95,23.3),"lower return approach"],[wp(-3.2,2.7,15.4),"second flight down"],[wp(-6.1,2.7,15.4),"half landing return"],[wp(-6.1,.45,23.3),"lower flight down"]])
	var report: Dictionary={"version":world.data.version,"failures":failures,"physical_legs":legs,"geometry_checks":geometry_checks,"build_ms":world.built_ms,"scope":"V52 targeted lower public stair up/down after half-landing waypoints clear rail ends. No geometry changes after guard fix. Prior L-court and six guard checks retained; ground-to7F access unbuilt."}
	FileAccess.open("res://tests/artifacts/shaw_sky_stair_finish_v52.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("SHAW_SKY_STAIR_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
