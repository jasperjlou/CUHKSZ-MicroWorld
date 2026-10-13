extends "res://tests/ResearchSiteV172.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	rt=world.builder.buildings["research"].global_transform
	await fixture(rp(25,.3,75),[[rp(43,0,69),"join ramp foot"],[Vector3(44,2.38,-894),"new ramp meets retained asphalt"],[Vector3(44.25,2.38,-889),"continue beyond old street mouth"],[Vector3(44,2.38,-894),"return to new road mouth"],[rp(43,0,69),"descend joint ramp"],[rp(25,0,75),"return along fitted perimeter"]])
	await capture("research-perimeter-v205-join-final",Vector3(46,4,-905),Vector3(44,2.5,-886))
	await capture("research-perimeter-v205-front-final",rp(-33,7,87),rp(-2,6,44))
	FileAccess.open("res://tests/artifacts/research_perimeter_v205_finish.json",FileAccess.WRITE).store_string(JSON.stringify({"version":world.data.version,"physical_legs":legs,"captures":captures,"failures":failures,"scope":"Only the corrected asphalt height joint and6legs; retain unaffected initial perimeter/sidewalk evidence separately."},"\t"))
	print("RESEARCH_PERIMETER_FINISH_V205 ",JSON.stringify({"legs":legs.size(),"failures":failures}));quit(0 if failures.is_empty() else 1)
