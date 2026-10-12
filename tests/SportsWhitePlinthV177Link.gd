extends "res://tests/SportsWhitePlinthV177.gd"
func run()->void:
	root.disable_3d=true
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	probe(sp177(-67,-1,-29),sp177(-67,-1,-24),true,"front plinth return below approach slab",checks)
	await fixture(sp177(-50,.4,22),[[sp177(-47,.1,22),"bypass forecourt bench"],[sp177(-47,.1,18),"join actual interhall gap"],[sp177(-20,.1,18),"continue clear of Hall wall"],[sp177(10,.1,18),"reach undercroft route"]])
	root.disable_3d=false;await frames(15)
	await capture("sports-v177-complete-overall",sp177(-97,12,-47),sp177(-48,4.5,0))
	FileAccess.open("res://tests/artifacts/sports_white_plinth_v177_link.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"checks":checks,"captures":captures,"failures":failures,"fixtures":1,"scope":"Continue from prior last valid forecourt stop, around fixed bench and Hall wall into existing undercroft route. Plinth end returns support the approach slabs; unchanged terrace/lower routes retained."},"\t"))
	print("SPORTS_WHITE_V177_LINK ",JSON.stringify({"legs":legs.size(),"checks":checks.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
