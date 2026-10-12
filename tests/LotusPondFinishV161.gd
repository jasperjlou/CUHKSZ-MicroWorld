extends "res://tests/LotusPondEdgesV161.gd"
func run()->void:
	world=load("res://world/visual_campus/VisualCampus.tscn").instantiate();root.add_child(world);await frames(15)
	world.ui.hide();world.player.hide();world.player.set_physics_process(false);world.overview.current=true
	var checks:Array=[]
	probe(Vector3(118.5,3.17,-340),Vector3(119.5,3.17,-340),false,"round opening after corner mesh fix",checks)
	await capture("pond-v161-moon-final",Vector3(115,3.2,-339),Vector3(119,3.17,-340))
	await capture("pond-v161-mall-final",Vector3(60.5,4,-341),Vector3(64.4,2.8,-359))
	FileAccess.open("res://tests/artifacts/lotus_pond_finish_v161.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"captures":captures,"failures":failures,"physical_legs":0,"scope":"Fill four small round-panel corner mesh gaps and correct visible colonnade stone/white finish; unchanged perimeter walking reused."},"\t"))
	print("LOTUS_POND_FINISH_V161 ",JSON.stringify(checks));quit(0 if failures.is_empty() else 1)
