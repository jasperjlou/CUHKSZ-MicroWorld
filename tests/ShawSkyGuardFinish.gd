extends "res://tests/ShawSkyCourtCapture.gd"
func run() -> void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	for pair: Array in [
		["rear",wp(1.66,22.65,-17),wp(1.66,22.65,-14)],
		["side",wp(-32,22.65,-3.05),wp(-35,22.65,-3.05)],
		["L corner",wp(32,22.65,25.5),wp(35,22.65,25.5)]]:
		check(pair[0]+" guard outward",pair[1],pair[2],true)
		check(pair[0]+" guard inward",pair[2],pair[1],true)
	await fixture(wp(24,22.35,18.5),[[wp(29,22.05,18.5),"L terrace door"],[wp(31.5,22.05,18.5),"L terrace north"],[wp(31.5,22.05,23),"L corner continuous join"],[wp(31.5,22.05,27),"L front terrace"],[wp(31.5,22.05,18.5),"L corner return"],[wp(24,22.05,18.5),"L door return"]])
	await fixture(wp(-6.1,.75,23.3),[[wp(-6.1,2.7,16),"lower flight up"],[wp(-3.2,2.7,16),"half landing"],[wp(-3.2,4.95,23.3),"second flight up"],[wp(0,4.95,23.3),"2F landing turn"],[wp(0,4.95,14),"public stair approach"],[wp(0,8.85,4),"3F stair up"],[wp(10,8.85,4),"3F platform"],[wp(0,8.85,4),"3F return"],[wp(0,4.95,14),"3F stair down"],[wp(0,4.95,23.3),"2F full landing"],[wp(-3.2,4.95,23.3),"lower return approach"],[wp(-3.2,2.7,16),"second flight down"],[wp(-6.1,2.7,16),"half landing return"],[wp(-6.1,.45,23.3),"lower flight down"]])
	var report: Dictionary={"version":world.data.version,"failures":failures,"physical_legs":legs,"geometry_checks":geometry_checks,"build_ms":world.built_ms,"scope":"V52 guard collision repair: both directions and affected public stairs/L court only. Original void/floor checks retained; ground-to7F access still unbuilt."}
	FileAccess.open("res://tests/artifacts/shaw_sky_guard_finish_v52.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("SHAW_SKY_GUARD_FINISH ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
